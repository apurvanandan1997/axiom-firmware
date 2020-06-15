library IEEE;
use IEEE.std_logic_1164.ALL;

package par_array_pkg is

    type par8_a is array (natural range <>) of
	std_logic_vector (7 downto 0);

    type par10_a is array (natural range <>) of
	std_logic_vector (9 downto 0);

    type par12_a is array (natural range <>) of
	std_logic_vector (11 downto 0);

    type par16_a is array (natural range <>) of
	std_logic_vector (15 downto 0);

end par_array_pkg;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.par_array_pkg.ALL;	-- Parallel Data


entity ser_to_par is
    generic (
	CHANNELS : natural := 32
    );
    port (
	serdes_clk	: in  std_logic;
	serdes_clkdiv	: in  std_logic;
	serdes_phase	: in  std_logic;
	serdes_rst	: in  std_logic;
	--
	ser_data	: in  std_logic_vector (CHANNELS - 1 downto 0);
	--
	par_clk		: in  std_logic;
	par_enable	: out  std_logic;
	par_data	: out par12_a (CHANNELS - 1 downto 0);
	--
	bitslip		: in  std_logic_vector (CHANNELS - 1 downto 0);
	count_enable    : in std_logic;
        counter_check   : out std_logic_vector(11 downto 0)
	
    );

end entity ser_to_par;


architecture RTL of ser_to_par is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";
    signal test           : par12_a(CHANNELS-1 downto 0);
    signal counter        : std_logic_vector(11 downto 0);
    signal ctrl_in        : std_logic_vector(11 downto 0);
    constant testpattern1 : std_logic_vector(11 downto 0):="111111111111";
    constant testpattern2 : std_logic_vector(11 downto 0):="111100000000";   --F00 (hex)
    constant testpattern3 : std_logic_vector(11 downto 0) :="111000000000";  --E00 (hex)
    signal fval_count     : std_logic_vector(5 downto 0) :=(others => '0');  --FFF (hex)
    
begin


counter_proc: process(serdes_clkdiv)
begin
	if rising_edge(serdes_clkdiv) then
	   if count_enable ='1' then
	       if counter = "000011111111" then
                    counter <= testpattern1;
		    ctrl_in<= "000000000100";
		    fval_count<=fval_count+1;
						  
		elsif counter= testpattern1 then
		    counter <= (others => '0');
		    ctrl_in <="000000000111";
							
		elsif counter=  "000001111111" then 
		    counter <= testpattern2;
		    ctrl_in<="000000000110";
							
		elsif counter= testpattern2 then
		    counter <= "000010000000" ;
		    ctrl_in <="000000000111";
							
		elsif fval_count="100000" then
		    counter<= testpattern3;
		    ctrl_in<="000000000000";
				
                else
                    counter <= counter + 1;
		    ctrl_in<="000000000111";

               end if;   
           end if;
        end if;
 end process;

counter_check <= counter;
----------------------------------------------------------------------
--assigning fake data (test) to par_data 
----------------------------------------------------------------------

GEN_PAT: for I in CHANNELS - 2 downto 0 generate
    test(I)<=counter;
    end generate;
    
    test(CHANNELS-1) <= ctrl_in;
    par_data<=test;
    
       
proc: process(serdes_clk, serdes_clkdiv)
	 begin
	    if rising_edge(serdes_clkdiv) then
	        par_enable <='1';
	    end if;

	    if falling_edge(serdes_clk) then
		par_enable<='0';
	    end if;
	end process;
			
end RTL;

