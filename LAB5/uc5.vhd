library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc5 is
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
end entity;

architecture a_uc5 of uc5 is

    component maq_estados is
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            estado : out unsigned(1 downto 0)
        );
    end component;

    signal estado_s  : unsigned(1 downto 0);
    signal opcode_s  : unsigned(3 downto 0);
    signal rd_s      : unsigned(2 downto 0);
    signal rs1_s     : unsigned(2 downto 0);
    signal rs2_s     : unsigned(2 downto 0);
    signal offset_s  : unsigned(6 downto 0);
    signal is_ld_s   : std_logic;
    signal is_add_s  : std_logic;
    signal is_subi_s : std_logic;
    signal is_mov_s  : std_logic;
    signal is_jmp_s  : std_logic;

begin

    inst_maq: maq_estados port map(
        clk    => clk,
        rst    => rst,
        estado => estado_s
    );

    opcode_s <= instr_i(14 downto 11);
    rd_s     <= instr_i(10 downto 8);
    rs1_s    <= instr_i(7 downto 5);
    rs2_s    <= instr_i(4 downto 2);
    offset_s <= instr_i(6 downto 0);

    is_ld_s   <= '1' when opcode_s = "0001" else '0';
    is_add_s  <= '1' when opcode_s = "0010" else '0';
    is_subi_s <= '1' when opcode_s = "0011" else '0';
    is_mov_s  <= '1' when opcode_s = "0100" else '0';
    is_jmp_s  <= '1' when opcode_s = "1111" else '0';

    -- flush: ativo no ciclo de fetch (estado=00) APOS o JMP executar.
    -- Nesse ciclo o IR ainda contem o opcode JMP e wr_en_ir=1
    flush_o <= '1' when (is_jmp_s = '1' and estado_s = "00") else '0';

    wr_en_ir_o <= '1' when estado_s = "00" else '0';

    wr_en_pc_o <= '1' when estado_s = "01" else
                  '1' when (estado_s = "10" and is_jmp_s = '1') else
                  '0';

    -- JMP salta para target-1 porque o ciclo de bolha NOP (flush) em estado=01
    -- sempre incrementa o PC em +1, entregando o PC correto ao target.
    -- Ex: JMP+15 com PC_execute=5 -> 5+15-1=19, bolha -> PC=20 (target) OK
    pc_next_o <= (pc_i + 1)            when estado_s = "01" else
                 (pc_i + offset_s - 1) when (estado_s = "10" and is_jmp_s = '1') else
                 pc_i;

    wr_en_reg_o <= '1' when (estado_s = "10" and
                             (is_ld_s = '1' or is_add_s = '1' or
                              is_subi_s = '1' or is_mov_s = '1')) else '0';

    reg_wr_o <= rd_s;
    reg_r1_o <= rs1_s;
    reg_r2_o <= rs2_s;

    sel_b_o  <= '1' when is_subi_s = '1' else '0';

    sel_wr_o <= "01" when is_ld_s  = '1' else
                "10" when is_mov_s = '1' else
                "00";

    ula_op_o <= "01" when is_subi_s = '1' else "00";

    estado_o <= estado_s;

end architecture;