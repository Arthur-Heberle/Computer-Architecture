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
--   1111 = JMP  offset          (relativo: target = JMP_addr + offset)
--
-- PROGRAMA DE TESTE - testa todas as instrucoes sorteadas:
--
--   LAB 2/6:  BLE, BCC (saltos condicionais, absolutos)
--   LAB 3/5:  ADD (somente regs), SUBI (com constante), LD (carrega diretamente)
--   LAB 4:    JMP (relativo, incondicional)
--   LAB 7/8:  DJNZ (loop), Excecao endereco invalido ROM
--             Divisor de 983 no bus debug (ula_out_o = 983)
--
-- ASSEMBLY:
--
--   ; --- Test LD ---
--   end  0: LD  R0, 1
--   end  1: LD  R1, 15
--   end  2: LD  R3, 10
--
--   ; --- Test ADD (somente registradores) ---
--   end  3: ADD R4, R1, R3     ; R4 = 25, seta BCC=1 (sem carry)
--
--   ; --- Test BCC ---
--   end  4: BCC 6              ; BCC flag=1 -> salta para 6
--   end  5: JMP +122           ; erro: nunca executado (-> addr 127)
--
--   ; --- Test SUBI ---
--   end  6: SUBI R5, R4, 5    ; R5 = 20
--   end  7: SUBI R4, R4, 15   ; R4 = 10
--   end  8: SUBI R4, R4, 10   ; R4 = 0, seta BLE=1 (Z=1)
--
--   ; --- Test BLE ---
--   end  9: BLE 11             ; BLE flag=1 -> salta para 11
--   end 10: JMP +117           ; erro: nunca executado (-> addr 127)
--
--   ; --- Test MOV ---
--   end 11: MOV R7, R5         ; R7 = 20
--
--   ; --- Test SW / LW ---
--   end 12: LD  R3, 10
--   end 13: LD  R4, 30
--   end 14: SW  R3, R4         ; RAM[10] = 30
--   end 15: LW  R5, R3         ; R5 = RAM[10] = 30
--
--   ; --- Loop DJNZ: constroi 983 = 31*31 + 22 ---
--   end 16: LD  R1, 31         ; passo
--   end 17: LD  R2, 0          ; acumulador
--   end 18: LD  R3, 31         ; contador DJNZ
-- loop983:
--   end 19: ADD R2, R2, R1     ; R2 += 31
--   end 20: DJNZ R3, 19        ; 31 iteracoes -> R2 = 961
--   end 21: LD  R4, 22
--   end 22: ADD R1, R2, R4     ; R1 = 983
--
--   ; --- Debug bus: exibe 983 em ula_out_o ---
--   end 23: LD  R2, 0
--   end 24: ADD R0, R1, R2     ; ula_out = 983
--
--   ; --- Test JMP relativo ---
--   end 25: JMP +2             ; salta para addr 27 (pula addr 26)
--   end 26: LD  R0, 0          ; IGNORADO
--
--   ; --- Excecao endereco invalido ROM ---
--   end 27: JMP +100           ; -> addr 127
--
--   ; loop de excecao: PC preso em 127, exception_o='1'
--   end 127: ADD R0, R0, R2    ; ula_out = 983 perpetuamente

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
        --  [14:11] [10:8] [7:5] [4:0]
         0 => "000100000000001",  -- LD  R0, 1
         1 => "000100100001111",  -- LD  R1, 15
         2 => "000101100001010",  -- LD  R3, 10
         3 => "001010000101100",  -- ADD R4, R1, R3    R4=25, BCC=1
         4 => "011000000000110",  -- BCC 6
         5 => "111111111111010",  -- JMP +122 -> 127   (erro)
         6 => "001110110000101",  -- SUBI R5, R4, 5    R5=20
         7 => "001110010001111",  -- SUBI R4, R4, 15   R4=10
         8 => "001110010001010",  -- SUBI R4, R4, 10   R4=0, BLE=1
         9 => "010100000001011",  -- BLE 11
        10 => "111111111110101",  -- JMP +117 -> 127   (erro)
        11 => "010011110100000",  -- MOV R7, R5        R7=20
        12 => "000101100001010",  -- LD  R3, 10
        13 => "000110000011110",  -- LD  R4, 30
        14 => "011101110000000",  -- SW  R3, R4        RAM[10]=30
        15 => "100010101100000",  -- LW  R5, R3        R5=30
        16 => "000100100011111",  -- LD  R1, 31
        17 => "000101000000000",  -- LD  R2, 0
        18 => "000101100011111",  -- LD  R3, 31
        19 => "001001001000100",  -- ADD R2, R2, R1
        20 => "100101100010011",  -- DJNZ R3, 19
        21 => "000110000010110",  -- LD  R4, 22
        22 => "001000101010000",  -- ADD R1, R2, R4    R1=983
        23 => "000101000000000",  -- LD  R2, 0
        24 => "001000000101000",  -- ADD R0, R1, R2    ula_out=983
        25 => "111111110000010",  -- JMP +2 -> 27
        26 => "000100000000000",  -- LD  R0, 0         (IGNORADO)
        27 => "111111111100100",  -- JMP +100 -> 127
       127 => "001000000001000",  -- ADD R0, R0, R2    loop excecao
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
