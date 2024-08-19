from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship

# Configuração do banco de dados
DATABASE_URL = "postgresql://gabriel:gabriel123@localhost:5432/data"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()

# Classes correspondentes às tabelas do banco de dados
class Mapa(Base):
    __tablename__ = 'mapa'
    idMapa = Column(Integer, primary_key=True)
    nomeM = Column(String)
    descricao = Column(String)
    regioes = relationship('Regiao', back_populates='mapa')

class Regiao(Base):
    __tablename__ = 'regiao'
    idRegiao = Column(Integer, primary_key=True)
    idMapa = Column(Integer, ForeignKey('mapa.idMapa'))
    nomeR = Column(String)
    tempR = Column(Integer)
    descricao = Column(String)
    mapa = relationship('Mapa', back_populates='regioes')
    salas = relationship('Sala', back_populates='regiao')

class Sala(Base):
    __tablename__ = 'sala'
    idSala = Column(Integer, primary_key=True)
    idRegiao = Column(Integer, ForeignKey('regiao.idRegiao'))
    nomeS = Column(String)
    descricao = Column(String)
    regiao = relationship('Regiao', back_populates='salas')
    personagens = relationship('Personagem', back_populates='sala')

class Personagem(Base):
    __tablename__ = 'personagem'
    idPersonagem = Column(Integer, primary_key=True)
    idSala = Column(Integer, ForeignKey('sala.idSala'))
    nomeP = Column(String)
    hpMax = Column(Integer)
    hpAtual = Column(Integer)
    sala = relationship('Sala', back_populates='personagens')

# Criação das tabelas no banco de dados
Base.metadata.create_all(engine)

# Funções do jogo
class Game:
    def __init__(self, personagem_id):
        self.personagem_id = personagem_id
        self.personagem = session.query(Personagem).filter_by(idPersonagem=personagem_id).first()

        if not self.personagem:
            raise ValueError("Personagem não encontrado!")
        
    def mostrar_localizacao_atual(self):
        sala_atual = self.personagem.sala
        if sala_atual:
            print(f"Você está atualmente em: {sala_atual.nomeS} - {sala_atual.descricao}")
        else:
            print("Personagem não está em nenhuma sala.")

    def mover_para_sala(self, nova_sala_id):
        nova_sala = session.query(Sala).filter_by(idSala=nova_sala_id).first()
        if nova_sala:
            self.personagem.idSala = nova_sala_id
            session.commit()
            print(f"Você se moveu para: {nova_sala.nomeS} - {nova_sala.descricao}")
        else:
            print("Sala não encontrada.")

    def listar_salas_disponiveis(self):
        regiao_atual = self.personagem.sala.regiao if self.personagem.sala else None

        if regiao_atual:
            salas = session.query(Sala).filter_by(idRegiao=regiao_atual.idRegiao).all()
            if salas:
                print("Salas disponíveis para se mover:")
                for sala in salas:
                    print(f"{sala.idSala}: {sala.nomeS} - {sala.descricao}")
            else:
                print("Nenhuma sala disponível na região.")
        else:
            print("Personagem não está em nenhuma sala ou região.")

# Interface de Linha de Comando
def iniciar_jogo():
    personagem_id = int(input("Digite o ID do seu personagem: "))
    try:
        jogo = Game(personagem_id)
        
        while True:
            print("\nEscolha uma ação:")
            print("1. Mostrar localização atual")
            print("2. Listar salas disponíveis")
            print("3. Mover para uma sala")
            print("4. Sair")
            
            escolha = input("Digite o número da sua escolha: ")
            
            if escolha == "1":
                jogo.mostrar_localizacao_atual()
            elif escolha == "2":
                jogo.listar_salas_disponiveis()
            elif escolha == "3":
                nova_sala_id = int(input("Digite o ID da sala para a qual deseja se mover: "))
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
