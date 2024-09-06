import os
import sqlalchemy
from sqlalchemy import create_engine, Table, Column, Integer, String, MetaData, ForeignKey, Text, Float, Boolean
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
import curses
import sys


# Configuração do banco de dados
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_URL = f"sqlite:///{os.path.join(BASE_DIR, 'dataa.db')}"

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()
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
    vitalidade = relationship('Vitalidade', back_populates='personagem', uselist=False)
    distrito = relationship('Distrito', back_populates='personagem', uselist=False)
    inventario = relationship('Inventario', back_populates='personagem', uselist=False)
    personagem_jogavel = relationship('PersonagemJogavel', back_populates='personagem', uselist=False)
    animal = relationship('Animal', back_populates='personagem', uselist=False)
    bestante = relationship('Bestante', back_populates='personagem', uselist=False)
    tributo = relationship('Tributo', back_populates='personagem', uselist=False)

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

class Inventario(Base):
    __tablename__ = 'inventario'
    idInventario = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    capMax = Column(Integer, default=2)
    capAtual = Column(Integer, default=0)
    personagem = relationship('Personagem', back_populates='inventario')
    itens = relationship('ItemInventario', back_populates='inventario')

class PersonagemJogavel(Base):
    __tablename__ = 'personagem_jogavel'
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'), primary_key=True)
    idDistrito = Column(Integer, ForeignKey('distrito.idDistrito'))
    personagem = relationship('Personagem', back_populates='personagem_jogavel')
    distrito = relationship('Distrito')

class Animal(Base):
    __tablename__ = 'animal'
    idAnimal = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    personagem = relationship('Personagem', back_populates='animal')

class Bestante(Base):
    __tablename__ = 'bestante'
    idBestante = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    agilidade = Column(Integer)
    nado = Column(Integer)
    voo = Column(Integer)
    personagem = relationship('Personagem', back_populates='bestante')

class Tributo(Base):
    __tablename__ = 'tributo'
    idTributo = Column(Integer, primary_key=True)
    idPersonagem = Column(Integer, ForeignKey('personagem.idPersonagem'))
    idDistrito = Column(Integer, ForeignKey('distrito.idDistrito'))
    statusT = Column(Boolean, default=False)
    personagem = relationship('Personagem', back_populates='tributo')
    distrito = relationship('Distrito')

class Item(Base):
    __tablename__ = 'item'
    idItem = Column(Integer, primary_key=True)
    nome = Column(String(50), nullable=False)
    vestimenta = relationship('Vestimenta', back_populates='item', uselist=False)
    arma = relationship('Arma', back_populates='item', uselist=False)
    consumivel = relationship('Consumivel', back_populates='item', uselist=False)
    legivel = relationship('Legivel', back_populates='item', uselist=False)
    compartimento = relationship('Compartimento', back_populates='item', uselist=False)
    utilidade = relationship('Utilidade', back_populates='item', uselist=False)
    construtor = relationship('Construtor', back_populates='item', uselist=False)

class ItemInventario(Base):
    __tablename__ = 'item_inventario'
    idItemInventario = Column(Integer, primary_key=True)
    idInventario = Column(Integer, ForeignKey('inventario.idInventario'))
    idItem = Column(Integer, ForeignKey('item.idItem'))
    inventario = relationship('Inventario', back_populates='itens')
    item = relationship('Item')

class Vestimenta(Base):
    __tablename__ = 'vestimenta'
    idVestimenta = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    descricao = Column(Text, default='')
    adCalor = Column(Integer, nullable=False)
    item = relationship('Item', back_populates='vestimenta')

class Arma(Base):
    __tablename__ = 'arma'
    idArma = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    descricao = Column(Text, default='')
    adDano = Column(Integer, nullable=False)
    item = relationship('Item', back_populates='arma')

class Consumivel(Base):
    __tablename__ = 'consumivel'
    idConsumivel = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    adHid = Column(Integer)
    adNut = Column(Integer)
    adSta = Column(Integer)
    adHp = Column(Integer)
    adCalor = Column(Integer)
    item = relationship('Item', back_populates='consumivel')

class Legivel(Base):
    __tablename__ = 'legivel'
    idLegivel = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    conteudo = Column(Text, default='')
    item = relationship('Item', back_populates='legivel')

