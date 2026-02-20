--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
--=============================================================================
--Entity Declaration:
--=============================================================================
entity controller_tb is
end controller_tb;
--=============================================================================
--Architecture Type:
--=============================================================================    
architecture testbench of controller_tb is

--=============================================================================
--Component Declaration:
--=============================================================================    
-- Declare the unit that is to be simulated
-- Need to specify what the input ports and output ports are
component wordle_controller IS
	Port (
		--timing:
			clk_port 		: in STD_LOGIC;
			take_guess_port	: in STD_LOGIC;
			load_guess	    : out STD_LOGIC;
			check_guess	    : out STD_LOGIC;
			game_over	    : out STD_LOGIC;
    );
end component;

--=============================================================================
--Signal and Constant Declarations: 
--=============================================================================
signal clk : STD_LOGIC;
signal take_guess : STD_LOGIC;
signal load_guess : STD_LOGIC;
signal check_guess : STD_LOGIC;
signal game_over : STD_LOGIC;

begin
--=============================================================================
--Port Map: 
--=============================================================================
--This "port map" connects the ports (inputs and outputs of bcd_digit)
--to the signals (behaves like variables) in the testbench

uut: wordle_controller PORT MAP(
	clk_port => clk,
    take_guess_port => take_guess,
    load_guess => load_guess,
    check_guess => check_guess,
    game_over => game_over
);


--=============================================================================
--Clock Generation Process: 
--=============================================================================
--Mimics the clock generation sub-component in the larger design

clk_proc : process
BEGIN
	clk <= '0';
	wait for 20ns;
	clk <= '1';
	wait for 20ns;
end process clk_proc;


--=============================================================================
--Stimulus Process: 
--=============================================================================
--Generates inputs to the system from the external world.
--In this case, pretends to be the user setting slide switches.
--Default behavior is the initialized values.

stimulus_proc : process
begin
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    take_guess <= '1';
    wait for 40 ns;
    take_guess <= '0';
    wait for 40 ns;
    wait;
end process stimulus_proc;

end testbench;