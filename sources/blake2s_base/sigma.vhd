----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/19/2023 07:38:24 PM
-- Design Name: 
-- Module Name: sigma - flujo_de_datos
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sigma is
    Port (  block_word_00 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_01 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_02 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_03 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_04 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_05 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_06 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_07 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_08 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_09 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_10 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_11 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_12 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_13 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_14 : in STD_LOGIC_VECTOR (31 downto 0);
            block_word_15 : in STD_LOGIC_VECTOR (31 downto 0);
            sigma00 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma01 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma02 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma03 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma04 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma05 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma06 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma07 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma08 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma09 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma10 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma11 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma12 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma13 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma14 : out STD_LOGIC_VECTOR (31 downto 0);
            sigma15 : out STD_LOGIC_VECTOR (31 downto 0);
            sel : in STD_LOGIC_VECTOR (3 downto 0)
         );
end sigma;

architecture flujo_de_datos of sigma is

begin

-- sixteen 12 to 1 multiplexers (just in case i wanna do blake2b)
-- why is this so verbose. should rewrite this.
-- maybe i should define an entity for this.

--type matriz_10x16x16logicvector is array (0 to 9, 0 to 15) of integer range 0 to 15;
--    constant SIGMA : matriz_10x16x16logicvector :=
--    (    m 0 m 1 m 2 m 3 m 4 m 5 m 6 m 7 m 8 m 9 m10 m11 m12 m13 m14 m15
--        (  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 ),
--        ( 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 ),
--        ( 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 ),
--        (  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 ),
--        (  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 ),
--        (  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 ),
--        ( 12,  5,  1, 15, 14, 13,  4,  10, 0,  7,  6,  3,  9,  2,  8, 11 ),
--        ( 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10 ),
--        (  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5 ),
--        ( 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13,  0 )
--    );

with sel select sigma00 <=
    block_word_00 when "0000",
    block_word_14 when "0001",
    block_word_11 when "0010",
    block_word_07 when "0011",
    block_word_09 when "0100",
    block_word_02 when "0101",
    block_word_12 when "0110",
    block_word_13 when "0111",
    block_word_06 when "1000",
    block_word_10 when "1001",
--    block_word_00 when "1010",
--    block_word_14 when "1011",
    (others => '0') when others;

with sel select sigma01 <=
    block_word_01 when "0000",
    block_word_10 when "0001",
    block_word_08 when "0010",
    block_word_09 when "0011",
    block_word_00 when "0100",
    block_word_12 when "0101",
    block_word_05 when "0110",
    block_word_11 when "0111",
    block_word_15 when "1000",
    block_word_02 when "1001",
--    block_word_01 when "1010",
--    block_word_10 when "1011",
    (others => '0') when others;

with sel select sigma02 <=
    block_word_02 when "0000",
    block_word_04 when "0001",
    block_word_12 when "0010",
    block_word_03 when "0011",
    block_word_05 when "0100",
    block_word_06 when "0101",
    block_word_01 when "0110",
    block_word_07 when "0111",
    block_word_14 when "1000",
    block_word_08 when "1001",
--    block_word_02 when "1010",
--    block_word_04 when "1011",
    (others => '0') when others;

with sel select sigma03 <=
    block_word_03 when "0000",
    block_word_08 when "0001",
    block_word_00 when "0010",
    block_word_01 when "0011",
    block_word_07 when "0100",
    block_word_10 when "0101",
    block_word_15 when "0110",
    block_word_14 when "0111",
    block_word_09 when "1000",
    block_word_04 when "1001",
--    block_word_03 when "1010",
--    block_word_08 when "1011",
    (others => '0') when others;

with sel select sigma04 <=
    block_word_04 when "0000",
    block_word_09 when "0001",
    block_word_05 when "0010",
    block_word_13 when "0011",
    block_word_02 when "0100",
    block_word_00 when "0101",
    block_word_14 when "0110",
    block_word_12 when "0111",
    block_word_11 when "1000",
    block_word_07 when "1001",
--    block_word_04 when "1010",
--    block_word_09 when "1011",
    (others => '0') when others;

with sel select sigma05 <=
    block_word_05 when "0000",
    block_word_15 when "0001",
    block_word_02 when "0010",
    block_word_12 when "0011",
    block_word_04 when "0100",
    block_word_11 when "0101",
    block_word_13 when "0110",
    block_word_01 when "0111",
    block_word_03 when "1000",
    block_word_06 when "1001",
--    block_word_05 when "1010",
--    block_word_15 when "1011",
    (others => '0') when others;

