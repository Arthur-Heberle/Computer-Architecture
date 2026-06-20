library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

    component processador8 is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            estado_o    : out unsigned(1 downto 0);
            pc_o        : out unsigned(6 downto 0);
            instr_o     : out unsigned(14 downto 0);
            ula_out_o   : out unsigned(15 downto 0);
            exception_o : out std_logic
        );
    end component;

    constant period_time : time := 100 ns;

    signal finished    : std_logic := '0';
    signal clk         : std_logic;
    signal rst         : std_logic;
    signal estado_o    : unsigned(1 downto 0);
    signal pc_o        : unsigned(6 downto 0);
    signal instr_o     : unsigned(14 downto 0);
    signal ula_out_o   : unsigned(15 downto 0);
    signal exception_o : std_logic;
    signal read_index  : natural := 0;

begin

    uut: processador8 port map(
        clk         => clk,
        rst         => rst,
        estado_o    => estado_o,
        pc_o        => pc_o,
        instr_o     => instr_o,
        ula_out_o   => ula_out_o,
        exception_o => exception_o
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
        wait for 500000 ns;
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

    monitor_proc: process(clk)
        variable value_i : integer;
    begin
        if rising_edge(clk) then
            -- During execute of instr@26 (ADD R1,R1,R7), pc_o has already
            -- been incremented to 27, so this samples the final display value.
            if pc_o = to_unsigned(27, 7) and estado_o = "10" then
                value_i := to_integer(ula_out_o);
                report "READ R1=" & integer'image(value_i) severity note;
                read_index <= read_index + 1;
            end if;
        end if;
    end process;

    watchdog_proc: process
    begin
        wait for 50000 ns;
        assert pc_o > to_unsigned(7, 7)
            report "FAIL: PC stuck at or below address 7 after fill loop" severity failure;
        wait;
    end process;

    read_phase_proc: process
    begin
        wait for 350000 ns;
        assert read_index > 0
            report "FAIL: read phase did not start by 350us" severity failure;
        wait;
    end process;

end architecture;
