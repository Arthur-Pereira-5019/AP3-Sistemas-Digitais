library ieee;
use ieee.std_logic_1164.all;

entity Test_Collision_and_Shape is

    generic (
        -- Formato do float de 24 bits: [ sinal | expoente | mantissa ]
        --                                1 bit   EXP_W bits  FRAC_W bits
        --
        -- EXP_W: quantidade de bits do EXPOENTE. Define a faixa de grandeza
        --        dos números (mais bits de expoente = valores maiores e menores).
        -- FRAC_W: quantidade de bits da MANTISSA (parte fracionária). Define a
        --         precisão (mais bits de mantissa = mais casas significativas).
        --
        -- confirmar as larguras do float de 24 bits.
        -- Regra: 1 (sinal) + EXP_W + FRAC_W = 24.
        EXP_W  : positive := 8;
        FRAC_W : positive := 15

    );

    port (
        C1 : in std_logic_vector(71 downto 0);
        C2 : in std_logic_vector(71 downto 0);
        Shape : out std_logic_vector(2 downto 0);
        Collided : out std_logic
    );

end Test_Collision_and_Shape;

architecture behavior of Test_Collision_and_Shape is
    constant NO_COLLISION_SHAPE : std_logic_vector(2 downto 0) := "100";
    signal maior_out    : std_logic_vector(2 downto 0); --saídas dos 3 comparador_maior_float
    signal collided_s   : std_logic; -- saída do nor3; atribui Collided e o sel do mux
    signal dif_out      : std_logic_vector(2 downto 0); --saídas dos 3 comparador_diferente
    signal dif_ext0, dif_ext1, dif_ext2 : std_logic_vector(1 downto 0); -- dif_out estendido com '0'
    signal soma1, soma2 : std_logic_vector(1 downto 0); --saídas dos dois somadores
    signal soma2_inv    : std_logic_vector(1 downto 0); --saída do inversor
    signal concat_out   : std_logic_vector(2 downto 0);--"0" concatenado com soma2_inv
    


begin

    u_maior_0 : entity work.comparador_maior_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(71 downto 48),
        B => C2(71 downto 48),
        S => maior_out(0)
    );

    u_maior_1 : entity work.comparador_maior_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(47 downto 24),
        B => C2(47 downto 24),
        S => maior_out(1)
    );

    u_maior_2 : entity work.comparador_maior_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(23 downto 0),
        B => C2(23 downto 0),
        S => maior_out(2)
    );

    u_nor3 : entity work.nor3
    port map (
        A => maior_out(0),
        B => maior_out(1),
        C => maior_out(2),
        S => collided_s
    );

    u_dif_0 : entity work.comparador_diferente_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(71 downto 48),
        B => C2(71 downto 48),
        S => dif_out(0)
    );

    u_dif_1 : entity work.comparador_diferente_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(47 downto 24),
        B => C2(47 downto 24),
        S => dif_out(1)
    );

    u_dif_2 : entity work.comparador_diferente_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => C1(23 downto 0),
        B => C2(23 downto 0),
        S => dif_out(2)
    );

    dif_ext0 <= '0' & dif_out(0);
    dif_ext1 <= '0' & dif_out(1);
    dif_ext2 <= '0' & dif_out(2);

    u_soma1 : entity work.somador
    generic map (N => 2)
    port map (
        A => dif_ext0,
        B => dif_ext1,
        soma => soma1
    );

    u_soma2 : entity work.somador
    generic map (N => 2)
    port map(
        A => soma1,
        B => dif_ext2,
        soma => soma2
    );

    u_inversor : entity work.inversor
    generic map (N => 2)
    port map (
        A => soma2,
        S => soma2_inv
    );

    concat_out <= "0" & soma2_inv;

    u_mux : entity work.mux2to1
    generic map(N => 3)
    port map(
        sel => collided_s,
        A => NO_COLLISION_SHAPE,
        B => concat_out,
        S => Shape
    );

    Collided <= collided_s;

end architecture behavior;