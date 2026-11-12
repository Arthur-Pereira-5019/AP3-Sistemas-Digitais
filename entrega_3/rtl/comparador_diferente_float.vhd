library ieee;
use ieee.std_logic_1164.all;
use ieee.float_pkg.all;

entity comparador_diferente_float is

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
        A : in  std_logic_vector(23 downto 0);
        B : in  std_logic_vector(23 downto 0);
        S : out std_logic
    );
end comparador_diferente_float;

architecture behavior of comparador_diferente_float is
begin
    -- Garante que as larguras informadas somam os 24 bits do vetor.
    assert (1 + EXP_W + FRAC_W = 24)
        report "comparador_diferente_float: 1 + EXP_W + FRAC_W deve ser igual a 24"
        severity failure;

    -- Comparador "diferente de" (A != B) para floats de 24 bits.
    -- A e B são convertidos de vetor para float antes da comparação.
    -- S = '1' quando A é diferente de B; caso contrário, S = '0'.
    S <= '1' when to_float(A, EXP_W, FRAC_W) /= to_float(B, EXP_W, FRAC_W) else '0';
end architecture behavior;