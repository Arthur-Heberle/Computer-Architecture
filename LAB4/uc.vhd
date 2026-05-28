library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Estado 0 (fetch):
--   IR recebe dado da ROM (wr_en_ir = 1)
--   PC nao muda (wr_en_pc = 0)
--
-- Estado 1 (execute):
--   IR nao muda (wr_en_ir = 0)
--   PC eh atualizado (wr_en_pc = 1)
--   Se JMP: PC <= PC + constante
--   Se NOP: PC <= PC + 1
-- 
--   JMP incondicional eh relativo
--   PC+1 gravado entre estado 0 e estado 1 (no estado 1)
--   JMP executado no ultimo estado (estado 1)

entity uc is
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        instr_i    : in  unsigned(14 downto 0);  -- instrucao vinda do IR
        pc_i       : in  unsigned(6 downto 0);   -- valor atual do PC
        pc_next_o  : out unsigned(6 downto 0);   -- proximo valor do PC
        wr_en_pc_o : out std_logic;              -- habilita escrita no PC
        wr_en_ir_o : out std_logic;              -- habilita escrita no IR
        estado_o   : out std_logic               -- estado atual (debug)
    );
end entity;

architecture a_uc of uc is

    component flop_t is
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            estado : out std_logic
        );
    end component;

    signal estado_s  : std_logic;
    signal opcode_s  : unsigned(3 downto 0);
    signal const_s   : unsigned(10 downto 0);
    signal jump_en_s : std_logic;

    signal const_ext_s : unsigned(6 downto 0);

begin

    inst_flop_t: flop_t port map(
        clk    => clk,
        rst    => rst,
        estado => estado_s
    );

    opcode_s <= instr_i(14 downto 11);
    const_s  <= instr_i(10 downto 0);

    jump_en_s <= '1' when opcode_s = "1111" else '0';
	
	-- constante de 7 bits (tamanho do pc)
    const_ext_s <= const_s(6 downto 0);

    -- se JMP: PC + constante (relativo, complemento de 2)
    -- se NOP: PC + 1
    pc_next_o <= (pc_i + const_ext_s) when jump_en_s = '1' else
                 (pc_i + 1);

    wr_en_ir_o <= '1' when estado_s = '0' else '0';

    wr_en_pc_o <= '1' when estado_s = '1' else '0';

    -- saida do estado
    estado_o <= estado_s;

end architecture;
