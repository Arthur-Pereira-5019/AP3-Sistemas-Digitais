library ieee;
use ieee.std_logic_1164.all;

entity geq_3d is

    generic (
        -- Formato do float de 24 bits: [ sinal | expoente | mantissa ]
        -- Regra: 1 (sinal) + EXP_W + FRAC_W = 24.
        EXP_W  : positive := 8;
        FRAC_W : positive := 15

    );

    port (
        G : in std_logic_vector(71 downto 0);
        T : in std_logic_vector(71 downto 0);
        S : out std_logic
    );

end geq_3d;

architecture behavior of geq_3d is

    signal maior_igual_out : std_logic_vector(2 downto 0);

begin

    u_maior_igual_0 : entity work.comparador_maior_igual_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => G(71 downto 48),
        B => T(71 downto 48),
        S => maior_igual_out(0)
    );

    u_maior_igual_1 : entity work.comparador_maior_igual_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => G(47 downto 24),
        B => T(47 downto 24),
        S => maior_igual_out(1)
    );

    u_maior_igual_2 : entity work.comparador_maior_igual_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => G(23 downto 0),
        B => T(23 downto 0),
        S => maior_igual_out(2)
    );

    S <= maior_igual_out(2) and maior_igual_out(1) and maior_igual_out(0);

end architecture behavior;