library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM sincrona, 128 posicoes x 15 bits
--
-- FORMATO DA INSTRUCAO (15 bits):
--   bits [14:11] = opcode (4 bits)
--   bits [10:8]  = Rd  registrador destino (3 bits)
--   bits [7:5]   = Rs1 registrador fonte 1 (3 bits)
--   bits [4:2]   = Rs2 registrador fonte 2 (3 bits) -- ADD, MOV
--   bits [4:0]   = constante (5 bits)               -- LD, SUBI
--   bits [10:0]  = offset (11 bits, comp2)          -- JMP
--
-- OPCODES:
--   0000 = NOP
--   0001 = LD   Rd, cte       Rd = cte
--   0010 = ADD  Rd, Rs1, Rs2  Rd = Rs1 + Rs2
--   0011 = SUBI Rd, Rs1, cte  Rd = Rs1 - cte
--   0100 = MOV  Rd, Rs1       Rd = Rs1
--   1111 = JMP  offset        PC = PC + offset
--
-- PROGRAMA DE TESTE:
--   end  0: LD   R3, 5
--   end  1: LD   R4, 8
--   end  2: ADD  R5, R3, R4   (passo C, alvo do loop)
--   end  3: SUBI R5, R5, 1    (passo D)
--   end  4: JMP  +15          (passo E, salta para end 20)
--   end  5: LD   R5, 0        (passo F, NUNCA executado)
--   end 20: MOV  R3, R5       (passo G)
--   end 21: JMP  -20          (passo H, volta para end 2)
--   end 22: LD   R3, 0        (passo I, NUNCA executado)
--
-- CALCULO DE OFFSETS (PC no execute = endereco_instrucao + 1):
--   JMP end4: destino=20, offset = 20-(4+1) = 15
--   JMP end21: destino=2, offset = 2-(21+1) = -20

entity rom is
    port(
        clk      : in  std_logic;
        endereco : in  unsigned(6 downto 0);
        dado     : out unsigned(14 downto 0)
    );
end entity;

architecture a_rom of rom is

    type mem is array (0 to 127) of unsigned(14 downto 0);

    constant conteudo_rom : mem := (
        0  => "000101100000101",  -- LD R3, 5
        1  => "000110000001000",  -- LD R4, 8
        2  => "001010101110000",  -- ADD R5, R3, R4
        3  => "001110110100001",  -- SUBI R5, R5, 1
        4  => "111100000001111",  -- JMP +15 (para end 20)
        5  => "000110100000000",  -- LD R5, 0 (NUNCA executado)
        6  => (others => '0'),
        7  => (others => '0'),
        8  => (others => '0'),
        9  => (others => '0'),
        10 => (others => '0'),
        11 => (others => '0'),
        12 => (others => '0'),
        13 => (others => '0'),
        14 => (others => '0'),
        15 => (others => '0'),
        16 => (others => '0'),
        17 => (others => '0'),
        18 => (others => '0'),
        19 => (others => '0'),
        20 => "010001110100000",  -- MOV R3, R5
        21 => "111111111101100",  -- JMP -20 (volta para end 2)
        22 => "000101100000000",  -- LD R3, 0 (NUNCA executado)
        others => (others => '0')
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            dado <= conteudo_rom(to_integer(endereco));
        end if;
    end process;

end architecture;
