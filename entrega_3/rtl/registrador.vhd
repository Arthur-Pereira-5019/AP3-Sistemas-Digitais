library ieee;
use ieee.std_logic_1164.all;

entity registrador is

    generic (
        N : positive
    );

    port (
        clk  : in  std_logic;                        -- clock (borda de subida)
        load : in  std_logic;                        -- '1' = carrega D no registrador
        D    : in  std_logic_vector(N-1 downto 0);   -- dado de entrada
        Q    : out std_logic_vector(N-1 downto 0)    -- dado guardado
    );
end registrador;

architecture behavior of registrador is
begin
    -- Registrador de N bits com carga controlada por load.
    -- Na borda de subida de clk, se load = '1', Q recebe D;
    -- caso contrário, Q mantém o valor anterior.
    process (clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end architecture behavior;