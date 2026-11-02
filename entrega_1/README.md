# AP3-05235A-Grupo-A

## integrantes do grupo:
 - Pedro Ferrari Barbosa
 - Samuel Schlemper
 - Pedro Mader Ebone
 - Rumenigue de Candio Fagundes
 - Bruno Peplau Mendes
 - Arthur Pereira
 - Márcio Schwarz Rezende 
 - Marco Antonio Molin Dagostini
 
## descrição do problema:
No contexto de desenvolvimentos de jogos, não é incomum o problema de encontrar a colisão entre dois paralelepípedos. Embora atualmente existam diversas técnicas para fazer tal análise, processamentos constantes e repetitivos podem facilmente aumentar a necessidade de processamento do jogo, seja por programadores inexperientes, erros e alucinações de LLMs utilizadas para gerar código, falhas de otimização de Game Engines ou mesmo por jogos factualmente com físicas complexas e dinâmicas. Pensamos, portanto, em projetar um bloco acelerador que verifica a colisão entre dois paralelepípedos, retornando os pontos de intersecção.
O sistema proposto funcionaria lendo de uma memória uma lista de coordenadas tridimensionais de ponto flutuante dos vértices compondo os paralelepípedos das duas zonas de colisão a serem testadas e após informados todos os pontos, realizaria o cálculo da colisão. Caso um paralelepípedo inválido fosse informado na memória, o circuito retornaria um sinal de erro. A saída esperada do sistema será se houve ou não colisão e os vértices da forma gerada pela colisão das duas formas geométricas, repetindo coordenadas em caso da colisão gerar uma forma de dimensão inferior a tridimensional.
