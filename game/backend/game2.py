from colorama import init, Fore, Back, Style

# Definindo as estruturas de dados para simular o banco
mapas = {
    1: {'idMapa': 1, 'nomeM': 'Mapa Principal', 'descricao': 'O mapa inicial do jogo.'}
}

# Estrutura de dados para as salas
salas = {
    1: {'idSala': 1, 'idRegiao': 1, 'nomeS': 'Base', 'descricao': 'A primeira sala do jogo.'},
    2: {'idSala': 2, 'idRegiao': 1, 'nomeS': 'Centro de Treinamento', 'descricao': 'Uma sala escura e sombria onde se fortalecem os guerreiros.'},
    3: {'idSala': 3, 'idRegiao': 1, 'nomeS': 'Midia', 'descricao': 'Onde os tributos falam com a imprensa.'},
    4: {'idSala': 4, 'idRegiao': 1, 'nomeS': 'Andar superior', 'descricao': 'Andar de preparação para os jogos.'},
    5: {'idSala': 5, 'idRegiao': 1, 'nomeS': 'Mundo aberto', 'descricao': 'Cada um por si...'},

    6: {'idSala': 6, 'idRegiao': 2, 'nomeS': 'Cume da Montanha', 'descricao': 'O ponto mais alto das montanhas, com uma vista espetacular.'},
    7: {'idSala': 7, 'idRegiao': 2, 'nomeS': 'Caverna Gelada', 'descricao': 'Uma caverna de gelo, repleta de estalactites.'},
    8: {'idSala': 8, 'idRegiao': 2, 'nomeS': 'Penhasco', 'descricao': 'Um penhasco íngreme que desce até um vale profundo.'},

    9: {'idSala': 9, 'idRegiao': 3, 'nomeS': 'Oásis', 'descricao': 'Um oásis refrescante no meio do deserto.'},
    10: {'idSala': 10, 'idRegiao': 3, 'nomeS': 'Dunas', 'descricao': 'Dunas de areia que parecem se mover com o vento.'},
    11: {'idSala': 11, 'idRegiao': 3, 'nomeS': 'Ruínas Antigas', 'descricao': 'Ruínas de uma civilização perdida, meio enterradas na areia.'},

    12: {'idSala': 12, 'idRegiao': 4, 'nomeS': 'Lagoa', 'descricao': 'Uma lagoa de águas turvas, com peixes e anfíbios.'},
    13: {'idSala': 13, 'idRegiao': 4, 'nomeS': 'Bosque de Ciprestes', 'descricao': 'Um bosque denso de ciprestes, com o solo encharcado.'},
    14: {'idSala': 14, 'idRegiao': 4, 'nomeS': 'Ruínas Submersas', 'descricao': 'Ruínas antigas parcialmente submersas.'},

    15: {'idSala': 15, 'idRegiao': 5, 'nomeS': 'Praça Central', 'descricao': 'Uma praça com estátuas caídas e fontes secas.'},
    16: {'idSala': 16, 'idRegiao': 5, 'nomeS': 'Prédio do Governo', 'descricao': 'Um prédio imponente, agora vazio e em ruínas.'},
    17: {'idSala': 17, 'idRegiao': 5, 'nomeS': 'Biblioteca Abandonada', 'descricao': 'Uma grande biblioteca, com livros empoeirados e móveis quebrados.'}
}

# Estrutura de dados para as regiões
regioes = {
    1: {'idRegiao': 1, 'idMapa': 1, 'nomeR': 'Região Norte', 'tempR': 15.5, 'descricao': 'Uma região montanhosa e fria.'},
    2: {'idRegiao': 2, 'idMapa': 1, 'nomeR': 'Montanhas Nevadas', 'tempR': -5.0, 'descricao': 'Uma região montanhosa coberta de neve.'},
    3: {'idRegiao': 3, 'idMapa': 1, 'nomeR': 'Deserto', 'tempR': 40.0, 'descricao': 'Um vasto deserto de areia.'},
    4: {'idRegiao': 4, 'idMapa': 1, 'nomeR': 'Pântano', 'tempR': 20.0, 'descricao': 'Uma região alagada, com vegetação densa e cheia de neblina.'},
    5: {'idRegiao': 5, 'idMapa': 1, 'nomeR': 'Cidade Abandonada', 'tempR': 25.0, 'descricao': 'Uma cidade em ruínas, deserta e esquecida.'}
}

personagens = {
    1: {'idPersonagem': 1, 'idSala': 1, 'tipoP': 'Guerreiro', 'nomeP': 'Arthas', 'hpMax': 120, 'hpAtual': 120}
}

# Funções do jogo
class Game:
    def __init__(self, personagemId):
        self.personagemId = personagemId
        self.personagem = personagens.get(personagemId)

        if not self.personagem:
            raise ValueError("Personagem não encontrado!")
        
    def mostrar_localizacao_atual(self):
        sala_atual = salas.get(self.personagem['idSala'])
        if sala_atual:
            print(Fore.RED + f"Você está atualmente em: {sala_atual['nomeS']} - {sala_atual['descricao']}" + Fore.RESET)
        else:
            print("Personagem não está em nenhuma sala.")

    def mover_para_sala(self, nova_sala_id):
        nova_sala = salas.get(nova_sala_id)
        if nova_sala:
            self.personagem['idSala'] = nova_sala_id
            print(Fore.BLUE + f"Você se moveu para: {nova_sala['nomeS']} - {nova_sala['descricao']}" + Fore.RESET)
        else:
            print("Sala não encontrada.")

    def listar_salas_disponiveis(self):
        sala_atual = salas.get(self.personagem['idSala'])
        regiao_atual_id = sala_atual['idRegiao'] if sala_atual else None

        if regiao_atual_id:
            salas_disponiveis = [sala for sala in salas.values() if sala['idRegiao'] == regiao_atual_id]
            if salas_disponiveis:
                print("Salas disponíveis para se mover:")
                for sala in salas_disponiveis:
                    print(f"{sala['idSala']}: {sala['nomeS']} - {sala['descricao']}")
            else:
                print("Nenhuma sala disponível na região.")
        else:
            print("Personagem não está em nenhuma sala ou região.")

# Interface de Linha de Comando
def iniciar_jogo():
    personagemId = int(input("Digite o ID do seu personagem: \n"))
    try:
        jogo = Game(personagemId)
        
        while True:
            print("\nEscolha uma ação:")
            print("1. Mostrar localização atual")
            print("2. Listar salas disponíveis")
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

# Iniciar o jogo
if __name__ == "__main__":
    iniciar_jogo()
