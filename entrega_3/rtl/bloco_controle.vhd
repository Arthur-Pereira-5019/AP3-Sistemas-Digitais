library ieee;
use ieee.std_logic_1164.all;
use work.record_pack.all;

entity bloco_controle is
    port (
        CLK, RST, Setup      : in  std_logic;
        Status               : in  status_t;
        Controle             : out command_t;
        ReadV, FinishV, ErroV : out std_logic
    );
end entity bloco_controle;

architecture rtl of bloco_controle is
    type Tipo_estado is (
        WAIT_START, INIT_SETUP, READ_VERTEX_1, READ_VERTEX_2,
        VERIFY_A, VERIFY_B, LOAD_C_REGS, TEST_COLLISION,
        FETCH_BV1, FETCH_BV2, NEXT_A, ERROR_STATE
    );

    signal EstadoAtual : Tipo_estado;

    alias Error_BO is Status.Error_BO;
    alias MA       is Status.MA;
    alias MB       is Status.MB;
    alias Collided is Status.Collided;

    alias Get_AV1  is Controle.Get_AV1;
    alias Get_AV2  is Controle.Get_AV2;
    alias Get_BV1  is Controle.Get_BV1;
    alias Get_BV2  is Controle.Get_BV2;
    alias ResetPA  is Controle.ResetPA;
    alias ResetPB  is Controle.ResetPB;
    alias cPA      is Controle.cPA;
    alias cPB      is Controle.cPB;
    alias ValidateB is Controle.ValidateB;
    alias cC       is Controle.cC;
    alias zC       is Controle.zC;
begin
    Estado_BC: process (RST, CLK)
    begin
        if RST = '1' then
            EstadoAtual <= WAIT_START;
        elsif rising_edge(CLK) then
            case EstadoAtual is
                when WAIT_START | ERROR_STATE =>
                    if Setup = '1' then
                        EstadoAtual <= INIT_SETUP;
                    end if;

                when INIT_SETUP =>
                    EstadoAtual <= READ_VERTEX_1;

                when READ_VERTEX_1 =>
                    EstadoAtual <= READ_VERTEX_2;

                when READ_VERTEX_2 =>
                    EstadoAtual <= VERIFY_A;

                when VERIFY_A =>
                    if Error_BO = '1' then
                        EstadoAtual <= ERROR_STATE;
                    elsif Error_BO = '0' then
                        EstadoAtual <= VERIFY_B;
                    end if;

                when VERIFY_B =>
                    if Error_BO = '1' then
                        EstadoAtual <= ERROR_STATE;
                    elsif Error_BO = '0' then
                        EstadoAtual <= LOAD_C_REGS;
                    end if;

                when LOAD_C_REGS =>
                    EstadoAtual <= TEST_COLLISION;

                when TEST_COLLISION =>
                    if Collided = '1' then
                        EstadoAtual <= WAIT_START;
                    elsif Collided = '0' then
                        if MB = '1' then
                            EstadoAtual <= FETCH_BV1;
                        elsif MB = '0' then
                            if MA = '1' then
                                EstadoAtual <= NEXT_A;
                            elsif MA = '0' then
                                EstadoAtual <= WAIT_START;
                            end if;
                        end if;
                    end if;

                when FETCH_BV1 =>
                    EstadoAtual <= FETCH_BV2;

                when FETCH_BV2 =>
                    EstadoAtual <= VERIFY_B;

                when NEXT_A =>
                    EstadoAtual <= READ_VERTEX_1;
            end case;
        end if;
    end process Estado_BC;

    Saidas_BC: process (EstadoAtual)
    begin
        -- Valores padrão para as saídas em cada estado.
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

        case EstadoAtual is
            when WAIT_START =>
                FinishV <= '1';

            when ERROR_STATE =>
                FinishV <= '1';
                ErroV <= '1';

            when INIT_SETUP =>
                Get_AV1 <= '0';
                Get_BV1 <= '0';
                Get_AV2 <= '0';
                Get_BV2 <= '0';
                cPA <= '1';
                cPB <= '1';
                cC <= '1';
                zC <= '1';
                ValidateB <= '0';
                ResetPA <= '1';
                ResetPB <= '1';
                ReadV <= '0';
                FinishV <= '0';
                ErroV <= '0';

            when READ_VERTEX_1 =>
                ReadV <= '1';
                ResetPA <= '0';
                ResetPB <= '0';
                Get_AV1 <= '1';
                Get_BV1 <= '1';
                cPA <= '1';
                cPB <= '1';
                cC <= '0';
                zC <= '0';

            when READ_VERTEX_2 =>
                Get_AV1 <= '0';
                Get_BV1 <= '0';
                Get_AV2 <= '1';
                Get_BV2 <= '1';
                ReadV <= '1';
                cPA <= '1';
                cPB <= '1';

            when VERIFY_A =>
                Get_AV2 <= '0';
                Get_BV2 <= '0';
                ReadV <= '0';
                cPA <= '0';
                cPB <= '0';

            when VERIFY_B =>
                ValidateB <= '1';
                Get_BV2 <= '0';
                cPB <= '0';

            when LOAD_C_REGS =>
                cC <= '1';
                ValidateB <= '0';

            when TEST_COLLISION =>
                cC <= '0';

            when FETCH_BV1 =>
                Get_BV1 <= '1';
                cPB <= '1';

            when FETCH_BV2 =>
                Get_BV1 <= '0';
                Get_BV2 <= '1';
                cPB <= '1';

            when NEXT_A =>
                ResetPB <= '1';
                cPB <= '1';

            when others =>
                null;
        end case;
    end process Saidas_BC;
end architecture rtl;
