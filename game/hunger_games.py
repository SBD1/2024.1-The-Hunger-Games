import psycopg2
from psycopg2 import sql, errors
from colorama import Fore, init
import curses
import sys
import os
import time
import threading
import traceback
from capital import mostrarSimbolo
import pygame

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

def TocarSom():
    try:
        pygame.mixer.init()
        pygame.mixer.music.load("game\The Hunger Games - Deep in the Meadow.mp3")
        pygame.mixer.music.set_volume(0.2)  # Volume ajustável entre 0.0 e 1.0
        # Reproduz a música indefinidamente
        pygame.mixer.music.play()
    except pygame.error as e:
        print(f"Erro ao tocar a música: {e}")
    except Exception as e:
        print(f"Erro inesperado: {e}")


def display_stats_curses(stdscr, stats):
    curses.curs_set(0)
    height, width = stdscr.getmaxyx()

    # Calcula a posição inicial da janela no canto inferior direito
    altura_max = len(stats) + 4
    largura_max = max(len(stat) for stat in stats) + 4
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
        time.sleep(1)  # Atualiza a cada 1 segundo

# Função para iniciar o display de estatísticas em uma nova thread
def iniciar_display(stats):
    # Função alvo para rodar curses na thread principal
    def curses_thread(stdscr):
        display_stats_curses(stdscr, stats)

    # Cria uma thread para rodar a interface curses
    display_thread = threading.Thread(target=curses.wrapper, args=(curses_thread,))
    display_thread.daemon = True  # Permite que a thread seja encerrada com o programa principal
    display_thread.start()  # Inicia a thread

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
                            f"Força: {stats[2]}",
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

        # Iniciar o display com as estatísticas em uma thread
        iniciar_display(self.stats)

    def _obter_personagem(self):
        cur.execute("SELECT idSala FROM personagem WHERE idPersonagem = %s", (self.personagemId,))
        resultado = cur.fetchone()
        if resultado:
            return {'idSala': resultado[0]}
        return None

    def mostrar_localizacao_atual(self):
        cur.execute("SELECT nomeS, descricao FROM sala WHERE idSala = %s", (self.personagem['idSala'],))
        sala_atual = cur.fetchone()
        if sala_atual:
            print(Fore.RED + f"Você está atualmente em: {sala_atual[0]} - {sala_atual[1]}")
        else:
            print("Personagem não está em nenhuma sala.")

    def mover_para_sala(self, nova_sala_id):
        cur.execute("SELECT nomeS, descricao FROM sala WHERE idSala = %s", (nova_sala_id,))
        nova_sala = cur.fetchone()
        if nova_sala:
            cur.execute("UPDATE personagem SET idSala = %s WHERE idPersonagem = %s", (nova_sala_id, self.personagemId))
            conn.commit()
            self.personagem['idSala'] = nova_sala_id
            print(Fore.BLUE + f"Você se moveu para: {nova_sala[0]} - {nova_sala[1]}")
        else:
            print("Sala não encontrada.")

    def listar_salas_disponiveis(self):
        cur.execute("SELECT idSala, nomeS, descricao FROM sala")
        salas_disponiveis = cur.fetchall()
        if salas_disponiveis:
            print("Salas disponíveis para se mover:")
            for sala in salas_disponiveis:
                print(f"{sala[0]}: {sala[1]} - {sala[2]}")
        else:
            print("Nenhuma sala disponível.")

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

    # Mapeamento dos IDs dos personagens
    personagens_ids = [1, 6, 24, 7]  # Dominic = 1, Gabrielle = 6, Leslie = 24, Icaro = 7

    while True:
        mostrar_personagens_tabela(stdscr, personagens, selected_idx)
        key = stdscr.getch()
        if key == curses.KEY_LEFT and selected_idx > 0:
            selected_idx -= 1
        elif key == curses.KEY_RIGHT and selected_idx < len(personagens) - 1:
            selected_idx += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            return personagens_ids[selected_idx]
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
            # Executa a inserção no banco de dados
            cur.execute(
                sql.SQL("INSERT INTO usuario (nome, senha) VALUES (%s, %s) RETURNING id"),
                (nome, senha)
            )
            usuario_id = cur.fetchone()[0]
            conn.commit()
            print("\nUsuário criado com sucesso!")
            escolher_personagem(usuario_id)
            iniciar_jogo(usuario_id)
            limpar_tela()
            break

        except errors.UniqueViolation as e:
            conn.rollback()  # Garante que o rollback é feito após a violação
            print(f"\nErro: O nome de usuário '{nome}' já existe no sistema. Escolha outro nome.")

        except errors.RaiseException as e:
            conn.rollback()  # Garante que o rollback é feito após qualquer outra exceção específica
            print("\nErro ao criar o usuário:", str(e))
        
        except Exception as e:
            conn.rollback()  # Rollback em caso de outros erros não esperados
            print("\nErro inesperado ao criar o usuário:", str(e))
            traceback.print_exc()


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
            "SELECT efeito_atributo, atributo, proximo_capitulo FROM opcao WHERE idopcao = %s",
            (opcao_id,)
        )
        opcao = cur.fetchone()
        if opcao is None:
            print("Opção não encontrada.")
            return

        efeito_atributo, atributo, proximo_capitulo = opcao

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

        else:
            # Subtrair o efeito_atributo do atributo correspondente
            cur.execute(
                f"UPDATE vitalidade SET {atributo} = {atributo} - %s WHERE idusuario = %s",
                (efeito_atributo, usuario_id)
            )

            # Atualizar o idcapitulo do usuário na tabela 'usuario' se necessário
            cur.execute(
                "UPDATE usuario SET idcapitulo = %s WHERE id = %s",
                (proximo_capitulo, usuario_id)
            )

        # Verificar a consequência para a opção escolhida
        cur.execute(
            "SELECT texto, atributo, recompensa FROM consequencia WHERE idopcao = %s",
            (opcao_id,)
        )
        consequencia = cur.fetchone()
        if consequencia:
            texto_consequencia, atributo_consequencia, recompensa = consequencia
            print(f"\n{texto_consequencia}\n")  # Linha em branco após o texto da consequência

            # Atualizar a tabela vitalidade com base na consequência
            if atributo_consequencia in ['carisma', 'perspicacia', 'popularidade']:
                cur.execute(
                    f"UPDATE vitalidade SET {atributo_consequencia} = {atributo_consequencia} + %s WHERE idusuario = %s",
                    (recompensa, usuario_id)
                )

        conn.commit()  # Commit para salvar as mudanças

    except Exception as e:
        print(f"Erro ao processar a opção: {e}")


