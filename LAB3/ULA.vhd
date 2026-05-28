library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (   x,y    : in  unsigned(15 downto 0);
               op     : in  unsigned(1 downto 0);
               output : out unsigned(15 downto 0);
               C,Z,N,V,BLE,BCC : out std_logic
    );
end entity;

architecture CC_LE_ula of ULA is
    signal op_17B    : unsigned(16 downto 0);
    signal resultado : unsigned(15 downto 0);
    signal C_int : std_logic;
    signal Z_int : std_logic;
    signal N_int : std_logic;
    signal V_int : std_logic;
begin
    resultado <=    (x+y)     when op="00" else
                    (x-y)     when op="01" else
                    (x and y) when op="10" else
                    (x or y)  when op="11" else
                    "0000000000000000";

    output <= resultado;

    op_17B <= ('0' & x) + ('0' & y) when op = "00" else
              ('0' & x) - ('0' & y) when op = "01" else
              "00000000000000000";

    C_int <= op_17B(16) when op = "00" or op = "01" else '0';

    Z_int <= '1' when resultado = "0000000000000000" else '0';

    N_int <= resultado(15);

    V_int <= ( (not x(15) and not y(15) and op_17B(15))
               or (x(15) and y(15) and not op_17B(15)) ) when op = "00" else
             ( (not x(15) and y(15) and op_17B(15))
               or (x(15) and not y(15) and not op_17B(15)) ) when op = "01" else
             '0';

    C <= C_int;
    Z <= Z_int;
    N <= N_int;
    V <= V_int;

    BCC <= '1' when C_int = '0' else '0';

    BLE <= '1' when (Z_int = '1' or N_int /= V_int) else '0';

end architecture;
