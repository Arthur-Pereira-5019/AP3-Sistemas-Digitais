# AP3-05235A-Grupo-A

## Integrantes do grupo:
 - Pedro Ferrari Barbosa
 - Samuel Schlemper
 - Pedro Mader Ebone
 - Rumenigue de Candio Fagundes
 - Bruno Peplau Mendes
 - Arthur Pereira
 - Márcio Schwarz Rezende 
 - Marco Antonio Molin Dagostini
 
## Descrição do problema:
No contexto de desenvolvimentos de jogos, não é incomum o problema de encontrar a colisão entre hitboxes (caixas de colisão), por vezes, simplificadas para um conjunto de paralelepípedos que envolvem o objeto. Embora atualmente existam diversas técnicas para fazer tal análise, processamentos constantes e repetitivos podem facilmente aumentar a necessidade de processamento do jogo e isso pode ser causado por programadores inexperientes, erros e alucinações de LLMs utilizadas para gerar código, falhas de otimização de Game Engines ou mesmo por jogos com físicas factualmente complexas e dinâmicas. Pensamos, portanto, em projetar um bloco acelerador que verifica a colisão entre duas hitboxes, retornando a primeira intersecção encontrada entre elas. \
\
O sistema opera por intermédio da leitura de duas memórias A e B que representam as zonas de colisão distintas, onde cada linha contém um vértice (triplas de números de pontos flutuantes de 24 bits concatenadas) de uma das formas geométricas que compõem a caixa de colisão. O sistema trabalha com formas sem rotação, isto é, paralelas aos eixos canônicos XY, YZ e ZX e que possam ser representadas por dois vértices extremos, o que permite então paralelepípedos (em especial cubos), planos, retas e vértices. Portanto, são necessárias duas linhas de uma memória para representar uma forma geométrica. Após a leitura, o sistema valida se o primeiro vértice tem suas componentes iguais ou maiores que o do segundo vértice, para facilitar o processamento subsequente. Após isso, o sistema passa a então iterar todas as formas de A contra as formas de B (a cada nova leitura, uma nova validação), a fim de encontrar a primeira colisão entre as hitboxes, retornando então um sinal que representa a forma e os vértices que compõem ela, encerrando a execução. Esse processo é repetido com base em sinais de inteiros informados ao sistema que indicam o número de colisões que devem ser testadas, evitando assim a leitura de lixo da memória ou de dados nulos, que poderiam ser interpretados como vértices na origem do espaço. Caso não haja colisão, o sistema se encerra informando que não houve colisão.

### Evolução e mudanças
Da primeira para a segunda entrega, amadurecemos em muito o projeto como um todo, criamos um Project no Github para organização de tarefas, buscamos otimizar os pseudocódigos, inclusive chegamos a disponibilizar um pequeno artigo no site [Wikibooks com o fundamento matemático e a implementação do algoritmo de colisão](https://pt.wikibooks.org/wiki/Guia_de_problemas_matem%C3%A1ticos/Geometria_s%C3%B3lida/Intersec%C3%A7%C3%A3o_entre_dois_paralelep%C3%ADpedos): 
Também notamos que não seria mais necessário oito vértices para fazer o processamento como acreditávamos na primeira entrega, mas sim apenas dois, simplificando processamento, diagramação, validação e organização de recursos, permitindo o simples e eficaz algoritmo supracitado, além da evolução de podermos trabalhar com formas mais simples que os paralelepípedos. Essa mudança também permitiu uma melhor estruturação da saída, que tínhamos como plano inicial utilizar oito saídas, uma para cada vértice da saída, que forçaria repetição ou saídas inúteis em caso de colisões com forma de dimensão inferior a 3. \
\
Durante a segunda etapa, cogitamos ter uma funcionalidade para remover a necessidade de um sinal de erro, que "consertaria" vértices mal ordenados ou informados, mas devido ao desenrolar do desenvolvimento, decidimos postergar essa decisão como mudança incremental ao sistema em caso de um bom andamento da terceira entrega. \
\
Nessa fase também desenvolvemos alguns casos de testes para agilizar o processo de simulação da segunda fase e após devido estudo do algoritmo de colsisão, utilizamos uma última validação com uso de LLMs, a fim de garantir a eficácia da solução antes de projetarmos o diagrama. O diagrama por sua vez, foi projetado na ferramenta draw.io. Buscamos nos inspirar nas etapas sugeridas pelo professor Güntzel em relação ao projeto do BO/BC. Pseudocódigo do algoritmo, elaboração da FSMD, criação do Datapath, desenvolvimento da FSM e por fim desenvolvimento do bloco BO/BC.