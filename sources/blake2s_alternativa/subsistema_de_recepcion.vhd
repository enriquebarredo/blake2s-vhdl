-- SPDX-FileCopyrightText: 2024-2026 Josue Enrique Barredo Alamilla
-- SPDX-License-Identifier: CERN-OHL-S-2.0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity subsistema_de_recepcion is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;

           rx_in : in STD_LOGIC;
           -- expecting_initial_parameters_input_signal : in STD_LOGIC;
           -- status_reading_port : out STD_LOGIC;
           block_full : out STD_LOGIC;
           
           wrd_0 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_1 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_2 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_3 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_4 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_5 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_6 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_7 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_8 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_9 : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_a : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_b : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_c : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_d : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_e : out STD_LOGIC_VECTOR (31 downto 0);
           wrd_f : out STD_LOGIC_VECTOR (31 downto 0)
           );
end subsistema_de_recepcion;

architecture el_atrocidad of subsistema_de_recepcion is


    component uart_receiver is
        Port (  clk : in STD_LOGIC;
                clr : in STD_LOGIC;
                uart_rx : in STD_LOGIC;
                
                ready: out STD_LOGIC;
                uart_rx_data : out STD_LOGIC_VECTOR (7 downto 0)
             );
    end component;

constant WIDTH : integer := 32;

type std_logic_aoa is
    array (natural range <>) of std_logic_vector(WIDTH - 1 downto 0);

    signal digest : std_logic_aoa(0 to 7);


--signals for uart modules data
signal uart_rx_data: std_logic_vector(7 downto 0);

signal receiver_ready_reg: std_logic := '1';


--signals for data registers
type m_word is
    array (3 downto 0) of std_logic_vector(7 downto 0);

type d_block is
    array (0 to 15) of m_word;

signal block_reg, block_next : d_block;

signal word_reg, word_next : m_word;

signal bytecount_reg, bytecount_next, bytecount_adder : std_logic_vector(1 downto 0); -- each word is made up of 4 bytes
signal wordcount_reg, wordcount_next, wordcount_adder : std_logic_vector(3 downto 0); -- each block is made up of 16 words

--signals for fsm
type state is (initial_idle, idle, building_word, building_block, awaiting_next_byte, input_registers_full);
signal state_reg, state_next : state;

--  status signals 
signal receiver_ready, do_send_data, new_byte_ready: std_logic;

begin


------------------------------------------------------------------
--control path:
------------------------------------------------------------------

---  state register
process(clk, clr)
begin
    if (clr='1') then
        state_reg <= idle;
    elsif rising_edge(clk) then
        state_reg <= state_next;
    end if;
end process;

-----------  fsm next-state logic
----------  also external signals
process(state_reg, new_byte_ready, bytecount_reg, do_send_data, wordcount_reg, bytecount_next)
begin
    case state_reg is

        when initial_idle =>
             if new_byte_ready = '1' then
                state_next <= building_word;
            else
                state_next <= initial_idle;
            end if;

        when idle =>

            if new_byte_ready = '1' then
                state_next <= building_word;
            else
                state_next <= idle;
            end if;

        when building_word =>
        
            if bytecount_reg = "11" then
                state_next <= building_block;
            else
                state_next <= awaiting_next_byte;
            end if;

        when building_block =>

            if wordcount_reg = "1111" then
                state_next <= input_registers_full;
            else
                state_next <= awaiting_next_byte;
            end if;

        when awaiting_next_byte =>
        
            if new_byte_ready = '1' then
                state_next <= building_word;
            else
                state_next <= awaiting_next_byte;
            end if;
        
        when input_registers_full =>
        
            state_next <= idle;
    end case;
end process;

---------------------------------
---------------  functional units
---------------------------------

------- strobe register (new byte incoming)
uart_rx_process : process (clk)
begin
	if (rising_edge(clk)) then
		receiver_ready_reg <= receiver_ready;
	end if;
end process;

-- edge detector for incoming rx
new_byte_ready <= '1' when (receiver_ready_reg='0' and receiver_ready='1') else
				  '0';

---------------------------------
----------  data path  ----------
---------------------------------

------------------  data register
process(clk, clr)
begin
    if clr = '1' then
    
        word_reg <= (others =>(others => '0'));    --looks funny, would << (others =>x"00000000") >> look better?
        block_reg <= (others => (others => (others => '0')));   --looks daft
        bytecount_reg <= (others => '0');
        wordcount_reg <= (others => '0');
        
    elsif clk'event and clk = '1' then
    
        bytecount_reg <= bytecount_next;
        wordcount_reg <= wordcount_next;
        word_reg <= word_next;
        block_reg <= block_next;
        
    end if;
end process;

