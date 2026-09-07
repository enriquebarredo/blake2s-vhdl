library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity funcion_g_parte_2a is
    Port ( entrada_a    : in std_logic_vector (31 downto 0);
           entrada_b    : in std_logic_vector (31 downto 0);
           entrada_c    : in std_logic_vector (31 downto 0);
           entrada_d    : in std_logic_vector (31 downto 0);
           entrada_y    : in std_logic_vector (31 downto 0);
           
           salida_a     : out std_logic_vector (31 downto 0);
           salida_b     : out std_logic_vector (31 downto 0);
           salida_c     : out std_logic_vector (31 downto 0);
           salida_d     : out std_logic_vector (31 downto 0)
         );
end funcion_g_parte_2a;

architecture flujo_de_datos of funcion_g_parte_2a is

-- From RFC 7693
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

signal a_primera: std_logic_vector(31 downto 0);

signal d_primera, d_segunda: std_logic_vector(31 downto 0);

--signals for muxes
signal  d_primera_ror8 : std_logic_vector(31 downto 0);

begin

--muxes para seleccionar entre parte 1 o parte 2 de la funcion g


-- para la primera palabra

a_primera <= std_logic_vector( unsigned(entrada_a) + unsigned(entrada_b) + unsigned(entrada_y) );
salida_a <= a_primera;

-- para la segunda palabra

salida_b <= entrada_b;

-- para la tercera palabra

salida_c <= entrada_c;


-- para la cuarta palabra

d_primera <= a_primera xor entrada_d;

d_primera_ror8 <= d_primera(7 downto 0) & d_primera(31 downto 8);
d_segunda <= d_primera_ror8;

salida_d <= d_segunda;

end flujo_de_datos;