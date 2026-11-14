library ieee;
use ieee.std_logic_1164.all;

entity collision_datapath is

    generic (
        -- Formato do float de 24 bits: [ sinal | expoente | mantissa ]
        -- Regra: 1 (sinal) + EXP_W + FRAC_W = 24.
        EXP_W  : positive := 8;
        FRAC_W : positive := 15
    );

    port (
        clk : in std_logic;

        -- Controle: carga dos registradores de vértices
        Get_AV1, Get_AV2 : in std_logic;
        Get_BV1, Get_BV2 : in std_logic;
        -- Controle: PA e PB
        ResetPA, cPA     : in std_logic;
        ResetPB, cPB     : in std_logic;
        -- Controle: validação
        ValidateB        : in std_logic;
        cC, zC           : in std_logic;
        -- Dados de entrada
        AV, BV           : in  std_logic_vector(71 downto 0);
        NA, NB           : in  std_logic_vector(9 downto 0);
        -- Sinais de status (para o bloco de controle)
        MA, MB           : out std_logic;
        Error            : out std_logic;
        Collided         : out std_logic;
        -- Dados de saída
        PA, PB           : out std_logic_vector(9 downto 0);
        C1, C2           : out std_logic_vector(71 downto 0);
        Shape            : out std_logic_vector(2 downto 0)
    );
end collision_datapath;

architecture behavior of collision_datapath is
        -- Constantes
    constant ZERO_72 : std_logic_vector(71 downto 0) := (others => '0'); -- entrada "0" dos muxes de zC
    constant ONE_10  : std_logic_vector(9 downto 0)  := "0000000001";    -- constante 1 dos subtratores
    -- Saídas dos registradores de vértices
    signal av1_reg_out, av2_reg_out : std_logic_vector(71 downto 0);
    signal bv1_reg_out, bv2_reg_out : std_logic_vector(71 downto 0);
    -- Validação (mux de G e T, e saída do geq_3d)
    signal mux_g_out, mux_t_out     : std_logic_vector(71 downto 0);
    signal geq_3d_out               : std_logic;
    -- Max e Min (cada parte ocupa uma fatia de 24 bits)
    signal max_out, min_out         : std_logic_vector(71 downto 0);
    -- C1 e C2 
    signal mux_c1_out, mux_c2_out   : std_logic_vector(71 downto 0);
    signal c1_reg_out, c2_reg_out   : std_logic_vector(71 downto 0);
    -- Contador PA
    signal mux_pa_out, pa_reg_out, subtractor_pa_out : std_logic_vector(9 downto 0);
    signal zero_pa_out              : std_logic;
    -- Contador PB
    signal mux_pb_out, pb_reg_out, subtractor_pb_out : std_logic_vector(9 downto 0);
    signal zero_pb_out              : std_logic;

