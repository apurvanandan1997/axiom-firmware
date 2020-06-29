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

use work.vivado_pkg.ALL;    -- Vivado Attributes
use work.par_array_pkg.ALL; -- Parallel Data


entity ser_to_par is
    generic (
        CHANNELS : natural := 32
    );
    port (
        serdes_clk    : in std_logic;
        serdes_clkdiv : in std_logic;
        serdes_phase  : in std_logic;
        serdes_rst    : in std_logic;
        --
        ser_data : in std_logic_vector (CHANNELS - 1 downto 0);
        --
        par_clk    : in  std_logic;
        par_enable : out std_logic;
        par_data   : out par12_a (CHANNELS - 1 downto 0);
        --
        bitslip       : in  std_logic_vector (CHANNELS - 1 downto 0);
        count_enable  : in  std_logic
    );

end entity ser_to_par;
---------------------------------------------------------------------------------------------------------------------------------------------------------
-- data_dval_low, data_lval_low and data_fval_low are used to set the data value to 
-- some constant testpattern i.e representing TP1, TP2 as in cmv sesnsor
---------------------------------------------------------------------------------------------------------------------------------------------------------

architecture RTL of ser_to_par is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";
    signal par_data_buf             : par12_a(CHANNELS - 1 downto 0);
    signal ctrl_in                  : std_logic_vector(11 downto 0) := (others => '0');
    constant data_dval_low          : std_logic_vector(11 downto 0) := x"FFF";
    constant data_lval_low          : std_logic_vector(11 downto 0) := x"EEE";
    constant data_fval_low          : std_logic_vector(11 downto 0) := x"DDD";
    signal counter                  : std_logic_vector(11 downto 0) := data_dval_low;
    signal lval_count               : std_logic_vector(1 downto 0)  := (others => '0'); --used to indicate number of rows

begin


    counter_proc : process(serdes_clkdiv)
    begin
        if rising_edge(serdes_clkdiv) and serdes_phase = '1' then
            if count_enable ='1' then
                if counter= x"07F" then
                    counter <= data_dval_low;
                    ctrl_in <= x"007";

                elsif counter= data_dval_low then
                    counter <= x"800" ;
                    ctrl_in <= x"007";

                elsif counter = x"0FF" then
                    counter    <= data_lval_low;
                    ctrl_in    <= x"004";
                    lval_count <= lval_count + 1;

                elsif counter= data_lval_low then
                    counter <= (others => '0');
                    ctrl_in <= x"007";

                elsif lval_count = "10" then
                    counter <= data_fval_low;
                    ctrl_in <= x"000";

                else
                    counter <= counter + 1;
                    ctrl_in <= x"000";

                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    --assigning fake data (test) to par_data 
    ----------------------------------------------------------------------

    GEN_PAT0 : for I in (CHANNELS - 2) downto 0 generate
        par_data_buf(I)(11 downto 8) <=  std_logic_vector(to_unsigned(I/2,4));                
        par_data_buf(I)(7 downto 0 ) <=  counter(7 downto 0 ) ;
    end generate;

    par_data_buf(CHANNELS-1) <= ctrl_in;
    par_data         <= par_data_buf;

    push_proc : process (par_clk)
        variable phase_d_v : std_logic;
    begin
        if rising_edge(par_clk) then
            if phase_d_v = '1' and serdes_phase = '0' then
                par_enable <= '1';
            else
                par_enable <= '0';
            end if;

            phase_d_v := serdes_phase;
        end if;
    end process;


end RTL;
