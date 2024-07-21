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
