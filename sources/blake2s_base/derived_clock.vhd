-- SPDX-FileCopyrightText: 2024-2026 Josue Enrique Barredo Alamilla
-- SPDX-License-Identifier: CERN-OHL-S-2.0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity derived_clock is
    Port ( clk : in STD_LOGIC;
           --clr : in STD_LOGIC;
           clk_out: out STD_LOGIC);
end derived_clock;

architecture Behavioral of derived_clock is

signal secondary_clk: std_logic;

begin

clock_divider2: process(clk)
begin
    if rising_edge(clk) then
        secondary_clk <= not secondary_clk;
    end if;
end process;

clk_out <= secondary_clk;

end Behavioral;