class Compartimento(Base):
    __tablename__ = 'compartimento'
    idCompartimento = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    adCapMax = Column(Integer, nullable=False)
    item = relationship('Item', back_populates='compartimento')

class Utilidade(Base):
    __tablename__ = 'utilidade'
    idUtilidade = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    nome = Column(String(50), nullable=False)
    descricao = Column(Text, default='')
    geraItem = Column(Boolean, default=False)
    capturaInimigo = Column(Boolean, default=False)
    geraCalor = Column(Boolean, default=False)
    item = relationship('Item', back_populates='utilidade')

class Construtor(Base):
    __tablename__ = 'construtor'
    idConstrutor = Column(Integer, primary_key=True)
    idItem = Column(Integer, ForeignKey('item.idItem'))
    item = relationship('Item', back_populates='construtor')
# Criação das tabelas no banco de dados

Base.metadata.create_all(engine)

# try:
#     with engine.connect() as con:
#         con.execute(text("INSERT INTO personagem (idPersonagem, idSala, nomeP, hpMax, hpAtual) VALUES (1, 1, 'Personagem1', 100, 100);"))
#         con.execute(text("INSERT INTO mapa (nomeM, descricao) VALUES ('Mapa Central', 'O mapa principal do jogo.');"))
#         con.execute(text("INSERT INTO regiao (idMapa, nomeR, tempR, descricao) VALUES (1, 'Floresta', 22.5, 'Uma floresta densa e úmida.');"))
#         con.execute(text("INSERT INTO sala (idRegiao, nomeS, descricao) VALUES (1, 'Clareira', 'Uma clareira aberta no meio da floresta.');"))
#         con.execute(text("INSERT INTO personagem (idSala, tipoP, nomeP, hpMax, hpAtual) VALUES (1, 'Guerreiro', 'Arthas', 120, 120);"))
#         con.execute(text("INSERT INTO vitalidade (idPersonagem, nutricao, hidratacao, stamina, calor, dano) VALUES (1, 80, 90, 100, 50, 0);"))
#         con.execute(text("INSERT INTO distrito (idPersonagem, popularidade, agilidade, forca, nado, carisma, combate, pespicacia, furtividade, sobrevivencia, precisao, descricao) VALUES (1, 10, 8, 7, 6, 5, 7, 9, 6, 8, 7, 'Distrito especializado em sobrevivência.');"))
#         con.execute(text("INSERT INTO inventario (idPersonagem, capMax, capAtual) VALUES (1, 5, 2);"))
#         con.execute(text("INSERT INTO personagem_jogavel (idPersonagem, idDistrito) VALUES (1, 1);"))
#         con.execute(text("INSERT INTO animal (idPersonagem) VALUES (1);"))
#         con.execute(text("INSERT INTO bestante (idPersonagem, agilidade, nado, voo) VALUES (1, 10, 7, 0);"))
#         con.execute(text("INSERT INTO tributo (idPersonagem, idDistrito, statusT) VALUES (1, 1, TRUE);"))
#         con.execute(text("INSERT INTO item (nome) VALUES ('Espada');"))
#         con.execute(text("INSERT INTO item_inventario (idInventario, idItem) VALUES (1, 1);"))
#         con.execute(text("INSERT INTO vestimenta (idItem, descricao, adCalor) VALUES (1, 'Uma armadura resistente.', 15);"))
#         con.execute(text("INSERT INTO arma (idItem, descricao, adDano) VALUES (1, 'Uma espada afiada.', 20);"))
#         con.execute(text("INSERT INTO consumivel (idItem, adHid, adNut, adSta, adHp, adCalor) VALUES (1, 10, 5, 20, 15, 0);"))
#         con.execute(text("INSERT INTO legivel (idItem, conteudo) VALUES (1, 'Um antigo pergaminho com escrituras esquecidas.');"))
#         con.execute(text("INSERT INTO compartimento (idItem, adCapMax) VALUES (1, 10);"))
#         con.execute(text("INSERT INTO utilidade (idItem, nome, descricao, geraItem, capturaInimigo, geraCalor) VALUES (1, 'Kit de Sobrevivência', 'Um kit completo para sobrevivência.', TRUE, FALSE, TRUE);"))
#         con.execute(text("INSERT INTO construtor (idItem) VALUES (1);"))
#         con.commit()
        
# except Exception as e:
#     print(f"Erro ao inserir dados: {e}")
