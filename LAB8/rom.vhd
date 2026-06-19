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
--   0111 = SW   Rs_addr, Rs_data
--   1000 = LW   Rd, Rs_addr
--   1001 = DJNZ Rd, addr        (decrementa Rd; se !=0 salta para addr)
--   1111 = JMP  offset          (relativo, complemento de 2)
--
-- PROGRAMA: Crivo de Eratostenes (primos de 2 a 32)
--
-- REGISTRADORES FIXOS:
--   R0 = 1  (incremento)
--   R7 = 0  (zero para eliminacao)
--   R6 = ponteiro de endereco RAM
--   R5 = contador DJNZ
--   R1 = valor lido da RAM (saida)
--
-- ASSEMBLY:
--   ; setup
--   LD R0, 1
--   LD R7, 0
--   ; fase 1: preencher RAM[2..32] com 2..32
--   LD R6, 2
--   LD R5, 31
-- loop_fill:
--   SW R6, R6        ; RAM[R6] = R6
--   ADD R6, R6, R0   ; R6++
--   DJNZ R5, loop_fill
--   ; fase 2: zerar multiplos de 2 (4,6,...,30)
--   LD R6, 4 / SW R6, R7  ... (repetido para 4,6,...,30)
--   LD R6, 31 / SUBI R6, R6, -1  ; R6=32
--   SW R6, R7        ; RAM[32]=0
--   ; fase 3: multiplos de 3 restantes (9,15,21,27)
--   ; fase 4: multiplos de 5 restantes (25)
--   ; fase 5: ler e exibir RAM[2..32]
--   LD R6, 2
--   LD R5, 31
-- loop_read:
--   LW R1, R6        ; R1 = RAM[R6]
--   ADD R1, R1, R7   ; ula_out = R1
--   ADD R6, R6, R0   ; R6++
--   DJNZ R5, loop_read
--   JMP -1           ; loop infinito

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
        0  => "000100000000001",  -- LD R0, 1
        1  => "000111100000000",  -- LD R7, 0
        2  => "000111000000010",  -- LD R6, 2
        3  => "000110100011111",  -- LD R5, 31
        4  => "011111011000000",  -- SW R6, R6
        5  => "001011011000000",  -- ADD R6, R6, R0
        6  => "100110100000100",  -- DJNZ R5, 4  (loop_fill)
        7  => "000111000000100",  -- LD R6, 4
        8  => "011111011100000",  -- SW R6, R7
        9  => "000111000000110",  -- LD R6, 6
        10 => "011111011100000",  -- SW R6, R7
        11 => "000111000001000",  -- LD R6, 8
        12 => "011111011100000",  -- SW R6, R7
        13 => "000111000001010",  -- LD R6, 10
        14 => "011111011100000",  -- SW R6, R7
        15 => "000111000001100",  -- LD R6, 12
        16 => "011111011100000",  -- SW R6, R7
        17 => "000111000001110",  -- LD R6, 14
        18 => "011111011100000",  -- SW R6, R7
        19 => "000111000010000",  -- LD R6, 16
        20 => "011111011100000",  -- SW R6, R7
        21 => "000111000010010",  -- LD R6, 18
        22 => "011111011100000",  -- SW R6, R7
        23 => "000111000010100",  -- LD R6, 20
        24 => "011111011100000",  -- SW R6, R7
        25 => "000111000010110",  -- LD R6, 22
        26 => "011111011100000",  -- SW R6, R7
        27 => "000111000011000",  -- LD R6, 24
        28 => "011111011100000",  -- SW R6, R7
        29 => "000111000011010",  -- LD R6, 26
        30 => "011111011100000",  -- SW R6, R7
        31 => "000111000011100",  -- LD R6, 28
        32 => "011111011100000",  -- SW R6, R7
        33 => "000111000011110",  -- LD R6, 30
        34 => "011111011100000",  -- SW R6, R7
        35 => "000111000011111",  -- LD R6, 31
        36 => "001111011011111",  -- SUBI R6, R6, -1  (R6=32)
        37 => "011111011100000",  -- SW R6, R7
        38 => "000111000001001",  -- LD R6, 9
        39 => "011111011100000",  -- SW R6, R7
        40 => "000111000001111",  -- LD R6, 15
        41 => "011111011100000",  -- SW R6, R7
        42 => "000111000010101",  -- LD R6, 21
        43 => "011111011100000",  -- SW R6, R7
        44 => "000111000011011",  -- LD R6, 27
        45 => "011111011100000",  -- SW R6, R7
        46 => "000111000011001",  -- LD R6, 25
        47 => "011111011100000",  -- SW R6, R7
        48 => "000111000000010",  -- LD R6, 2
        49 => "000110100011111",  -- LD R5, 31
        50 => "100000111000000",  -- LW R1, R6
        51 => "001000100111100",  -- ADD R1, R1, R7
        52 => "001011011000000",  -- ADD R6, R6, R0
        53 => "100110100110010",  -- DJNZ R5, 50  (loop_read)
        54 => "111111111111111",  -- JMP -1  (loop infinito)
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
