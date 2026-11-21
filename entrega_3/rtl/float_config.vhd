library ieee;
use ieee.std_logic_1164.all;

package float_config is
    -- Constantes globais do ponto flutuante
    constant EXP_W  : positive := 8;
    constant FRAC_W : positive := 15;

        -- Formato do float de 24 bits: [ sinal | expoente | mantissa ]
        --                               1 bit   EXP_W bits  FRAC_W bits
        --
        -- EXP_W: quantidade de bits do EXPOENTE. Define a faixa de grandeza
        --        dos números (mais bits de expoente = valores maiores e menores).
        -- FRAC_W: quantidade de bits da MANTISSA (parte fracionária). Define a
        --         precisão (mais bits de mantissa = mais casas significativas).
    constant FLOAT_W : positive := 1 + EXP_W + FRAC_W;
end package float_config;