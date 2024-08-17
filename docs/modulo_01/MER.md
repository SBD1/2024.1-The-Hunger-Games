### Versionamento

| Versão | Data       | Modificação                                                                              | Autor                               |
| ------ | ---------- | ---------------------------------------------------------------------------------------- | ----------------------------------- |
| 0.0    | 19/07/2024 | Criação do Documento                                                                     | Natália Rodrigues                   |
| 1.0    | 21/07/2024 | Adição da versão 1.0                                                                     | Natália Rodrigues, Gabriel Monteiro |

# Modelo Entidade-Relacionamento

O Modelo Entidade-Relacionamento (MER) é uma metodologia de modelagem de dados usada para descrever a estrutura lógica dos bancos de dados, abaixo segue o DER - Diagrama Entidade-Relacionamento - de acordo com o jogo "The Hunger Games"

### DER

Um diagrama de entidade e relacionamento (ER) é uma ferramenta usada na modelagem de banco de dados para representar visualmente a estrutura de um sistema e suas relações. Ele ajuda a entender e planejar como os dados serão organizados e relacionados dentro de um banco de dados.

<div align="center">
    <img src="/modulo_01/assets/DER.png">
</div>

## Entidades

- Personagem
- Personagem jogável
- Personagem não-jogável
- Bestante
- Tributo
- Inventário
- Sala
- Região
- Mapa
- Item
- Arma
- Vestimenta
- Construtor
- Consumível
- Utilidade
- Legível
- Instância
- História
- Capítulo
- Decisão
- Animal
- Companheiro
- Inimigo
- Instância Animal
- Compartimento

## Atributos

- Personagem: nome, idPersonagem, gênero, idade, idDistrito, sobrevivência, furtividade, perspicácia, carisma, agilidade, combate, precisão, nado, força, escalada
- Bestante: agilidade, nado, escalada, voo, hpMax, fala, descrição
- Inventário: idinventario, capMax
- Sala: idsala, nome, idregiao
- Região: idregiao, nome, idmapa
- Mapa: idmapa, nome
- Item: iditem, tipoP, descrição, dano, hidratação, nutrição, stamina, popularidade, calor, adCalor, adDano
- Construtor: adHid, adNut
- Consumível: adCalor, adHp, adSta
- Instância: idInst
- História: idHis, nome
- Capítulo: idCap, nome
- Decisão: idDec, descrição
- Instância Animal: idInst, Referencia
- Compartimento: adCapMax

## Associações

- Personagem possui Distrito (1,1)(1,n)
- Personagem possui Inventário (1,1) (n,1)
- Sala contém Região (1,1)(1,n)
- Região contém Mapa (1,N)(1,1)
- Região contém Sala (1,N)
- Item contém Instância (1,1)(1,M)
- Item possui Tipo (T, E)
- História possui Capítulo (1,1)(1,N)
- História possui Decisão (1,1)
- Decisão acompanha (1,1)(1,N)
- Animal possui Companheiro (T, E)
- Animal possui Inimigo (T, E)
- Tributo pode virar Companheiro (T, E)
- Companheiro pode virar Tributo (T, E)
- Animal ataca (N,1)(1,N)
