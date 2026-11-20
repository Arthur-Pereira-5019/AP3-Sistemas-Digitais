LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY single_port_ram IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 10
    );
    PORT (
        clock   : IN  STD_LOGIC;
        address : IN  STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
        data    : IN  STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        wren    : IN  STD_LOGIC;
        q       : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
    );
END ENTITY single_port_ram;

ARCHITECTURE rtl OF single_port_ram IS

    TYPE mem_t IS ARRAY (0 TO (2**ADDR_WIDTH)-1)
        OF STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);

    SIGNAL ram : mem_t;

BEGIN

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF wren = '1' THEN
                ram(to_integer(unsigned(address))) <= data;
            END IF;

            q <= ram(to_integer(unsigned(address)));
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;
