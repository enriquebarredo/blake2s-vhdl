----------------------------------------------------------------------------------
-- Company:
-- Engineer: JosuÅEEnrique Barredo Alamilla
-- 
-- Create Date: 04/28/2023 06:06:01 PM
-- Design Name: 
-- Module Name: funcion_compresion - estructura
-- Project Name: Blake2s hardware implementation
-- Target Devices: PYNQ-Z1

-- Additional Comments:
-- birgilio dise:
-- AHORA ESTOY MOTIVADO
-- MUESTRAME TU MOTIVACION
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ronda_compresion is
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
end ronda_compresion;

architecture buffers_and_buffers of ronda_compresion is

component funcion_g_parte_1a
    Port ( entrada_a    : in std_logic_vector (31 downto 0);
           entrada_b    : in std_logic_vector (31 downto 0);
           entrada_c    : in std_logic_vector (31 downto 0);
           entrada_d    : in std_logic_vector (31 downto 0);
           entrada_x    : in std_logic_vector (31 downto 0);
           
           salida_a     : out std_logic_vector (31 downto 0);
           salida_b     : out std_logic_vector (31 downto 0);
           salida_c     : out std_logic_vector (31 downto 0);
           salida_d     : out std_logic_vector (31 downto 0)
         );
end component;

component funcion_g_parte_1b
    Port ( entrada_a    : in std_logic_vector (31 downto 0);
           entrada_b    : in std_logic_vector (31 downto 0);
           entrada_c    : in std_logic_vector (31 downto 0);
           entrada_d    : in std_logic_vector (31 downto 0);
           
           salida_a     : out std_logic_vector (31 downto 0);
           salida_b     : out std_logic_vector (31 downto 0);
           salida_c     : out std_logic_vector (31 downto 0);
           salida_d     : out std_logic_vector (31 downto 0)
         );
end component;

component funcion_g_parte_2a
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
end component;

component funcion_g_parte_2b
    Port ( entrada_a    : in std_logic_vector (31 downto 0);
           entrada_b    : in std_logic_vector (31 downto 0);
           entrada_c    : in std_logic_vector (31 downto 0);
           entrada_d    : in std_logic_vector (31 downto 0);

           salida_a     : out std_logic_vector (31 downto 0);
           salida_b     : out std_logic_vector (31 downto 0);
           salida_c     : out std_logic_vector (31 downto 0);
           salida_d     : out std_logic_vector (31 downto 0)
         );
end component;

constant WIDTH: integer:= 32;

    type buffercito is
        array (0 to 3) of std_logic_vector(WIDTH - 1 downto 0);

    type buffersote is
        array (0 to 2) of buffercito;

signal g0_buffer_reg, g0_buffer_next : buffersote;
signal g1_buffer_reg, g1_buffer_next : buffersote;
signal g2_buffer_reg, g2_buffer_next : buffersote;
signal g3_buffer_reg, g3_buffer_next : buffersote;

signal x0_entrada, y0_entrada : std_logic_vector(WIDTH -1 downto 0);
signal x1_entrada, y1_entrada : std_logic_vector(WIDTH -1 downto 0);
signal x2_entrada, y2_entrada : std_logic_vector(WIDTH -1 downto 0);
signal x3_entrada, y3_entrada : std_logic_vector(WIDTH -1 downto 0);

signal b_g0_entrada, c_g0_entrada, d_g0_entrada : std_logic_vector(WIDTH -1 downto 0);
signal b_g1_entrada, c_g1_entrada, d_g1_entrada : std_logic_vector(WIDTH -1 downto 0);
signal b_g2_entrada, c_g2_entrada, d_g2_entrada : std_logic_vector(WIDTH -1 downto 0);
signal b_g3_entrada, c_g3_entrada, d_g3_entrada : std_logic_vector(WIDTH -1 downto 0);

signal a_g0_1a_salida, b_g0_1a_salida, c_g0_1a_salida, d_g0_1a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g1_1a_salida, b_g1_1a_salida, c_g1_1a_salida, d_g1_1a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g2_1a_salida, b_g2_1a_salida, c_g2_1a_salida, d_g2_1a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g3_1a_salida, b_g3_1a_salida, c_g3_1a_salida, d_g3_1a_salida : std_logic_vector(WIDTH -1 downto 0);

