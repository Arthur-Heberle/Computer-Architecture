library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- registrador simples de 7 bits
-- A contagem eh feita externamente por um somador +1
-- O write enable controla quando o PC eh atualizado
entity pc is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        wr_en    : in  std_logic;
        data_in  : in  unsigned(6 downto 0);
        data_out : out unsigned(6 downto 0)
    );
end entity;

architecture a_pc of pc is
    signal pc_data : unsigned(6 downto 0) := (others => '0');
begin

    process(clk, rst, wr_en)
    begin
        if rst = '1' then
            pc_data <= (others => '0');
        elsif wr_en = '1' then
            if rising_edge(clk) then
                pc_data <= data_in;
            end if;
        end if;
    end process;

    data_out <= pc_data;

end architecture;
