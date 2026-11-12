library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nor3 is 

    port (
        A : in std_logic;
        B : in std_logic;
        C : in std_logic;
        S : out std_logic
    );
end nor3;

architecture behavior of nor3 is 
begin
    S <= not (A or B or C); -- S = '1' somente quando A, B e C são todos '0'; caso contrário, S = '0'.
end architecture behavior;