signal a_g0_1b_salida, b_g0_1b_salida, c_g0_1b_salida, d_g0_1b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g1_1b_salida, b_g1_1b_salida, c_g1_1b_salida, d_g1_1b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g2_1b_salida, b_g2_1b_salida, c_g2_1b_salida, d_g2_1b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g3_1b_salida, b_g3_1b_salida, c_g3_1b_salida, d_g3_1b_salida : std_logic_vector(WIDTH -1 downto 0);

signal a_g0_2a_salida, b_g0_2a_salida, c_g0_2a_salida, d_g0_2a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g1_2a_salida, b_g1_2a_salida, c_g1_2a_salida, d_g1_2a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g2_2a_salida, b_g2_2a_salida, c_g2_2a_salida, d_g2_2a_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g3_2a_salida, b_g3_2a_salida, c_g3_2a_salida, d_g3_2a_salida : std_logic_vector(WIDTH -1 downto 0);

signal a_g0_2b_salida, b_g0_2b_salida, c_g0_2b_salida, d_g0_2b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g1_2b_salida, b_g1_2b_salida, c_g1_2b_salida, d_g1_2b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g2_2b_salida, b_g2_2b_salida, c_g2_2b_salida, d_g2_2b_salida : std_logic_vector(WIDTH -1 downto 0);
signal a_g3_2b_salida, b_g3_2b_salida, c_g3_2b_salida, d_g3_2b_salida : std_logic_vector(WIDTH -1 downto 0);

begin

-- data buffers
process(clk)
begin
    if rising_edge(clk) then
        g0_buffer_reg <= g0_buffer_next;
        g1_buffer_reg <= g1_buffer_next;
        g2_buffer_reg <= g2_buffer_next;
        g3_buffer_reg <= g3_buffer_next;
    end if;
end process;


---------------------  mux para x's

x0_entrada <= m0 when mix_status = '0' else
              m8;

x1_entrada <= m2 when mix_status = '0' else
              m10;

x2_entrada <= m4 when mix_status = '0' else
              m12;

x3_entrada <= m6 when mix_status = '0' else
              m14;

---------------------  mux para y's

y0_entrada <= m1 when mix_status = '0' else
              m9;

y1_entrada <= m3 when mix_status = '0' else
              m11;

y2_entrada <= m5 when mix_status = '0' else
              m13;

y3_entrada <= m7 when mix_status = '0' else
              m15;

------------  mux para entradas b's

b_g0_entrada <= v4_entrante when mix_status = '0' else
                 v5_entrante;

b_g1_entrada <= v5_entrante when mix_status = '0' else
                 v6_entrante;

b_g2_entrada <= v6_entrante when mix_status = '0' else
                 v7_entrante;

b_g3_entrada <= v7_entrante when mix_status = '0' else
                 v4_entrante;

----------  mux para entradas c's

c_g0_entrada <= v8_entrante when mix_status = '0' else
                 v10_entrante;

c_g1_entrada <= v9_entrante when mix_status = '0' else
                 v11_entrante;

c_g2_entrada <= v10_entrante when mix_status = '0' else
                 v8_entrante;

c_g3_entrada <= v11_entrante when mix_status = '0' else
                 v9_entrante;

----------  mux para entradas d's


d_g0_entrada <= v12_entrante when mix_status = '0' else
                v15_entrante;

d_g1_entrada <= v13_entrante when mix_status = '0' else
                v12_entrante;

d_g2_entrada <= v14_entrante when mix_status = '0' else
                v13_entrante;

d_g3_entrada <= v15_entrante when mix_status = '0' else
                v14_entrante;

-----------------------  salidas

---  no hay mux para salidas a's

v0_saliente <= a_g0_2b_salida;
v1_saliente <= a_g1_2b_salida;
v2_saliente <= a_g2_2b_salida;
v3_saliente <= a_g3_2b_salida;

----------  mux para salidas b's

v4_saliente <=  b_g0_2b_salida when mix_status = '0' else
                b_g3_2b_salida;

