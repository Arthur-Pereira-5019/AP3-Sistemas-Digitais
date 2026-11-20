library ieee;
use ieee.std_logic_1164.all;

entity bloco_controle is
    port (
        CLK, RST, Setup       : in std_logic;
        Error_BO              : in std_logic;
        MA, MB, Collided      : in std_logic;

        Get_AV1, Get_AV2      : out std_logic;
        Get_BV1, Get_BV2      : out std_logic;
        ResetPA, cPA          : out std_logic;
        ResetPB, cPB          : out std_logic;
        ValidateB, cC, zC     : out std_logic;

        ReadV, FinishV, ErroV    : out std_logic
    );
end entity bloco_controle;

architecture rtl of bloco_controle is
    type estado_t is (
        WAIT_START, INIT_SETUP, READ_VERTEX_1, READ_VERTEX_2,
        VERIFY_A, VERIFY_B, LOAD_C_REGS, TEST_COLLISION,
        FETCH_BV1, FETCH_BV2, NEXT_A, ERROR_STATE
    );

    signal estado_atual, proximo_estado : estado_t;
begin
    process (CLK, RST)
    begin
        if RST = '1' then
            estado_atual <= WAIT_START;
        elsif rising_edge(CLK) then
            estado_atual <= proximo_estado;
        end if;
    end process;

    process (estado_atual, Setup, Error_BO, MA, MB, Collided)
    begin
        -- Por padrão, mantenha o estado e desative as saídas.
        proximo_estado <= estado_atual;
        Get_AV1 <= '0';
        Get_AV2 <= '0';
        Get_BV1 <= '0';
        Get_BV2 <= '0';
        ResetPA <= '0';
        ResetPB <= '0';
        cPA <= '0';
        cPB <= '0';
        ValidateB <= '0';
        cC <= '0';
        zC <= '0';
        ReadV <= '0';
        FinishV <= '0';
        ErroV <= '0';

        case estado_atual is
            when WAIT_START | ERROR_STATE =>
                FinishV <= '1';
                if estado_atual = ERROR_STATE then
                    ErroV <= '1';
                end if;
                if Setup = '1' then
                    proximo_estado <= INIT_SETUP;
                end if;

            when INIT_SETUP =>
                ResetPA <= '1';
                ResetPB <= '1';
                cPA <= '1';
                cPB <= '1';
                cC <= '1';
                zC <= '1';
                proximo_estado <= READ_VERTEX_1;

            when READ_VERTEX_1 =>
                ReadV <= '1';
                Get_AV1 <= '1';
                Get_BV1 <= '1';
                cPA <= '1';
                cPB <= '1';
                proximo_estado <= READ_VERTEX_2;

            when READ_VERTEX_2 =>
                ReadV <= '1';
                Get_AV2 <= '1';
                Get_BV2 <= '1';
                cPA <= '1';
                cPB <= '1';
                proximo_estado <= VERIFY_A;

            when VERIFY_A =>
                if Error_BO = '1' then
                    proximo_estado <= ERROR_STATE;
                elsif Error_BO = '0' then
                    proximo_estado <= VERIFY_B;
                end if;

            when VERIFY_B =>
                ValidateB <= '1';
                if Error_BO = '1' then
                    proximo_estado <= ERROR_STATE;
                elsif Error_BO = '0' then
                    proximo_estado <= LOAD_C_REGS;
                end if;

            when LOAD_C_REGS =>
                cC <= '1';
                proximo_estado <= TEST_COLLISION;

            when TEST_COLLISION =>
                if Collided = '1' then
                    proximo_estado <= WAIT_START;
                elsif Collided = '0' then
                    if MB = '1' then
                        proximo_estado <= FETCH_BV1;
                    elsif MB = '0' then
                        if MA = '1' then
                            proximo_estado <= NEXT_A;
                        elsif MA = '0' then
                            proximo_estado <= WAIT_START;
                        end if;
                    end if;
                end if;

            when FETCH_BV1 =>
                Get_BV1 <= '1';
                cPB <= '1';
                proximo_estado <= FETCH_BV2;

            when FETCH_BV2 =>
                Get_BV2 <= '1';
                cPB <= '1';
                proximo_estado <= VERIFY_B;

            when NEXT_A =>
                ResetPB <= '1';
                cPB <= '1';
                proximo_estado <= READ_VERTEX_1;
        end case;
    end process;
end architecture rtl;
