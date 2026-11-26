library ieee;
use ieee.std_logic_1164.all;
use work.float_config;

entity Min is

    generic (
        EXP_W  : positive := float_config.EXP_W;
        FRAC_W : positive := float_config.FRAC_W
    );

    port (
        A : in  std_logic_vector(23 downto 0);
        B : in  std_logic_vector(23 downto 0);
        M : out std_logic_vector(23 downto 0) 
    );
end Min;

architecture behavior of Min is
    signal maior_out : std_logic; 
begin
    -- Garante que as larguras informadas somam a largura do vetor.
    assert (1 + EXP_W + FRAC_W = A'length)
        report "Min: 1 + EXP_W + FRAC_W deve ser igual a largura de A"
        severity failure;

    -- Mínimo entre A e B (floats de 24 bits).
    -- O comparador diz se A > B, e esse resultado seleciona no mux
    -- qual das duas entradas vai para M: B quando A > B, A caso contrário.
    
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
        A => A,
        B => B,
        S => M
      -- sel = '0' (A <= B): sai A | sel = '1' (A > B): sai B
    );

end architecture behavior;