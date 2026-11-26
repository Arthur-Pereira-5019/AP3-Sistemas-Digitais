library ieee;
use ieee.std_logic_1164.all;
use work.record_pack.all;

entity top_level is
    port (
        -- Entradas
        NA, NB           : in  std_logic_vector(9 downto 0);
        AV, BV           : in  std_logic_vector(71 downto 0);
        RST, Setup, CLK  : in  std_logic;

        -- Saídas
        C1, C2           : out std_logic_vector(71 downto 0);
        PA, PB           : out std_logic_vector(9 downto 0);
        Shape            : out std_logic_vector(2 downto 0);
        ReadV            : out std_logic;
        ErroV            : out std_logic;
        FinishV          : out std_logic
    );
end entity top_level;

architecture rtl of top_level is
    signal Controle : command_t;
    signal Status   : status_t;
begin

    U_BC : entity work.bloco_controle
        port map (
            CLK      => CLK,
            RST      => RST,
            Setup    => Setup,
            Status   => Status,
            Controle => Controle,
            ReadV    => ReadV,
            FinishV  => FinishV,
            ErroV    => ErroV
        );

    U_BO : entity work.collision_datapath
        port map (
            clk      => CLK,
            Controle => Controle,
            Status   => Status,
            AV       => AV,
            BV       => BV,
            NA       => NA,
            NB       => NB,
            PA       => PA,
            PB       => PB,
            C1       => C1,
            C2       => C2,
            Shape    => Shape
        );

end architecture rtl;
