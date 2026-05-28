library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_regs_tb is
end entity;

architecture a_banco_regs_tb of banco_regs_tb is

    component banco_regs is
        port(
            clk     : in  std_logic;
            rst     : in  std_logic;
            wr_en   : in  std_logic;
            reg_r1  : in  unsigned(2 downto 0);
            reg_r2  : in  unsigned(2 downto 0);
            reg_wr  : in  unsigned(2 downto 0);
            data_wr : in  unsigned(15 downto 0);
            data_r1 : out unsigned(15 downto 0);
            data_r2 : out unsigned(15 downto 0)
        );
    end component;

    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';

    signal clk     : std_logic;
    signal rst     : std_logic;
    signal wr_en   : std_logic := '0';
    signal reg_r1  : unsigned(2 downto 0) := "000";
    signal reg_r2  : unsigned(2 downto 0) := "000";
    signal reg_wr  : unsigned(2 downto 0) := "000";
    signal data_wr : unsigned(15 downto 0) := (others => '0');
    signal data_r1 : unsigned(15 downto 0);
    signal data_r2 : unsigned(15 downto 0);

begin

    uut: banco_regs port map(
        clk     => clk,
        rst     => rst,
        wr_en   => wr_en,
        reg_r1  => reg_r1,
        reg_r2  => reg_r2,
        reg_wr  => reg_wr,
        data_wr => data_wr,
        data_r1 => data_r1,
        data_r2 => data_r2
    );

    -- gerador de clock
    clk_proc: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process;

    -- tempo total de simulacao
    sim_time_proc: process
    begin
        wait for 10 us;
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

    -- casos de teste
    process
    begin
        -- espera o reset terminar
        wait for period_time * 2;

        -- -------------------------------------------------------
        -- TESTE 1: escrever 0xABCD em R3
        -- Esperado: data_r1 = 0xABCD quando reg_r1 = "011"
        -- -------------------------------------------------------
        wr_en   <= '1';
        reg_wr  <= "011";
        data_wr <= x"ABCD";
        wait for period_time;
        wr_en   <= '0';

        -- ler R3 na saida 1
        reg_r1  <= "011";
        wait for period_time;
        -- data_r1 deve ser 0xABCD aqui

        -- -------------------------------------------------------
        -- TESTE 2: escrever 0x1234 em R7
        -- Esperado: data_r2 = 0x1234 quando reg_r2 = "111"
        -- -------------------------------------------------------
        wr_en   <= '1';
        reg_wr  <= "111";
        data_wr <= x"1234";
        wait for period_time;
        wr_en   <= '0';

        -- ler R3 e R7 simultaneamente
        reg_r1  <= "011";  -- deve ser 0xABCD
        reg_r2  <= "111";  -- deve ser 0x1234
        wait for period_time;

        -- -------------------------------------------------------
        -- TESTE 3: tentar escrever com wr_en = 0
        -- R5 nao deve mudar (continua sendo 0x0000)
        -- -------------------------------------------------------
        wr_en   <= '0';
        reg_wr  <= "101";
        data_wr <= x"FFFF";
        wait for period_time;

        reg_r1  <= "101";  -- deve ser 0x0000 (nao foi escrito)
        wait for period_time;

        -- -------------------------------------------------------
        -- TESTE 4: escrever 0x0001 em R0 (registrador zero)
        -- -------------------------------------------------------
        wr_en   <= '1';
        reg_wr  <= "000";
        data_wr <= x"0001";
        wait for period_time;
        wr_en   <= '0';

        reg_r1  <= "000";  -- deve ser 0x0001
        reg_r2  <= "011";  -- deve continuar 0xABCD
        wait for period_time;

        -- -------------------------------------------------------
        -- TESTE 5: reset zera tudo novamente
        -- -------------------------------------------------------
        rst    <= '1';
        wait for period_time;
        rst    <= '0';

        reg_r1 <= "000";  -- deve ser 0x0000
        reg_r2 <= "111";  -- deve ser 0x0000
        wait for period_time;

        wait;
    end process;

end architecture;
