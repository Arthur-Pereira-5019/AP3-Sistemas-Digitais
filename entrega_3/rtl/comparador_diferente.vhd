library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador_diferente is 
    generic (
        N : positive
    );

    port (
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        S : out std_logic
    );
end comparador_diferente;

architecture behavior of comparador_diferente is 
begin
    S <= '1' when A /= B else '0'; -- S = '1' quando A for diferente de B; caso contrário, S = '0'.
end architecture behavior;