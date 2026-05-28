library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

    component processador6 is
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            estado_o  : out unsigned(1 downto 0);
            pc_o      : out unsigned(6 downto 0);
            instr_o   : out unsigned(14 downto 0);
            ula_out_o : out unsigned(15 downto 0)
        );
    end component;

    constant period_time : time := 100 ns;
    signal finished  : std_logic := '0';
    signal clk       : std_logic;
    signal rst       : std_logic;
    signal estado_o  : unsigned(1 downto 0);
    signal pc_o      : unsigned(6 downto 0);
    signal instr_o   : unsigned(14 downto 0);
    signal ula_out_o : unsigned(15 downto 0);

begin

    uut: processador6 port map(
        clk       => clk,
        rst       => rst,
        estado_o  => estado_o,
        pc_o      => pc_o,
        instr_o   => instr_o,
        ula_out_o => ula_out_o
    );

    clk_proc: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time / 2;
            clk <= '1';
            wait for period_time / 2;
        end loop;
        wait;
    end process;

    sim_time_proc: process
    begin
        wait for 100000 ns;
        finished <= '1';
        wait;
    end process;

    reset_proc: process
    begin
        rst <= '1';
        wait for period_time * 2;
        rst <= '0';
        wait;
    end process;

    process
    begin
        wait;
    end process;

end architecture;
