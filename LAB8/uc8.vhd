library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc8 is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        instr_i      : in  unsigned(14 downto 0);
        pc_i         : in  unsigned(6 downto 0);
        flag_ble_i   : in  std_logic;
        flag_bcc_i   : in  std_logic;
        flag_z_i     : in  std_logic;
        ula_zero_i   : in  std_logic;
        pc_next_o    : out unsigned(6 downto 0);
        wr_en_pc_o   : out std_logic;
        wr_en_ir_o   : out std_logic;
        flush_o      : out std_logic;
        wr_en_reg_o  : out std_logic;
        wr_en_ram_o  : out std_logic;
        wr_en_flag_o : out std_logic;
        reg_wr_o     : out unsigned(2 downto 0);
        reg_r1_o     : out unsigned(2 downto 0);
        reg_r2_o     : out unsigned(2 downto 0);
        sel_b_o      : out std_logic;
        sel_wr_o     : out unsigned(1 downto 0);
        ula_op_o     : out unsigned(1 downto 0);
        djnz_dec_o   : out std_logic;
        estado_o     : out unsigned(1 downto 0);
        exception_o  : out std_logic
    );
end entity;

architecture a_uc8 of uc8 is

    component maq_estados is
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            estado : out unsigned(1 downto 0)
        );
    end component;

    signal estado_s       : unsigned(1 downto 0);
    signal opcode_s       : unsigned(3 downto 0);
    signal rd_s           : unsigned(2 downto 0);
    signal rs1_s          : unsigned(2 downto 0);
    signal rs2_s          : unsigned(2 downto 0);
    signal offset_s       : unsigned(6 downto 0);
    signal addr_abs_s     : unsigned(6 downto 0);
    signal is_ld_s        : std_logic;
    signal is_add_s       : std_logic;
    signal is_subi_s      : std_logic;
    signal is_mov_s       : std_logic;
    signal is_jmp_s       : std_logic;
    signal is_ble_s       : std_logic;
    signal is_bcc_s       : std_logic;
    signal is_sw_s        : std_logic;
    signal is_lw_s        : std_logic;
    signal is_djnz_s      : std_logic;
    signal branch_taken_s : std_logic;
    signal pc_8b_s        : unsigned(7 downto 0);
    signal exception_s    : std_logic;

begin

    inst_maq: maq_estados port map(
        clk    => clk,
        rst    => rst,
        estado => estado_s
    );

    opcode_s   <= instr_i(14 downto 11);
    rd_s       <= instr_i(10 downto 8);
    rs1_s      <= instr_i(7 downto 5);
    rs2_s      <= instr_i(4 downto 2);
    offset_s   <= instr_i(6 downto 0);
    addr_abs_s <= instr_i(6 downto 0);

    is_ld_s   <= '1' when opcode_s = "0001" else '0';
    is_add_s  <= '1' when opcode_s = "0010" else '0';
    is_subi_s <= '1' when opcode_s = "0011" else '0';
    is_mov_s  <= '1' when opcode_s = "0100" else '0';
    is_ble_s  <= '1' when opcode_s = "0101" else '0';
    is_bcc_s  <= '1' when opcode_s = "0110" else '0';
    is_sw_s   <= '1' when opcode_s = "0111" else '0';
    is_lw_s   <= '1' when opcode_s = "1000" else '0';
    is_djnz_s <= '1' when opcode_s = "1001" else '0';
    is_jmp_s  <= '1' when opcode_s = "1111" else '0';

    branch_taken_s <= '1' when (is_ble_s = '1' and flag_ble_i = '1') else
                      '1' when (is_bcc_s = '1' and flag_bcc_i = '1') else
                      '0';

    -- overflow do PC em 8 bits
    pc_8b_s     <= ('0' & pc_i) + 1;
    exception_s <= pc_8b_s(7);
    exception_o <= exception_s;

    -- flush: no estado 00, o IR ainda contem a instrucao de desvio
    -- para DJNZ usa flag_z_i (registrado no final do estado 10), nao ula_zero_i:
    -- no estado 00, banco_regs ja entregou R5_novo (leitura combinacional apos
    -- a borda de clock que atualizou R5), entao ula_zero_i reflete R5_novo-1,
    -- nao R5_novo. flag_z_i foi armazenado na borda do execute e esta correto.
    flush_o <= '1' when (estado_s = "00" and is_jmp_s      = '1') else
               '1' when (estado_s = "00" and branch_taken_s = '1') else
               '1' when (estado_s = "00" and is_djnz_s = '1' and flag_z_i = '0') else
               '0';

    wr_en_ir_o <= '1' when estado_s = "00" else '0';

    wr_en_pc_o <= '0' when (exception_s = '1' and estado_s = "01") else
                  '1' when estado_s = "01" else
                  '1' when (estado_s = "10" and is_jmp_s      = '1') else
                  '1' when (estado_s = "10" and branch_taken_s = '1') else
                  '1' when (estado_s = "10" and is_djnz_s = '1' and ula_zero_i = '0') else
                  '0';

    pc_next_o <= (pc_i + 1)            when estado_s = "01" else
                 (pc_i + offset_s - 1) when (estado_s = "10" and is_jmp_s      = '1') else
                 (addr_abs_s - 1)      when (estado_s = "10" and branch_taken_s = '1') else
                 (addr_abs_s - 1)      when (estado_s = "10" and is_djnz_s = '1' and ula_zero_i = '0') else
                 pc_i;

    wr_en_flag_o <= '1' when (estado_s = "10" and
                              (is_add_s = '1' or is_subi_s = '1' or
                               is_djnz_s = '1')) else '0';

    wr_en_reg_o <= '1' when (estado_s = "10" and
                             (is_ld_s = '1' or is_add_s = '1' or
                              is_subi_s = '1' or is_mov_s = '1' or
                              is_lw_s = '1' or is_djnz_s = '1')) else '0';

    wr_en_ram_o <= '1' when (estado_s = "10" and is_sw_s = '1') else '0';

    reg_wr_o <= rd_s;

    reg_r1_o <= rd_s  when (is_sw_s = '1' or is_djnz_s = '1') else rs1_s;
    reg_r2_o <= rs1_s when is_sw_s = '1' else rs2_s;

    sel_b_o  <= '1' when (is_subi_s = '1' or is_djnz_s = '1') else '0';

    sel_wr_o <= "01" when is_ld_s  = '1' else
                "10" when is_mov_s = '1' else
                "11" when is_lw_s  = '1' else
                "00";

    ula_op_o <= "01" when (is_subi_s = '1' or is_djnz_s = '1') else "00";

    djnz_dec_o <= is_djnz_s;

    estado_o <= estado_s;

end architecture;