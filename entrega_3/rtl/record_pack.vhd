library ieee;
use ieee.std_logic_1164.all;

package record_pack is 
    type command_t is record
        -- Controle: carga dos registradores de vértices
        Get_AV1, Get_AV2 : std_logic;
        Get_BV1, Get_BV2 : std_logic;
        -- Controle: PA e PB
        ResetPA, cPA     : std_logic;
        ResetPB, cPB     : std_logic;
        -- Controle: validação
        ValidateB        : std_logic;
        cC, zC           : std_logic;
    end record;
    
    type status_t is record
         Error_BO              :  std_logic;
        MA, MB, Collided      :  std_logic;
    end record;
end package record_pack;