begin

    AV1_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => Get_AV1,
        D    => AV,
        Q    => av1_reg_out 
    );

    AV2_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => Get_AV2,
        D    => AV,
        Q    => av2_reg_out 
    );

    BV1_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => Get_BV1,
        D    => BV,
        Q    => bv1_reg_out 
    );

    BV2_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => Get_BV2,
        D    => BV,
        Q    => bv2_reg_out 
    );

    u_mux_g : entity work.mux2to1
    generic map(N => 72)
    port map(
        sel => validateB,
        A => av1_reg_out,
        B => bv1_reg_out,
        S => mux_g_out
    );

    u_mux_t : entity work.mux2to1
    generic map(N => 72)
    port map(
        sel => validateB,
        A => av2_reg_out,
        B => bv2_reg_out,
        S => mux_t_out
    );

    u_3D : entity work.geq_3d
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        G => mux_g_out,
        T => mux_t_out,
        S => geq_3d_out
    );

    u_error : entity work.inversor
    generic map (N => 1)
    port map (
        A(0) => geq_3d_out,
        S(0) => Error
    );

    u_max_0 : entity work.Max
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av2_reg_out(71 downto 48),
        B => bv2_reg_out(71 downto 48),
        M => max_out(71 downto 48)
    );

    u_max_1 : entity work.Max
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av2_reg_out(47 downto 24),
        B => bv2_reg_out(47 downto 24),
        M => max_out(47 downto 24)
    );

    u_max_2 : entity work.Max
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av2_reg_out(23 downto 0),
        B => bv2_reg_out(23 downto 0),
        M => max_out(23 downto 0)
    );

    u_min_0 : entity work.Min
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av1_reg_out(71 downto 48),
        B => bv1_reg_out(71 downto 48),
        M => min_out(71 downto 48)
    );

    u_min_1 : entity work.Min
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av1_reg_out(47 downto 24),
        B => bv1_reg_out(47 downto 24),
        M => min_out(47 downto 24)
    );

    u_min_2 : entity work.Min
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => av1_reg_out(23 downto 0),
        B => bv1_reg_out(23 downto 0),
        M => min_out(23 downto 0)
    );

    u_mux_c1 : entity work.mux2to1
    generic map(N => 72)
    port map(
        sel => zC,
        A => min_out,
        B => ZERO_72,
        S => mux_c1_out
    );

    u_mux_c2 : entity work.mux2to1
    generic map(N => 72)
    port map(
        sel => zC,
        A => max_out,
        B => ZERO_72,
        S => mux_c2_out
    );

    C1_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => cC,
        D    => mux_c1_out,
        Q    => c1_reg_out 
    );

    C2_REG : entity work.registrador
    generic map (N => 72)
    port map (
        clk  => clk,
        load => cC,
        D    => mux_c2_out,
        Q    => c2_reg_out
    );

    TCAS : entity work.Test_Collision_and_Shape
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        -- confirmar inversão antes de submeter
        C1 => c2_reg_out,
        C2 => c1_reg_out,
        Shape => Shape,
        Collided => Collided
    );

    u_mux_pb : entity work.mux2to1
    generic map(N => 10)
    port map(
        -- confirmar port map antes de submeter
        sel => ResetPB,
        A => subtractor_pb_out,
        B => NB,
        S => mux_pb_out
    );

    u_mux_pa : entity work.mux2to1
    generic map(N => 10)
    port map(
        -- confirmar port map antes de submeter
        sel => ResetPA,
        A => subtractor_pa_out,
        B => NA,
        S => mux_pa_out
    );

    PB_REG : entity work.registrador
    generic map (N => 10)
    port map (
        clk  => clk,
        load => cPB,
        D    => mux_pb_out,
        Q    => pb_reg_out 
    );

    PA_REG : entity work.registrador
    generic map (N => 10)
    port map (
        clk  => clk,
        load => cPA,
        D    => mux_pa_out,
        Q    => pa_reg_out 
    );

    u_zero_pb : entity work.comparador_zero
    generic map (N => 10)
    port map (
        A => pb_reg_out,
        S => zero_pb_out
    );

    u_zero_pa : entity work.comparador_zero
    generic map (N => 10)
    port map (
        A => pa_reg_out,
        S => zero_pa_out
    );

    u_sub_pb : entity work.subtrator
    generic map (N => 10)
    port map (
        A => pb_reg_out,
        B => ONE_10,
        S => subtractor_pb_out
    );

    u_sub_pa : entity work.subtrator
    generic map (N => 10)
    port map (
        A => pa_reg_out,
        B => ONE_10, 
        S => subtractor_pa_out
    );

    u_mb : entity work.inversor
    generic map (N => 1)
    port map (
        A(0) => zero_pb_out,
        S(0) => MB
    );

    u_ma : entity work.inversor
    generic map (N => 1)
    port map (
        A(0) => zero_pa_out,
        S(0) => MA
    );

    C1 <= c1_reg_out;
    C2 <= c2_reg_out;

    PA <= pa_reg_out;
    PB <= pb_reg_out;

end architecture behavior;