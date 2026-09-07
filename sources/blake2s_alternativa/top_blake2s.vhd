------------------------------------------------------------------
-- Author: Josue Enrique Barredo Alamilla
-- 
-- Create Date: 04/23/2023 01:24:17 AM
-- Design Name: 
-- Module Name: top_blake2s - Structural
-- Project Name: 
-- Target Devices: PYNQ-Z1
-- Description: A quick and dirty hardware 
-- implementantion of the blake2s hashing algorithm

-- PLS REMBER:

-- * BLOCK INPUT LENGTH FOR BLAKE2S IS 64 BYTES, THAT IS: 16*4*8 BITS.
-- * DIGEST OUTPUT LENGTH FOR BLAKE2S IS 32 BYTES, THAT IS: 8*4*8 BITS.
-- * ON WORDS: 
-- * FOR BLAKE2S, A WORD HAS A LENGTH OF 32 BITS, THAT IS, 8 BYTES.
-- * THERE ARE 16 WORDS IN ONE INPUT BLOCK
-- * AND 8 WORDS IN AN OUTPUT DIGEST 
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_blake2s is
    port (  clr : in STD_LOGIC;
            clk : in STD_LOGIC;
            
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
            output_pulse_digest_ready : out STD_LOGIC; -- for this i/o interface, this is the only actually useful output signal
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
end top_blake2s;

architecture Structural of top_blake2s is

constant WIDTH: integer:= 32;

    --signal v : STD_LOGIC_VECTOR((16*32) -1 downto 0); no no no, mejor una matriz
    type std_logic_aoa is
        array (natural range <>) of std_logic_vector(WIDTH - 1 downto 0);

    --these IV values were obtained from the decimal part of the square root of two
    -- same as that one hash everyone uses, apparently...
    constant IV : std_logic_aoa(0 to 7) :=
        (
            x"6A09E667",
            x"BB67AE85",
            x"3C6EF372",
            x"A54FF53A",
            x"510E527F",
            x"9B05688C",
            x"1F83D9AB",
            x"5BE0CD19"
        );

    -- this register merely holds the current input block, it might be worthwhile to experiment with reusing it
    signal d_reg, d_next : std_logic_aoa(0 to 15);

    --signals for the 'local' state vector
    signal v_reg, v_next, CONFIGURA_V_OUTPUT, INVIERTE_V14_OUTPUT : std_logic_aoa(0 to 15);

    --signals for the 'persistent' state vector
    signal h_reg, h_next, INICIALIZA_H_OUTPUT, MEZCLA_V_EN_H_OUTPUT : std_logic_aoa(0 to 7);

    -- this register merely holds the words in the order sigma dictates so i can deal with timing issues
    signal sched_reg, sched_next: std_logic_aoa(0 to 15);

    --signal between the message schedule mixer 'sigma' and the 'single round mix' module
    signal round_m : std_logic_aoa(0 to 15);
    
    --signal between the round mixer and the v register
    signal round_v : std_logic_aoa(0 to 15);

    type control_fsm_states is (idle, awaiting_initial_block, digest_done, setup_v, schedule_words, mix_columns,
    mix_diagonals, mix_v_into_h, awaiting_next_block);
    signal state_reg, state_next: control_fsm_states;


--signals for functional units

-- to simplify some additions
signal last_block_has_even_length : std_logic;

signal last_block_length : std_logic_vector( 6 downto 0);

--counters
signal roundcounter_reg, roundcounter_next : std_logic_vector(3 downto 0);
signal mixcounter_reg, mixcounter_next : std_logic_vector(1 downto 0);

-- parameter signals
signal keysize_reg, keysize_next : std_logic_vector(7 downto 0);
signal digestsize_reg, digestsize_next : std_logic_vector(7 downto 0);

    --t_reg is probably the most important register
    --this counts how many bytes we have compressed
    --it's also fed into a status signal from the data path
    --and, finally, it also works as data for the
    --compression process itself, because we mix the highest
    --and lowest word into the compression process (the local
    --v vector specifically)
signal t_reg, t_next, messagesize_reg, messagesize_next, t_reg_comparator, final_block_test_addition: std_logic_vector(2*WIDTH - 1 downto 0);

-- data path status signals
signal final_block_hashed, rounds_done, final_block_ahead, mix_status : STD_LOGIC;

component sigma
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
end component;

component ronda_compresion
    port (  mix_status : in STD_LOGIC; --0: columnas, 1: diagonales

            clk : in STD_LOGIC;

            v0_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v1_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v2_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v3_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v4_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v5_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v6_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v7_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v8_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v9_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v10_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v11_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v12_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v13_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v14_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            v15_entrante : in STD_LOGIC_VECTOR (31 downto 0);
            
            m0 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m1 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m2 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m3 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m4 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m5 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m6 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m7 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m8 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m9 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m10 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m11 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m12 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m13 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m14 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            m15 : in STD_LOGIC_VECTOR (32 - 1 downto 0);
            
            v0_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v1_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v2_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v3_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v4_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v5_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v6_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v7_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v8_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v9_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v10_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v11_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v12_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v13_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v14_saliente : out STD_LOGIC_VECTOR (31 downto 0);
            v15_saliente : out STD_LOGIC_VECTOR (31 downto 0)
            );
end component;

component custom_logic
    Port ( total_bytes_processed : in STD_LOGIC_VECTOR (63 downto 0);
           message_size : in STD_LOGIC_VECTOR (63 downto 0);
           final_block_ahead : out STD_LOGIC;
           final_block_already_hashed : out STD_LOGIC;
           last_block_test_addition: out std_logic_vector(63 downto 0);
           total_bytes_processed_plus_64 : out STD_LOGIC_VECTOR (63 downto 0);
           total_bytes_processed_plus_final_odd_bytes: out STD_LOGIC_VECTOR(63 downto 0);
           final_block_is_even : out STD_LOGIC
           );
end component;


--  signals for functional units

signal INCREMENTA_1_A_crounds : STD_LOGIC_VECTOR (3 downto 0);

signal INCREMENTA_1_A_cmix: STD_LOGIC_VECTOR(1 downto 0);

signal SUMA_64_BYTES_A_t_reg, REEMPLAZA_BYTES_FINALES_A_t_reg : STD_LOGIC_VECTOR (2*WIDTH -1 downto 0);


begin

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
                                --CONTROL PATH--
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------
--control path: state register
------------------------------------------------------------------

process(clk, clr)
begin
    if (clr='1') then
        state_reg <= idle;
    elsif rising_edge(clk) then
            state_reg <= state_next;
    end if;
end process;

------------------------------------------------------------------
--control path: next state logic ONLY
------------------------------------------------------------------
process(state_reg, rounds_done, final_block_hashed, final_block_ahead, data_ready, mixcounter_reg)
begin
    case state_reg is

        when idle => 
            if data_ready = '1' then
                    state_next <= awaiting_initial_block;
            else
                    state_next <= idle;
            end if;

        when digest_done => 
            state_next <= idle;

        when awaiting_initial_block =>
            if data_ready = '1' then
                state_next <= setup_v;
            else
                state_next <= awaiting_initial_block;
            end if;

        when setup_v =>
            state_next <= schedule_words;
        
        when schedule_words =>
            state_next <= mix_columns;

        when mix_columns =>
            if mixcounter_reg = "11" then
                state_next <= mix_diagonals;
            else
                state_next <= mix_columns;
            end if;

        when mix_diagonals =>
            if  mixcounter_reg = "11" then
                if rounds_done = '1' then
                    state_next <= mix_v_into_h;
                else
                    state_next <= schedule_words;
                end if;
            else
                state_next <= mix_diagonals;
            end if;
        when  mix_v_into_h =>
            if  final_block_hashed = '1' then
                    state_next <= digest_done;
                else
                    state_next <= awaiting_next_block;
                end if;

        when awaiting_next_block =>
            if data_ready = '1' then
                state_next <= setup_v;
            else
                state_next <= awaiting_next_block;
            end if;

    end case;
end process;

------------------------------------------------------------------
--control path: external signals, maybe i should manage the digest output from here, once i got the final design
------------------------------------------------------------------

process(state_reg)
begin
    --default values
    -- status_ready_to_compress <='0';
    output_pulse_digest_ready <= '0';
    -- status_awaiting_next_block <= '0';
    -- status_awaiting_first_block <= '0';
    
    mix_status <= '0';
    
    case state_reg is
        when idle => 
            -- status_ready_to_compress <= '1';

        when awaiting_initial_block =>
            -- status_awaiting_first_block <= '1';
        when digest_done =>
            output_pulse_digest_ready <= '1';

        when setup_v =>
        
        when schedule_words =>

        when mix_columns =>
        
            mix_status <= '0';


        when mix_diagonals =>

            mix_status <= '1';

        when mix_v_into_h =>
        
        when awaiting_next_block =>
            -- status_awaiting_next_block <= '1';
        
    end case;
end process;


------------------------------------------------------------------
------------------------------------------------------------------
                         --DATA PATH--
------------------------------------------------------------------
------------------------------------------------------------------

------------------------------------------------------------------
--data path: data registers
------------------------------------------------------------------

process(clk, clr)
begin
    if clr = '1' then
        -- most register names are pretty much lifted from variables used in the software algorithm
        t_reg <= (others => '0');
        v_reg <= (others =>(others => '0'));    --looks funny, would << (others =>x"00000000") >> look better?
        h_reg <= (others =>(others => '0'));
        sched_reg <= (others =>(others => '0'));
        roundcounter_reg <= (others => '0');
        mixcounter_reg <= (others => '0');

        -- these three registers are needed to 'stage-ify' the input parameters
        d_reg <= (others => (others => '0'));
        messagesize_reg <= (others => '0');
        digestsize_reg <= (others => '0');
        keysize_reg <= (others => '0');
        
    elsif rising_edge(clk) then

            -- these three get updated once every hash
            messagesize_reg <= messagesize_next;
            digestsize_reg <= digestsize_next;
            keysize_reg <= keysize_next;

            -- this gets updated once every block
            d_reg <= d_next;

            -- these five get updated several times on each hash, except for h_reg
            t_reg <= t_next;
            v_reg <= v_next;
            h_reg <= h_next;
            sched_reg <= sched_next;
            roundcounter_reg <= roundcounter_next;
            mixcounter_reg <= mixcounter_next;
            
    end if;
end process;

------------------------------------------------------------------
--data path: routing multiplexer RTL operations for Moore OR Mealy Outputs
------------------------------------------------------------------

process(state_reg, d_reg, t_reg, v_reg, h_reg, t_next, digestsize_reg, keysize_reg, block_wrd_0_and_msg_size_uphlf,
        block_wrd_1_and_msg_size_lohlf, block_wrd_2_and_dgst_key_sizes, block_wrd_3, block_wrd_4, block_wrd_5,
        block_wrd_6, block_wrd_7, block_wrd_8, block_wrd_9, block_wrd_a, block_wrd_b, block_wrd_c, block_wrd_d,
        block_wrd_e, block_wrd_f, v_next, h_next, roundcounter_reg, messagesize_reg, INICIALIZA_H_OUTPUT,
        SUMA_64_BYTES_A_t_reg, final_block_test_addition, CONFIGURA_V_OUTPUT, INVIERTE_V14_OUTPUT,
        round_v, INCREMENTA_1_A_crounds, INCREMENTA_1_A_cmix, MEZCLA_V_EN_H_OUTPUT, final_block_hashed, final_block_ahead,
        data_ready, mixcounter_reg, mixcounter_next)
begin
    --default operations
            t_next <= t_reg;
            v_next <= v_reg;
            h_next <= h_reg;
            d_next <= d_reg;

            roundcounter_next <= roundcounter_reg;
            mixcounter_next <= mixcounter_reg;
            
            messagesize_next <= messagesize_reg;
            digestsize_next <= digestsize_reg;
            keysize_next <= keysize_reg;

    case state_reg is
        when idle =>

            d_next <= (others => (others => '0'));
            t_next <= (others => '0');
            v_next <= ( others => ( others => '0' ) );
            h_next <= h_reg;
            roundcounter_next <= ( others => '0' );
            mixcounter_next  <= ( others => '0');
            
            if data_ready = '1' then
                messagesize_next(63 downto 56) <= block_wrd_0_and_msg_size_uphlf( 7 downto  0);
                messagesize_next(55 downto 48) <= block_wrd_0_and_msg_size_uphlf(15 downto  8);
                messagesize_next(47 downto 40) <= block_wrd_0_and_msg_size_uphlf(23 downto 16);
                messagesize_next(39 downto 32) <= block_wrd_0_and_msg_size_uphlf(31 downto 24);
    
                messagesize_next(31 downto 24) <= block_wrd_1_and_msg_size_lohlf( 7 downto  0);
                messagesize_next(23 downto 16) <= block_wrd_1_and_msg_size_lohlf(15 downto  8);
                messagesize_next(15 downto  8) <= block_wrd_1_and_msg_size_lohlf(23 downto 16);
                messagesize_next( 7 downto  0) <= block_wrd_1_and_msg_size_lohlf(31 downto 24);
                
                digestsize_next <= block_wrd_2_and_dgst_key_sizes(31 downto 24);
                
                keysize_next <= block_wrd_2_and_dgst_key_sizes(23 downto 16);
            else
                messagesize_next <= (others => '0');
                digestsize_next <= (others => '0');
                keysize_next <= (others => '0');
            end if;

        when awaiting_initial_block =>

            -- moore output
                v_next <= ( others => ( others => '0' ) );
                roundcounter_next <= ( others => '0' );

            if data_ready = '1' then

                h_next <= INICIALIZA_H_OUTPUT;

                d_next(0) <= block_wrd_0_and_msg_size_uphlf;
                d_next(1) <= block_wrd_1_and_msg_size_lohlf;
                d_next(2) <= block_wrd_2_and_dgst_key_sizes;
                d_next(3) <= block_wrd_3;
                d_next(4) <= block_wrd_4;
                d_next(5) <= block_wrd_5;
                d_next(6) <= block_wrd_6;
                d_next(7) <= block_wrd_7;
                d_next(8) <= block_wrd_8;
                d_next(9) <= block_wrd_9;
                d_next(10) <= block_wrd_a;
                d_next(11) <= block_wrd_b;
                d_next(12) <= block_wrd_c;
                d_next(13) <= block_wrd_d;
                d_next(14) <= block_wrd_e;
                d_next(15) <= block_wrd_f;

                if final_block_ahead = '1' then
                    t_next <= final_block_test_addition;
                else
                    t_next <= SUMA_64_BYTES_A_t_reg;
                end if;
            else
                d_next <= ( others => (others => '0'));
                t_next <= t_reg;
                h_next <= (others => (others => '0') );
            end if;
            
        when digest_done =>
                    
            t_next <= (others => '0');
            v_next <= ( others => ( others => '0' ) );
            h_next <= h_reg;
            roundcounter_next <= ( others => '0' );
            
        when setup_v =>
                    
            h_next <= h_reg;
            roundcounter_next <= ( others => '0' );
            
            if final_block_hashed = '1' then
                v_next <= INVIERTE_V14_OUTPUT;
            else
                v_next <= CONFIGURA_V_OUTPUT;
            end if;
        
        when schedule_words =>
        
        when mix_columns =>

            mixcounter_next <= INCREMENTA_1_A_cmix;
            roundcounter_next <= roundcounter_reg;

            if mixcounter_next = "00" then
                v_next <= round_v;
            else
                v_next <= v_reg;
            end if;

        when mix_diagonals =>

            mixcounter_next <= INCREMENTA_1_A_cmix;

            if mixcounter_next = "00" then
                v_next <= round_v;
                roundcounter_next <= INCREMENTA_1_A_crounds;
            else
                v_next <= v_reg;
                roundcounter_next <= roundcounter_reg;
            end if;
            
        when mix_v_into_h =>
        
            t_next <= t_reg;
            v_next <= v_reg;
            h_next <= MEZCLA_V_EN_H_OUTPUT;
            roundcounter_next <= ( others => '0' );

        when awaiting_next_block =>

            v_next <= v_reg;
            roundcounter_next <= ( others => '0' );
            mixcounter_next  <= ( others => '0');

            if data_ready = '1' then
            
                d_next(0) <= block_wrd_0_and_msg_size_uphlf;
                d_next(1) <= block_wrd_1_and_msg_size_lohlf;
                d_next(2) <= block_wrd_2_and_dgst_key_sizes;
                d_next(3) <= block_wrd_3;
                d_next(4) <= block_wrd_4;
                d_next(5) <= block_wrd_5;
                d_next(6) <= block_wrd_6;
                d_next(7) <= block_wrd_7;
                d_next(8) <= block_wrd_8;
                d_next(9) <= block_wrd_9;
                d_next(10) <= block_wrd_a;
                d_next(11) <= block_wrd_b;
                d_next(12) <= block_wrd_c;
                d_next(13) <= block_wrd_d;
                d_next(14) <= block_wrd_e;
                d_next(15) <= block_wrd_f;
            
                if final_block_ahead = '1' then
                    t_next <= final_block_test_addition;
                else
                    t_next <= SUMA_64_BYTES_A_t_reg;
                end if;
            else
                t_next <= t_reg;
                d_next <= (others => (others => '0'));
            end if;

    end case;
end process;


------------------------------------------------------------------
--data path: functional units
------------------------------------------------------------------

-- increment the number of rounds done by one
INCREMENTA_1_A_crounds <= std_logic_vector( unsigned(roundcounter_reg) + 1 );

-- increment the number of stages done by the mixer by one
INCREMENTA_1_A_cmix <= std_logic_vector( unsigned(mixcounter_reg) + 1 );

---- final block is not 64 bytes in length
--REEMPLAZA_BYTES_FINALES_A_t_reg(63 DOWNTO 6) <= t_reg(63 DOWNTO 6);
--REEMPLAZA_BYTES_FINALES_A_t_reg(5 DOWNTO 0) <= messagesize_reg(5 downto 0);

---- next block is 64 bytes in length
--SUMA_64_BYTES_A_t_reg(63 downto 6) <= std_logic_vector ( unsigned(t_reg(63 downto 6)) + 1 );
--SUMA_64_BYTES_A_t_reg(5 downto 0) <= "000000";

------------- INICIALIZA_H_output
INICIALIZA_H_OUTPUT(0) <= IV(0) xor x"0101" & keysize_reg & digestsize_reg;

INICIALIZA_H_1_to_7: for i in 1 to 7 generate
    INICIALIZA_H_OUTPUT(i) <= IV(i);
end generate INICIALIZA_H_1_to_7;
---------------------------------

-------------  CONFIGURA_V_output
CONFIGURA_V_OUTPUT_0_to_7: for i in 0 to 7 generate
    CONFIGURA_V_OUTPUT(i) <= h_reg(i);
end generate CONFIGURA_V_OUTPUT_0_to_7;

CONFIGURA_V_OUTPUT_8_to_11: for i in 8 to 11 generate
    CONFIGURA_V_OUTPUT(i) <= IV(i-8);
end generate CONFIGURA_V_OUTPUT_8_to_11;

CONFIGURA_V_OUTPUT(12) <= IV(4) xor t_reg(WIDTH - 1 downto 0);
CONFIGURA_V_OUTPUT(13) <= IV(5) xor t_reg(2*WIDTH - 1 downto WIDTH);

CONFIGURA_V_OUTPUT_14_to_15: for i in 14 to 15 generate
    CONFIGURA_V_OUTPUT(i) <= IV(i - 8);
end generate CONFIGURA_V_OUTPUT_14_to_15;
---------------------------------

------------  INVIERTE_V14_output
--too verbose? pointless? should i just stick a NOT in front of v_14 and be done with it?
INVIERTE_V14_OUTPUT_0_to_13: for i in 0 to 13 generate
    INVIERTE_V14_OUTPUT(i) <= CONFIGURA_V_OUTPUT(i);
end generate INVIERTE_V14_OUTPUT_0_to_13;

INVIERTE_V14_OUTPUT(14) <= not (CONFIGURA_V_OUTPUT(14));
INVIERTE_V14_OUTPUT(15) <= CONFIGURA_V_OUTPUT(15);
--------------------------------


-- MEZCLA_V_EN_H_output
MEZCLA_V_EN_H_OUTPUT_0_to_7: for i in 0 to 7 generate
    MEZCLA_V_EN_H_OUTPUT(i) <= ( ( h_reg(i) XOR v_reg(i) ) XOR ( v_reg(i + 8) ) );
end generate MEZCLA_V_EN_H_OUTPUT_0_to_7;

--round mixer--------------------------------
combinational_compression_round: ronda_compresion
port map (  clk => clk,

            mix_status => mix_status,

            v0_entrante => v_reg(0),
            v1_entrante => v_reg(1),
            v2_entrante => v_reg(2),
            v3_entrante => v_reg(3),
            v4_entrante => v_reg(4),
            v5_entrante => v_reg(5),
            v6_entrante => v_reg(6),
            v7_entrante => v_reg(7),
            v8_entrante => v_reg(8),
            v9_entrante => v_reg(9),
            v10_entrante => v_reg(10),
            v11_entrante => v_reg(11),
            v12_entrante => v_reg(12),
            v13_entrante => v_reg(13),
            v14_entrante => v_reg(14),
            v15_entrante => v_reg(15),

            m0 => sched_reg(0),
            m1 => sched_reg(1),
            m2 => sched_reg(2),
            m3 => sched_reg(3),
            m4 => sched_reg(4),
            m5 => sched_reg(5),
            m6 => sched_reg(6),
            m7 => sched_reg(7),
            m8 => sched_reg(8),
            m9 => sched_reg(9),
            m10 => sched_reg(10),
            m11 => sched_reg(11),
            m12 => sched_reg(12),
            m13 => sched_reg(13),
            m14 => sched_reg(14),
            m15 => sched_reg(15),

            v0_saliente => round_v(0),
            v1_saliente => round_v(1),
            v2_saliente => round_v(2),
            v3_saliente => round_v(3),
            v4_saliente => round_v(4),
            v5_saliente => round_v(5),
            v6_saliente => round_v(6),
            v7_saliente => round_v(7),
            v8_saliente => round_v(8),
            v9_saliente => round_v(9),
            v10_saliente => round_v(10),
            v11_saliente => round_v(11),
            v12_saliente => round_v(12),
            v13_saliente => round_v(13),
            v14_saliente => round_v(14),
            v15_saliente => round_v(15)
            );

--round mixer end----------------------------

sigma_mux: sigma
port map (

    block_word_00 => d_reg(0),
    block_word_01 => d_reg(1),
    block_word_02 => d_reg(2),
    block_word_03 => d_reg(3),
    block_word_04 => d_reg(4),
    block_word_05 => d_reg(5),
    block_word_06 => d_reg(6),
    block_word_07 => d_reg(7),
    block_word_08 => d_reg(8),
    block_word_09 => d_reg(9),
    block_word_10 => d_reg(10),
    block_word_11 => d_reg(11),
    block_word_12 => d_reg(12),
    block_word_13 => d_reg(13),
    block_word_14 => d_reg(14),
    block_word_15 => d_reg(15),

--    block_word_00 => message_0_and_t_upper_word,
--    block_word_01 => message_1_and_t_lower_word,
--    block_word_02 => message_2_and_parameters,
--    block_word_03 => message_3,
--    block_word_04 => message_4,
--    block_word_05 => message_5,
--    block_word_06 => message_6,
--    block_word_07 => message_7,
--    block_word_08 => message_8,
--    block_word_09 => message_9,
--    block_word_10 => message_a,
--    block_word_11 => message_b,
--    block_word_12 => message_c,
--    block_word_13 => message_d,
--    block_word_14 => message_e,
--    block_word_15 => message_f,
    sigma00 => sched_next(0),
    sigma01 => sched_next(1),
    sigma02 => sched_next(2),
    sigma03 => sched_next(3),
    sigma04 => sched_next(4),
    sigma05 => sched_next(5),
    sigma06 => sched_next(6),
    sigma07 => sched_next(7),
    sigma08 => sched_next(8),
    sigma09 => sched_next(9),
    sigma10 => sched_next(10),
    sigma11 => sched_next(11),
    sigma12 => sched_next(12),
    sigma13 => sched_next(13),
    sigma14 => sched_next(14),
    sigma15 => sched_next(15),
    sel => roundcounter_reg
);

------------------------------------------------------------------
--data path: status signals
------------------------------------------------------------------

rounds_done <= '1' when roundcounter_next = "1010" else '0';

------------------------------------------------------------------
--data path: custom logic signals
------------------------------------------------------------------

-- this entity houses both status signals and data operators

t_handler: custom_logic
port map (
    total_bytes_processed => t_reg,
    message_size => messagesize_reg,
    final_block_ahead => final_block_ahead,
    final_block_already_hashed  => final_block_hashed,
    total_bytes_processed_plus_64 => SUMA_64_BYTES_A_t_reg,
    total_bytes_processed_plus_final_odd_bytes => REEMPLAZA_BYTES_FINALES_A_t_reg,
    final_block_is_even => last_block_has_even_length,
    last_block_test_addition => final_block_test_addition
);

------------------------------------------------------------------
--data path: outputs
------------------------------------------------------------------

        digest_wrd_0 <= h_reg(0);
        digest_wrd_1 <= h_reg(1);
        digest_wrd_2 <= h_reg(2);
        digest_wrd_3 <= h_reg(3);
        digest_wrd_4 <= h_reg(4);
        digest_wrd_5 <= h_reg(5);
        digest_wrd_6 <= h_reg(6);
        digest_wrd_7 <= h_reg(7);

end Structural;