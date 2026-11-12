library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.float_pkg.all; -- Biblioteca de float, precisa do VHDL 2008 no quartus
 
entity testbench is
end testbench; 

architecture tb of testbench is

signal NA: std_logic_vector(9 DOWNTO 0);
signal NB: std_logic_vector(9 DOWNTO 0);

signal AV: std_logic_vector(71 DOWNTO 0);
signal BV: std_logic_vector(71 DOWNTO 0);

signal RST: std_logic;
signal Setup: std_logic;
signal CLK: std_logic;

--Saidas

signal C1: std_logic_vector(71 downto 0);
signal C2: std_logic_vector(71 downto 0);

signal PA: std_logic_vector(9 downto 0);
signal PB: std_logic_vector(9 downto 0);

signal Shape: std_logic_vector(2 downto 0);

signal Read: std_logic;
signal Erro: std_logic;
signal Finish: std_logic;

CONSTANT passo : TIME := <Tempo do projeto> ns;  

CONSTANT exp : INTEGER := 8; 
CONSTANT matice : INTEGER := 15;    

begin

  DUV: entity work.<Nome VHDL>
    port map(
    -- Entradas
    NA,
    NB,
    AV,
    BV,
    RST,
    Setup,
    CLK,
   
    
    -- Saidas
    C1,
    C2,
    PA,
    PB,
    Shape,
    Read,
    Erro,
    Finish);

  process
  begin
    -- 1. Reset inicial ("Wait Start")
    NA <= std_logic_vector(to_unsigned(2, NA'length));
    NB <= std_logic_vector(to_unsigned(2, NB'length));
    AV <= (others => '0');
    BV <= (others => '0');

    RST <= '1';
    Setup <= '0';
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 2. Estado de Setup (carrega PA=2 e PB=2)
    RST <= '0';
    Setup <= '1';
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 3. Vai para "Read Vertex 1" e fornece (-2.5, 0.0, 4.2)
    Setup <= '0';
    AV <= to_slv(to_float(-2.5, exp, mantice)) & to_slv(to_float(0.0, exp, mantice)) & to_slv(to_float(4.2, exp, mantice));
    BV <= to_slv(to_float(-2.5, exp, mantice)) & to_slv(to_float(0.0, exp, mantice)) & to_slv(to_float(4.2, exp, mantice));
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 4. Forcene o vértice 
    AV <= to_slv(to_float(5.0, exp, mantice)) & to_slv(to_float(8.5, exp, mantice)) & to_slv(to_float(10.0, exp, mantice));
    BV <= to_slv(to_float(5.0, exp, mantice)) & to_slv(to_float(8.5, exp, mantice)) & to_slv(to_float(10.0, exp, mantice));
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 5. Verificação do vertice B
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 6. Load nos Regs C
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 7. Teste de colisoes
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    -- 8. Passa do test collision para o wait
    CLK <= '0';
    wait for passo;
    CLK <= '1';
    wait for passo;

    assert(
    C1     = to_slv(to_float(5.0, exp, mantice)) & to_slv(to_float(8.5, exp, mantice)) & to_slv(to_float(10.0, exp, mantice)) and
    C2     = to_slv(to_float(-2.5, exp, mantice)) & to_slv(to_float(0.0, exp, mantice)) & to_slv(to_float(4.2, exp, mantice)) and
    PA     = "0000000000" and
    PB     = "0000000000" and
    Shape  = "000"        and
    Read   = '0'          and
    Erro   = '0'          and
    Finish = '1'
    ) 
    report "Teste dois identicos falhou" severity error;

    wait for passo;
    assert false report "Teste dois identicos feito." severity note;
    -- =========================================================================
    -- CASO 2: Colisao Parcial 3D (Intersecao de dois cubos -> Shape "000")
    -- A: (0,0,0) a (4,4,4) | B: (2,2,2) a (6,6,6) -> Intersecao: (2,2,2) a (4,4,4)
    -- =========================================================================
    NA <= std_logic_vector(to_unsigned(2, NA'length));
    NB <= std_logic_vector(to_unsigned(2, NB'length));
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice));
    BV <= to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Load C
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Test Collision
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Wait Start

    assert(
      C1 = to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) and
      C2 = to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 2 (Colisao parcial 3D) falhou" severity error;

    -- =========================================================================
    -- CASO 3: B totalmente dentro de A (Shape "000")
    -- A: (-10,-10,-10) a (10,10,10) | B: (-1,-2,-3) a (1,2,3)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(-10.0, exp,  mantice)) & to_slv(to_float(-10.0, exp,  mantice)) & to_slv(to_float(-10.0, exp,  mantice));
    BV <= to_slv(to_float(-1.0, exp,  mantice))  & to_slv(to_float(-2.0, exp,  mantice))  & to_slv(to_float(-3.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice));
    BV <= to_slv(to_float(1.0, exp,  mantice))  & to_slv(to_float(2.0, exp,  mantice))  & to_slv(to_float(3.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(1.0, exp,  mantice))  & to_slv(to_float(2.0, exp,  mantice))  & to_slv(to_float(3.0, exp,  mantice)) and
      C2 = to_slv(to_float(-1.0, exp,  mantice)) & to_slv(to_float(-2.0, exp,  mantice)) & to_slv(to_float(-3.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 3 (B dentro de A) falhou" severity error;

    -- =========================================================================
    -- CASO 4: A totalmente dentro de B (Shape "000")
    -- A: (1.5, 2.5, 3.5) a (4.5, 5.5, 6.5) | B: (0,0,0) a (10,10,10)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(1.5, exp,  mantice)) & to_slv(to_float(2.5, exp,  mantice)) & to_slv(to_float(3.5, exp,  mantice));
    BV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(4.5, exp,  mantice)) & to_slv(to_float(5.5, exp,  mantice)) & to_slv(to_float(6.5, exp,  mantice));
    BV <= to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(4.5, exp,  mantice)) & to_slv(to_float(5.5, exp,  mantice)) & to_slv(to_float(6.5, exp,  mantice)) and
      C2 = to_slv(to_float(1.5, exp,  mantice)) & to_slv(to_float(2.5, exp,  mantice)) & to_slv(to_float(3.5, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 4 (A dentro de B) falhou" severity error;

    -- =========================================================================
    -- CASO 5: Colisao de Plano YZ (Encostam na face X = 5.0 -> Shape "001")
    -- A: (0,0,0) a (5,4,4) | B: (5,1,1) a (exp3,3) -> C1=(5,3,3), C2=(5,1,1)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice));
    BV <= to_slv(to_float(8.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) and
      C2 = to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "001" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 5 (Colisao Plano YZ) falhou" severity error;

    -- =========================================================================
    -- CASO 6: Colisao de Plano XZ (Encostam na face Y = 2.0 -> Shape "001")
    -- A: (0,0,0) a (6,2,6) | B: (1,2,2) a (4,5,5) -> C1=(4,2,5), C2=(1,2,2)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice));
    BV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) and
      C2 = to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "001" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 6 (Colisao Plano XZ) falhou" severity error;

    -- =========================================================================
    -- CASO 7: Colisao de Reta paralela ao eixo Z (Encostam em X=3 e Y=3 -> Shape "010")
    -- A: (0,0,0) a (3,3,8) | B: (3,3,2) a (6,6,6) -> C1=(3,3,6), C2=(3,3,2)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(8.0, exp,  mantice));
    BV <= to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice)) and
      C2 = to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "010" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 7 (Colisao Reta Z) falhou" severity error;

    -- =========================================================================
    -- CASO 8: Colisao de Reta paralela ao eixo X (Encostam em Y=0 e Z=0 -> Shape "010")
    -- A: (-4,-2,-2) a (4,0,0) | B: (-1,0,0) a (2,3,3) -> C1=(2,0,0), C2=(-1,0,0)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(-4.0, exp,  mantice)) & to_slv(to_float(-2.0, exp,  mantice)) & to_slv(to_float(-2.0, exp,  mantice));
    BV <= to_slv(to_float(-1.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(2.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) and
      C2 = to_slv(to_float(-1.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "010" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 8 (Colisao Reta X) falhou" severity error;

    -- =========================================================================
    -- CASO 9: Colisao de Vertice/Ponto Unico (Tocam apenas na quina (2,2,2) -> Shape "011")
    -- A: (0,0,0) a (2,2,2) | B: (2,2,2) a (5,5,5) -> C1=(2,2,2), C2=(2,2,2)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    BV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      C1 = to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      C2 = to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "011" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 9 (Colisao Vertice) falhou" severity error;

    -- =========================================================================
    -- CASO 10: Sem Colisao (Separados no eixo X -> Shape "100")
    -- A: (0,0,0) a (2,2,2) | B: (3,0,0) a (5,2,2)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    BV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      PA = "0000000000" and PB = "0000000000" and Shape = "100" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 10 (Sem Colisao eixo X) falhou" severity error;

    -- =========================================================================
    -- CASO 11: Sem Colisao com coordenadas negativas (Separados em Z -> Shape "100")
    -- A: (-10,-10,-10) a (-5,-5,-5) | B: (-exp-exp-4.5) a (-2,-2,-1)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(-10.0, exp,  mantice)) & to_slv(to_float(-10.0, exp,  mantice)) & to_slv(to_float(-10.0, exp,  mantice));
    BV <= to_slv(to_float(-8.0, exp,  mantice))  & to_slv(to_float(-8.0, exp,  mantice))  & to_slv(to_float(-4.5, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    AV <= to_slv(to_float(-5.0, exp,  mantice)) & to_slv(to_float(-5.0, exp,  mantice)) & to_slv(to_float(-5.0, exp,  mantice));
    BV <= to_slv(to_float(-2.0, exp,  mantice)) & to_slv(to_float(-2.0, exp,  mantice)) & to_slv(to_float(-1.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    assert(
      PA = "0000000000" and PB = "0000000000" and Shape = "100" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 11 (Sem Colisao negativo) falhou" severity error;

    -- =========================================================================
    -- CASO 12: Erro na validacao de A (AV2 < AV1 -> Vai direto para estado Error)
    -- A1: (5,5,5) e A2: (2,5,5) [Invalido!]
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    AV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice));
    BV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Read Vertex 1

    AV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice));
    BV <= to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Read Vertex 2 -> Verify A

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify A detecta Error -> Error state

    assert(
      Erro = '1' and Finish = '1' and Read = '0'
    ) report "Caso 12 (Erro em A) falhou" severity error;

    -- =========================================================================
    -- CASO 13: Erro na validacao de B (BV2 < BV1 -> Sai de Error via Setup='1')
    -- A valido: (0,0,0) a (5,5,5) | B invalido: B1=(4,4,4) e B2=(4,1,4)
    -- =========================================================================
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Sai de Error -> Setup

    Setup <= '0';
    AV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Read Vertex 1

    AV <= to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice)) & to_slv(to_float(5.0, exp,  mantice));
    BV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Read Vertex 2 -> Verify A

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify A OK -> Verify B
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B detecta Error -> Error state

    assert(
      Erro = '1' and Finish = '1' and Read = '0'
    ) report "Caso 13 (Erro em B) falhou" severity error;

    -- =========================================================================
    -- CASO 14: Iteracao com 2 formas em B (NA=2, NB=4): 1a forma de B nao colide, 2a colide!
    -- A1: (0,0,0)-(2,2,2) | B_forma1: (10,10,10)-(12,12,12) | B_forma2: (1,1,1)-(3,3,3)
    -- =========================================================================
    NA <= std_logic_vector(to_unsigned(2, NA'length));
    NB <= std_logic_vector(to_unsigned(4, NB'length));
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Error -> Setup

    Setup <= '0';
    -- Leitura inicial (A1 e B_forma1_v1)
    AV <= to_slv(to_float(0.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice));
    BV <= to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice)) & to_slv(to_float(10.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    -- Leitura 2 (A2 e B_forma1_v2)
    AV <= to_slv(to_float(2.0, exp,  mantice))  & to_slv(to_float(2.0, exp,  mantice))  & to_slv(to_float(2.0, exp,  mantice));
    BV <= to_slv(to_float(12.0, exp,  mantice)) & to_slv(to_float(12.0, exp,  mantice)) & to_slv(to_float(12.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Load C
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Test Collision (falha, MB='1')
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Vai para Get BV1

    -- Fornece B_forma2_v1 = (1,1,1)
    BV <= to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Get BV1 -> Get BV2

    -- Fornece B_forma2_v2 = (3,3,3)
    BV <= to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice)) & to_slv(to_float(3.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Get BV2 -> Verify B

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B -> Load C
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Load C -> Test Collision
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Test Collision (colide!) -> Wait Start

    assert(
      C1 = to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      C2 = to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) & to_slv(to_float(1.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 14 (Iteracao 2 formas em B) falhou" severity error;

    -- =========================================================================
    -- CASO 15: Iteracao com 2 formas em A e 1 em B (NA=4, NB=2): 1a de A nao colide, 2a colide!
    -- A_forma1: (20,20,20)-(25,25,25) | B: (0,0,0)-(4,4,4) | A_forma2: (2,2,2)-(6,6,6)
    -- =========================================================================
    NA <= std_logic_vector(to_unsigned(4, NA'length));
    NB <= std_logic_vector(to_unsigned(2, NB'length));
    Setup <= '1';
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    Setup <= '0';
    -- Leitura 1 (A_forma1_v1 e B1)
    AV <= to_slv(to_float(20.0, exp,  mantice)) & to_slv(to_float(20.0, exp,  mantice)) & to_slv(to_float(20.0, exp,  mantice));
    BV <= to_slv(to_float(0.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice))  & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    -- Leitura 2 (A_forma1_v2 e B2)
    AV <= to_slv(to_float(25.0, exp,  mantice)) & to_slv(to_float(25.0, exp,  mantice)) & to_slv(to_float(25.0, exp,  mantice));
    BV <= to_slv(to_float(4.0, exp,  mantice))  & to_slv(to_float(4.0, exp,  mantice))  & to_slv(to_float(4.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Load C
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Test Collision (falha, MB='0', MA='1')
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Vai para Next A (reseta PB=2)

    -- Next A -> Read Vertex 1 (A_forma2_v1 = (2,2,2), B1 = (0,0,0))
    AV <= to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice));
    BV <= to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice)) & to_slv(to_float(0.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    -- Read Vertex 1 -> Read Vertex 2 (A_forma2_v2 = (6,6,6), B2 = (4,4,4))
    AV <= to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice)) & to_slv(to_float(6.0, exp,  mantice));
    BV <= to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice));
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo;

    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Verify B
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Load C
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Test Collision (colide!)
    CLK <= '0'; wait for passo; CLK <= '1'; wait for passo; -- Wait Start

    assert(
      C1 = to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) & to_slv(to_float(4.0, exp,  mantice)) and
      C2 = to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) & to_slv(to_float(2.0, exp,  mantice)) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and Read = '0' and Erro = '0' and Finish = '1'
    ) report "Caso 15 (Iteracao 2 formas em A) falhou" severity error;

    wait for passo;
    assert false report "Todos os 15 testes concluidos!" severity note;
    wait;
  end process;
end tb;