v5_saliente <=  b_g1_2b_salida when mix_status = '0' else
                b_g0_2b_salida;

v6_saliente <=  b_g2_2b_salida when mix_status = '0' else
                b_g1_2b_salida;

v7_saliente <=  b_g3_2b_salida when mix_status = '0' else
                b_g2_2b_salida;

----------  mux para salidas c's

v8_saliente <=  c_g0_2b_salida when mix_status = '0' else
                c_g2_2b_salida;

v9_saliente <=  c_g1_2b_salida when mix_status = '0' else
                c_g3_2b_salida;

v10_saliente <= c_g2_2b_salida when mix_status = '0' else
                c_g0_2b_salida;

v11_saliente <= c_g3_2b_salida when mix_status = '0' else
                c_g1_2b_salida;

----------  mux para salidas d's

v12_saliente <= d_g0_2b_salida when mix_status = '0' else
                d_g1_2b_salida;

v13_saliente <= d_g1_2b_salida when mix_status = '0' else
                d_g2_2b_salida;

v14_saliente <= d_g2_2b_salida when mix_status = '0' else
                d_g3_2b_salida;

v15_saliente <= d_g3_2b_salida when mix_status = '0' else
                d_g0_2b_salida;

g0_1a: funcion_g_parte_1a
port map (  entrada_a => v0_entrante,
            entrada_b => b_g0_entrada,
            entrada_c => c_g0_entrada,
            entrada_d => d_g0_entrada,

            entrada_x => x0_entrada,
            
            salida_a => a_g0_1a_salida,
            salida_b => b_g0_1a_salida,
            salida_c => c_g0_1a_salida,
            salida_d => d_g0_1a_salida
    ) ;

g0_buffer_next(0)(0) <= a_g0_1a_salida;
g0_buffer_next(0)(1) <= b_g0_1a_salida;
g0_buffer_next(0)(2) <= c_g0_1a_salida;
g0_buffer_next(0)(3) <= d_g0_1a_salida;

g0_1b: funcion_g_parte_1b
port map (  entrada_a => g0_buffer_reg(0)(0),
            entrada_b => g0_buffer_reg(0)(1),
            entrada_c => g0_buffer_reg(0)(2),
            entrada_d => g0_buffer_reg(0)(3),

            salida_a => a_g0_1b_salida,
            salida_b => b_g0_1b_salida,
            salida_c => c_g0_1b_salida,
            salida_d => d_g0_1b_salida
    ) ;

g0_buffer_next(1)(0) <= a_g0_1b_salida;
g0_buffer_next(1)(1) <= b_g0_1b_salida;
g0_buffer_next(1)(2) <= c_g0_1b_salida;
g0_buffer_next(1)(3) <= d_g0_1b_salida;

g0_2a: funcion_g_parte_2a
port map (  entrada_a => g0_buffer_reg(1)(0),
            entrada_b => g0_buffer_reg(1)(1),
            entrada_c => g0_buffer_reg(1)(2),
            entrada_d => g0_buffer_reg(1)(3),
            
            entrada_y => y0_entrada,
            
            salida_a => a_g0_2a_salida,
            salida_b => b_g0_2a_salida,
            salida_c => c_g0_2a_salida,
            salida_d => d_g0_2a_salida
    ) ;

g0_buffer_next(2)(0) <= a_g0_2a_salida;
g0_buffer_next(2)(1) <= b_g0_2a_salida;
g0_buffer_next(2)(2) <= c_g0_2a_salida;
g0_buffer_next(2)(3) <= d_g0_2a_salida;

g0_2b: funcion_g_parte_2b
port map (  entrada_a => g0_buffer_reg(2)(0),
            entrada_b => g0_buffer_reg(2)(1),
            entrada_c => g0_buffer_reg(2)(2),
            entrada_d => g0_buffer_reg(2)(3),

            salida_a => a_g0_2b_salida,
            salida_b => b_g0_2b_salida,
            salida_c => c_g0_2b_salida,
            salida_d => d_g0_2b_salida
    ) ;


