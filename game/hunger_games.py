import psycopg2
from psycopg2 import sql, errors
from colorama import Fore, init
import curses
import sys
import time

# Inicializar Colorama
init(autoreset=True)

# Dados de conexão com o PostgreSQL
conn = psycopg2.connect(
    dbname="hunger_games",
    user="postgres",
    password="20082003",
    host="localhost",
    port="5432"
)

# Criar um cursor
cur = conn.cursor()

# Dicionário de personagens (exemplo)
personagens = {
    1: {'idSala': 1, 'nome': 'Personagem 1'},
    2: {'idSala': 2, 'nome': 'Personagem 2'}
}

# Funções do jogo
class Game:
    def __init__(self, personagemId):
        self.personagemId = personagemId
        self.personagem = personagens.get(personagemId)

        if not self.personagem:
            raise ValueError("Personagem não encontrado!")

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

            

# Criação de Conta

def criar_conta():
    while True:
        nome = input("\nDigite o nome de usuário: ")
        senha = input("Digite a senha: ")

        try:
            # Tenta inserir o usuário no banco de dados
            cur.execute(
                sql.SQL("INSERT INTO usuario (nome, senha) VALUES (%s, %s)"),
                (nome, senha),
            )
            conn.commit()
            print("\nUsuário criado com sucesso!")
            break  # Sai do loop se a inserção for bem-sucedida
        
        except errors.UniqueViolation as e:  # Captura o erro específico de violação de unicidade
            conn.rollback() 
            mensagem_erro = str(e).splitlines()[0]
            print(f"\nErro: O nome de usuário '{nome}' já existe no sistema. Escolha outro nome.")
        
        except errors.RaiseException as e:  # Captura outros erros
            conn.rollback() 
            mensagem_erro = str(e).splitlines()[0]
            print("\nErro ao criar o usuário:", mensagem_erro)

    input("\nPressione Enter para voltar ao menu.")

# Interface de Linha de Comando
def iniciar_jogo():
    personagemId = int(input("Digite o ID do seu personagem: \n"))
    try:
        jogo = Game(personagemId)

        while True:
            print("\nEscolha uma ação:")
            print("1. Mostrar localização atual")
            print("2. Listar todas as salas disponíveis")
            print("3. Mover para uma sala")
            print("4. Sair")

            escolha = input("\nDigite o número da sua escolha: ")

            if escolha == "1":
                jogo.mostrar_localizacao_atual()
            elif escolha == "2":
                jogo.listar_salas_disponiveis()
            elif escolha == "3":
                nova_sala_id = int(input("\nDigite o ID da sala para a qual deseja se mover: \n"))
                jogo.mover_para_sala(nova_sala_id)
            elif escolha == "4":
                print("Saindo do jogo...")
                break
            else:
                print("Escolha inválida. Tente novamente.")
    except ValueError as e:
        print(e)

# Função para exibir o menu na tela com curses
def print_menu(stdscr, selected_row_idx):
    stdscr.clear()
    menu = ["Novo jogo", "Iniciar Jogo", "Controles", "Sair"]

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
        elif key == curses.KEY_DOWN and current_row < 2:
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
                exibir_texto_centralizado(stdscr, "Iniciando o jogo...")
                stdscr.refresh()
                time.sleep(2)
                curses.endwin()  # Finaliza curses antes de iniciar o jogo
                iniciar_jogo()  # Chamando a função de jogo
                curses.wrapper(menu_inicial)  # Retorna ao menu após o jogo

            elif current_row == 2:  # Controles
                stdscr.clear()
                stdscr.addstr(0, 0, "W - Move-se para cima\nA - Move-se para esquerda\nS - Move-se para baixo\nD - Move-se para direita\nQ - Retorna ao menu")
                stdscr.refresh()
                stdscr.getch()
                current_row = 0

            elif current_row == 3:  # Sair
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Saindo do jogo...")
                stdscr.refresh()
                time.sleep(2)
                sair = True
                print("""                                                                   
                                                                ##MM                          ..                        
                                                                ..MM                          @@####                    
                                                        MM++--                            ::##mm::                    
               #####  #  #   ####                       ######MM..                            mm                                              
                 #    #  #   #                      ##########                                          --            
                 #    ####   ###                    ##########            ##        ##                                  
                 #    #  #   #                  ####@@####        @@######        ######MM                            
                 #    #  #   #                      ++##        ####mm####        ##########        ..mm####..        
                 #    #  #   ####                   ##          ######MM####        ##########MM        ####::          
                                            ####            ##############        ##############              ##      
                                            ##  ####      ################        ################        ######++    
 #  #   #  #   #  #    ##    ####   ###     ######          ###########@##        ##++##########            ####      
 #  #   #  #   ## #   #  #   #      #  #    ::            @@##::############        ############::####        --::MM    
 ####   #  #   # ##   #      ###    #  #    ######        ############mm..##        ##::MM####@@######        ##  ##..  
 #  #   #  #   #  #   # ##   #      ###     ##::##        ##################        ##################          ##mm    
 #  #   #  #   #  #   #  #   #      #  #    ##          ##..########mm####  ::##  ##############..##::        @@      
 #  #    ##    #  #    ##    ####   #  #    ##  ##      ##########@@mm######  MM##--######++MM########mm        ##  ##  
                                            ######        ##################  ####  ##################          ##@@##  
                                            ####          ######::    ####################    --@@####++          @@::  
      ##      #    #   #  ####    ##        ##  ##        ############++###############@@############        --##--##  
     #  #    # #   ## ##  #      #  #       ##++##                      #################                      ########  
     #      #   #  # # #  ###     #         @@##                        ############                          ##++    
     # ##   #####  # # #  #        #        ##    ##              ####      ########      mm##                MM..      
     #  #   #   #  #   #  #      #  #       ++##  ##          ####  ..##    ########    --##MM####            ######    
      ##    #   #  #   #  ####    ##        ##@@##            ++##  ##++::######@@  @@##mm##..              ##  ##    
                                                    ##            ##::..################  ++##@@            mm##        
                                                ##  ##            ####  --############++  ####            ++##..##      
                                                ######MM                ##########++####                  mm####MM      
                                                ####MM##              ################                ##    @@        
                                                ##@@  ####                                        --####++##--        
                                                    ####  ++##                                    ####@@####..          
                                                        --mm######                            ##  ##..::--              
                                                        ######  ######                    ######  ######                
                                                            ####--######                ######  ####                    
                                                            MM##  @@..                ..@@::++##                      
                                                                MM####::mmmm    ##++::######                                                                                                                                                             
""")

                time.sleep(3)
                sys.exit()

# Iniciar o menu inicial com curses
if __name__ == "__main__":
    curses.wrapper(menu_inicial)

# Fechar o cursor e a conexão
cur.close()
conn.close()
