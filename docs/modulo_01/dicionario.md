# Dicionário de dados

## Introdução
Um dicionário de dados consiste em um sistema integrado no banco de dados que visa fornecer uma descrição dos elementos usados no desenvolvimento do projeto. Segue o dicionário de dados do jogo "The Hunger Games":

### Tabela: Personagem

- Descrição da Tabela: Armazena informações sobre personagens jogáveis e não-jogáveis.

| Nome         | Descrição                            | Tipo de Dado | Chave | 
| ------------ | ------------------------------------ | ------------ | ----- | 
| idPersonagem | Identificação única do personagem    | Inteiro      | PK    | 
| nome         | Nome do personagem                   | Texto        |       | 
| gênero       | Gênero do personagem                 | Texto        |       | 
| idade        | Idade do personagem                  | Inteiro      |       | 
| idDistrito   | Distrito do personagem               | Inteiro      | FK    | 
| sobrevivência| Habilidade de sobrevivência          | Inteiro      |       | 
| furtividade  | Habilidade de furtividade            | Inteiro      |       | 
| perspicácia  | Habilidade de perspicácia            | Inteiro      |       | 
| carisma      | Habilidade de carisma                | Inteiro      |       | 
| agilidade    | Habilidade de agilidade              | Inteiro      |       | 
| combate      | Habilidade de combate                | Inteiro      |       | 
| precisão     | Habilidade de precisão               | Inteiro      |       | 
| nado         | Habilidade de nado                   | Inteiro      |       | 
| força        | Habilidade de força                  | Inteiro      |       | 
| escalada     | Habilidade de escalada               | Inteiro      |       | 
| idInventario | Inventário do personagem             | Inteiro      | FK    | 
| idHis        | História do personagem               | Inteiro      | FK    | 
| idCap        | Capítulo do personagem               | Inteiro      | FK    | 

### Tabela: Distrito

- Descrição da Tabela: Armazena informações sobre os distritos.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idDistrito | Identificação única      | Inteiro      | PK    | 
| nome       | Nome do distrito         | Texto        |       | 

### Tabela: Inventário

- Descrição da Tabela: Armazena informações sobre os inventários.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idInventario | Identificação única    | Inteiro      | PK    | 
| capMax     | Capacidade máxima        | Inteiro      |       | 

### Tabela: Instância de Item

- Descrição da Tabela: Armazena informações sobre instâncias de itens específicos.

| Nome        | Descrição                           | Tipo de Dado | Chave | 
| ----------- | ----------------------------------- | ------------ | ----- | 
| idInstancia | Identificação única da instância    | Inteiro      | PK    | 
| idItem      | Identificação do item               | Inteiro      | FK    | 

### Tabela: Item

- Descrição da Tabela: Armazena informações sobre itens gerais.

| Nome         | Descrição                           | Tipo de Dado | Chave | 
| ------------ | ----------------------------------- | ------------ | ----- | 
| idItem       | Identificação única do item         | Inteiro      | PK    | 
| nome         | Nome do item                        | Texto        |       | 
| tipoItem     | Tipo do item                        | Texto        |       | 
| dano         | Dano causado pelo item              | Inteiro      |       | 
| hidratação   | Hidratação fornecida pelo item      | Inteiro      |       | 
| nutrição     | Nutrição fornecida pelo item        | Inteiro      |       | 
| stamina      | Stamina fornecida pelo item         | Inteiro      |       | 
| popularidade | Popularidade do item                | Inteiro      |       | 
| calor        | Calor fornecido pelo item           | Inteiro      |       | 
| adCalor      | Adicional de calor do item          | Inteiro      |       | 
| adDano       | Adicional de dano do item           | Inteiro      |       | 
| adHid        | Adicional de hidratação do item     | Inteiro      |       | 
| adNut        | Adicional de nutrição do item       | Inteiro      |       | 
| adSta        | Adicional de stamina do item        | Inteiro      |       | 
| hpAtual      | HP atual do item                    | Inteiro      |       | 
| adHp         | Adicional de HP do item             | Inteiro      |       | 
| idInventario | Inventário que possui o item        | Inteiro      | FK    | 

### Tabela: Sala

- Descrição da Tabela: Armazena informações sobre salas.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idSala     | Identificação única      | Inteiro      | PK    | 
| nome       | Nome da sala             | Texto        |       | 
| idRegiao   | Região onde a sala está  | Inteiro      | FK    | 

### Tabela: Região

- Descrição da Tabela: Armazena informações sobre regiões.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idRegiao   | Identificação única      | Inteiro      | PK    | 
| nome       | Nome da região           | Texto        |       | 
| idMapa     | Mapa onde a região está  | Inteiro      | FK    | 

### Tabela: Mapa

- Descrição da Tabela: Armazena informações sobre mapas.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idMapa     | Identificação única      | Inteiro      | PK    | 
| nome       | Nome do mapa             | Texto        |       | 

### Tabela: Decisão

- Descrição da Tabela: Armazena informações sobre decisões.

| Nome       | Descrição                  | Tipo de Dado | Chave | 
| ---------- | -------------------------- | ------------ | ----- | 
| idDec      | Identificação única        | Inteiro      | PK    | 
| descrição  | Descrição da decisão       | Texto        |       | 
| idCap      | Capítulo da decisão        | Inteiro      | FK    | 
| idPersonagem | Personagem relacionado    | Inteiro      | FK    | 

### Tabela: Capítulo

- Descrição da Tabela: Armazena informações sobre capítulos.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idCap      | Identificação única      | Inteiro      | PK    | 
| nome       | Nome do capítulo         | Texto        |       | 
| idHis      | História do capítulo     | Inteiro      | FK    | 

### Tabela: História

- Descrição da Tabela: Armazena informações sobre a história.

| Nome       | Descrição                | Tipo de Dado | Chave | 
| ---------- | ------------------------ | ------------ | ----- | 
| idHis      | Identificação única      | Inteiro      | PK    | 
| nome       | Nome da história         | Texto        |       | 

### Tabela: Animal

- Descrição da Tabela: Armazena informações sobre animais.

| Nome         | Descrição                            | Tipo de Dado | Chave | 
| ------------ | ------------------------------------ | ------------ | ----- | 
| idInst       | Identificação única da instância     | Inteiro      | PK    | 
| Referencia   | Referência do animal                 | Texto        |       | 
| hpMax        | HP máximo do animal                  | Inteiro      |       | 
| fala         | Fala do animal                       | Texto        |       | 
| descrição    | Descrição do animal                  | Texto        |       | 
| idMapa       | Mapa onde o animal está              | Inteiro      | FK    | 
