library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Guarda a instrucao da ROM para usar no estado 1 (execute)
-- wr_en ativo no estado 0 (fetch)
entity ir is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        wr_en    : in  std_logic;
        data_in  : in  unsigned(14 downto 0);
        data_out : out unsigned(14 downto 0)
    );
end entity;

architecture a_ir of ir is
    signal ir_data : unsigned(14 downto 0) := (others => '0');
begin

    process(clk, rst, wr_en)
    begin
        if rst = '1' then
            ir_data <= (others => '0');
        elsif wr_en = '1' then
            if rising_edge(clk) then
                ir_data <= data_in;
            end if;
        end if;
    end process;

    data_out <= ir_data;

end architecture;
