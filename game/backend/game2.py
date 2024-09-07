from colorama import init, Fore
import os
import sqlalchemy
from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, Text, Float, Boolean, select
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

# Configuração do banco de dados
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_URL = f"sqlite:///{os.path.join(BASE_DIR, '3_data.db')}"  # Conecta ao arquivo .db gerado

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()

# Classes do banco de dados usando SQLAlchemy
class Mapa(Base):
    __tablename__ = 'mapa'
    idMapa = Column(Integer, primary_key=True)
    nomeM = Column(String)
    descricao = Column(Text)


class Regiao(Base):
    __tablename__ = 'regiao'
    idRegiao = Column(Integer, primary_key=True)
    idMapa = Column(Integer, ForeignKey('mapa.idMapa'))
    nomeR = Column(String)
    tempR = Column(Integer)
    descricao = Column(Text)


class Sala(Base):
    __tablename__ = 'sala'
    idSala = Column(Integer, primary_key=True)
    idRegiao = Column(Integer, ForeignKey('regiao.idRegiao'))
    nomeS = Column(String)
    descricao = Column(Text)


# Dicionário para armazenar personagens (apenas para exemplo; idealmente deveria estar no banco)
personagens = {
    1: {'idSala': 1, 'nome': 'Tributo 1'},
    2: {'idSala': 2, 'nome': 'Tributo 2'},
    # Adicione outros personagens conforme necessário
}

# Funções do jogo
class Game:
    def __init__(self, personagemId):
        self.personagemId = personagemId
        self.personagem = personagens.get(personagemId)

        if not self.personagem:
            raise ValueError("Personagem não encontrado!")
        
    def mostrar_localizacao_atual(self):
        sala_atual = session.query(Sala).filter_by(idSala=self.personagem['idSala']).first()
        if sala_atual:
            print(Fore.RED + f"Você está atualmente em: {sala_atual.nomeS} - {sala_atual.descricao}" + Fore.RESET)
        else:
            print("Personagem não está em nenhuma sala.")

    def mover_para_sala(self, nova_sala_id):
        nova_sala = session.query(Sala).filter_by(idSala=nova_sala_id).first()
        if nova_sala:
            self.personagem['idSala'] = nova_sala_id
            print(Fore.BLUE + f"Você se moveu para: {nova_sala.nomeS} - {nova_sala.descricao}" + Fore.RESET)
        else:
            print("Sala não encontrada.")

    def listar_salas_disponiveis(self):
        sala_atual = session.query(Sala).filter_by(idSala=self.personagem['idSala']).first()
        if sala_atual:
            salas_disponiveis = session.query(Sala).filter_by(idRegiao=sala_atual.idRegiao).all()
            if salas_disponiveis:
                print("Salas disponíveis para se mover:")
                for sala in salas_disponiveis:
                    print(f"{sala.idSala}: {sala.nomeS} - {sala.descricao}")
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
                                                              Escolha um personagem
| **Personagem**     | **Dominic**                                                                                                                                                          | **Gabrielle**                                                                                                                                                        | **Leslie**                                                                                                                                                                      | **Icaro**                                                                                                                                                                  |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Popularidade** | 6                                                                                                                                                                    | 3                                                                                                                                                                    | 4                                                                                                                                                                              | 4                                                                                                                                                                          |
| **Agilidade**    | 4                                                                                                                                                                    | 4                                                                                                                                                                    | 6                                                                                                                                                                              | 8                                                                                                                                                                          |
| **Força**        | 5                                                                                                                                                                    | 4                                                                                                                                                                    | 4                                                                                                                                                                              | 4                                                                                                                                                                          |
| **Nado**         | 4                                                                                                                                                                    | 5                                                                                                                                                                    | 6                                                                                                                                                                              | 9                                                                                                                                                                          |
| **Carisma**      | 4                                                                                                                                                                    | 4                                                                                                                                                                    | 8                                                                                                                                                                              | 5                                                                                                                                                                          |
| **Combate**      | 8                                                                                                                                                                    | 4                                                                                                                                                                    | 4                                                                                                                                                                              | 5                                                                                                                                                                          |
| **Perspicácia**  | 5                                                                                                                                                                    | 10                                                                                                                                                                   | 5                                                                                                                                                                              | 3                                                                                                                                                                          |
| **Furtividade**  | 3                                                                                                                                                                    | 8                                                                                                                                                                    | 5                                                                                                                                                                              | 4                                                                                                                                                                          |
| **Sobrevivência**| 4                                                                                                                                                                    | 6                                                                                                                                                                    | 8                                                                                                                                                                              | 5                                                                                                                                                                          |
| **Precisão**     | 7                                                                                                                                                                    | 4                                                                                                                                                                    | 5                                                                                                                                                                              | 6                                                                                                                                                                          |

                                                                   Descrição
Dominic é o tributo masculino do Distrito 1, um Carreirista que treinou anos em uma academia especial apenas para se voluntariar aos Jogos quando completasse 18 anos. Ele é conhecido por sua habilidade em combate e precisão.

Gabrielle é a tributo feminina do Distrito 3, conhecido pelo desenvolvimento tecnológico de toda a Panem. Gabrielle é famosa pela sua inteligência e pela facilidade de se esconder. | Leslie é a tributo feminina do Distrito 12, conhecido pela mineração e por ser o Distrito mais pobre de Panem. A falta de recursos nas cidades fez com que a sobrevivência no ambiente natural se tornasse essencial. Ela é conhecida pelo seu carisma e pelo seu conhecimento da natureza.

Icaro é o tributo masculino do Distrito 4, o Distrito da Pesca. Cresceu nadando e pescando de diversas formas, e é conhecido por sua habilidade em nado e agilidade.
