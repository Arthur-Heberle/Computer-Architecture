library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM sincrona, 128 posicoes x 15 bits
-- Programa: crivo de Eratostenes (primos de 2 a 32).
-- O formato das instrucoes, os opcodes e o passo-a-passo do
-- programa estao em instrucoes.md.

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
        -- setup
        0  => "000100000000001",  -- LD   R0, 1        ; R0 = 1
        1  => "000111100000000",  -- LD   R7, 0        ; R7 = 0
        2  => "000110000000000",  -- LD   R4, 0        ; constroi R4 = -32 ...
        3  => "001110010001111",  -- SUBI R4, R4, 15   ;   R4 = -15
        4  => "001110010001111",  -- SUBI R4, R4, 15   ;   R4 = -30
        5  => "001110010000010",  -- SUBI R4, R4, 2    ;   R4 = -32
        -- fase 1: preencher RAM[1..32] = 1..32
        6  => "000111000000001",  -- LD   R6, 1        ; indice = 1
        7  => "000110100011111",  -- LD   R5, 31       ; contador = 32 ...
        8  => "001110110111111",  -- SUBI R5, R5, -1   ;   contador = 32
        9  => "011111011000000",  -- SW   R6, R6       ; RAM[indice]=indice (loop_fill)
        10 => "001011011000000",  -- ADD  R6, R6, R0   ; indice++
        11 => "100110100001001",  -- DJNZ R5, 9        ; repete 32x -> 9
        -- fase 2: crivo
        12 => "000101000000010",  -- LD   R2, 2        ; i = 2
        13 => "000110100011111",  -- LD   R5, 31       ; contador externo (i=2..32)
        14 => "001011001001000",  -- ADD  R6, R2, R2   ; k = 2*i           (loop_outer)
        15 => "001001111010000",  -- ADD  R3, R6, R4   ; R3=k-32 (flag BLE) (inner)
        16 => "010100000010010",  -- BLE  18           ; se k<=32 -> corpo(18)
        17 => "111111110000011",  -- JMP  +3           ; senao sai -> 21
        18 => "011111011100000",  -- SW   R6, R7       ; RAM[k]=0          (inner_body)
        19 => "001011011001000",  -- ADD  R6, R6, R2   ; k += i
        20 => "111111111111010",  -- JMP  -6           ; volta para inner (15)
        21 => "001001001000000",  -- ADD  R2, R2, R0   ; i++              (exit_inner)
        22 => "100110100001110",  -- DJNZ R5, 14       ; laco externo -> 14
        -- fase 3: ler e exibir RAM[2..32]
        23 => "000111000000010",  -- LD   R6, 2        ; indice = 2
        24 => "000110100011111",  -- LD   R5, 31       ; contador = 31
        25 => "100000111000000",  -- LW   R1, R6       ; R1 = RAM[indice]  (loop_read)
        26 => "001000100111100",  -- ADD  R1, R1, R7   ; ula_out = R1
        27 => "001011011000000",  -- ADD  R6, R6, R0   ; indice++
        28 => "100110100011001",  -- DJNZ R5, 25       ; repete 31x -> 25
        29 => "111111111111111",  -- JMP  -1           ; halt (self-loop)
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
