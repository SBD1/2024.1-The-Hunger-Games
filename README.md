# Grupo - The Hunger Games

<div align="center">

<div align="center"><img src= "https://vgboxart.com/resources/logo/2407_the-hunger-games-prev.png" height="230" width="auto"/></div>

</div>

## Alunos

| Nome                             | Matrícula | Github                                         |
| -------------------------------- | --------- | ---------------------------------------------- |
| Natália Rodrigues de Morais      | 221037975 | [Natyrodrigues](https://github.com/Natyrodrigues) |
| Gabriel Santos Monteiro          | 221021975 | [GabrielSMonteiro](https://github.com/GabrielSMonteiro) |


## Sobre

<div align="center"><img src= "https://giffiles.alphacoders.com/923/9238.gif" height="230" width="auto"/></div>

The Hunger Games é um RPG imersivo ambientado em um universo distópico. Neste jogo, você entra em um mundo de competição feroz e sobrevivência, onde cada decisão pode ser a diferença entre a vida e a morte.

Você assume o papel de um tributo, competindo em desafios e batalhas enquanto explora um ambiente rico e perigoso. Forme alianças com companheiros, enfrente bestantes e lute contra tributos rivais. Com habilidades únicas baseadas em seu distrito e a capacidade de adaptar suas estratégias, você deve usar todos os recursos disponíveis para sair vitorioso.

# Apresentações

- [MÓDULO 1](https://youtu.be/5YzNXej9BE8?si=OnlFL7Rn5b7EIj5Y)
- [MÓDULO 2](https://youtu.be/OgMNaJGtN2w)

# Entregas

| MÓDULO 1                                  | MÓDULO 2                                                         |
|-------------------------------------------|------------------------------------------------------------------|
| [DER](docs/modulo_01/DER.md)              |         [DDL](docs/modulo_02/DDL.md)                             |
| [MERV](docs/modulo_01/MERV.md)            |         [DML](docs/modulo_02/DML.md)                             |
| [Dicionário](docs/modulo_01/dicionario.md)|         [DQL](docs/modulo_02/DQL.md)                             |

# Como rodar o jogo

O jogo precisa de 'psycopg2' 'colorama' 'pygame' para funcionar, para instalar ultilize o arquivo 'requirements.txt'

Adicionar um servidor PostgreSQL:

- No PGAdmin, clique em "Adicionar Novo Servidor".
- Em "General", insira um nome para o servidor: `hunger_games`.
- Em "Conexão", configure as seguintes informações:
  - Hostname/address: `postgres`.
  - Port: `5432`
  - Username: `postgres`
  - Password: `20082003`
-  Depois de preencher essas informações, clique em "Salvar".

Rode o código normalmente.

