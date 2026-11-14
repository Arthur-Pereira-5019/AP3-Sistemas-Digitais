library ieee;
use ieee.std_logic_1164.all;

entity Max is

    generic (

        EXP_W  : positive := 8;
        FRAC_W : positive := 15
    );

    port (
        A : in  std_logic_vector(23 downto 0);
        B : in  std_logic_vector(23 downto 0);
        M : out std_logic_vector(23 downto 0) 
    );
end Max;

architecture behavior of Max is
    signal maior_out : std_logic; 
begin
    -- Garante que as larguras informadas somam os 24 bits do vetor.
    assert (1 + EXP_W + FRAC_W = 24)
        report "max: 1 + EXP_W + FRAC_W deve ser igual a 24"
        severity failure;

    -- Máximo entre A e B (floats de 24 bits).
    -- O comparador diz se A > B, e esse resultado seleciona no mux
    -- qual das duas entradas vai para M: A quando A > B, B caso contrário.

    u_maior : entity work.comparador_maior_float
    generic map (EXP_W => EXP_W, FRAC_W => FRAC_W)
    port map (
        A => A,
        B => B,
        S => maior_out
    );

    u_mux : entity work.mux2to1
    generic map(N => 24)
    port map(
        sel => maior_out,
        A => B,
        B => A,
        S => M
         -- Atenção: as entradas do mux estão invertidas em relação aos nomes.
         -- O mux2to1 escolhe a entrada A quando sel = '0' e a entrada B quando sel = '1'.
         -- Como sel = '1' significa A > B (o máximo é A), o port map liga
         -- A => B (sai B quando A <= B) e B => A (sai A quando A > B).
    );

end architecture behavior;