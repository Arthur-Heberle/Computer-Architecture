library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        estado_o  : out unsigned(1 downto 0);
        pc_o      : out unsigned(6 downto 0);
        instr_o   : out unsigned(14 downto 0);
        ula_out_o : out unsigned(15 downto 0)
    );
end entity;

architecture a_processador of processador is

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

    component uc5 is
        port(
            clk         : in  std_logic;
            rst         : in  std_logic;
            instr_i     : in  unsigned(14 downto 0);
            pc_i        : in  unsigned(6 downto 0);
            pc_next_o   : out unsigned(6 downto 0);
            wr_en_pc_o  : out std_logic;
            wr_en_ir_o  : out std_logic;
            flush_o     : out std_logic;
            wr_en_reg_o : out std_logic;
            reg_wr_o    : out unsigned(2 downto 0);
            reg_r1_o    : out unsigned(2 downto 0);
            reg_r2_o    : out unsigned(2 downto 0);
            sel_b_o     : out std_logic;
            sel_wr_o    : out unsigned(1 downto 0);
            ula_op_o    : out unsigned(1 downto 0);
            estado_o    : out unsigned(1 downto 0)
        );
    end component;

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

    signal pc_out_s     : unsigned(6 downto 0);
    signal pc_next_s    : unsigned(6 downto 0);
    signal rom_out_s    : unsigned(14 downto 0);
    signal ir_in_s      : unsigned(14 downto 0);
    signal ir_out_s     : unsigned(14 downto 0);
    signal wr_en_pc_s   : std_logic;
    signal wr_en_ir_s   : std_logic;
    signal flush_s      : std_logic;
    signal wr_en_reg_s  : std_logic;
    signal reg_wr_s     : unsigned(2 downto 0);
    signal reg_r1_s     : unsigned(2 downto 0);
    signal reg_r2_s     : unsigned(2 downto 0);
    signal sel_b_s      : std_logic;
    signal sel_wr_s     : unsigned(1 downto 0);
    signal ula_op_s     : unsigned(1 downto 0);
    signal estado_s     : unsigned(1 downto 0);
    signal banco_out1_s : unsigned(15 downto 0);
    signal banco_out2_s : unsigned(15 downto 0);
    signal ula_out_s    : unsigned(15 downto 0);
    signal mux_b_s      : unsigned(15 downto 0);
    signal data_wr_s    : unsigned(15 downto 0);
    signal cte_ext_s    : unsigned(15 downto 0);

begin

    cte_ext_s <= "00000000000" & ir_out_s(4 downto 0);

    -- mux de flush: quando JMP executa, forca NOP (zeros) na entrada do IR
    -- no proximo estado 0, o IR captura NOP em vez da instrucao errada da ROM
    ir_in_s <= (others => '0') when flush_s = '1' else rom_out_s;

    mux_b_s   <= cte_ext_s    when sel_b_s  = '1'  else banco_out2_s;

    data_wr_s <= cte_ext_s    when sel_wr_s = "01" else
                 banco_out1_s when sel_wr_s = "10" else
                 ula_out_s;

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

    -- IR recebe ir_in_s: instrucao real ou NOP forcado pelo flush
    inst_ir: ir port map(
        clk      => clk,
        rst      => rst,
        wr_en    => wr_en_ir_s,
        data_in  => ir_in_s,
        data_out => ir_out_s
    );

    inst_uc5: uc5 port map(
        clk         => clk,
        rst         => rst,
        instr_i     => ir_out_s,
        pc_i        => pc_out_s,
        pc_next_o   => pc_next_s,
        wr_en_pc_o  => wr_en_pc_s,
        wr_en_ir_o  => wr_en_ir_s,
        flush_o     => flush_s,
        wr_en_reg_o => wr_en_reg_s,
        reg_wr_o    => reg_wr_s,
        reg_r1_o    => reg_r1_s,
        reg_r2_o    => reg_r2_s,
        sel_b_o     => sel_b_s,
        sel_wr_o    => sel_wr_s,
        ula_op_o    => ula_op_s,
        estado_o    => estado_s
    );

    inst_banco: banco_regs port map(
        clk     => clk,
        rst     => rst,
        wr_en   => wr_en_reg_s,
        reg_r1  => reg_r1_s,
        reg_r2  => reg_r2_s,
        reg_wr  => reg_wr_s,
        data_wr => data_wr_s,
        data_r1 => banco_out1_s,
        data_r2 => banco_out2_s
    );

    inst_ula: ULA port map(
        x      => banco_out1_s,
        y      => mux_b_s,
        op     => ula_op_s,
        output => ula_out_s,
        C      => open,
        Z      => open,
        N      => open,
        V      => open,
        BLE    => open,
        BCC    => open
    );

    estado_o  <= estado_s;
    pc_o      <= pc_out_s;
    instr_o   <= ir_out_s;
    ula_out_o <= ula_out_s;

end architecture;