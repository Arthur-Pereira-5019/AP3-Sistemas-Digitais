library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.float_pkg.all; -- Biblioteca de float (requer VHDL-2008 no Quartus/ModelSim/GHDL)
use work.float_config;

entity testbench is
end testbench;

architecture tb of testbench is

  -- Parametros de ponto flutuante (sincronizados com float_config.vhd)
  constant EXP_W  : positive := float_config.EXP_W;
  constant FRAC_W : positive := float_config.FRAC_W;

  -- Meio periodo de clock (ajustar conforme periodo critico sintetizado no projeto)
  constant passo : time := 10 ns;

  -- Entradas do sistema
  signal NA    : std_logic_vector(9 downto 0)  := (others => '0');
  signal NB    : std_logic_vector(9 downto 0)  := (others => '0');
  signal AV    : std_logic_vector(71 downto 0) := (others => '0');
  signal BV    : std_logic_vector(71 downto 0) := (others => '0');
  signal RST   : std_logic := '1';
  signal Setup : std_logic := '0';
  signal CLK   : std_logic := '0';

  -- Saidas do sistema
  signal C1      : std_logic_vector(71 downto 0);
  signal C2      : std_logic_vector(71 downto 0);
  signal PA      : std_logic_vector(9 downto 0);
  signal PB      : std_logic_vector(9 downto 0);
  signal Shape   : std_logic_vector(2 downto 0);
  signal ReadV   : std_logic;
  signal ErroV   : std_logic;
  signal FinishV : std_logic;

  -- Funcao auxiliar: empacota 3 coordenadas reais em vetor de 72 bits (3 x float 24 bits)
  function vec3(x, y, z : real) return std_logic_vector is
    variable res : std_logic_vector(71 downto 0);
  begin
    res := to_slv(to_float(x, EXP_W, FRAC_W)) &
           to_slv(to_float(y, EXP_W, FRAC_W)) &
           to_slv(to_float(z, EXP_W, FRAC_W));
    return res;
  end function;

