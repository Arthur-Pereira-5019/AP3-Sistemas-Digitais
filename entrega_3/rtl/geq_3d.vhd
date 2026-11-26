library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity geq_3d is

    port (
        G : in std_logic_vector(71 downto 0);
        T : in std_logic_vector(71 downto 0);
        S : out std_logic
    );

end geq_3d;

architecture behavior of geq_3d is
    signal g_un : unsigned(71 downto 0);
    signal t_un : unsigned(71 downto 0);
    signal maior_igual : std_logic_vector(2 downto 0);

begin
    g_un <= unsigned(G);
    t_un <= unsigned(T);
    maior_igual(0) <= '1' when g_un(71 downto 48) >= t_un(71 downto 48) else '0';
    maior_igual(1) <= '1' when g_un(47 downto 24) >= t_un(47 downto 24) else '0';
    maior_igual(2) <= '1' when g_un(23 downto 0) >= t_un(23 downto 0) else '0';

    S <= maior_igual(2) and maior_igual(1) and maior_igual(0);

end architecture behavior;