------------------  routing muxer
process(state_reg, word_reg, uart_rx_data, bytecount_reg, bytecount_adder, wordcount_reg, block_reg, wordcount_adder, bytecount_next)
begin
    --default rt operations
            bytecount_next <= bytecount_reg;
            wordcount_next <= wordcount_reg;
            word_next <= word_reg;
            block_next <= block_reg;
    
    --default status/signal routing
            -- status_reading_port <= '0';
            block_full <= '0';

    case state_reg is
    
        when initial_idle => 
        
            bytecount_next <= (others => '0');
            wordcount_next <= (others => '0');
            word_next <= (others => (others => '0')); -- looks dopey
            block_next <= (others => (others => (others => '0'))); -- looks nutty
            
        when idle =>
        
            -- status_reading_port <= '1';

        when building_word =>
        
            bytecount_next <= bytecount_adder;
            
            if bytecount_reg = "00" then
            
                word_next(3) <= uart_rx_data;
                
            elsif bytecount_reg = "01" then

                word_next(2) <= uart_rx_data;
                
            elsif bytecount_reg = "10" then
            
                word_next(1) <= uart_rx_data;
            
            elsif bytecount_reg = "11" then
            
                word_next(0) <= uart_rx_data;
            
            else
            
                word_next <= (others => (others => '0'));
            
            end if;

        when building_block =>

            wordcount_next <= wordcount_adder;
            word_next <= (others => (others => '0'));
            -- there's no point in resetting byte_count; once you add "01" to "11" in a two-bit adder, it just cycles back to "00"
            
            if wordcount_reg = "0000" then
                block_next(0) <= word_reg;

            elsif wordcount_reg = "0001" then
                block_next(1) <= word_reg;

            elsif wordcount_reg = "0010" then
                block_next(2) <= word_reg;

            elsif wordcount_reg = "0011" then
                block_next(3) <= word_reg;

            elsif wordcount_reg = "0100" then
                block_next(4) <= word_reg;

            elsif wordcount_reg = "0101" then
                block_next(5) <= word_reg;

            elsif wordcount_reg = "0110" then
                block_next(6) <= word_reg;

            elsif wordcount_reg = "0111" then
                block_next(7) <= word_reg;

            elsif wordcount_reg = "1000" then
                block_next(8) <= word_reg;

            elsif wordcount_reg = "1001" then
                block_next(9) <= word_reg;

            elsif wordcount_reg = "1010" then
                block_next(10) <= word_reg;

            elsif wordcount_reg = "1011" then
                block_next(11) <= word_reg;

            elsif wordcount_reg = "1100" then
                block_next(12) <= word_reg;

            elsif wordcount_reg = "1101" then
                block_next(13) <= word_reg;

            elsif wordcount_reg = "1110" then
                block_next(14) <= word_reg;

            elsif wordcount_reg = "1111" then
                block_next(15) <= word_reg;
 
            else
                block_next <= (others => (others => (others => '0')));

            end if;

        when awaiting_next_byte =>
            -- status_reading_port <= '1';
        
        when input_registers_full =>
            block_full <= '1';
        
        -- i should be using a ce for this whole module, but i'm still hoping
        -- i can find a way to use the base frequency 
    end case;
end process;

---------------- uart receiver
uart_receiver_instance: uart_receiver port map(
    clk => clk,
    clr => clr,
    READY => receiver_ready,
    uart_rx => rx_in,
    uart_rx_data => uart_rx_data
    );


------------bytecount adder
bytecount_adder <= std_logic_vector( 1 + unsigned(bytecount_reg));

------------wordcount adder
wordcount_adder <= std_logic_vector( 1 + unsigned(wordcount_reg));

------------  output wiring
wrd_0 <= block_reg(0)(0) & block_reg(0)(1) & block_reg(0)(2) & block_reg(0)(3);
wrd_1 <= block_reg(1)(0) & block_reg(1)(1) & block_reg(1)(2) & block_reg(1)(3);
wrd_2 <= block_reg(2)(0) & block_reg(2)(1) & block_reg(2)(2) & block_reg(2)(3);
wrd_3 <= block_reg(3)(0) & block_reg(3)(1) & block_reg(3)(2) & block_reg(3)(3);
wrd_4 <= block_reg(4)(0) & block_reg(4)(1) & block_reg(4)(2) & block_reg(4)(3);
wrd_5 <= block_reg(5)(0) & block_reg(5)(1) & block_reg(5)(2) & block_reg(5)(3);
wrd_6 <= block_reg(6)(0) & block_reg(6)(1) & block_reg(6)(2) & block_reg(6)(3);
wrd_7 <= block_reg(7)(0) & block_reg(7)(1) & block_reg(7)(2) & block_reg(7)(3);
wrd_8 <= block_reg(8)(0) & block_reg(8)(1) & block_reg(8)(2) & block_reg(8)(3);
wrd_9 <= block_reg(9)(0) & block_reg(9)(1) & block_reg(9)(2) & block_reg(9)(3);
wrd_a <= block_reg(10)(0) & block_reg(10)(1) & block_reg(10)(2) & block_reg(10)(3);
wrd_b <= block_reg(11)(0) & block_reg(11)(1) & block_reg(11)(2) & block_reg(11)(3);
wrd_c <= block_reg(12)(0) & block_reg(12)(1) & block_reg(12)(2) & block_reg(12)(3);
wrd_d <= block_reg(13)(0) & block_reg(13)(1) & block_reg(13)(2) & block_reg(13)(3);
wrd_e <= block_reg(14)(0) & block_reg(14)(1) & block_reg(14)(2) & block_reg(14)(3);
wrd_f <= block_reg(15)(0) & block_reg(15)(1) & block_reg(15)(2) & block_reg(15)(3);

end el_atrocidad;