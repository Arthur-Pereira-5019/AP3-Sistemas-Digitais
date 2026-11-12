library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
	generic(
		N : positive 
	);
	port(
		sel        : in  std_logic;                        -- sinal de seleção
		A, B       : in  std_logic_vector(N - 1 downto 0); -- entradas do mux
		S          : out std_logic_vector(N - 1 downto 0)  -- saída do mux
	);
end mux2to1;

architecture behavior of mux2to1 is 
begin
    S <= A when sel = '0' else B; -- S = A quando sel = '0'; S = B quando sel = '1'.
end architecture behavior;