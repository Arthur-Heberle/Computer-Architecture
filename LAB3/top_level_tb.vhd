library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture a_top_level_tb of top_level_tb is

    component top_level is
        port(
            clk       : in  std_logic;
            rst       : in  std_logic;
            wr_en     : in  std_logic;
            reg_r1    : in  unsigned(2 downto 0);
            reg_r2    : in  unsigned(2 downto 0);
            reg_wr    : in  unsigned(2 downto 0);
            op        : in  unsigned(1 downto 0);
            constante : in  unsigned(15 downto 0);
            sel_b     : in  std_logic;
            sel_wr    : in  std_logic;
            C, Z, N, V, BLE, BCC : out std_logic
        );
    end component;

    constant period_time : time := 100 ns;
    signal finished : std_logic := '0';
    
    signal clk       : std_logic;
    signal rst       : std_logic;
    signal wr_en     : std_logic := '0';
    signal reg_r1    : unsigned(2 downto 0) := "000";
    signal reg_r2    : unsigned(2 downto 0) := "000";
    signal reg_wr    : unsigned(2 downto 0) := "000";
    signal op        : unsigned(1 downto 0) := "00";
    signal constante : unsigned(15 downto 0) := (others => '0');
    signal sel_b     : std_logic := '0';
    signal sel_wr    : std_logic := '0';
    signal C, Z, N, V, BLE, BCC : std_logic;

    signal r1,r2,r3  : unsigned(15 downto 0);

begin

    uut: top_level port map(
        clk       => clk,
        rst       => rst,
        wr_en     => wr_en,
        reg_r1    => reg_r1,
        reg_r2    => reg_r2,
        reg_wr    => reg_wr,
        op        => op,
        constante => constante,
        sel_b     => sel_b,
        sel_wr    => sel_wr,
        C         => C,
        Z         => Z,
        N         => N,
        V         => V,
        BLE       => BLE,
        BCC       => BCC
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
        wait for 20 us;
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
        -- aguarda fim do reset
        wait for period_time * 2;

        -- -------------------------------------------------------
        -- INSTRUCAO: LD R2, 10
        -- R2 <= 10 (constante direto, sem ULA)
        -- sel_wr=1 faz data_wr = constante
        -- Esperado: R2 = 0x000A
        -- -------------------------------------------------------
        sel_wr    <= '1';
        sel_b     <= '0';
        op        <= "00";
        constante <= to_unsigned(10, 16);
        reg_wr    <= "010";
        wr_en     <= '1';
        wait for period_time;
        wr_en     <= '0';

        
        -- -------------------------------------------------------
        -- INSTRUCAO: LD R3, 5
        -- R3 <= 5
        -- Esperado: R3 = 0x0005
        -- -------------------------------------------------------
        constante <= to_unsigned(5, 16);
        reg_wr    <= "011";
        wr_en     <= '1';
        wait for period_time;
        wr_en     <= '0';

        -- -------------------------------------------------------
        -- INSTRUCAO: ADD R1, R2, R3
        -- R1 <= R2 + R3 = 10 + 5 = 15
        -- sel_b=0 (y = R3), sel_wr=0 (data_wr = saida ULA)
        -- op=00 (ADD)
        -- Esperado: R1 = 0x000F, Z=0, N=0
        -- -------------------------------------------------------
        sel_wr    <= '0';
        sel_b     <= '0';
        op        <= "00";
        reg_r1    <= "010";  -- x = R2 = 10
        reg_r2    <= "011";  -- y = R3 = 5
        reg_wr    <= "001";  -- destino = R1
        wr_en     <= '1';
        wait for period_time;
        wr_en     <= '0';

        -- aguarda para visualizar resultado final
        wait for period_time * 3;

        wait;
    end process;

end architecture;
