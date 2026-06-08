library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_regs is
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
end entity;

architecture a_banco_regs of banco_regs is

    -- declaracao do componente registrador
    component reg16bits is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;

    -- sinais de saida de cada registrador
    signal q_r0, q_r1, q_r2, q_r3 : unsigned(15 downto 0);
    signal q_r4, q_r5, q_r6, q_r7 : unsigned(15 downto 0);

    -- sinais de write enable individuais (decodificador de escrita)
    signal wr_r0, wr_r1, wr_r2, wr_r3 : std_logic;
    signal wr_r4, wr_r5, wr_r6, wr_r7 : std_logic;

begin

    -- -------------------------------------------------------
    -- DECODIFICADOR DE ESCRITA
    -- Ativa o wr_en apenas do registrador apontado por reg_wr
    -- wr_en global = 0 desativa todos
    -- -------------------------------------------------------
    wr_r0 <= '1' when (reg_wr = "000" and wr_en = '1') else '0';
    wr_r1 <= '1' when (reg_wr = "001" and wr_en = '1') else '0';
    wr_r2 <= '1' when (reg_wr = "010" and wr_en = '1') else '0';
    wr_r3 <= '1' when (reg_wr = "011" and wr_en = '1') else '0';
    wr_r4 <= '1' when (reg_wr = "100" and wr_en = '1') else '0';
    wr_r5 <= '1' when (reg_wr = "101" and wr_en = '1') else '0';
    wr_r6 <= '1' when (reg_wr = "110" and wr_en = '1') else '0';
    wr_r7 <= '1' when (reg_wr = "111" and wr_en = '1') else '0';

    -- -------------------------------------------------------
    -- INSTANCIAS DOS 8 REGISTRADORES
    -- Todos recebem o mesmo data_wr, mas soh um grava por vez
    -- -------------------------------------------------------
    R0: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r0, data_in=>data_wr, data_out=>q_r0);
    R1: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r1, data_in=>data_wr, data_out=>q_r1);
    R2: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r2, data_in=>data_wr, data_out=>q_r2);
    R3: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r3, data_in=>data_wr, data_out=>q_r3);
    R4: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r4, data_in=>data_wr, data_out=>q_r4);
    R5: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r5, data_in=>data_wr, data_out=>q_r5);
    R6: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r6, data_in=>data_wr, data_out=>q_r6);
    R7: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_r7, data_in=>data_wr, data_out=>q_r7);

    -- -------------------------------------------------------
    -- MULTIPLEXADOR DE LEITURA 1 (data_r1)
    -- Seleciona qual registrador aparece na saida 1
    -- -------------------------------------------------------
    with reg_r1 select
        data_r1 <= q_r0 when "000",
                   q_r1 when "001",
                   q_r2 when "010",
                   q_r3 when "011",
                   q_r4 when "100",
                   q_r5 when "101",
                   q_r6 when "110",
                   q_r7 when "111",
                   "0000000000000000" when others;

    -- -------------------------------------------------------
    -- MULTIPLEXADOR DE LEITURA 2 (data_r2)
    -- Seleciona qual registrador aparece na saida 2
    -- -------------------------------------------------------
    with reg_r2 select
        data_r2 <= q_r0 when "000",
                   q_r1 when "001",
                   q_r2 when "010",
                   q_r3 when "011",
                   q_r4 when "100",
                   q_r5 when "101",
                   q_r6 when "110",
                   q_r7 when "111",
                   "0000000000000000" when others;


end architecture;
