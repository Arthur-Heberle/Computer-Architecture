library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_uc_tb is
end entity;

architecture a_top_level_uc_tb of top_level_uc_tb is

    component top_level_uc is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            pc_o     : out unsigned(6 downto 0);
            instr_o  : out unsigned(14 downto 0);
            estado_o : out std_logic
        );
    end component;

    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal pc_o     : unsigned(6 downto 0);
    signal instr_o  : unsigned(14 downto 0);
    signal estado_o : std_logic;

begin

    uut: top_level_uc port map(
        clk      => clk,
        rst      => rst,
        pc_o     => pc_o,
        instr_o  => instr_o,
        estado_o => estado_o
    );

    -- gerador de clock
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

    -- tempo total: suficiente para executar umas 20 instrucoes
    -- cada instrucao = 2 clocks -> 40 clocks = 4000 ns
    sim_time_proc: process
    begin
        wait for 6000 ns;
        finished <= '1';
        wait;
    end process;

    -- reset inicial
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
