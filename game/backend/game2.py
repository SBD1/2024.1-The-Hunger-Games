import psycopg2
from psycopg2 import sql, errors
from colorama import Fore, init
import curses
import sys
import os
import time
import threading
# from capital import mostrarSimbolo

# Inicializar Colorama
init(autoreset=True)

# Dados de conexão com o PostgreSQL
conn = psycopg2.connect(
    dbname="hunger_games",
    user="postgres",
    password="20082003",
    host="localhost",
    port="5433"
)

# Criar um cursor
cur = conn.cursor()

def display_stats_curses(stdscr, stats):
    # Inicializa cores e configura o display de estatísticas
    curses.curs_set(0)
    height, width = stdscr.getmaxyx()

    # Calcula a posição inicial da janela no canto inferior direito
    altura_max = len(stats) + 4  # Adiciona espaço para bordas
    largura_max = max(len(stat) for stat in stats) + 4  # Adiciona espaço para bordas
    pos_y = max(0, height - altura_max)
    pos_x = max(0, width - largura_max)

    # Cria a janela para exibição das estatísticas
    stat_win = curses.newwin(altura_max, largura_max, pos_y, pos_x)

    while True:
        stat_win.clear()
        stat_win.border()
        for idx, stat in enumerate(stats):
            stat_win.addstr(idx + 1, 2, stat)
        stat_win.refresh()
        time.sleep(1)

def iniciar_display_curses(stats):
    curses.wrapper(display_stats_curses, stats)

# Função para iniciar o display de estatísticas em paralelo
def iniciar_display(stats):
    display_thread = threading.Thread(target=iniciar_display_curses, args=(stats,))
    display_thread.daemon = True
    display_thread.start()
    return display_thread  # Retorne a thread para controle


