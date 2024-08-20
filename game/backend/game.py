import os
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Text, Boolean, Float
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

# Configuração do banco de dados
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_URL = f"sqlite:///{os.path.join(BASE_DIR, 'data.db')}"

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()

# Classes correspondentes às tabelas do banco de dados
class Mapa(Base):
    __tablename__ = 'mapa'
    idMapa = Column(Integer, primary_key=True)
    nomeM = Column(String)
    descricao = Column(Text)
    regioes = relationship('Regiao', back_populates='mapa')

class Regiao(Base):
    __tablename__ = 'regiao'
    idRegiao = Column(Integer, primary_key=True)
    idMapa = Column(Integer, ForeignKey('mapa.idMapa'))
    nomeR = Column(String)
    tempR = Column(Float)
    descricao = Column(Text)
    mapa = relationship('Mapa', back_populates='regioes')
    salas = relationship('Sala', back_populates='regiao')

class Sala(Base):
    __tablename__ = 'sala'
    idSala = Column(Integer, primary_key=True)
    idRegiao = Column(Integer, ForeignKey('regiao.idRegiao'))
    nomeS = Column(String)
    descricao = Column(Text)
    regiao = relationship('Regiao', back_populates='salas')
    personagens = relationship('Personagem', back_populates='sala')

class Personagem(Base):
    __tablename__ = 'personagem'
    idPersonagem = Column(Integer, primary_key=True)
    idSala = Column(Integer, ForeignKey('sala.idSala'), default=1)
    tipoP = Column(String(25))
    nomeP = Column(String)
    hpMax = Column(Integer, default=100)
    hpAtual = Column(Integer, default=100)
    sala = relationship('Sala', back_populates='personagens')

class Vitalidade(Base):
    __tablename__ = 'vitalidade'
    idVitalidade = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    nutricao = Column(Integer, default=100)
    hidratacao = Column(Integer, default=100)
    stamina = Column(Integer, default=100)
    calor = Column(Integer, default=50)
    dano = Column(Integer, default=0)
    personagem = relationship('Personagem', back_populates='vitalidade')

Personagem.vitalidade = relationship('Vitalidade', back_populates='personagem', uselist=False)

class Distrito(Base):
    __tablename__ = 'distrito'
    idDistrito = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    popularidade = Column(Integer, default=0)
    agilidade = Column(Integer)
    forca = Column(Integer)
    nado = Column(Integer)
    carisma = Column(Integer)
    combate = Column(Integer)
    pespicacia = Column(Integer)
    furtividade = Column(Integer)
    sobrevivencia = Column(Integer)
    precisao = Column(Integer)
    descricao = Column(Text, default='')
    personagem = relationship('Personagem', back_populates='distrito')

Personagem.distrito = relationship('Distrito', back_populates='personagem', uselist=False)

class Inventario(Base):
    __tablename__ = 'inventario'
    idInventario = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    capMax = Column(Integer, default=2)
    capAtual = Column(Integer, default=0)
    personagem = relationship('Personagem', back_populates='inventario')

Personagem.inventario = relationship('Inventario', back_populates='personagem', uselist=False)

# Criação das tabelas no banco de dados
Base.metadata.create_all(engine)

# Funções do jogo
class Game:
    def __init__(self, personagemId):
        self.personagemId = personagemId
        self.personagem = session.query(Personagem).filter_by(idPersonagem=personagemId).first()

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
    personagemId = int(input("Digite o ID do seu personagem: "))
    try:
        jogo = Game(personagemId)
        
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
