-- SPDX-FileCopyrightText: 2024-2026 Josue Enrique Barredo Alamilla
-- SPDX-License-Identifier: CERN-OHL-S-2.0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity subsistema_de_transmision is
    Port (  clk : in STD_LOGIC;
            clr : in STD_LOGIC;
            
            data_ready : in STD_LOGIC;
            
            tx_out : out STD_LOGIC;
            
            wrd_0 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_1 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_2 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_3 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_4 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_5 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_6 : in STD_LOGIC_VECTOR (31 downto 0);
            wrd_7 : in STD_LOGIC_VECTOR (31 downto 0)
            );
end subsistema_de_transmision;

architecture dios_mio of subsistema_de_transmision is

component hastily_conceived_transmitter is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           send : in STD_LOGIC;
           
           tx_out : out STD_LOGIC;
           ready : out STD_LOGIC
           );
end component;

constant WIDTH : integer := 32;

type std_logic_aoa is
    array (natural range <>) of std_logic_vector(WIDTH - 1 downto 0);

    signal digest : std_logic_aoa(0 to 7);


--signals for uart modules data
signal uart_tx_data: std_logic_vector(7 downto 0);

--signals for data registers
type m_word is
    array (3 downto 0) of std_logic_vector(7 downto 0);

type d_block is
    array (0 to 7) of m_word;

signal block_reg, block_next : d_block;

signal word_reg, word_next : m_word;

signal bytecount_reg, bytecount_next, bytecount_adder : std_logic_vector(1 downto 0); -- each word is made up of 4 bytes
signal wordcount_reg, wordcount_next, wordcount_adder : std_logic_vector(2 downto 0); -- each digest is made up of 8 words

--signals for fsm
type state is (ready_to_transmit, loading_digest, sending_data, awaiting_ready_transmitter, swapping_words);
signal state_reg, state_next : state;

--  status signals 
signal transmitter_ready, transmit_pulse: std_logic;

begin

---------------------------------
--------  control  path  --------
---------------------------------

-----------------  state register
process(clk, clr)
begin
    if  clr = '1' then
        state_reg <= ready_to_transmit;    --looks funny, would << (others =>x"00000000") >> look better?
    elsif rising_edge(clk) then
        state_reg <= state_next;
    end if;
end process;

-----------  fsm next-state logic
----------  also external signals
process(state_reg, bytecount_reg, transmitter_ready, wordcount_reg, bytecount_next, data_ready)
begin
    case state_reg is

        when ready_to_transmit =>
            
            if data_ready = '1' then
                state_next <= loading_digest;
            else
                state_next <= ready_to_transmit;
            end if;

        when loading_digest =>
        
            state_next <= sending_data;

        when sending_data =>

            if  bytecount_reg= "11" then
                state_next <= swapping_words;
            else
                state_next <= awaiting_ready_transmitter;
            end if;
        
        when awaiting_ready_transmitter =>
        
            if transmitter_ready = '1' then
                state_next <= sending_data;
            else 
                state_next <= awaiting_ready_transmitter;
            end if;
        
        when swapping_words =>
            if wordcount_reg = "111" then
                state_next <= ready_to_transmit;
            else
                state_next <= awaiting_ready_transmitter;
            end if;

    end case;
    
end process;

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
        
    elsif rising_edge(clk) then
    
        bytecount_reg <= bytecount_next;
        wordcount_reg <= wordcount_next;
        word_reg <= word_next;
        block_reg <= block_next;
        
    end if;
end process;

-- now for the true test, drop in the variable data
    digest(0) <= wrd_0;
    digest(1) <= wrd_1;
    digest(2) <= wrd_2;
    digest(3) <= wrd_3;
    digest(4) <= wrd_4;
    digest(5) <= wrd_5;
    digest(6) <= wrd_6;
    digest(7) <= wrd_7;

------------------  routing muxer
process(state_reg, word_reg, 
--uart_rx_data,
 bytecount_reg, bytecount_adder, wordcount_reg, block_reg, wordcount_adder, bytecount_next, digest)