g1_1a: funcion_g_parte_1a
port map (  entrada_a => v1_entrante,
            entrada_b => b_g1_entrada,
            entrada_c => c_g1_entrada,
            entrada_d => d_g1_entrada,

            entrada_x => x1_entrada,
            
            salida_a => a_g1_1a_salida,
            salida_b => b_g1_1a_salida,
            salida_c => c_g1_1a_salida,
            salida_d => d_g1_1a_salida
    ) ;

g1_buffer_next(0)(0) <= a_g1_1a_salida;
g1_buffer_next(0)(1) <= b_g1_1a_salida;
g1_buffer_next(0)(2) <= c_g1_1a_salida;
g1_buffer_next(0)(3) <= d_g1_1a_salida;

g1_1b: funcion_g_parte_1b
port map (  entrada_a => g1_buffer_reg(0)(0),
            entrada_b => g1_buffer_reg(0)(1),
            entrada_c => g1_buffer_reg(0)(2),
            entrada_d => g1_buffer_reg(0)(3),

            salida_a => a_g1_1b_salida,
            salida_b => b_g1_1b_salida,
            salida_c => c_g1_1b_salida,
            salida_d => d_g1_1b_salida
    ) ;

g1_buffer_next(1)(0) <= a_g1_1b_salida;
g1_buffer_next(1)(1) <= b_g1_1b_salida;
g1_buffer_next(1)(2) <= c_g1_1b_salida;
g1_buffer_next(1)(3) <= d_g1_1b_salida;

g1_2a: funcion_g_parte_2a
port map (  entrada_a => g1_buffer_reg(1)(0),
            entrada_b => g1_buffer_reg(1)(1),
            entrada_c => g1_buffer_reg(1)(2),
            entrada_d => g1_buffer_reg(1)(3),
            
            entrada_y => y1_entrada,
            
            salida_a => a_g1_2a_salida,
            salida_b => b_g1_2a_salida,
            salida_c => c_g1_2a_salida,
            salida_d => d_g1_2a_salida
    ) ;

g1_buffer_next(2)(0) <= a_g1_2a_salida;
g1_buffer_next(2)(1) <= b_g1_2a_salida;
g1_buffer_next(2)(2) <= c_g1_2a_salida;
g1_buffer_next(2)(3) <= d_g1_2a_salida;

g1_2b: funcion_g_parte_2b
port map (  entrada_a => g1_buffer_reg(2)(0),
            entrada_b => g1_buffer_reg(2)(1),
            entrada_c => g1_buffer_reg(2)(2),
            entrada_d => g1_buffer_reg(2)(3),

            salida_a => a_g1_2b_salida,
            salida_b => b_g1_2b_salida,
            salida_c => c_g1_2b_salida,
            salida_d => d_g1_2b_salida
    ) ;



g2_1a: funcion_g_parte_1a
port map (  entrada_a => v2_entrante,
            entrada_b => b_g2_entrada,
            entrada_c => c_g2_entrada,
            entrada_d => d_g2_entrada,

            entrada_x => x2_entrada,
            
            salida_a => a_g2_1a_salida,
            salida_b => b_g2_1a_salida,
            salida_c => c_g2_1a_salida,
            salida_d => d_g2_1a_salida
    ) ;

g2_buffer_next(0)(0) <= a_g2_1a_salida;
g2_buffer_next(0)(1) <= b_g2_1a_salida;
g2_buffer_next(0)(2) <= c_g2_1a_salida;
g2_buffer_next(0)(3) <= d_g2_1a_salida;

g2_1b: funcion_g_parte_1b
port map (  entrada_a => g2_buffer_reg(0)(0),
            entrada_b => g2_buffer_reg(0)(1),
            entrada_c => g2_buffer_reg(0)(2),
            entrada_d => g2_buffer_reg(0)(3),

            salida_a => a_g2_1b_salida,
            salida_b => b_g2_1b_salida,
            salida_c => c_g2_1b_salida,
            salida_d => d_g2_1b_salida
    ) ;

g2_buffer_next(1)(0) <= a_g2_1b_salida;
g2_buffer_next(1)(1) <= b_g2_1b_salida;
g2_buffer_next(1)(2) <= c_g2_1b_salida;
g2_buffer_next(1)(3) <= d_g2_1b_salida;

