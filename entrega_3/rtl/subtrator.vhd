library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity subtrator is 

    generic (
        N : positive
    );

    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S    : out std_logic_vector(N-1 downto 0)
    );
end subtrator;

architecture behavior of subtrator is 
begin
    -- subtrator sem sinal (unsigned) de N bits: A, B e subtracao têm a mesma quantidade de bits.
    subtracao <= std_logic_vector(unsigned(A) - unsigned(B)); 
end architecture behavior;