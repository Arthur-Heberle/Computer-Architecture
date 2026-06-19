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
    signal clk         : std_logic := '0';
    signal rst         : std_logic;
    signal estado_o    : unsigned(1 downto 0);
    signal pc_o        : unsigned(6 downto 0);
    signal instr_o     : unsigned(14 downto 0);
    signal ula_out_o   : unsigned(15 downto 0);
    signal exception_o : std_logic;

    signal pass_983       : std_logic := '0';
    signal pass_exception : std_logic := '0';

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
        wait for 200000 ns;
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

    -- Verifica ula_out=983 durante execute de ADD addr 24 (pc_o=25 em state "10")
    check_983_proc: process(clk)
    begin
        if rising_edge(clk) then
            if pc_o = "0011001" and estado_o = "10" then
                assert ula_out_o = to_unsigned(983, 16)
                    report "FAIL: ula_out esperado 983, obtido " &
                           integer'image(to_integer(ula_out_o))
                    severity failure;
                report "PASS: 983 no bus debug (ula_out_o = " &
                       integer'image(to_integer(ula_out_o)) & ")"
                    severity note;
                pass_983 <= '1';
            end if;
        end if;
    end process;

    -- Verifica excecao ROM quando PC=127
    check_exception_proc: process(clk)
    begin
        if rising_edge(clk) then
            if pc_o = "1111111" then
                assert exception_o = '1'
                    report "FAIL: exception_o deveria ser 1 quando PC=127"
                    severity failure;
                if pass_exception = '0' then
                    report "PASS: excecao ROM ativada (PC=127, exception_o=1)"
                        severity note;
                    pass_exception <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Watchdog: DJNZ loop deve terminar antes de 50us (PC avanca alem de 20)
    watchdog_proc: process
    begin
        wait for 50000 ns;
        assert pc_o > "0010100"
            report "FAIL: PC preso em addr <= 20 apos 50us - loop DJNZ nao terminou!"
            severity failure;
        wait;
    end process;

    -- Resumo final
    summary_proc: process
    begin
        wait for 190000 ns;
        assert pass_983 = '1'
            report "FAIL: instrucao ADD addr 24 nunca executou com ula_out=983"
            severity failure;
        assert pass_exception = '1'
            report "FAIL: excecao ROM (PC=127) nunca foi ativada"
            severity failure;
        report "TODAS AS VERIFICACOES PASSARAM" severity note;
        wait;
    end process;

end architecture;