with sel select sigma06 <=
    block_word_06 when "0000",
    block_word_13 when "0001",
    block_word_15 when "0010",
    block_word_11 when "0011",
    block_word_10 when "0100",
    block_word_08 when "0101",
    block_word_04 when "0110",
    block_word_03 when "0111",
    block_word_00 when "1000",
    block_word_01 when "1001",
--    block_word_06 when "1010",
--    block_word_13 when "1011",
    (others => '0') when others;

with sel select sigma07 <=
    block_word_07 when "0000",
    block_word_06 when "0001",
    block_word_13 when "0010",
    block_word_14 when "0011",
    block_word_15 when "0100",
    block_word_03 when "0101",
    block_word_10 when "0110",
    block_word_09 when "0111",
    block_word_08 when "1000",
    block_word_05 when "1001",
--    block_word_07 when "1010",
--    block_word_06 when "1011",
    (others => '0') when others;

with sel select sigma08 <=
    block_word_08 when "0000",
    block_word_01 when "0001",
    block_word_10 when "0010",
    block_word_02 when "0011",
    block_word_14 when "0100",
    block_word_04 when "0101",
    block_word_00 when "0110",
    block_word_05 when "0111",
    block_word_12 when "1000",
    block_word_15 when "1001",
--    block_word_08 when "1010",
--    block_word_01 when "1011",
    (others => '0') when others;

with sel select sigma09 <=
    block_word_09 when "0000",
    block_word_12 when "0001",
    block_word_14 when "0010",
    block_word_06 when "0011",
    block_word_01 when "0100",
    block_word_13 when "0101",
    block_word_07 when "0110",
    block_word_00 when "0111",
    block_word_02 when "1000",
    block_word_11 when "1001",
--    block_word_09 when "1010",
--    block_word_12 when "1011",
    (others => '0') when others;

with sel select sigma10 <=
    block_word_10 when "0000",
    block_word_00 when "0001",
    block_word_03 when "0010",
    block_word_05 when "0011",
    block_word_11 when "0100",
    block_word_07 when "0101",
    block_word_06 when "0110",
    block_word_15 when "0111",
    block_word_13 when "1000",
    block_word_09 when "1001",
--    block_word_10 when "1010",
--    block_word_00 when "1011",
    (others => '0') when others;

with sel select sigma11 <=
    block_word_11 when "0000",
    block_word_02 when "0001",
    block_word_06 when "0010",
    block_word_10 when "0011",
    block_word_12 when "0100",
    block_word_05 when "0101",
    block_word_03 when "0110",
    block_word_04 when "0111",
    block_word_07 when "1000",
    block_word_14 when "1001",
--    block_word_11 when "1010",
--    block_word_02 when "1011",
    (others => '0') when others;

with sel select sigma12 <=
    block_word_12 when "0000",
    block_word_11 when "0001",
    block_word_07 when "0010",
    block_word_04 when "0011",
    block_word_06 when "0100",
    block_word_15 when "0101",
    block_word_09 when "0110",
    block_word_08 when "0111",
    block_word_01 when "1000",
    block_word_03 when "1001",
--    block_word_12 when "1010",
--    block_word_11 when "1011",
    (others => '0') when others;

with sel select sigma13 <=
    block_word_13 when "0000",
    block_word_07 when "0001",
    block_word_01 when "0010",
    block_word_00 when "0011",
    block_word_08 when "0100",
    block_word_14 when "0101",
    block_word_02 when "0110",
    block_word_06 when "0111",
    block_word_04 when "1000",
    block_word_12 when "1001",
--    block_word_13 when "1010",
--    block_word_07 when "1011",
    (others => '0') when others;

with sel select sigma14 <=
    block_word_14 when "0000",
    block_word_05 when "0001",
    block_word_09 when "0010",
    block_word_15 when "0011",
    block_word_03 when "0100",
    block_word_01 when "0101",
    block_word_08 when "0110",
    block_word_02 when "0111",
    block_word_10 when "1000",
    block_word_13 when "1001",
--    block_word_14 when "1010",
--    block_word_05 when "1011",
    (others => '0') when others;

with sel select sigma15 <=
    block_word_15 when "0000",
    block_word_03 when "0001",
    block_word_04 when "0010",
    block_word_08 when "0011",
    block_word_13 when "0100",
    block_word_09 when "0101",
    block_word_11 when "0110",
    block_word_10 when "0111",
    block_word_05 when "1000",
    block_word_00 when "1001",
--    block_word_15 when "1010",
--    block_word_03 when "1011",
    (others => '0') when others;

end flujo_de_datos;