begin
    --default rt operations
            bytecount_next <= bytecount_reg;
            wordcount_next <= wordcount_reg;
            word_next <= word_reg;
            block_next <= block_reg;
    
    --default routing
            uart_tx_data <= (others => '0');
            transmit_pulse <= '0';

    case state_reg is
    
        when ready_to_transmit => 
        
            bytecount_next <= (others => '0');
            wordcount_next <= (others => '0');
            word_next <= (others => (others => '0')); -- looks dopey
            block_next <= (others => (others => (others => '0'))); -- looks nutty

        when loading_digest =>

            block_next(0)(0) <= digest(0)(31 downto 24);
            block_next(0)(1) <= digest(0)(23 downto 16);
            block_next(0)(2) <= digest(0)(15 downto 8);
            block_next(0)(3) <= digest(0)(7 downto 0);

            block_next(1)(0) <= digest(1)(31 downto 24);
            block_next(1)(1) <= digest(1)(23 downto 16);
            block_next(1)(2) <= digest(1)(15 downto 8);
            block_next(1)(3) <= digest(1)(7 downto 0);

            block_next(2)(0) <= digest(2)(31 downto 24);
            block_next(2)(1) <= digest(2)(23 downto 16);
            block_next(2)(2) <= digest(2)(15 downto 8);
            block_next(2)(3) <= digest(2)(7 downto 0);

            block_next(3)(0) <= digest(3)(31 downto 24);
            block_next(3)(1) <= digest(3)(23 downto 16);
            block_next(3)(2) <= digest(3)(15 downto 8);
            block_next(3)(3) <= digest(3)(7 downto 0);

            block_next(4)(0) <= digest(4)(31 downto 24);
            block_next(4)(1) <= digest(4)(23 downto 16);
            block_next(4)(2) <= digest(4)(15 downto 8);
            block_next(4)(3) <= digest(4)(7 downto 0);

            block_next(5)(0) <= digest(5)(31 downto 24);
            block_next(5)(1) <= digest(5)(23 downto 16);
            block_next(5)(2) <= digest(5)(15 downto 8);
            block_next(5)(3) <= digest(5)(7 downto 0);

            block_next(6)(0) <= digest(6)(31 downto 24);
            block_next(6)(1) <= digest(6)(23 downto 16);
            block_next(6)(2) <= digest(6)(15 downto 8);
            block_next(6)(3) <= digest(6)(7 downto 0);

            block_next(7)(0) <= digest(7)(31 downto 24);
            block_next(7)(1) <= digest(7)(23 downto 16);
            block_next(7)(2) <= digest(7)(15 downto 8);
            block_next(7)(3) <= digest(7)(7 downto 0);


            -- let's load the first word in advance
            word_next(0) <= digest(0)(31 downto 24);
            word_next(1) <= digest(0)(23 downto 16);
            word_next(2) <= digest(0)(15 downto 8);
            word_next(3) <= digest(0)(7 downto 0);
            

        when sending_data =>
        
            bytecount_next <= bytecount_adder;
            transmit_pulse <= '1';
            if bytecount_reg = "00" then
            
                uart_tx_data <= word_reg(3);
                
            elsif bytecount_reg = "01" then
            
                uart_tx_data <= word_reg(2);
                
            elsif bytecount_reg = "10" then

                uart_tx_data <= word_reg(1);
                
            elsif bytecount_reg = "11" then
            
                uart_tx_data <= word_reg(0);
            
            else
            
                uart_tx_data <= (others => '0');
            
            end if;
            
        when awaiting_ready_transmitter =>
        
        when swapping_words =>

            -- there's no point in resetting byte_count; once you add "01" to "11" in a two-bit adder, it just cycles back to "00"
                wordcount_next <= wordcount_adder;
            
            if wordcount_reg = "000" then
            
                word_next <= block_reg(1);

            elsif wordcount_reg = "001" then
            
                word_next <= block_reg(2);

            elsif wordcount_reg = "010" then

                word_next <= block_reg(3);

            elsif wordcount_reg = "011" then

                word_next <= block_reg(4);

            elsif wordcount_reg = "100" then

                word_next <= block_reg(5);

            elsif wordcount_reg = "101" then

                word_next <= block_reg(6);

            elsif wordcount_reg = "110" then

                word_next <= block_reg(7);

            elsif wordcount_reg = "111" then

                word_next <= block_reg(0);

            else
            
                block_next <= (others => (others => (others => '0')));

            end if;
        
    end case;
end process;


---------------------------------
---------------  functional units
---------------------------------


---------------- uart transmitter
uart_transmitter_instance: hastily_conceived_transmitter
port map(
        clk => clk,
        clr => clr,
        
        send => transmit_pulse,
        data_in => uart_tx_data,
        
        ready => transmitter_ready,
        tx_out => tx_out
        );


------------bytecount adder
bytecount_adder <= std_logic_vector( 1 + unsigned(bytecount_reg));

------------wordcount adder
wordcount_adder <= std_logic_vector( 1 + unsigned(wordcount_reg));


end dios_mio;