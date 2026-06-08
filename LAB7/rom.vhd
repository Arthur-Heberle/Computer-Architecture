library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM sincrona, 128 posicoes x 15 bits
--
-- FORMATO DA INSTRUCAO (15 bits):
--   [14:11] opcode  [10:8] Rd  [7:5] Rs1  [4:2] Rs2  [4:0] cte5
--
-- OPCODES:
--   0000 = NOP
--   0001 = LD   Rd, cte5
--   0010 = ADD  Rd, Rs1, Rs2
--   0011 = SUBI Rd, Rs1, cte5  (cte em complemento de 2)
--   0100 = MOV  Rd, Rs1
--   0101 = BLE  addr            (absoluto)
--   0110 = BCC  addr            (absoluto)
--   0111 = SW   Rs_addr, Rs_data  -- RAM[Rs_addr] = Rs_data
--   1000 = LW   Rd, Rs_addr      -- Rd = RAM[Rs_addr]
--   1111 = JMP  offset           (relativo, complemento de 2)
--
-- PROGRAMA DE TESTE (Lab 7):
--   end  0: LD  R1, 10
--   end  1: LD  R2, 7
--   end  2: SW  R1, R2     -- RAM[10] = 7
--   end  3: LD  R3, 25
--   end  4: LD  R4, 17
--   end  5: SW  R3, R4     -- RAM[25] = 17
--   end  6: LD  R5, 5
--   end  7: LD  R6, 31
--   end  8: SW  R5, R6     -- RAM[5] = 31
--   end  9: LD  R7, 20
--   end 10: LD  R0, 9
--   end 11: SW  R7, R0     -- RAM[20] = 9
--   end 12: LW  R2, R3     -- R2 = RAM[25] = 17
--   end 13: LW  R4, R5     -- R4 = RAM[5]  = 31
--   end 14: LW  R6, R7     -- R6 = RAM[20] = 9
--   end 15: LW  R0, R1     -- R0 = RAM[10] = 7

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
        0  => "000100100001010",  -- LD R1, 10
        1  => "000101000000111",  -- LD R2, 7
        2  => "011100101000000",  -- SW R1, R2  (RAM[10]=7)
        3  => "000101100011001",  -- LD R3, 25
        4  => "000110000010001",  -- LD R4, 17
        5  => "011101110000000",  -- SW R3, R4  (RAM[25]=17)
        6  => "000110100000101",  -- LD R5, 5
        7  => "000111000011111",  -- LD R6, 31
        8  => "011110111000000",  -- SW R5, R6  (RAM[5]=31)
        9  => "000111100010100",  -- LD R7, 20
        10 => "000100000001001",  -- LD R0, 9
        11 => "011111100000000",  -- SW R7, R0  (RAM[20]=9)
        12 => "100001001100000",  -- LW R2, R3  (R2=RAM[25]=17)
        13 => "100010010100000",  -- LW R4, R5  (R4=RAM[5]=31)
        14 => "100011011100000",  -- LW R6, R7  (R6=RAM[20]=9)
        15 => "100000000100000",  -- LW R0, R1  (R0=RAM[10]=7)
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
