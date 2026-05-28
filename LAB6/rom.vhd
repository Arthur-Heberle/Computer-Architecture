library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM sincrona, 128 posicoes x 15 bits
--
-- FORMATO DA INSTRUCAO (15 bits):
--   [14:11] opcode  [10:8] Rd  [7:5] Rs1  [4:2] Rs2  [4:0] cte5  [10:0] addr/offset
--
-- OPCODES:
--   0000 = NOP
--   0001 = LD   Rd, cte5
--   0010 = ADD  Rd, Rs1, Rs2
--   0011 = SUBI Rd, Rs1, cte5   (cte em complemento de 2)
--   0100 = MOV  Rd, Rs1
--   0101 = BLE  addr            (absoluto, salta se flag BLE=1)
--   0110 = BCC  addr            (absoluto, salta se flag BCC=1)
--   1111 = JMP  offset          (relativo, complemento de 2)
--
-- PROGRAMA DE TESTE (Lab 6):
--   end 0: LD   R3, 0
--   end 1: LD   R4, 0
--   end 2: ADD  R4, R3, R4       (passo C, alvo do loop)
--   end 3: SUBI R3, R3, -1       (passo D: R3 = R3+1, seta flags)
--   end 4: SUBI R0, R3, 30       (compara R3 com 30, seta BLE)
--   end 5: BLE  2                (passo E: se R3<=30, volta para end 2)
--   end 6: MOV  R5, R4           (passo F: R5 = R4)

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
        0 => "000101100000000",  -- LD R3, 0
        1 => "000110000000000",  -- LD R4, 0
        2 => "001010001110000",  -- ADD R4, R3, R4
        3 => "001101101111111",  -- SUBI R3, R3, -1  (R3 = R3+1)
        4 => "001100001111110",  -- SUBI R0, R3, 30  (seta flags)
        5 => "010100000000010",  -- BLE 2
        6 => "010010110000000",  -- MOV R5, R4
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
