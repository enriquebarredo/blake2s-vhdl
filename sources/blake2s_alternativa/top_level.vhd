# SPDX-FileCopyrightText: 2024-2026 Josué Enrique Barredo Alamilla
# SPDX-License-Identifier: CERN-OHL-S-2.0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_and_process is
    Port ( clk : in STD_LOGIC;
           uart_rx : in STD_LOGIC;
           uart_tx : out STD_LOGIC;
           clr: in STD_LOGIC
           
           -- status_reading_port: out STD_LOGIC;
           -- status_ready_to_compress: out STD_LOGIC;
           -- status_awaiting_next_block: out STD_LOGIC;
           -- status_awaiting_first_block : out STD_LOGIC
           );
end uart_and_process;

architecture Behavioral of uart_and_process is

component subsistema_de_recepcion is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;

           rx_in : in STD_LOGIC;

           --parameter_block_in : in STD_LOGIC;

           --status_reading_port : out STD_LOGIC;
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
end component;

component subsistema_de_transmision is
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
end component;

--component derived_clock is
--port    (   
--            clk : in STD_LOGIC;
            --clr : in STD_LOGIC;
--            clk_out: out STD_LOGIC
--        );
--end component;


--component anti-rebote
--port    (
--        bot_in : in std_logic_vector(3 downto 0);
--        clk : in std_logic;          
--        deb_out : out std_logic_vector(3 downto 0)
--        );
--end component;

component top_blake2s is
    port (  clr : in STD_LOGIC;
            clk : in STD_LOGIC;
--            ce : in STD_LOGIC;
            
            data_ready : in STD_LOGIC;
--            [DEPRECATED THANKS TO ^]
--            parameters_ready_input_signal : in STD_LOGIC;
--            start_hashing_input_signal : in STD_LOGIC;
--            next_block_ready_input_signal : in STD_LOGIC;
            
            block_wrd_0_and_msg_size_uphlf : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_1_and_msg_size_lohlf : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_2_and_dgst_key_sizes : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_3 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_4 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_5 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_6 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_7 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_8 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_9 : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_a : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_b : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_c : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_d : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_e : in STD_LOGIC_VECTOR (31 downto 0);
            block_wrd_f : in STD_LOGIC_VECTOR (31 downto 0);
            
            -- status_ready_to_compress : out STD_LOGIC;
            output_pulse_digest_ready : out STD_LOGIC;
            -- status_awaiting_next_block : out STD_LOGIC;
            -- status_awaiting_first_block : out STD_LOGIC;

            digest_wrd_0 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_1 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_2 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_3 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_4 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_5 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_6 : out STD_LOGIC_VECTOR (31 downto 0);
            digest_wrd_7 : out STD_LOGIC_VECTOR (31 downto 0)
         );
end component;

-- MUITO REAL
constant WIDTH : integer := 32;

-- constants for testing (for historical purposes only!)
--constant digest_length_test : std_logic_vector(7 downto 0) := x"20";
--constant key_length_test : std_logic_vector(7 downto 0) := x"00";
-- constant last_block_length_test : std_logic_vector(6 downto 0) := "1000000";
-- constant total_message_length_test : std_logic_vector(2*WIDTH - 1 downto 0) := x"0000000000000040";

--signals for debouncers
--signal btnReg : std_logic_vector (3 downto 0) := "0000";
--signal btnDeBnc : std_logic_vector(3 downto 0);

-- these signals all come ultimately from push buttons
--signal clr : std_logic;

--inter-module signaling or smthng
signal blake_input_data_ready, start_transmission: std_logic;

--signals for uart modules data, internal
signal uart_rx_data, uart_tx_data: std_logic_vector(7 downto 0);

--signal v : STD_LOGIC_VECTOR((16*32) -1 downto 0); no no no, mejor una matriz
type std_logic_aoa is
    array (natural range <>) of std_logic_vector(WIDTH - 1 downto 0);

    signal input_block : std_logic_aoa(0 to 15);

    signal preliminary_digest: std_logic_aoa(0 to 7);

signal output_reg, output_next : std_logic_aoa(0 to 7);

--  signal
signal derived_clk: std_logic;

begin

--clr <= btnDeBnc(3);


---------------------------------
---------------  functional units
---------------------------------

------------------  clock divisor
--derived_clock_inst: derived_clock port map(
--                clk => clk,
--                clk_out => derived_clk
--);

