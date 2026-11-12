library ieee;
use ieee.std_logic_1164.all;

entity inversor is 
    generic (
        N : positive
    );

    port (
        A : in std_logic_vector(N-1 downto 0);
        S : out std_logic_vector(N-1 downto 0)
    );
end inversor;

architecture behavior of inversor is 
begin
    S <= not A; -- S = NOT A, bit a bit.
end architecture behavior;