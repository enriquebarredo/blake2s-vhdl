-- SPDX-FileCopyrightText: 2024-2026 Josue Enrique Barredo Alamilla
-- SPDX-License-Identifier: CERN-OHL-S-2.0

----------------------------------------------------------------------------------
-- Transmisor UART simple
-- hay un contador independiente que envía un pulso cada que termina 
-- de contar. este pulso tiene la misma frequencia que el baudrate 
-- cada que este pulso se activa, se envía un bit de acuerdo al estandar 
-- uart (10 bits por byte), y se mantiene hasta el siguiente pulso del baudrate,
-- cuando se envía un nuevo pulso. este ciclo continúa hasta que se hayan enviado 
-- todos lost bits (el de inicio, los de los datos, y el del final)
-- 
-- baud_constant para 500,000 baudios baud_constant = round(freq/desired_baud_rate) -1 = 249 = 0xf9
-- baud_constant para 2,000,000 baudios baud_constant = round(freq/desired_baud_rate) -1 = 62 = 0x3E
-- baud_constant para 6,000,000 baudios baud_constant = round(freq/desired_baud_rate) -1 = 20 = 0x14

-- baud_constant para 9600 baudios : 13020 = 0x32DC = 11 0010 1101 1100
-- baud_constant para 2m baudios : 13020 = 0x3E =  11 1110
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity hastily_conceived_transmitter is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           send : in STD_LOGIC;
           
           tx_out : out STD_LOGIC;
           ready : out STD_LOGIC
           );
end hastily_conceived_transmitter;

architecture Behavioral of hastily_conceived_transmitter is

-- signals for fsm
type state is (idling, waiting_for_baudrate_pulse, shifting_bits, updating_bitcount);
signal state_reg, state_next : state;

-- signals for functional units

-- signals for baud pulse generator
--REAL CONSTANT HERE
constant baud_constant: std_logic_vector(5 downto 0) := "111110"; -- 62 en base 10
--constant baud_constant: std_logic_vector(13 downto 0) := "11001011011100";
--signal baudcount_reg : std_logic_vector(13 downto 0) := (others => '0');
--signal baudcount_next : std_logic_vector(13 downto 0);
signal baudcount_reg : STD_LOGIC_VECTOR(5 downto 0) := "000000";
signal baudcount_next : STD_LOGIC_VECTOR(5 downto 0);
signal baud_pulse : STD_LOGIC;

-- signals for shift_register
signal shift_reg : STD_LOGIC_VECTOR(10 downto 0) := "11111111111";

signal shift_next, shifter_out : STD_LOGIC_VECTOR(10 downto 0);

-- signals for bit_counter and bitcount_adder
signal bitcount_reg : STD_LOGIC_VECTOR(3 downto 0) := x"0";
signal bitcount_next, bitcount_adder_out : STD_LOGIC_VECTOR(3 downto 0);

begin

-- control path, state register
process(clk, clr)
begin
    if clr = '1' then
        state_reg <= idling;
    elsif rising_edge(clk) then
        state_reg <= state_next;
    end if;
end process;


-- control path, next-state logic
process(state_reg, send, baud_pulse, bitcount_next)
begin
    case state_reg is
        when idling =>
            if send = '1' then
                state_next <= waiting_for_baudrate_pulse;
            else
                state_next <= idling;
            end if;
        when waiting_for_baudrate_pulse =>
            if baud_pulse = '1' then
                state_next <= shifting_bits;
            else
                state_next <= waiting_for_baudrate_pulse;
            end if;
        when shifting_bits =>
            state_next <= updating_bitcount;
        when updating_bitcount =>
           if bitcount_next = x"a" then
                state_next <= idling;
            else
                state_next <= waiting_for_baudrate_pulse;
            end if;


    end case;

end process;

-- control path, control_signals, rtl_operations and output
process(state_reg, bitcount_reg, bitcount_adder_out, shift_reg, send, data_in, shifter_out) begin

    -- defaul operations    
    bitcount_next <= bitcount_reg;
    shift_next <= shift_reg;

    -- default output
    ready <= '0';

    case state_reg is 
    
        when idling =>
            -- moore output
            ready <= '1';
            bitcount_next <= (others => '0');
            shift_next <= (others => '1');  -- maybe i should get rid of this and make it so it's always loading from the input data

            -- mealy output
            if send = '1' then
                shift_next <= '1' & data_in & "01"; -- would this be better?
            end if;
        when waiting_for_baudrate_pulse  =>

        when shifting_bits =>
            shift_next <= shifter_out;
            
        when updating_bitcount =>
            bitcount_next <= bitcount_adder_out;
    end case;

end process;

-- data path, data register
process(clk, clr)
begin
    if clr = '1' then
        bitcount_reg <= (others => '0');
    elsif rising_edge(clk) then
        bitcount_reg <= bitcount_next;
    end if;
end process;

-----------  baud pulse generator
process(clk, clr)
begin
    if clr = '1' then
        baudcount_reg <= (others => '0');
    elsif rising_edge(clk) then
        if baud_pulse = '1' then
            baudcount_reg <= (others => '0');
        else
            baudcount_reg <= baudcount_next;
        end if;
    end if;
end process;

-- baud counter comparator
baud_pulse <= '1' when baudcount_reg = baud_constant else '0';

-- baud counter adder
baudcount_next <= std_logic_vector(1 + unsigned(baudcount_reg));
---------------------------------

-----------------  shift register
process(clk, clr) begin
    if clr = '1' then
        shift_reg <= (others => '1');
    elsif rising_edge(clk) then
        shift_reg <= shift_next;
    end if;
end process;

-- next_state logic
shifter_out <= '1' & shift_reg(10 downto 1);

-- bitcount adder
bitcount_adder_out <= std_logic_vector( unsigned(bitcount_reg) + 1);

-- output_logic
tx_out <= shift_reg(0);

end Behavioral;