g2_2a: funcion_g_parte_2a
port map (  entrada_a => g2_buffer_reg(1)(0),
            entrada_b => g2_buffer_reg(1)(1),
            entrada_c => g2_buffer_reg(1)(2),
            entrada_d => g2_buffer_reg(1)(3),

            entrada_y => y2_entrada,

            salida_a => a_g2_2a_salida,
            salida_b => b_g2_2a_salida,
            salida_c => c_g2_2a_salida,
            salida_d => d_g2_2a_salida
    ) ;

g2_buffer_next(2)(0) <= a_g2_2a_salida;
g2_buffer_next(2)(1) <= b_g2_2a_salida;
g2_buffer_next(2)(2) <= c_g2_2a_salida;
g2_buffer_next(2)(3) <= d_g2_2a_salida;

g2_2b: funcion_g_parte_2b
port map (  entrada_a => g2_buffer_reg(2)(0),
            entrada_b => g2_buffer_reg(2)(1),
            entrada_c => g2_buffer_reg(2)(2),
            entrada_d => g2_buffer_reg(2)(3),

            salida_a => a_g2_2b_salida,
            salida_b => b_g2_2b_salida,
            salida_c => c_g2_2b_salida,
            salida_d => d_g2_2b_salida
    ) ;

g3_1a: funcion_g_parte_1a
port map (  entrada_a => v3_entrante,
            entrada_b => b_g3_entrada,
            entrada_c => c_g3_entrada,
            entrada_d => d_g3_entrada,

            entrada_x => x3_entrada,
            
            salida_a => a_g3_1a_salida,
            salida_b => b_g3_1a_salida,
            salida_c => c_g3_1a_salida,
            salida_d => d_g3_1a_salida
    ) ;

g3_buffer_next(0)(0) <= a_g3_1a_salida;
g3_buffer_next(0)(1) <= b_g3_1a_salida;
g3_buffer_next(0)(2) <= c_g3_1a_salida;
g3_buffer_next(0)(3) <= d_g3_1a_salida;

g3_1b: funcion_g_parte_1b
port map (  entrada_a => g3_buffer_reg(0)(0),
            entrada_b => g3_buffer_reg(0)(1),
            entrada_c => g3_buffer_reg(0)(2),
            entrada_d => g3_buffer_reg(0)(3),

            salida_a => a_g3_1b_salida,
            salida_b => b_g3_1b_salida,
            salida_c => c_g3_1b_salida,
            salida_d => d_g3_1b_salida
    ) ;

g3_buffer_next(1)(0) <= a_g3_1b_salida;
g3_buffer_next(1)(1) <= b_g3_1b_salida;
g3_buffer_next(1)(2) <= c_g3_1b_salida;
g3_buffer_next(1)(3) <= d_g3_1b_salida;

g3_2a: funcion_g_parte_2a
port map (  entrada_a => g3_buffer_reg(1)(0),
            entrada_b => g3_buffer_reg(1)(1),
            entrada_c => g3_buffer_reg(1)(2),
            entrada_d => g3_buffer_reg(1)(3),
            
            entrada_y => y3_entrada,
            
            salida_a => a_g3_2a_salida,
            salida_b => b_g3_2a_salida,
            salida_c => c_g3_2a_salida,
            salida_d => d_g3_2a_salida
    ) ;

g3_buffer_next(2)(0) <= a_g3_2a_salida;
g3_buffer_next(2)(1) <= b_g3_2a_salida;
g3_buffer_next(2)(2) <= c_g3_2a_salida;
g3_buffer_next(2)(3) <= d_g3_2a_salida;

g3_2b: funcion_g_parte_2b
port map (  entrada_a => g3_buffer_reg(2)(0),
            entrada_b => g3_buffer_reg(2)(1),
            entrada_c => g3_buffer_reg(2)(2),
            entrada_d => g3_buffer_reg(2)(3),

            salida_a => a_g3_2b_salida,
            salida_b => b_g3_2b_salida,
            salida_c => c_g3_2b_salida,
            salida_d => d_g3_2b_salida
    ) ;

end buffers_and_buffers;