library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador is 

    generic (
        N : positive
    )

    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        soma    : out std_logic_vector(N-1 downto 0)
    );
end somador;

architecture behavior of somador is 
begin
    -- Somador sem sinal (unsigned) de N bits: A, B e S têm a mesma quantidade de bits.
    soma <= std_logic_vector(unsigned(A) + unsigend(B)); 
end architecture behavior;