-----------------  blake2s module
blake2s_module: top_blake2s port map(
            clr => clr,
            clk => clk,
--            ce => derived_clk,
            
            data_ready => blake_input_data_ready,
--            parameters_ready_input_signal => start_hashing_input,
--            start_hashing_input_signal => start_hashing_input,
--            next_block_ready_input_signal => start_hashing_input,
            
            block_wrd_0_and_msg_size_uphlf => input_block(0),
            block_wrd_1_and_msg_size_lohlf => input_block(1),
            block_wrd_2_and_dgst_key_sizes => input_block(2),
            block_wrd_3 => input_block(3),
            block_wrd_4 => input_block(4),
            block_wrd_5 => input_block(5),
            block_wrd_6 => input_block(6),
            block_wrd_7 => input_block(7),
            block_wrd_8 => input_block(8),
            block_wrd_9 => input_block(9),
            block_wrd_a => input_block(10),
            block_wrd_b => input_block(11),
            block_wrd_c => input_block(12),
            block_wrd_d => input_block(13),
            block_wrd_e => input_block(14),
            block_wrd_f => input_block(15),
            
            -- status_ready_to_compress => status_ready_to_compress,
            output_pulse_digest_ready => start_transmission,
            -- status_awaiting_next_block => status_awaiting_next_block,
            -- status_awaiting_first_block => status_awaiting_first_block,
            
            digest_wrd_0 => preliminary_digest(0),
            digest_wrd_1 => preliminary_digest(1),
            digest_wrd_2 => preliminary_digest(2),
            digest_wrd_3 => preliminary_digest(3),
            digest_wrd_4 => preliminary_digest(4),
            digest_wrd_5 => preliminary_digest(5),
            digest_wrd_6 => preliminary_digest(6),
            digest_wrd_7 => preliminary_digest(7)
    );

------  subsistema de transmision
inst_transmision: subsistema_de_transmision port map (
            clk => clk,
            clr => clr,
            
            data_ready => start_transmission,
            
            tx_out => uart_tx,
            
            wrd_0 => preliminary_digest(0),
            wrd_1 => preliminary_digest(1),
            wrd_2 => preliminary_digest(2),
            wrd_3 => preliminary_digest(3),
            wrd_4 => preliminary_digest(4),
            wrd_5 => preliminary_digest(5),
            wrd_6 => preliminary_digest(6),
            wrd_7 => preliminary_digest(7)
            );

------  subsistema de recepcion
inst_recepcion: subsistema_de_recepcion
    port map (
            clk => clk,
            clr => clr,
            
            -- status_reading_port => status_reading_port,
            block_full => blake_input_data_ready,
                        
            rx_in => uart_rx,
            
            --parameter_block_in => awaiting_initial_parameters,
            
            wrd_0 => input_block(0),
            wrd_1 => input_block(1),
            wrd_2 => input_block(2),
            wrd_3 => input_block(3),
            wrd_4 => input_block(4),
            wrd_5 => input_block(5),
            wrd_6 => input_block(6),
            wrd_7 => input_block(7),
            wrd_8 => input_block(8),
            wrd_9 => input_block(9),
            wrd_a => input_block(10),
            wrd_b => input_block(11),
            wrd_c => input_block(12),
            wrd_d => input_block(13),
            wrd_e => input_block(14),
            wrd_f => input_block(15)

            );

-----------------------  debouncer
--Inst_btn_debounce: debouncer 
--    generic map(
--        DEBNC_CLOCKS => (2**16),
--        PORT_WIDTH => 4)
--    port map(
--		SIGNAL_I => BTN,
--		CLK_I => clk,
--		SIGNAL_O => btnDeBnc
--	);

------- strobe register (buttons)
--btn_reg_process : process (clk)
--begin
--	if (rising_edge(clk)) then
--		btnReg <= btnDeBnc(3 downto 0);
--	end if;
--end process;

-- edge detector, for BUTTON 0,
-- this one shuffles the data from the reception/blake2s subsystems
-- into their respective next stages (blake2s/transmission)
--start_hashing_input <= '1' when ((btnReg(0)='0' and btnDeBnc(0)='1')) else
--				  '0';

-- edge detector, for BUTTON 1,
-- this one starts the blake2s system (hash)
--start_transmission_input <= '1' when ((btnReg(1)='0' and btnDeBnc(1)='1')) else
--				  '0';

end Behavioral;