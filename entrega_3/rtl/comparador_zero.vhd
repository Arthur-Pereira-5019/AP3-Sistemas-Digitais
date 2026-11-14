library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity comparador_zero is
 
    generic (
        N : positive
    );
 
    port (
        A : in  std_logic_vector(N-1 downto 0);
        S : out std_logic
    );
end comparador_zero;
 
architecture behavior of comparador_zero is
begin
    -- Comparador "igual a zero" (A = 0) para vetores de N bits.
    -- S = '1' quando todos os bits de A são '0'; caso contrário, S = '0'.
    S <= '1' when unsigned(A) = 0 else '0';
end architecture behavior;