def iniciar_jogo(usuario_id):
    try:
        while True:  # Inicia o loop do jogo
            # Passo 1: Buscar o id do personagem e o id do capítulo a partir do id do usuário
            cur.execute(
                "SELECT idpersonagem, idcapitulo FROM usuario WHERE id = %s",
                (usuario_id,)
            )
            result = cur.fetchone()
            if result is None:
                print("Usuário não encontrado.")
                break  # Sai do loop se o usuário não for encontrado

            personagem_id = result[0]
            capitulo_atual = result[1]

            if capitulo_atual is None:
                print("O personagem ainda não foi vinculado a um capítulo.")
                break  # Sai do loop se o personagem não estiver vinculado a um capítulo

            # Passo 2: Buscar o texto e o objetivo do capítulo atual
            cur.execute(
                "SELECT texto, objetivo FROM capitulo WHERE idcapitulo = %s",
                (capitulo_atual,)
            )
            capitulo = cur.fetchone()
            if capitulo is None:
                print("Capítulo não encontrado.")
                break  # Sai do loop se o capítulo não for encontrado

            texto, objetivo = capitulo

            # Passo 3: Mostrar o texto e o objetivo
            print(texto)
            print("\nObjetivo: " + objetivo)  # Linha em branco antes do objetivo
            input("\nPressione Enter para continuar...")

            # Passo 4: Buscar todas as opções disponíveis para o capítulo atual
            cur.execute(
                "SELECT idopcao, descricao, efeito_atributo, atributo, peso FROM opcao WHERE iddecisao = %s",
                (capitulo_atual,)
            )
            opcoes = cur.fetchall()

            if not opcoes:
                print("Nenhuma opção encontrada para o capítulo atual.")
                break  # Sai do loop se não houver opções

            # Passo 4a: Obter os atributos do usuário da tabela vitalidade
            cur.execute(
                "SELECT popularidade, agilidade, forca, nado, carisma, combate, perspicacia, furtividade, sobrevivencia, precisao FROM vitalidade WHERE idusuario = %s",
                (usuario_id,)
            )
            atributos = cur.fetchone()
            if atributos is None:
                print("Atributos não encontrados.")
                break  # Sai do loop se os atributos não forem encontrados

            atributos_dict = dict(zip(
                ['popularidade', 'agilidade', 'forca', 'nado', 'carisma', 'combate', 'perspicacia', 'furtividade', 'sobrevivencia', 'precisao'],
                atributos
            ))

            # Filtrar opções com base no atributo e peso
            opcoes_filtradas = []
            for opcao in opcoes:
                idopcao, descricao, efeito_atributo, atributo, peso = opcao
                if atributos_dict.get(atributo, 0) >= peso:
                    opcoes_filtradas.append((idopcao, descricao))

            if not opcoes_filtradas:
                print("Nenhuma opção disponível com base em seus atributos.")
                continue  # Retorna ao início do loop se não houver opções filtradas

            # Passo 4b: Mostrar as opções filtradas
            print("\nEscolha uma das opções:")
            for opcao in opcoes_filtradas:
                idopcao, descricao = opcao
                print(f"{idopcao}. {descricao}")

            # Passo 5: Capturar a escolha do jogador
            escolha = input("\nDigite o número da opção escolhida (ou 'sair' para encerrar): ")

            if escolha.lower() == 'sair':
                print("Você saiu do jogo.")
                break  # Sai do loop se o jogador escolher sair

            # Tenta converter a escolha para um número inteiro
            try:
                escolha = int(escolha)
            except ValueError:
                print("Escolha inválida. Por favor, digite um número ou 'sair'.")
                continue  # Retorna ao início do loop se a escolha não for um número

            # Verificar se a escolha está entre as opções disponíveis
            if escolha not in [opcao[0] for opcao in opcoes_filtradas]:
                print("Escolha inválida.")
                continue  # Retorna ao início do loop se a escolha for inválida

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
    TocarSom()

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

            elif current_row == 2:  # Sobre
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
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Saindo do jogo...")
                stdscr.refresh()
                time.sleep(2)
                sair = True
                mostrarSimbolo()
                sys.exit()
                

# Iniciar o menu inicial com curses
if __name__ == "__main__":
    curses.wrapper(menu_inicial)

# Fechar o cursor e a conexão
cur.close()
conn.close()