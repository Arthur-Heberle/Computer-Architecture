library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        wr_en     : in  std_logic;

        reg_r1    : in  unsigned(2 downto 0);  -- registrador fonte 1 (operando x da ULA)
        reg_r2    : in  unsigned(2 downto 0);  -- registrador fonte 2 (operando y, se sel_b=0)
        reg_wr    : in  unsigned(2 downto 0);  -- registrador destino

        op        : in  unsigned(1 downto 0);  -- 00=ADD, 01=SUB

        -- constante externa (subi e ld)
        constante : in  unsigned(15 downto 0);

        sel_b     : in  std_logic;  -- 0=data_r2 (reg), 1=constante (SUBI)
        sel_wr    : in  std_logic;  -- 0=saida ULA (ADD/SUB), 1=constante (LD)

        C, Z, N, V, BLE, BCC : out std_logic
    );
end entity;

architecture a_top_level of top_level is

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

    component ULA is
        port(
            x, y   : in  unsigned(15 downto 0);
            op     : in  unsigned(1 downto 0);
            output : out unsigned(15 downto 0);
            C, Z, N, V, BLE, BCC : out std_logic
        );
    end component;

    signal banco_out1 : unsigned(15 downto 0);  -- saida 1 do banco -> x da ULA
    signal banco_out2 : unsigned(15 downto 0);  -- saida 2 do banco -> MUX B
    signal mux_b_out  : unsigned(15 downto 0);  -- saida do MUX B -> y da ULA
    signal ula_out    : unsigned(15 downto 0);  -- saida da ULA -> MUX WR
    signal mux_wr_out : unsigned(15 downto 0);  -- saida do MUX WR -> data_wr do banco

begin

    -- -------------------------------------------------------
    -- MUX B: seleciona o operando Y da ULA
    -- sel_b=0 -> registrador (ADD, SUB)
    -- sel_b=1 -> constante externa (SUBI)
    -- -------------------------------------------------------
    mux_b_out <= constante when sel_b = '1' else banco_out2;

    -- -------------------------------------------------------
    -- MUX WR: seleciona o que sera escrito no banco
    -- sel_wr=0 -> resultado da ULA (ADD, SUB, SUBI)
    -- sel_wr=1 -> constante externa (LD)
    -- -------------------------------------------------------
    mux_wr_out <= constante when sel_wr = '1' else ula_out;

    -- -------------------------------------------------------
    -- INSTANCIA DO BANCO DE REGISTRADORES
    -- -------------------------------------------------------
    banco: banco_regs port map(
        clk     => clk,
        rst     => rst,
        wr_en   => wr_en,
        reg_r1  => reg_r1,
        reg_r2  => reg_r2,
        reg_wr  => reg_wr,
        data_wr => mux_wr_out,
        data_r1 => banco_out1,
        data_r2 => banco_out2
    );

    -- -------------------------------------------------------
    -- INSTANCIA DA ULA
    -- x vem sempre de banco_out1 (registrador fonte 1)
    -- y vem do MUX B (registrador ou constante)
    -- -------------------------------------------------------
    inst_ula: ULA port map(
        x      => banco_out1,
        y      => mux_b_out,
        op     => op,
        output => ula_out,
        C      => C,
        Z      => Z,
        N      => N,
        V      => V,
        BLE    => BLE,
        BCC    => BCC
    );

end architecture;
