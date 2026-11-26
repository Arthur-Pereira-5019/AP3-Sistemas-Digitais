library ieee;
use ieee.std_logic_1164.all;


entity Min is
    port (
        A : in  std_logic_vector(23 downto 0);
        B : in  std_logic_vector(23 downto 0);
        M : out std_logic_vector(23 downto 0) 
    );
end Min;

architecture behavior of Min is
    signal maior_out : std_logic; 
begin    
    M <= A when A < B else B;

end architecture behavior;
