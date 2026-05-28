library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- troca de estado a cada clock
-- estado 0: fetch
-- estado 1: execute
entity flop_t is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        estado : out std_logic
    );
end entity;

architecture a_flop_t of flop_t is
    signal estado_signal : std_logic := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            estado_signal <= '0';
        elsif rising_edge(clk) then
            estado_signal <= not estado_signal;
        end if;
    end process;

    estado <= estado_signal;

end architecture;
