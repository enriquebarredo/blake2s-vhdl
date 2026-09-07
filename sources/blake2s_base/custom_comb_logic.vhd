----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2024 06:44:19 PM
-- Design Name: 
-- Module Name: custom_comb_logic - hodgepodge
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
use IEEE.NUMERIC_STD.ALL;

entity custom_logic is
    Port ( total_bytes_processed : in STD_LOGIC_VECTOR (63 downto 0);
           message_size : in STD_LOGIC_VECTOR (63 downto 0);
           final_block_ahead : out STD_LOGIC;
           final_block_already_hashed : out STD_LOGIC;
           last_block_test_addition: out std_logic_vector(63 downto 0);
           total_bytes_processed_plus_64 : out STD_LOGIC_VECTOR (63 downto 0);
           total_bytes_processed_plus_final_odd_bytes: out STD_LOGIC_VECTOR(63 downto 0);
           final_block_is_even : out STD_LOGIC);
end custom_logic;

architecture hodgepodge of custom_logic is

-- MUITO REAL
constant WIDTH : integer := 32;

signal COMPARADOR_BYTES_PROCESADOS, final_block_test_addition, final_block_test_comparison: std_logic_vector(2*WIDTH - 1 downto 0);

-- data path status signals
signal ULTIMO_BLOQUE_MIDE_64_BYTES : STD_LOGIC;

signal SUMA_64_BYTES_A_PROCESSED_BYTES, REEMPLAZA_BYTES_FINALES_A_processed_bytes : STD_LOGIC_VECTOR (2*WIDTH -1 downto 0);

signal last_block_length : std_logic_vector( 6 downto 0);

begin

-- most straightforward signal first, if the number of the bytes that have been processed
-- equals the number of bytes in the message currently being processed, then the state machine
-- has-just processed, is processing OR is about to process the final block
COMPARADOR_BYTES_PROCESADOS <= message_size xor total_bytes_processed;
final_block_already_hashed <= '1' when COMPARADOR_BYTES_PROCESADOS = x"0000000000000000" else '0';

-- just so i can make the script easier to write
-- we note precisely if the final block is 'even' (its size is that of a full block)
-- or if it's 'odd' (its size goes from 1 to 63 bytes) to make some operations a bit faster
ULTIMO_BLOQUE_MIDE_64_BYTES <= '1' when message_size(6 downto 0)= "0000000" else '0';
-- the line below assigns the exact size in case the final block is odd.
-- it  took TWO DAYS to debug a typo in here D:
last_block_length <= "1000000" when ULTIMO_BLOQUE_MIDE_64_BYTES = '1' else '0' & message_size(5 downto 0);
-- this signal is also a useful status signal for the control unit
final_block_is_even <= ULTIMO_BLOQUE_MIDE_64_BYTES;

-- this operator 'adds' the number of bytes that are found in the final block and
-- it's only used when the final block is 'odd': when it's not 64 bytes in length
REEMPLAZA_BYTES_FINALES_A_processed_bytes(63 DOWNTO 6) <= total_bytes_processed(63 DOWNTO 6);
REEMPLAZA_BYTES_FINALES_A_processed_bytes(5 DOWNTO 0) <= message_size(5 downto 0);
total_bytes_processed_plus_final_odd_bytes <= REEMPLAZA_BYTES_FINALES_A_processed_bytes;

-- this operator always adds 64 bytes to the current number of processed bytes, and
-- it's used when the final block is 64 bytes in length as well.
SUMA_64_BYTES_A_PROCESSED_BYTES(63 downto 6) <= std_logic_vector ( unsigned(total_bytes_processed(63 downto 6)) + 1 );
SUMA_64_BYTES_A_PROCESSED_BYTES(5 downto 0) <= "000000";
total_bytes_processed_plus_64 <= SUMA_64_BYTES_A_PROCESSED_BYTES;

--'look ahead' comparator' this one adds the final_block_length and then
--checks for the final block

-- original logic:
--final_block_test_addition <= std_logic_vector( unsigned(t_reg) + unsigned(last_block_length) );
--final_block_test_comparison <= total_message_length_reg xor final_block_test_addition;
--final_block_ahead <= '1' when final_block_test_comparison = x"0000000000000000" else '0';

final_block_test_addition <= SUMA_64_BYTES_A_PROCESSED_BYTES when ULTIMO_BLOQUE_MIDE_64_BYTES = '1' else REEMPLAZA_BYTES_FINALES_A_processed_bytes;
final_block_test_comparison <= message_size xor final_block_test_addition;
final_block_ahead <= '1' when final_block_test_comparison = x"0000000000000000" else '0';

last_block_test_addition <= final_block_test_addition;

end hodgepodge;
