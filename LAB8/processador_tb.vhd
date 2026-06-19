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
    signal finished  : std_logic := '0';
    signal clk       : std_logic;
    signal rst       : std_logic;
    signal estado_o  : unsigned(1 downto 0);
    signal pc_o      : unsigned(6 downto 0);
    signal instr_o   : unsigned(14 downto 0);
    signal ula_out_o : unsigned(15 downto 0);
    signal exception_o : std_logic;

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

    -- fill: 31 iter*12cyc*100ns=37.2us; elimination: ~50cyc*100ns=5us; read: 31 iter*15cyc*100ns=46.5us
    -- total ~100us plus setup/JMP loop overhead
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
    begin
        if rising_edge(clk) then
            -- during execute of instr@51 (ADD R1,R1,R7) pc_o has already
            -- been incremented to 52 (decode stage), so check pc_o=52, state=exec
            if pc_o = "0110100" and estado_o = "10" then
                report "READ R1=" & integer'image(to_integer(ula_out_o)) severity note;
            end if;
        end if;
    end process;

    -- fill loop: 31 iter * 12 cycles * 100ns = ~37.2us; check at 45us that PC is past the fill loop
    watchdog_proc: process
    begin
        wait for 45000 ns;
        assert pc_o > "0000110"
            report "FAIL: PC stuck at or below address 6 after 45us - DJNZ loop never exits!" severity failure;
        wait;
    end process;

    -- verify PC reaches address 48 (read phase) within simulation time
    reach48_proc: process
    begin
        wait for 65000 ns;
        assert pc_o >= "0110000"
            report "FAIL: PC has not reached address 48 (read phase) by 65us!" severity failure;
        wait;
    end process;

end architecture;
