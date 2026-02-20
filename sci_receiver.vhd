library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sci_receiver is
Port (clk: in std_logic;
    Rx: in std_logic;
    data_ready: out std_logic;
    parallel_reg: out std_logic_vector(7 downto 0));
end sci_receiver;

architecture Behavioral of sci_receiver is

--signals
constant BAUD_PERIOD: integer := 10416;
constant BAUD_PERIOD_HALF: integer := 5207;
signal baud_counter: unsigned (15 downto 0) := (others => '0');
signal shift_reg : std_logic_vector (9 downto 0) := (others => '1');
signal baud_tc : std_logic;
signal bit_counter: unsigned(3 downto 0);
type states is (IDLE, START_BIT, SAMPLE, STOP_BIT);
signal curr_state, next_state : states := IDLE;
signal move_past_idle: std_logic := '0';
signal previous_Rx: std_logic := '1';
signal curr_Rx : std_logic := '1';
signal falling_Rx_edge : std_logic := '0';
signal move_to_sample : std_logic := '0';
signal move_to_idle : std_logic := '0';


begin

updateRxs: process(clk)
begin
    if rising_edge(clk) then
        curr_Rx <= Rx;
        previous_Rx <= curr_Rx;
    end if;
end process updateRxs;
falling_Rx_edge <= '1' when curr_Rx = '0' and previous_Rx = '1' else '0';

datapath: process(clk)
begin
    if rising_edge(clk) then
        curr_state <= next_state;
        data_ready <= '0';
        if curr_state = IDLE then
            bit_counter <= (others => '0');
            move_to_idle <= '0';
            if falling_Rx_edge = '1' then
                baud_counter <= (others => '0');
                move_past_idle <= '1';
            else    
                baud_counter <= baud_counter +1;
            end if;
        elsif curr_state = START_BIT then
            if to_integer(baud_counter) = BAUD_PERIOD_HALF then
                shift_reg <= curr_Rx & shift_reg(9 downto 1);
                baud_counter <= (others => '0');
                move_to_sample <= '1';
            else    
                baud_counter <= baud_counter +1;
            end if;
        elsif curr_state = SAMPLE then
            if baud_tc = '1' then
                shift_reg <= curr_Rx & shift_reg(9 downto 1);
                baud_counter <= (others => '0');
                bit_counter <= bit_counter +1;
            else    
                baud_counter <= baud_counter +1;
            end if;
            move_past_idle <= '0';
         elsif curr_state = STOP_BIT then
            move_to_sample <= '0';
            if baud_tc = '1' then
                shift_reg <= curr_Rx & shift_reg(9 downto 1);
                baud_counter <= (others => '0');
                move_to_idle <= '1';
                data_ready <= '1';
            else    
                baud_counter <= baud_counter +1;
            end if;
        end if;
   end if;
end process datapath;

nextState: process(curr_state, move_past_idle, bit_counter, move_to_sample, move_to_idle)
begin
    next_state <= curr_state;
    case curr_state is 
        when IDLE =>
            if move_past_idle = '1' then
                next_state <= START_BIT;
            end if;
        when START_BIT => 
            if move_to_sample = '1' then
                next_state <= SAMPLE;
            end if;
        when SAMPLE =>
            if bit_counter = 8 then
                next_state <= STOP_BIT;
            end if;
        when STOP_BIT => 
            if move_to_idle = '1' then
                next_state <= IDLE;
            end if;
    end case;
end process;

baud_tc <= '1' when baud_counter = BAUD_PERIOD -1 else '0';

parallel_reg <= shift_reg(8 downto 1);

end Behavioral;
