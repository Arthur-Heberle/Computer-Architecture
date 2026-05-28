library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port(
        clk      : in  std_logic;
        endereco : in  unsigned(6 downto 0);   -- 7 bits -> 128 posicoes
        dado     : out unsigned(14 downto 0)   -- 15 bits por instrucao
    );
end entity;

architecture a_rom of rom is

    type mem is array (0 to 127) of unsigned(14 downto 0);

    -- Formato da instrucao (15 bits):
    -- bits [14:11] = opcode (4 bits)
    -- bits [10:0]  = constante (11 bits, complemento de 2 para JMP relativo)
    --
    -- Opcodes:
    -- 0000 = NOP
    -- 1111 = JMP incondicional relativo
    --
    -- Programa de teste:
    -- end 0: NOP
    -- end 1: NOP
    -- end 2: JMP +3  -> salta para end 5 (PC_atual + 3 = 2 + 3 = 5)
    -- end 3: NOP     -> nunca executado
    -- end 4: NOP     -> nunca executado
    -- end 5: NOP
    -- end 6: JMP -4  -> salta para end 2 (6 + (-4) = 2) -> loop
    -- end 7: NOP     -> nunca executado

    constant conteudo_rom : mem := (
        -- opcode(4) | constante(11)
        0  => "0000" & "00000000000",  -- NOP
        1  => "0000" & "00000000000",  -- NOP
        2  => "1111" & "00000000011",  -- JMP +3 (vai para end 5)
        3  => "0000" & "00000000000",  -- NOP (nunca executado)
        4  => "0000" & "00000000000",  -- NOP (nunca executado)
        5  => "0000" & "00000000000",  -- NOP
        6  => "1111" & "11111111100",  -- JMP -4 em complemento de 2 (volta para end 2)
        7  => "0000" & "00000000000",  -- NOP (nunca executado)
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
