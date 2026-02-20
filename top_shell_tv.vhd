-- Testbench for sci_shell (top-level integration)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- Required for unsigned and arithmetic

entity sci_shell_tb is
end sci_shell_tb;

architecture testbench of sci_shell_tb is

    component sci_shell
        port (
            clk : in std_logic;
            Rx  : in std_logic;
            Tx  : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal Rx  : std_logic := '1'; -- idle high for UART
    signal Tx  : std_logic;
    signal tb_tx_busy : std_logic := '0';
    signal tb_tx_start : std_logic := '0';
    signal tb_baud_counter: unsigned (15 downto 0) := (others => '0');
    constant tb_BAUD_PERIOD: integer := 10416;
    signal tb_shift_reg : std_logic_vector (9 downto 0) := (others => '1');
    signal tb_baud_tc : std_logic;
    signal tb_bit_counter: integer range 0 to 11 := 11;
    signal tb_data_ready : std_logic := '0';
    signal tb_parallel_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    uut : sci_shell
        port map (
            clk => clk,
            Rx  => Rx,
            Tx  => Tx
        );

    clk_proc : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process clk_proc;

    tb_uart_tx: process(clk)
    begin
        if rising_edge(clk) then
            if tb_data_ready = '1' then 
                tb_baud_counter <= (others => '0');
                tb_shift_reg <= '1' & tb_parallel_reg & '0';
                tb_bit_counter <= 0;
            elsif tb_baud_tc = '1' then
                tb_shift_reg <= '1' & tb_shift_reg(9 downto 1);
                tb_baud_counter <= (others => '0');
                if tb_bit_counter < 10 then
                    tb_bit_counter <= tb_bit_counter +1;
                end if;
            else    
                tb_baud_counter <= tb_baud_counter +1;
            end if;
        end if;
    end process tb_uart_tx;

    --Send busy signal while sending bits
    tb_Tx_busy <= '1' when tb_bit_counter < 10 else '0';
    --Flag when all bits have been sent
    tb_baud_tc <= '1' when tb_baud_counter = tb_BAUD_PERIOD -1 else '0';
    --Transmit data at index 0 of shift register
    RX <= tb_shift_reg(0);


    stim_proc : process
    begin
        wait for 1 ms;
        -- Send "HELLO"
        tb_parallel_reg <= x"47"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'G'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"45"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'E'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4D"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'M'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4E"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'N'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"0A"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- Carriage Return
        wait for 2 ms; -- Add delay to simulate realistic typing

        wait for 10 ms;

        tb_parallel_reg <= x"47"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'G'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"45"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'E'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4F"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'O'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"0A"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- Carriage Return
        
          wait for 10 ms;

        tb_parallel_reg <= x"47"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'G'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"45"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'E'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4F"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'O'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"0A"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- Carriage binary_read
        
          wait for 10 ms;

        tb_parallel_reg <= x"47"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'G'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"45"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'E'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4F"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'O'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"0A"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- Carriage binary_read
          wait for 10 ms;

        tb_parallel_reg <= x"47"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'G'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"45"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'E'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4C"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'L'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"4F"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- 'O'
        wait for 2 ms; -- Add delay to simulate realistic typing
        tb_parallel_reg <= x"0A"; tb_data_ready <= '1'; wait until tb_Tx_busy = '1'; tb_data_ready <= '0'; wait until tb_Tx_busy = '0'; -- Carriage binary_read
        wait;
        

    end process stim_proc;

end testbench;