# Funções do jogo
# Funções do jogo
class Game:

    @staticmethod
    def fetch_stats_from_db(personagemId):
        try:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT popularidade, agilidade, forca, nado, carisma, combate, 
                        perspicacia, furtividade, sobrevivencia, precisao 
                    FROM distrito 
                    WHERE idPersonagem = %s
                """, (personagemId,))
                stats = cur.fetchone()
                if stats:
                    return [f"Popularidade: {stats[0]}",
                            f"Agilidade: {stats[1]}",
                            f"Forca: {stats[2]}",
                            f"Nado: {stats[3]}",
                            f"Carisma: {stats[4]}",
                            f"Combate: {stats[5]}",
                            f"Perspicácia: {stats[6]}",
                            f"Furtividade: {stats[7]}",
                            f"Sobrevivência: {stats[8]}",
                            f"Precisão: {stats[9]}"]
                return ["Sem estatísticas"]
        except Exception as e:
            print(f"Erro ao buscar estatísticas: {e}")
            return ["Erro ao carregar estatísticas"]

    def __init__(self, personagemId):
        self.personagemId = personagemId
        self.personagem = self._obter_personagem()

        # Verificar se o personagem foi encontrado antes de prosseguir
        if not self.personagem:
            raise ValueError("Personagem não encontrado!")

        # Após garantir que o personagem existe, busque as estatísticas
        self.stats = Game.fetch_stats_from_db(self.personagemId)

        # Iniciar o display com as estatísticas
        iniciar_display(self.stats)

    def _obter_personagem(self):
        cur.execute("SELECT idSala FROM personagem WHERE idPersonagem = %s", (self.personagemId,))
        resultado = cur.fetchone()
        if resultado:
            return {'idSala': resultado[0]}
        return None

    def mostrar_localizacao_atual(self, stdscr):
        cur.execute("SELECT nomeS, descricao FROM sala WHERE idSala = %s", (self.personagem['idSala'],))
        sala_atual = cur.fetchone()
        if sala_atual:
            stdscr.addstr(f"\nVocê está atualmente em: {sala_atual[0]} - {sala_atual[1]}\n", curses.color_pair(1))
        else:
            stdscr.addstr("Personagem não está em nenhuma sala.\n")

    def mover_para_sala(self, nova_sala_id, stdscr):
        cur.execute("SELECT nomeS, descricao FROM sala WHERE idSala = %s", (nova_sala_id,))
        nova_sala = cur.fetchone()
        if nova_sala:
            cur.execute("UPDATE personagem SET idSala = %s WHERE idPersonagem = %s", (nova_sala_id, self.personagemId))
            conn.commit()
            self.personagem['idSala'] = nova_sala_id
            stdscr.addstr(f"\nVocê se moveu para: {nova_sala[0]} - {nova_sala[1]}\n", curses.color_pair(2))
        else:
            stdscr.addstr("Sala não encontrada.\n")

    def listar_salas_disponiveis(self, stdscr):
        cur.execute("SELECT idSala, nomeS, descricao FROM sala")
        salas_disponiveis = cur.fetchall()
        if salas_disponiveis:
            stdscr.addstr("\nSalas disponíveis para se mover:\n")
            for sala in salas_disponiveis:
                stdscr.addstr(f"{sala[0]}: {sala[1]} - {sala[2]}\n")
        else:
            stdscr.addstr("Nenhuma sala disponível.\n")

def mostrar_personagens_tabela(stdscr, personagens, selected_idx):
    stdscr.clear()
    height, width = stdscr.getmaxyx()
    start_x = 5
    start_y = 5

    # Verifica se a posição inicial está dentro dos limites
    if start_y >= height or start_x >= width:
        stdscr.addstr(0, 0, "Erro: Posição de início fora dos limites da tela.", curses.A_BOLD)
        stdscr.refresh()
        return

    # Título centralizado
    stdscr.addstr(2, max((width // 2) - 10, 0), "Escolha seu Personagem", curses.A_BOLD)

    # Cabeçalhos para os atributos dos personagens
    headers = ["Atributos", "Dominic", "Gabrielle", "Leslie", "Icaro"]

    col_width = max((width - start_x) // len(headers), 12)

    # Exibe os cabeçalhos
    for idx, header in enumerate(headers):
        try:
            stdscr.addstr(start_y, start_x + idx * col_width, header, curses.A_BOLD)
        except curses.error:
            break

    # Atributos e valores correspondentes para cada personagem
    atributos = [
        ("Popularidade", [6, 3, 4, 4]),
        ("Agilidade", [4, 4, 6, 8]),
        ("Força", [5, 4, 4, 4]),
        ("Nado", [4, 5, 6, 9]),
        ("Carisma", [4, 4, 8, 5]),
        ("Combate", [8, 4, 4, 5]),
        ("Perspicácia", [5, 10, 5, 3]),
        ("Furtividade", [3, 8, 5, 4]),
        ("Sobrevivência", [4, 6, 8, 5]),
        ("Precisão", [7, 4, 5, 6])
    ]

    # Exibe os atributos e seus valores para cada personagem
    for i, (atributo, valores) in enumerate(atributos):
        linha_y = start_y + i + 2
        stdscr.addstr(linha_y, start_x, atributo, curses.A_BOLD)
        
        for j, valor in enumerate(valores):
            try:
                if j == selected_idx:  # Se o personagem está selecionado
                    stdscr.attron(curses.A_REVERSE)
                stdscr.addstr(linha_y, start_x + (j + 1) * col_width, str(valor))
                stdscr.attroff(curses.A_REVERSE)
            except curses.error:
                break

    # Espaço em branco para separar a tabela da descrição
    stdscr.addstr(linha_y + 2, start_x, "-" * (width - start_x))

    # Exibe as descrições dos personagens abaixo da tabela
    descricao_y = linha_y + 4
    descricoes = [
        "Dominic é o tributo masculino do Distrito 1, um Carreirista conhecido por sua habilidade em combate e precisão.",
        "Gabrielle é a tributo feminina do Distrito 3, famosa por sua inteligência e furtividade.",
        "Leslie é a tributo feminina do Distrito 12, destacada pelo seu carisma e conhecimento da natureza.",
        "Icaro é o tributo masculino do Distrito 4, com habilidades impressionantes de nado e agilidade."
    ]

    if selected_idx < len(descricoes):
        descricao = descricoes[selected_idx]
        try:
            stdscr.addstr(descricao_y, start_x, "Descrição: ", curses.A_BOLD)
            stdscr.addstr(descricao_y + 1, start_x, descricao[:width - start_x])
        except curses.error:
            pass

    stdscr.refresh()


def escolher_personagem_com_interface(stdscr, personagens):
    curses.curs_set(0)
    selected_idx = 0
    
    while True:
        mostrar_personagens_tabela(stdscr, personagens, selected_idx)
        key = stdscr.getch()

        if key == curses.KEY_LEFT and selected_idx > 0:
            selected_idx -= 1
        elif key == curses.KEY_RIGHT and selected_idx < len(personagens) - 1:
            selected_idx += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            return personagens[selected_idx][1]
        elif key == ord('q') or key == ord('Q'):
            break


def mostrar_personagens_opcoes_curses():
 
    cur.execute(
        """
        SELECT d.idDistrito, d.idPersonagem, d.popularidade, d.agilidade, d.forca, d.nado,
               d.carisma, d.combate, d.perspicacia, d.furtividade, d.sobrevivencia, d.precisao, d.descricao,
               p.nomeP 
        FROM distrito d
        JOIN personagem p ON d.idPersonagem = p.idPersonagem
        WHERE d.idPersonagem IN (1, 7, 24, 6)
        """
    )
    personagens = cur.fetchall()
    idPersonagem = curses.wrapper(escolher_personagem_com_interface, personagens)
    return idPersonagem


def escolher_personagem(usuario_id):
    try:
        idPersonagem = mostrar_personagens_opcoes_curses()
        if idPersonagem:
            cur.execute(
                "UPDATE personagem SET tipoP = 'pj' WHERE idPersonagem = %s",
                (idPersonagem,)
            )
            cur.execute(
                "UPDATE usuario SET idPersonagem = %s WHERE id = %s",
                (idPersonagem, usuario_id)
            )
            conn.commit()
            print("\nPersonagem escolhido com sucesso!")
        else:
            print("\nNenhum personagem foi selecionado.")
    except Exception as e:
        conn.rollback()
        print("\nErro ao selecionar o personagem:", str(e))

        

def criar_conta():
    while True:
        nome = input("\nDigite o nome de usuário: ")
        senha = input("Digite a senha: ")

        try:
            cur.execute(
                sql.SQL("INSERT INTO usuario (nome, senha) VALUES (%s, %s) RETURNING id"),
                (nome, senha)
            )
            usuario_id = cur.fetchone()[0]
            conn.commit()
            print("\nUsuário criado com sucesso!")
            escolher_personagem(usuario_id)  # Selecionar o personagem
            iniciar_jogo(usuario_id)  # Entrar diretamente no jogo com o novo usuário logado
            break
        
        except errors.UniqueViolation as e:
            conn.rollback() 
            print(f"\nErro: O nome de usuário '{nome}' já existe no sistema. Escolha outro nome.")
        
        except errors.RaiseException as e:
            conn.rollback() 
            print("\nErro ao criar o usuário:", str(e))


def login():
    while True:
        nome = input("\nDigite o nome de usuário: ")
        senha = input("Digite a senha: ")

        try:
            cur.execute(
                sql.SQL("SELECT id FROM usuario WHERE nome = %s AND senha = %s"),
                (nome, senha)
            )
            usuario = cur.fetchone()

            if usuario:
                usuario_id = usuario[0]
                print("\nLogin bem-sucedido!")
                iniciar_jogo(usuario_id)
            else:
                print("\nNome de usuário ou senha incorretos. Tente novamente.")
        except Exception as e:
            print("\nErro ao tentar fazer login:", str(e))

def limpar_tela():
    # Verifica o sistema operacional e executa o comando apropriado
    if os.name == 'nt':  # Windows
        os.system('cls')
    else:  # Linux/macOS
        os.system('clear')


def processar_opcao(usuario_id, opcao_id):
    try:
        # Passo 1: Obter o id do personagem e o id do capítulo atual
        cur.execute(
            "SELECT idpersonagem, idcapitulo FROM usuario WHERE id = %s",
            (usuario_id,)
        )
        result = cur.fetchone()
        if result is None:
            print("Usuário não encontrado.")
            return

        personagem_id = result[0]
        capitulo_atual = result[1]

        # Passo 2: Obter a opção escolhida
        cur.execute(
            "SELECT efeito_atributo, proximo_capitulo, atributo FROM opcao WHERE idopcao = %s",
            (opcao_id,)
        )
        opcao = cur.fetchone()
        if opcao is None:
            print("Opção não encontrada.")
            return

        efeito_atributo, proximo_capitulo, atributo = opcao

        # Passo 3: Verificar o atributo e realizar a movimentação
        if atributo == 'idsala':
            # Obter o id da sala associado à opção escolhida
            cur.execute(
                "SELECT efeito_atributo FROM opcao WHERE idopcao = %s",
                (opcao_id,)
            )
            sala_id = cur.fetchone()[0]

            # Inserir a nova localização na tabela 'localizacao'
            cur.execute(
                "INSERT INTO localizacao (idcapitulo, idpersonagem, idsala, idusuario) VALUES (%s, %s, %s, %s)",
                (proximo_capitulo, personagem_id, sala_id, usuario_id)
            )

            # Atualizar o idcapitulo do usuário na tabela 'usuario'
            cur.execute(
                "UPDATE usuario SET idcapitulo = %s WHERE id = %s",
                (proximo_capitulo, usuario_id)
            )

            conn.commit()  # Commit para salvar as mudanças

            print(f"Movimento registrado: Capítulo {proximo_capitulo}, Sala {sala_id}, Usuário {usuario_id}")

        # Outras ações baseadas na opção podem ser adicionadas aqui

    except Exception as e:
        print(f"Erro ao processar a opção: {e}")



def exibir_menu_jogo(stdscr, jogo):
    curses.curs_set(0)
    current_row = 0
    opcoes = ["Mostrar localização atual", "Listar todas as salas disponíveis", "Mover para uma sala", "Sair"]

    while True:
        stdscr.clear()
        
        # Exibe o menu do jogo com as opções
        for idx, opcao in enumerate(opcoes):
            x = 5
            y = 5 + idx
            if idx == current_row:
                stdscr.addstr(y, x, f"> {opcao}", curses.A_REVERSE)
            else:
                stdscr.addstr(y, x, opcao)
        
        stdscr.refresh()

        # Captura a tecla pressionada pelo usuário
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(opcoes) - 1:
            current_row += 1
        elif key in [curses.KEY_ENTER, 10, 13]:
            if current_row == 0:
                stdscr.clear()
                jogo.mostrar_localizacao_atual()
                stdscr.addstr(0, 0, "Pressione qualquer tecla para voltar ao menu...")
                stdscr.refresh()
                stdscr.getch()
            elif current_row == 1: 
                stdscr.clear()
                jogo.listar_salas_disponiveis()
                stdscr.addstr(0, 0, "Pressione qualquer tecla para voltar ao menu...")
                stdscr.refresh()
                stdscr.getch()
            elif current_row == 2:
                stdscr.clear()
                stdscr.addstr(0, 0, "Digite o ID da sala para a qual deseja se mover: ")
                stdscr.refresh()
                curses.echo() 
                nova_sala_id = stdscr.getstr().decode() 
                curses.noecho() 
                try:
                    nova_sala_id = int(nova_sala_id)
                    jogo.mover_para_sala(nova_sala_id)
                except ValueError:
                    stdscr.addstr(1, 0, "Entrada inválida. Pressione qualquer tecla para continuar...")
                    stdscr.refresh()
                    stdscr.getch()
            elif current_row == 3:  # Sair
                break
        elif key == ord('q') or key == ord('Q'):
            break

def iniciar_jogo_curses(stdscr, jogo):
    # Inicializar cores
    curses.start_color()
    curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)   # Localização atual
    curses.init_pair(2, curses.COLOR_BLUE, curses.COLOR_BLACK)  # Movimento para sala
    curses.curs_set(0)
    
    current_row = 0
    menu = ["Mostrar localização atual", "Listar todas as salas disponíveis", "Mover para uma sala", "Sair"]

    while True:
        stdscr.clear()
        stdscr.addstr("Escolha uma ação:\n", curses.A_BOLD)

        # Mostra o menu com setas para navegação
        for idx, row in enumerate(menu):
            if idx == current_row:
                stdscr.addstr(f"> {row}\n", curses.A_REVERSE)
            else:
                stdscr.addstr(f"  {row}\n")

        stdscr.refresh()

        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < len(menu) - 1:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if current_row == 0:
                # Mostrar localização atual
                stdscr.clear()
                jogo.mostrar_localizacao_atual(stdscr)
                stdscr.refresh()
                stdscr.getch()  # Pausa para o usuário ver a informação
            elif current_row == 1:
                # Listar todas as salas disponíveis
                stdscr.clear()
                jogo.listar_salas_disponiveis(stdscr)
                stdscr.refresh()
                stdscr.getch()  # Pausa para o usuário ver a informação
            elif current_row == 2:
                # Mover para uma sala
                stdscr.clear()
                jogo.listar_salas_disponiveis(stdscr)
                stdscr.addstr("\nDigite o ID da sala para a qual deseja se mover: ")
                stdscr.refresh()
                curses.echo()
                nova_sala_id = stdscr.getstr().decode()
                curses.noecho()
                stdscr.clear()
                try:
                    nova_sala_id = int(nova_sala_id)
                    jogo.mover_para_sala(nova_sala_id, stdscr)
                except ValueError:
                    stdscr.addstr("ID de sala inválido. Tente novamente.\n")
                stdscr.refresh()
                stdscr.getch()  # Pausa para o usuário ver a informação
            elif current_row == 3:
                stdscr.clear()
                stdscr.addstr("Saindo do jogo...\n")
                stdscr.refresh()
                time.sleep(1)
                break

def iniciar_jogo(usuario_id):
    try:
        cur.execute(
            "SELECT idpersonagem, idcapitulo FROM usuario WHERE id = %s",
            (usuario_id,)
        )
        personagem_id = cur.fetchone()[0]

        jogo = Game(personagem_id)
        curses.wrapper(iniciar_jogo_curses, jogo)
    except ValueError as e:
        print(e)
   
        result = cur.fetchone()
        if result is None:
            print("Usuário não encontrado.")
            return

        personagem_id = result[0]
        capitulo_atual = result[1]

        if capitulo_atual is None:
            print("O personagem ainda não foi vinculado a um capítulo.")
            return

        # Passo 2: Buscar o texto e o objetivo do capítulo atual
        cur.execute(
            "SELECT texto, objetivo FROM capitulo WHERE idcapitulo = %s",
            (capitulo_atual,)
        )
        capitulo = cur.fetchone()
        if capitulo is None:
            print("Capítulo não encontrado.")
            return

        texto, objetivo = capitulo

        # Passo 3: Mostrar o texto e o objetivo
        print(texto)
        print(f"\nObjetivo: {objetivo}")
        input("\nPressione Enter para continuar...")

        # Passo 4: Buscar e mostrar todas as opções disponíveis para o capítulo atual
        cur.execute(
            "SELECT idopcao, descricao FROM opcao WHERE iddecisao = %s",
            (capitulo_atual,)
        )
        opcoes = cur.fetchall()  # Use fetchall() para obter todas as opções

        if not opcoes:
            print("Nenhuma opção encontrada para o capítulo atual.")
            return

        print("\nEscolha uma das opções:")
        for opcao in opcoes:
            idopcao, descricao = opcao
            print(f"{idopcao}. {descricao}")

        # Passo 5: Capturar a escolha do jogador
        escolha = int(input("\nDigite o número da opção escolhida: "))

        # Verificar se a escolha está entre as opções disponíveis
        if escolha not in [opcao[0] for opcao in opcoes]:
            print("Escolha inválida.")
            return

        # Passo 6: Processar a opção escolhida
        processar_opcao(usuario_id, escolha)

    except Exception as e:
        print(f"Erro ao iniciar o jogo: {e}")

# Função para exibir o menu na tela com curses
def print_menu(stdscr, selected_row_idx):
    stdscr.clear()
    menu = ["Novo jogo", "Retomar Jogo", "Sobre o Jogo", "Sair"]

    # Adiciona a arte ASCII e o título
    ascii_art1 = """
          #####  #  #   ####                 #  #   #  #   #  #    ##    ####   ###                   ##      #    #   #  ####    ##
            #    #  #   #                    #  #   #  #   ## #   #  #   #      #  #                 #  #    # #   ## ##  #      #  #
            #    ####   ###                  ####   #  #   # ##   #      ###    #  #                 #      #   #  # # #  ###     #
            #    #  #   #                    #  #   #  #   #  #   # ##   #      ###                  # ##   #####  # # #  #        #
            #    #  #   #                    #  #   #  #   #  #   #  #   #      #  #                 #  #   #   #  #   #  #      #  #
            #    #  #   ####                 #  #    ##    #  #    ##    ####   #  #                  ##    #   #  #   #  ####    ##
    """

    # Adiciona a arte ASCII na tela
    stdscr.addstr(0, 0, "=" * 150)
    stdscr.addstr(1, 0, ascii_art1, curses.A_BOLD)
    stdscr.addstr(10, 0, "=" * 150)

    # Menu
    for idx, row in enumerate(menu):
        if idx == selected_row_idx:
            stdscr.addstr(12 + idx, 50, f"> {row}", curses.A_REVERSE)
        else:
            stdscr.addstr(12 + idx, 50, f"  {row}")

    stdscr.addstr(17, 0, "=" * 150)
    stdscr.refresh()

# Função para centralizar texto na tela
def exibir_texto_centralizado(stdscr, texto):
    stdscr.clear()
    height, width = stdscr.getmaxyx()
    x = width // 2 - len(texto) // 2
    y = height // 2
    stdscr.addstr(y, x, texto)
    stdscr.refresh()

# Função do menu inicial com curses
def menu_inicial(stdscr):
    curses.curs_set(0)
    current_row = 0
    sair = False

    while not sair:
        print_menu(stdscr, current_row)
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < 3:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if current_row == 0:  # Novo Jogo
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Indo para a tela de cadastro...")
                stdscr.refresh()
                time.sleep(2)
                curses.endwin()  # Finaliza curses antes de criar a conta
                criar_conta()  # Chama a função para criar uma nova conta
                curses.wrapper(menu_inicial)  # Retorna ao menu após criar a conta

            elif current_row == 1:  # Iniciar Jogo
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Carregando tela de Login...")
                stdscr.refresh()
                time.sleep(2)
                curses.endwin()  # Finaliza curses antes de iniciar o jogo
                login()  # Chamando a função de jogo
                curses.wrapper(menu_inicial)  # Retorna ao menu após o jogo

            elif current_row == 2:
                stdscr.clear()
                curses.start_color()
                curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)  # Define o par de cores para verde

                # Exibe o texto formatado em verde
                stdscr.addstr(0, 0, (
                    "The Hunger Games é um RPG imersivo ambientado em um universo distópico.\n\n"
                    "Neste jogo, você entra em um mundo de competição feroz e sobrevivência, onde cada decisão pode "
                    "ser a diferença entre a vida e a morte.\nVocê assume o papel de um tributo, competindo em desafios "
                    "e batalhas enquanto explora um ambiente rico e perigoso.\n Forme alianças com companheiros, enfrente "
                    "bestantes e lute contra tributos rivais. Com habilidades únicas baseadas em seu distrito e a capacidade "
                    "de adaptar suas estratégias, você deve usar todos os recursos disponíveis para sair vitorioso."
                ), curses.color_pair(1))  # Aplica o par de cores

                stdscr.refresh()
                stdscr.getch()
                current_row = 0


            elif current_row == 3:  # Sair
                exibir_texto_centralizado(stdscr, "Saindo do jogo...")
                # mostrarSimbolo()
                sys.exit()
                

# Iniciar o menu inicial com curses
if __name__ == "__main__":
    curses.wrapper(menu_inicial)

# Fechar o cursor e a conexão
cur.close()
conn.close()
