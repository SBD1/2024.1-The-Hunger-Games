Tabelas de chaves e relacionamentos

### Personagem

| Campo         | Tipo   | Chave  |
|---------------|--------|--------|
| idPersonagem  | INT    | PK     |
| nome          | STRING | UNIQUE |
| gênero        | STRING |        |
| idade         | INT    |        |
| idDistrito    | INT    | FK     |
| sobrevivência | INT    |        |
| furtividade   | INT    |        |
| perspicácia   | INT    |        |
| carisma       | INT    |        |
| agilidade     | INT    |        |
| combate       | INT    |        |
| precisão      | INT    |        |
| nado          | INT    |        |
| força         | INT    |        |
| escalada      | INT    |        |

### Distrito

| Campo      | Tipo   | Chave  |
|------------|--------|--------|
| idDistrito | INT    | PK     |
| nome       | STRING | UNIQUE |

### Inventário

| Campo        | Tipo   | Chave  |
|--------------|--------|--------|
| idInventario | INT    | PK     |
| capMax       | INT    |        |

### Item

| Campo        | Tipo   | Chave  |
|--------------|--------|--------|
| idItem       | INT    | PK     |
| nome         | STRING | UNIQUE |
| tipoItem     | STRING |        |
| dano         | INT    |        |
| hidratação   | INT    |        |
| nutrição     | INT    |        |
| stamina      | INT    |        |
| popularidade | INT    |        |
| calor        | INT    |        |
| adCalor      | INT    |        |
| adDano       | INT    |        |
| adHid        | INT    |        |
| adNut        | INT    |        |
| adSta        | INT    |        |
| hpAtual      | INT    |        |
| adHp         | INT    |        |

### Mapa

| Campo  | Tipo   | Chave  |
|--------|--------|--------|
| idMapa | INT    | PK     |
| nome   | STRING | UNIQUE |

### Região

| Campo    | Tipo   | Chave  |
|----------|--------|--------|
| idRegiao | INT    | PK     |
| nome     | STRING | UNIQUE |
| idMapa   | INT    | FK     |

### Sala

| Campo    | Tipo   | Chave  |
|----------|--------|--------|
| idSala   | INT    | PK     |
| nome     | STRING | UNIQUE |
| idRegiao | INT    | FK     |

### Instância de Item

| Campo       | Tipo   | Chave  |
|-------------|--------|--------|
| idInstancia | INT    | PK     |
| idItem      | INT    | FK     |

### História

| Campo | Tipo   | Chave  |
|-------|--------|--------|
| idHis | INT    | PK     |
| nome  | STRING | UNIQUE |

### Capítulo

| Campo | Tipo   | Chave  |
|-------|--------|--------|
| idCap | INT    | PK     |
| nome  | STRING | UNIQUE |
| idHis | INT    | FK     |

### Decisão

| Campo      | Tipo   | Chave  |
|------------|--------|--------|
| idDec      | INT    | PK     |
| descrição  | STRING |        |
| idCap      | INT    | FK     |

### Animal

| Campo      | Tipo   | Chave  |
|------------|--------|--------|
| idInst     | INT    | PK     |
| Referencia | STRING | UNIQUE |
| hpMax      | INT    |        |
| fala       | STRING |        |
| descrição  | STRING |        |

## Relacionamento

### Personagem - Distrito
FK: idDistrito em Personagem referenciando idDistrito em Distrito

### Personagem - Inventário
FK: idInventario em Personagem referenciando idInventario em Inventário

### Inventário - Item
FK: idInventario em Item referenciando idInventario em Inventário

### Mapa - Região
FK: idMapa em Região referenciando idMapa em Mapa

### Região - Sala
FK: idRegiao em Sala referenciando idRegiao em Região

### Instância de Item - Personagem
FK: idPersonagem em Instância de Item referenciando idPersonagem em Personagem

### História - Capítulo
FK: idHis em Capítulo referenciando idHis em História

### Capítulo - Decisão
FK: idCap em Decisão referenciando idCap em Capítulo

### Animal - Instância de Item
FK: idInst em Instância de Item referenciando idInst em Animal
