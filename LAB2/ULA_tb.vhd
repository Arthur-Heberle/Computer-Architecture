library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA_tb is
end entity;

architecture a_ula_tb of ULA_tb is

   component ULA is
      port (   x,y    : in  unsigned(15 downto 0);
               op     : in  unsigned(1 downto 0);
               output : out unsigned(15 downto 0);
               C,Z,N,V,BLE,BCC : out std_logic
      );
   end component;

   signal x, y    : unsigned(15 downto 0);
   signal op      : unsigned(1 downto 0);
   signal output  : unsigned(15 downto 0);
   signal C, Z, N, V, BLE, BCC : std_logic;

begin

   uut: ULA port map(
        x => x,
        y => y,
        op => op,
        output => output,
        C => C,
        Z => Z,
        N => N,
        V => V,
        BLE => BLE,
        BCC => BCC
   );

   x <= "0000000000000101",
        "0000000000000000" after 50 ns,
        "1111111111111111" after 100 ns,
        "0111111111111111" after 150 ns,
        "1111111111111111" after 200 ns,
        "0000000000001010" after 250 ns,
        "0000000000000101" after 300 ns,
        "0000000000000011" after 350 ns,
        "1000000000000000" after 400 ns,
        "1111111100000000" after 450 ns,
        "1010101010101010" after 500 ns,
        "1111000011110000" after 550 ns,
        "0000000000000000" after 600 ns,
        "1000000000000000" after 650 ns;

   y <= "0000000000000011",
        "0000000000000000" after 50 ns,
        "0000000000000001" after 100 ns,
        "0000000000000001" after 150 ns,
        "1111111111111111" after 200 ns,
        "0000000000000011" after 250 ns,
        "0000000000000101" after 300 ns,
        "0000000000001010" after 350 ns,
        "0000000000000001" after 400 ns,
        "0000111111110000" after 450 ns,
        "0101010101010101" after 500 ns,
        "0000111100001111" after 550 ns,
        "0000000000000000" after 600 ns,
        "0000000000000001" after 650 ns;

   op <= "00",
         "00" after 50 ns,
         "00" after 100 ns,
         "00" after 150 ns,
         "00" after 200 ns,
         "01" after 250 ns,
         "01" after 300 ns,
         "01" after 350 ns,
         "01" after 400 ns,
         "10" after 450 ns,
         "10" after 500 ns,
         "11" after 550 ns,
         "11" after 600 ns,
         "11" after 650 ns;

end architecture;
