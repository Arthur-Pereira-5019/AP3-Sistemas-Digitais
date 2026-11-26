library ieee;
use ieee.std_logic_1164.all;

entity Test_Collision_and_Shape is

    port (
        C1 : in std_logic_vector(71 downto 0);
        C2 : in std_logic_vector(71 downto 0);
        Shape : out std_logic_vector(2 downto 0);
        Collided : out std_logic
    );

end Test_Collision_and_Shape;

architecture behavior of Test_Collision_and_Shape is
    constant NO_COLLISION_SHAPE : std_logic_vector(2 downto 0) := "100";
    signal c2_g      : std_logic_vector(2 downto 0); -- Se c2 é maior
    signal difs      : std_logic_vector(2 downto 0); -- Quais são diferentes
    signal s_adder   : std_logic;
    signal Cout_adder   : std_logic;
    signal collided_s   : std_logic;
    signal col_shape   : std_logic_vector(2 downto 0);


begin
    c2_g(0) <= '1' when C2(71 downto 48) > C1(71 downto 48) else '0';
    c2_g(1) <= '1' when C2(47 downto 24) > C1(47 downto 24) else '0';
    c2_g(2) <= '1' when C2(23 downto 0) > C1(23 downto 0) else '0';

    nor3_1 : entity work.nor3_1
    port map (
        A => c2_g(0),
        B => c2_g(1),
        C => c2_g(2),
        S => collided_s
    );

    Collided <= collided_s;

    difs(0) <= '1' when C2(71 downto 48) /= C1(71 downto 48) else '0';
    difs(1) <= '1' when C2(47 downto 24) /= C1(47 downto 24) else '0';
    difs(2) <= '1' when C2(23 downto 0) /= C1(23 downto 0) else '0';

    FA : entity work.full_adder
    port map (
        A => difs(0),
        B => difs(1),
        Cin => difs(2),
        S => s_adder,
        Cout => Cout_adder
    );

    col_shape <= '0' & Cout_adder & s_adder;

    Mux : entity work.mux2to1
    generic map (N => 3)
    port map (
        sel => s_adder,
        A => NO_COLLISION_SHAPE,
        B => col_shape,
        S => shape
    );

end architecture behavior;
