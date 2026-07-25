-- SPDX-FileCopyrightText: 2006 Pong P. Chu
-- SPDX-License-Identifier: NOASSERTION

-- Original Source: Pages 456-459, Chapter 14 of the textbook "RTL Hardware Design Using VHDL - Coding for Efficiency, Portability, and Scalability" by Pong P. Chu

----------------------------------------------------------------------------------
-- shamelessly lifted from Pong P. Chu's book, this UART receiver was modified to
-- work with a 125mhz clock at 2million baudrate:
-- dvsr = (clock_freq)/(baudrate*16)
-- clock_freq = 125 mhz 
-- baudrate = 2,000,000
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_receiver is
    Port ( clk : in STD_LOGIC;
           clr : in STD_LOGIC;
           uart_rx : in STD_LOGIC;
           ready: out STD_LOGIC;
           uart_rx_data : out STD_LOGIC_VECTOR (7 downto 0)
           );
end uart_receiver;

architecture Behavioral of uart_receiver is


type control_path_fsm_state is (idle, start, data, stop);
signal state_reg, state_next: control_path_fsm_state;
signal clk16_next, clk16_reg: unsigned(1 downto 0);

signal s_reg, s_next: unsigned(3 downto 0);
signal n_reg, n_next: unsigned(2 downto 0);
signal b_reg, b_next: std_logic_vector(7 downto 0);
signal s_pulse: std_logic;


constant DVSR: integer := 4;

begin

---------------------------------
----  data & control paths   ----
---------------------------------

--  free-running mod-6509 counter
-----------  independent of b_reg
process(clk, clr)
begin
    if clr = '1' then
        clk16_reg <= (others => '0');
    elsif rising_edge(clk) then
        clk16_reg <= clk16_next;
    end if;
end process;

--  next-state/output logic
clk16_next <= (others => '0') when clk16_reg = (DVSR-1) else
                clk16_reg + 1;
s_pulse <= '1' when clk16_reg = 0 else '0';

----  fsmd state & data registers
process(clr, clk) begin
    if clr = '1' then
        state_reg <= idle;
        s_reg <= (others => '0');
        n_reg <= (others => '0');
        b_reg <= (others => '0');
    elsif rising_edge(clk) then
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end if;
end process;


---------------------------------
-------  control  path  ---------
---------------------------------

---  control fsm next state logic
process (state_reg, uart_rx, s_pulse, s_reg, b_reg, n_reg) begin
    s_next <= s_reg;
    n_next <= n_reg;
    b_next <= b_reg;
    ready <= '0';
    
    case state_reg is
    
        when idle =>
            if uart_rx = '0' then
                state_next <= start;
            else
                state_next <= idle;
            end if;
            ready <= '1';
            
        when start =>
            if (s_pulse = '0') then
                state_next <= start;
            else
                if s_reg = 7 then
                    state_next <= data;
                    s_next <= (others => '0');
                else
                    state_next <= start;
                    s_next <= s_reg + 1;
                end if;
            end if;

        when data =>
            if (s_pulse = '0') then
                state_next <= data;
            else
                if s_reg = 15 then
                    s_next <= (others => '0');
                    b_next <= uart_rx & b_reg(7 downto 1);
                    if n_reg = 7 then
                        state_next <= stop;
                        n_next <= (others => '0');
                    else
                        state_next <= data;
                        n_next <= n_reg + 1;
                    end if;
                else
                    state_next <= data;
                    s_next <= s_reg + 1;
                end if;
            end if;
            
        when stop =>
            if (s_pulse = '0') then
                state_next <= stop;
            else
                if s_reg = 15 then
                    state_next <= idle;
                    s_next <= (others => '0');
                else
                    state_next <= stop;
                    s_next <= s_reg + 1;
                end if;
            end if;
        end case;
    end process;
    uart_rx_data <= b_reg;
-------  control fsm output logic

end Behavioral;