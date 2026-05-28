library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

    component processador is
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

    uut: processador port map(
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
        wait for 30000 ns;
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

    -- Garante que instrucoes nunca-executaveis nao aparecam em estado execute.
    -- LD R5,0 (addr 5) = "000110100000000", LD R3,0 (addr 22) = "000101100000000"
    check_no_spurious: process(clk)
    begin
        if clk'event and clk = '0' then
            assert not (estado_o = "10" and instr_o = "000110100000000")
                report "FALHA: LD R5,0 (addr 5) executado - instrucao espuria apos JMP+15!"
                severity failure;
            assert not (estado_o = "10" and instr_o = "000101100000000")
                report "FALHA: LD R3,0 (addr 22) executado - instrucao espuria apos JMP-20!"
                severity failure;
        end if;
    end process;

    -- Verifica que ula_out_o (= R5 apos SUBI R5,R5,1) segue 12, 19, 26, 33, ...
    -- SUBI R5,R5,1 = "001110110100001"
    check_r5_sequence: process
        variable esperado : unsigned(15 downto 0);
        variable iter     : integer;
    begin
        wait until rst = '0';
        esperado := to_unsigned(12, 16);
        iter     := 1;
        for i in 1 to 10 loop
            loop
                wait until clk'event and clk = '0';
                exit when estado_o = "10" and instr_o = "001110110100001";
            end loop;
            assert ula_out_o = esperado
                report "FALHA iter " & integer'image(iter) &
                       ": R5 esperado=" & integer'image(to_integer(esperado)) &
                       " obtido=" & integer'image(to_integer(ula_out_o))
                severity failure;
            report "PASS iter " & integer'image(iter) &
                   ": R5=" & integer'image(to_integer(esperado));
            esperado := esperado + 7;
            iter     := iter + 1;
        end loop;
        report "=== Verificacao q_r5 OK: 12,19,26,...,75 confirmados ===";
        wait;
    end process;

end architecture;
