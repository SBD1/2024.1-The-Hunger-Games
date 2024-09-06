import os
import sqlalchemy
from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, Text, Float, Boolean
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
import curses
import sys
import termios
import tty
import time
from mapas import mapa1, mapa2, mapa3
import banco


def main(stdscr):
    curses.curs_set(0)
    stdscr.nodelay(1)
    stdscr.timeout(100)

mapas = {
    'mapa1': mapa1,
    'mapa2': mapa2,
    'mapa3': mapa3,
}

estado_jogo = {
    'mapa_atual': 'mapa1',  # Mapa inicial
    'posicao_personagem': (18, 3),  # Posição inicial do personagem
}



def verificar_transicao(posicao, mapa_atual):
    x, y = posicao
    
    transicoes = {
        'mapa1': {
            'mapa2': (123, 31),  # 1 para o 2
        },
        'mapa2': {
            'mapa1': (7, 1),    # Volta para o mapa 1
            'mapa3': (51, 32),   # Mapa 2 leva ao mapa 3
        },
        'mapa3': {
            'mapa2': (25, 0),    # Mapa 3 volta para o mapa 2
        },
    }

    
    if mapa_atual in transicoes:
        for mapa_destino, posicao_transicao in transicoes[mapa_atual].items():
            if posicao == posicao_transicao:
                return mapa_destino  # Retorna o mapa para o qual deve transitar
    
    return mapa_atual

def desenhar_mapa(stdscr, mapa, pos_x, pos_y):
    for y, linha in enumerate(mapa):
        stdscr.addstr(y, 0, linha)
    stdscr.addch(pos_y, pos_x, '@')

def mover_personagem(tecla, pos_x, pos_y, mapa):
    nova_x, nova_y = pos_x, pos_y
    if tecla == 'w' and pos_y > 0 and mapa[pos_y - 1][pos_x] == ' ':
        nova_y -= 1
    elif tecla == 's' and pos_y < len(mapa) - 1 and mapa[pos_y + 1][pos_x] == ' ':
        nova_y += 1
    elif tecla == 'a' and pos_x > 0 and mapa[pos_y][pos_x - 1] == ' ':
        nova_x -= 1
    elif tecla == 'd' and pos_x < len(mapa[0]) - 1 and mapa[pos_y][pos_x + 1] == ' ':
        nova_x += 1

    return nova_x, nova_y

def main(stdscr):
    curses.curs_set(0)
    pos_x, pos_y = estado_jogo['posicao_personagem']
    
    while True:
        stdscr.clear()
        mapa_atual = estado_jogo['mapa_atual']
        mapa = mapas[mapa_atual]
        desenhar_mapa(stdscr, mapa, pos_x, pos_y)
        stdscr.refresh()

        tecla = stdscr.getch()
        if tecla == ord('q'):
            break
        elif tecla in [ord('w'), ord('a'), ord('s'), ord('d')]:
            pos_x, pos_y = mover_personagem(chr(tecla), pos_x, pos_y, mapa)

        novo_mapa = verificar_transicao((pos_x, pos_y), mapa_atual)
        if novo_mapa != mapa_atual:
            estado_jogo['mapa_atual'] = novo_mapa
            if novo_mapa == 'mapa1':
                pos_x, pos_y = 120, 31  # Posição inicial no mapa 1
            elif novo_mapa == 'mapa2':
                if mapa_atual == 'mapa1':
                    pos_x, pos_y = 35, 3  # Posição inicial no mapa 2 vindo do mapa 1
                elif mapa_atual == 'mapa3':
                    pos_x, pos_y = 51, 29  # Posição inicial no mapa 2 vindo do mapa 3
            elif novo_mapa == 'mapa3':
                pos_x, pos_y = 25, 4  # Posição inicial no mapa 3
            else:
                pos_x, pos_y = (5, 5)  # Posição padrão se nenhum mapa específico for encontrado


        estado_jogo['posicao_personagem'] = (pos_x, pos_y)

def exibir_texto_centralizado(stdscr, texto):
    altura, largura = stdscr.getmaxyx()
    x_inicial = (largura // 2) - (len(texto) // 2)
    y_inicial = altura // 2
    stdscr.clear()
    stdscr.addstr(y_inicial, x_inicial, texto)
    stdscr.refresh()
    time.sleep(2)

def print_menu(stdscr, selected_row_idx):
    stdscr.clear()
    menu = ["Iniciar Jogo", "Controles", "Sair"]

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
    stdscr.addstr(0, 0, "===============================================================================================================================================")
    stdscr.addstr(1, 0, ascii_art1, curses.A_BOLD)
    stdscr.addstr(10, 0, "===============================================================================================================================================")

    # Menu
    for idx, row in enumerate(menu):
        if idx == selected_row_idx:
            stdscr.addstr(12 + idx, 50, f"> {row}", curses.A_REVERSE)
        else:
            stdscr.addstr(12 + idx, 50, f"  {row}")

    stdscr.addstr(15, 0, "===============================================================================================================================================")
    
    stdscr.refresh()


def menu_inicial(stdscr):
    curses.curs_set(0)
    current_row = 0

    while True:
        print_menu(stdscr, current_row)
        key = stdscr.getch()

        if key == curses.KEY_UP and current_row > 0:
            current_row -= 1
        elif key == curses.KEY_DOWN and current_row < 2:
            current_row += 1
        elif key == curses.KEY_ENTER or key in [10, 13]:
            if current_row == 0:
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Iniciando o jogo...")
                stdscr.refresh()
                time.sleep(2)
                main(stdscr) 
                current_row = 0 

            elif current_row == 1:
                stdscr.clear()
                stdscr.addstr(0, 0, "W - Move-se para cima\nA - Move-se para esquerda\nS - Move-se para baixo\nD - Move-se para direita\nQ - Retorna ao menu")
                stdscr.refresh()
                stdscr.getch()
                current_row = 0  

            elif current_row == 2:
                stdscr.clear()
                exibir_texto_centralizado(stdscr, "Saindo do jogo...")
                stdscr.refresh()
                time.sleep(2)
                sys.exit()

if __name__ == "__main__":
    curses.wrapper(menu_inicial)
