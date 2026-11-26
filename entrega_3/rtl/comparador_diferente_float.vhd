library ieee;
use ieee.std_logic_1164.all;
use ieee.float_pkg.all;
use work.float_config;

entity comparador_diferente_float is

    generic (
        EXP_W  : positive := float_config.EXP_W;
        FRAC_W : positive := float_config.FRAC_W
    );

    port (
        A : in  std_logic_vector(23 downto 0);
        B : in  std_logic_vector(23 downto 0);
        S : out std_logic
    );
end comparador_diferente_float;

architecture behavior of comparador_diferente_float is
begin
    -- Garante que as larguras informadas somam a largura do vetor.
    assert (1 + EXP_W + FRAC_W = A'length)
        report "comparador_diferente_float: 1 + EXP_W + FRAC_W deve ser igual a largura de A"
        severity failure;

    -- Comparador "diferente de" (A != B) para floats de 24 bits.
    -- A e B são convertidos de vetor para float antes da comparação.
    -- S = '1' quando A é diferente de B; caso contrário, S = '0'.
    S <= '1' when to_float(A, EXP_W, FRAC_W) /= to_float(B, EXP_W, FRAC_W) else '0';
end architecture behavior;