begin

  DUV : entity work.top_level
    generic map (
      EXP_W  => EXP_W,
      FRAC_W => FRAC_W
    )
    port map (
      -- Entradas
      NA      => NA,
      NB      => NB,
      AV      => AV,
      BV      => BV,
      RST     => RST,
      Setup   => Setup,
      CLK     => CLK,
      -- Saidas
      C1      => C1,
      C2      => C2,
      PA      => PA,
      PB      => PB,
      Shape   => Shape,
      ReadV   => ReadV,
      ErroV   => ErroV,
      FinishV => FinishV
    );

  process
    procedure tick is
    begin
      CLK <= '0';
      wait for passo;
      CLK <= '1';
      wait for passo;
    end procedure;
  begin
    -- =========================================================================
    -- Reset inicial ("WAIT_START")
    -- =========================================================================
    NA    <= std_logic_vector(to_unsigned(2, NA'length));
    NB    <= std_logic_vector(to_unsigned(2, NB'length));
    AV    <= (others => '0');
    BV    <= (others => '0');
    RST   <= '1';
    Setup <= '0';
    tick;

    assert (FinishV = '1' and ErroV = '0' and ReadV = '0')
      report "Reset inicial falhou" severity error;

    -- =========================================================================
    -- CASO 1: Dois paralelepipedos identicos (Shape "000")
    -- A e B: V1=(5.0, 8.5, 10.0), V2=(-2.5, 0.0, 4.2)
    -- =========================================================================
    RST   <= '0';
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1 (carrega PA=2, PB=2, C1=0, C2=0)

    AV <= vec3(5.0, 8.5, 10.0);
    BV <= vec3(5.0, 8.5, 10.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2 (carrega AV1, BV1)

    AV <= vec3(-2.5, 0.0, 4.2);
    BV <= vec3(-2.5, 0.0, 4.2);
    tick; -- READ_VERTEX_2 -> VERIFY_A (carrega AV2, BV2)

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1      = vec3(5.0, 8.5, 10.0) and
      C2      = vec3(-2.5, 0.0, 4.2) and
      PA      = "0000000000"         and
      PB      = "0000000000"         and
      Shape   = "000"                and
      ReadV   = '0'                  and
      ErroV   = '0'                  and
      FinishV = '1'
    ) report "Caso 1 (Dois identicos) falhou" severity error;
    report "Caso 1 (Dois identicos) concluido." severity note;

    -- =========================================================================
    -- CASO 2: Colisao Parcial 3D (Intersecao de dois cubos -> Shape "000")
    -- A: V1=(4,4,4), V2=(0,0,0) | B: V1=(6,6,6), V2=(2,2,2)
    -- Intersecao: C1=(4,4,4), C2=(2,2,2)
    -- =========================================================================
    NA    <= std_logic_vector(to_unsigned(2, NA'length));
    NB    <= std_logic_vector(to_unsigned(2, NB'length));
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(4.0, 4.0, 4.0);
    BV <= vec3(6.0, 6.0, 6.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(2.0, 2.0, 2.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(4.0, 4.0, 4.0) and
      C2 = vec3(2.0, 2.0, 2.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 2 (Colisao parcial 3D) falhou" severity error;

    -- =========================================================================
    -- CASO 3: B totalmente dentro de A (Shape "000")
    -- A: V1=(10,10,10), V2=(-10,-10,-10) | B: V1=(1,2,3), V2=(-1,-2,-3)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(10.0, 10.0, 10.0);
    BV <= vec3(1.0, 2.0, 3.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(-10.0, -10.0, -10.0);
    BV <= vec3(-1.0, -2.0, -3.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(1.0, 2.0, 3.0)    and
      C2 = vec3(-1.0, -2.0, -3.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 3 (B dentro de A) falhou" severity error;

    -- =========================================================================
    -- CASO 4: A totalmente dentro de B (Shape "000")
    -- A: V1=(4.5,5.5,6.5), V2=(1.5,2.5,3.5) | B: V1=(10,10,10), V2=(0,0,0)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(4.5, 5.5, 6.5);
    BV <= vec3(10.0, 10.0, 10.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(1.5, 2.5, 3.5);
    BV <= vec3(0.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(4.5, 5.5, 6.5) and
      C2 = vec3(1.5, 2.5, 3.5) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 4 (A dentro de B) falhou" severity error;

    -- =========================================================================
    -- CASO 5: Colisao de Plano YZ (Encostam na face X = 5.0 -> Shape "001")
    -- A: V1=(5,4,4), V2=(0,0,0) | B: V1=(8,3,3), V2=(5,1,1)
    -- Intersecao: C1=(5,3,3), C2=(5,1,1)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(5.0, 4.0, 4.0);
    BV <= vec3(8.0, 3.0, 3.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(5.0, 1.0, 1.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(5.0, 3.0, 3.0) and
      C2 = vec3(5.0, 1.0, 1.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "001" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 5 (Colisao Plano YZ) falhou" severity error;

    -- =========================================================================
    -- CASO 6: Colisao de Plano XZ (Encostam na face Y = 2.0 -> Shape "001")
    -- A: V1=(6,2,6), V2=(0,0,0) | B: V1=(4,5,5), V2=(1,2,2)
    -- Intersecao: C1=(4,2,5), C2=(1,2,2)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(6.0, 2.0, 6.0);
    BV <= vec3(4.0, 5.0, 5.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(1.0, 2.0, 2.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(4.0, 2.0, 5.0) and
      C2 = vec3(1.0, 2.0, 2.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "001" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 6 (Colisao Plano XZ) falhou" severity error;

    -- =========================================================================
    -- CASO 7: Colisao de Reta paralela ao eixo Z (X=3 e Y=3 -> Shape "010")
    -- A: V1=(3,3,8), V2=(0,0,0) | B: V1=(6,6,6), V2=(3,3,2)
    -- Intersecao: C1=(3,3,6), C2=(3,3,2)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(3.0, 3.0, 8.0);
    BV <= vec3(6.0, 6.0, 6.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(3.0, 3.0, 2.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(3.0, 3.0, 6.0) and
      C2 = vec3(3.0, 3.0, 2.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "010" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 7 (Colisao Reta Z) falhou" severity error;

    -- =========================================================================
    -- CASO 8: Colisao de Reta paralela ao eixo X (Y=0 e Z=0 -> Shape "010")
    -- A: V1=(4,0,0), V2=(-4,-2,-2) | B: V1=(2,3,3), V2=(-1,0,0)
    -- Intersecao: C1=(2,0,0), C2=(-1,0,0)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(4.0, 0.0, 0.0);
    BV <= vec3(2.0, 3.0, 3.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(-4.0, -2.0, -2.0);
    BV <= vec3(-1.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(2.0, 0.0, 0.0)  and
      C2 = vec3(-1.0, 0.0, 0.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "010" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 8 (Colisao Reta X) falhou" severity error;

    -- =========================================================================
    -- CASO 9: Colisao de Vertice/Ponto Unico (quina (2,2,2) -> Shape "011")
    -- A: V1=(2,2,2), V2=(0,0,0) | B: V1=(5,5,5), V2=(2,2,2)
    -- Intersecao: C1=(2,2,2), C2=(2,2,2)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(2.0, 2.0, 2.0);
    BV <= vec3(5.0, 5.0, 5.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(2.0, 2.0, 2.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      C1 = vec3(2.0, 2.0, 2.0) and
      C2 = vec3(2.0, 2.0, 2.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "011" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 9 (Colisao Vertice) falhou" severity error;

    -- =========================================================================
    -- CASO 10: Sem Colisao (Separados no eixo X -> Shape "100")
    -- A: V1=(2,2,2), V2=(0,0,0) | B: V1=(5,2,2), V2=(3,0,0)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(2.0, 2.0, 2.0);
    BV <= vec3(5.0, 2.0, 2.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(3.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      PA = "0000000000" and PB = "0000000000" and Shape = "100" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 10 (Sem Colisao eixo X) falhou" severity error;

    -- =========================================================================
    -- CASO 11: Sem Colisao com coordenadas negativas (Separados em Z -> Shape "100")
    -- A: V1=(-5,-5,-5), V2=(-10,-10,-10) | B: V1=(-2,-2,-1), V2=(-8,-8,-4.5)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(-5.0, -5.0, -5.0);
    BV <= vec3(-2.0, -2.0, -1.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(-10.0, -10.0, -10.0);
    BV <= vec3(-8.0, -8.0, -4.5);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION -> WAIT_START

    assert (
      PA = "0000000000" and PB = "0000000000" and Shape = "100" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 11 (Sem Colisao negativo) falhou" severity error;

    -- =========================================================================
    -- CASO 12: Erro na validacao de A (AV1 < AV2 -> Vai direto para ERROR_STATE)
    -- A invalido: AV1=(2,5,5) e AV2=(5,5,5) | B valido: BV1=(1,1,1) e BV2=(0,0,0)
    -- =========================================================================
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(2.0, 5.0, 5.0);
    BV <= vec3(1.0, 1.0, 1.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(5.0, 5.0, 5.0);
    BV <= vec3(0.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A detecta Error_BO='1' -> ERROR_STATE

    assert (
      ErroV = '1' and FinishV = '1' and ReadV = '0'
    ) report "Caso 12 (Erro em A) falhou" severity error;

    -- =========================================================================
    -- CASO 13: Erro na validacao de B (BV1 < BV2 -> Sai de ERROR_STATE via Setup='1')
    -- A valido: AV1=(5,5,5), AV2=(0,0,0) | B invalido: BV1=(4,1,4), BV2=(4,4,4)
    -- =========================================================================
    Setup <= '1';
    tick; -- ERROR_STATE -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1

    AV <= vec3(5.0, 5.0, 5.0);
    BV <= vec3(4.0, 1.0, 4.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2

    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(4.0, 4.0, 4.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A

    tick; -- VERIFY_A OK -> VERIFY_B
    tick; -- VERIFY_B detecta Error_BO='1' -> ERROR_STATE

    assert (
      ErroV = '1' and FinishV = '1' and ReadV = '0'
    ) report "Caso 13 (Erro em B) falhou" severity error;

    -- =========================================================================
    -- CASO 14: Iteracao com 2 formas em B (NA=2, NB=4)
    -- 1a forma de B nao colide, 2a colide!
    -- A: V1=(2,2,2), V2=(0,0,0)
    -- B_forma1: V1=(12,12,12), V2=(10,10,10) | B_forma2: V1=(3,3,3), V2=(1,1,1)
    -- =========================================================================
    NA    <= std_logic_vector(to_unsigned(2, NA'length));
    NB    <= std_logic_vector(to_unsigned(4, NB'length));
    Setup <= '1';
    tick; -- ERROR_STATE -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1 (carrega PA=2, PB=4)

    -- Leitura inicial (AV1 e B_forma1_v1)
    AV <= vec3(2.0, 2.0, 2.0);
    BV <= vec3(12.0, 12.0, 12.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2 (PA=1, PB=3)

    -- Leitura 2 (AV2 e B_forma1_v2)
    AV <= vec3(0.0, 0.0, 0.0);
    BV <= vec3(10.0, 10.0, 10.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A (PA=0, PB=2)

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION (nao colide, MB='1') -> FETCH_BV1

    -- Fornece B_forma2_v1 = (3,3,3)
    BV <= vec3(3.0, 3.0, 3.0);
    tick; -- FETCH_BV1 -> FETCH_BV2 (PB=1)

    -- Fornece B_forma2_v2 = (1,1,1)
    BV <= vec3(1.0, 1.0, 1.0);
    tick; -- FETCH_BV2 -> VERIFY_B (PB=0)

    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION (colide!) -> WAIT_START

    assert (
      C1 = vec3(2.0, 2.0, 2.0) and
      C2 = vec3(1.0, 1.0, 1.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 14 (Iteracao 2 formas em B) falhou" severity error;

    -- =========================================================================
    -- CASO 15: Iteracao com 2 formas em A e 1 em B (NA=4, NB=2)
    -- 1a forma de A nao colide, 2a colide!
    -- A_forma1: V1=(25,25,25), V2=(20,20,20) | B: V1=(4,4,4), V2=(0,0,0)
    -- A_forma2: V1=(6,6,6), V2=(2,2,2)
    -- =========================================================================
    NA    <= std_logic_vector(to_unsigned(4, NA'length));
    NB    <= std_logic_vector(to_unsigned(2, NB'length));
    Setup <= '1';
    tick; -- WAIT_START -> INIT_SETUP

    Setup <= '0';
    tick; -- INIT_SETUP -> READ_VERTEX_1 (carrega PA=4, PB=2)

    -- Leitura 1 (A_forma1_v1 e BV1)
    AV <= vec3(25.0, 25.0, 25.0);
    BV <= vec3(4.0, 4.0, 4.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2 (PA=3, PB=1)

    -- Leitura 2 (A_forma1_v2 e BV2)
    AV <= vec3(20.0, 20.0, 20.0);
    BV <= vec3(0.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A (PA=2, PB=0)

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION (nao colide, MB='0', MA='1') -> NEXT_A
    tick; -- NEXT_A (reseta PB=2) -> READ_VERTEX_1

    -- Leitura 1 da 2a forma de A (A_forma2_v1 e BV1)
    AV <= vec3(6.0, 6.0, 6.0);
    BV <= vec3(4.0, 4.0, 4.0);
    tick; -- READ_VERTEX_1 -> READ_VERTEX_2 (PA=1, PB=1)

    -- Leitura 2 da 2a forma de A (A_forma2_v2 e BV2)
    AV <= vec3(2.0, 2.0, 2.0);
    BV <= vec3(0.0, 0.0, 0.0);
    tick; -- READ_VERTEX_2 -> VERIFY_A (PA=0, PB=0)

    tick; -- VERIFY_A -> VERIFY_B
    tick; -- VERIFY_B -> LOAD_C_REGS
    tick; -- LOAD_C_REGS -> TEST_COLLISION
    tick; -- TEST_COLLISION (colide!) -> WAIT_START

    assert (
      C1 = vec3(4.0, 4.0, 4.0) and
      C2 = vec3(2.0, 2.0, 2.0) and
      PA = "0000000000" and PB = "0000000000" and Shape = "000" and
      ReadV = '0' and ErroV = '0' and FinishV = '1'
    ) report "Caso 15 (Iteracao 2 formas em A) falhou" severity error;

    wait for passo;
    report "Todos os 15 testes concluidos!" severity note;
    wait;
  end process;

end tb;
