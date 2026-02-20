library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sci_transmitter is
Port (clk: in std_logic;
    tx_parallel_reg: in std_logic_vector(7 downto 0);
    tx_start: in std_logic;
    Tx_busy: out std_logic := '0';
    Tx: out std_logic);
end sci_transmitter;

architecture Behavioral of sci_transmitter is

--signals
constant BAUD_PERIOD: integer := 10416;
signal baud_counter: unsigned (15 downto 0) := (others => '0');
signal shift_reg : std_logic_vector (9 downto 0) := (others => '1');
signal baud_tc : std_logic;
signal bit_counter: integer range 0 to 11 := 11;

begin

datapath: process(clk)
begin
    if rising_edge(clk) then
        if tx_start = '1' then 
            baud_counter <= (others => '0');
            shift_reg <= '1' & tx_parallel_reg & '0';
            bit_counter <= 0;
        elsif baud_tc = '1' then
            shift_reg <= '1' & shift_reg(9 downto 1);
            baud_counter <= (others => '0');
            if bit_counter < 10 then
                bit_counter <= bit_counter +1;
            end if;
        else    
            baud_counter <= baud_counter +1;
        end if;
   end if;
end process datapath;
Tx_busy <= '1' when bit_counter < 10 else '0';

baud_tc <= '1' when baud_counter = BAUD_PERIOD -1 else '0';

Tx <= shift_reg(0);
        
        


end Behavioral;
