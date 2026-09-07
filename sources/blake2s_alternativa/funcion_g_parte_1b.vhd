library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity funcion_g_parte_1b is
    Port ( entrada_a    : in std_logic_vector (31 downto 0);
           entrada_b    : in std_logic_vector (31 downto 0);
           entrada_c    : in std_logic_vector (31 downto 0);
           entrada_d    : in std_logic_vector (31 downto 0);
           
           salida_a     : out std_logic_vector (31 downto 0);
           salida_b     : out std_logic_vector (31 downto 0);
           salida_c     : out std_logic_vector (31 downto 0);
           salida_d     : out std_logic_vector (31 downto 0)
         );
end funcion_g_parte_1b;

architecture flujo_de_datos of funcion_g_parte_1b is

-- From RFC 7693, full function goes like:
--       FUNCTION G( v[0..15], a, b, c, d, x, y )
--       |
--       |   v[a] := (v[a] + v[b] + x) mod 2**w
--       |   v[d] := (v[d] ^ v[a]) >>> R1
--       |   v[c] := (v[c] + v[d])     mod 2**w
--       |   v[b] := (v[b] ^ v[c]) >>> R2
--       |   v[a] := (v[a] + v[b] + y) mod 2**w
--       |   v[d] := (v[d] ^ v[a]) >>> R3
--       |   v[c] := (v[c] + v[d])     mod 2**w
--       |   v[b] := (v[b] ^ v[c]) >>> R4
--       |
--       |   RETURN v[0..15]
--       |
--       END FUNCTION.
--
--          where R1 = 16, R2 = 12, R3 = 8, R4 = 7

signal b_primera, b_segunda: std_logic_vector(31 downto 0);
signal c_primera: std_logic_vector(31 downto 0);

--signals for muxes
signal  b_primera_ror12 : std_logic_vector(31 downto 0);

begin

-- para la primera palabra


salida_a <= entrada_a;

-- para la segunda palabra

b_primera <= entrada_b xor c_primera;

b_primera_ror12 <= b_primera(11 downto 0) & b_primera(31 downto 12);

b_segunda <= b_primera_ror12;

salida_b <= b_segunda;

-- para la tercera palabra

c_primera <= std_logic_vector( unsigned(entrada_c) + unsigned(entrada_d) );

salida_c <= c_primera;


-- para la cuarta palabra

salida_d <= entrada_d;

end flujo_de_datos;