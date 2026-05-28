library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM + PC + IR + UC

entity top_level_uc is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        pc_o     : out unsigned(6 downto 0);   -- valor atual do PC
        instr_o  : out unsigned(14 downto 0);  -- instrucao no IR
        estado_o : out std_logic               -- estado da maquina
    );
end entity;

architecture a_top_level_uc of top_level_uc is

    component rom is
        port(
            clk      : in  std_logic;
            endereco : in  unsigned(6 downto 0);
            dado     : out unsigned(14 downto 0)
        );
    end component;

    component pc is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
        );
    end component;

    component ir is
        port(
            clk      : in  std_logic;
            rst      : in  std_logic;
            wr_en    : in  std_logic;
            data_in  : in  unsigned(14 downto 0);
            data_out : out unsigned(14 downto 0)
        );
    end component;

    component uc is
        port(
            clk        : in  std_logic;
            rst        : in  std_logic;
            instr_i    : in  unsigned(14 downto 0);
            pc_i       : in  unsigned(6 downto 0);
            pc_next_o  : out unsigned(6 downto 0);
            wr_en_pc_o : out std_logic;
            wr_en_ir_o : out std_logic;
            estado_o   : out std_logic
        );
    end component;

    -- sinais internos
    signal pc_out_s    : unsigned(6 downto 0);   -- saida do PC -> ROM e UC
    signal rom_out_s   : unsigned(14 downto 0);  -- saida da ROM -> IR
    signal ir_out_s    : unsigned(14 downto 0);  -- saida do IR -> UC
    signal pc_next_s   : unsigned(6 downto 0);   -- proximo PC calculado pela UC
    signal wr_en_pc_s  : std_logic;              -- habilita escrita no PC
    signal wr_en_ir_s  : std_logic;              -- habilita escrita no IR
    signal estado_s    : std_logic;              -- estado atual

begin

    inst_pc: pc port map(
        clk      => clk,
        rst      => rst,
        wr_en    => wr_en_pc_s,
        data_in  => pc_next_s,
        data_out => pc_out_s
    );

    inst_rom: rom port map(
        clk      => clk,
        endereco => pc_out_s,
        dado     => rom_out_s
    );

	inst_ir: ir port map(
        clk      => clk,
        rst      => rst,
        wr_en    => wr_en_ir_s,
        data_in  => rom_out_s,
        data_out => ir_out_s
    );

    inst_uc: uc port map(
        clk        => clk,
        rst        => rst,
        instr_i    => ir_out_s,
        pc_i       => pc_out_s,
        pc_next_o  => pc_next_s,
        wr_en_pc_o => wr_en_pc_s,
        wr_en_ir_o => wr_en_ir_s,
        estado_o   => estado_s
    );

    pc_o     <= pc_out_s;
    instr_o  <= ir_out_s;
    estado_o <= estado_s;

end architecture;
