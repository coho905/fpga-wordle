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

entity sci_shell is
--  Port ( );
    PORT(
        clk: in std_logic;
        Rx: in std_logic;
        Tx: out std_logic);
end sci_shell;

architecture Behavioral of sci_shell is


component sci_transmitter is
Port (clk: in std_logic;
    tx_parallel_reg: in std_logic_vector(7 downto 0);
    tx_start: in std_logic;
    Tx_busy: out std_logic;
    Tx: out std_logic);
end component;

component sci_receiver is
Port (clk: in std_logic;
    Rx: in std_logic;
    data_ready: out std_logic;
    parallel_reg: out std_logic_vector(7 downto 0));
end component;

signal data_ready: std_logic;
signal parallel_reg: std_logic_vector(7 downto 0);
signal guess0:  std_logic_vector(7 downto 0);
signal guess1:  std_logic_vector(7 downto 0);
signal guess2:  std_logic_vector(7 downto 0);
signal guess3:  std_logic_vector(7 downto 0);
signal guess4:  std_logic_vector(7 downto 0);
signal guess_ready: std_logic;
signal wptr: unsigned(2 downto 0);
signal reset: std_logic := '0';
signal Tx_start: std_logic := '0';
signal guess_ready_past : std_logic :='0';
signal Tx_busy: std_logic;
signal print_to_terminal : std_logic_vector(7 downto 0);
signal counter: integer range 0 to 8:= 0;
signal send_active : std_logic := '0';
signal print: std_logic := '0';
signal reset_buffer : std_logic := '0';
signal check_guess_port: std_logic;
signal load_guess_port: std_logic;
signal game_over_port: std_logic;
signal win_port: std_logic := '0';
signal lose_port: std_logic := '0';
signal result_port_1 : std_logic_vector(7 downto 0);
signal result_port_2 : std_logic_vector(7 downto 0);
signal result_port_3 : std_logic_vector(7 downto 0);
signal result_port_4 : std_logic_vector(7 downto 0);
signal result_port_5 : std_logic_vector(7 downto 0);
signal wait_one_cycle : std_logic := '0';
signal local_echo_active : std_logic := '1';
signal echo_tx_start : std_logic := '0';
signal echo_to_terminal : std_logic_vector(7 downto 0);
signal check_guess_done : std_logic := '0';
signal take_guess_check_done : std_logic := '0';
signal check_result_port : std_logic := '0';
signal out_reset_buffer : std_logic := '0';
signal out_tx_start : std_logic := '0';
signal out_done_printing : std_logic := '0';
signal out_guess_check_done : std_logic := '0';
signal out_win : std_logic := '0';
signal out_lose : std_logic := '0';
signal out_tx_busy : std_logic := '0';
signal load_guess : std_logic := '0';
signal check_guess : std_logic := '0';
signal print_win : std_logic := '0';
signal print_lose : std_logic := '0';
signal game_over : std_logic := '0';
signal check_result : std_logic := '0';
signal send_result_to_terminal : std_logic := '0';
signal echo_enable : std_logic := '0';
signal take_echo_enable : std_logic := '0';
signal tx_parallel_reg : std_logic_vector(7 downto 0);
signal out_printed_win_result : std_logic := '0';
signal out_printed_lose_result : std_logic := '0';
signal take_print_win : std_logic := '0';
signal take_print_lose : std_logic := '0';
signal take_reset_buffer : std_logic := '0';
signal out_max_guesses_reached : std_logic := '0';

begin

    tx_monopulse: process(clk)
    begin
        if rising_edge(clk) then
            guess_ready_past <= check_guess_port;
        end if;
    end process tx_monopulse;


    receiving: sci_receiver
        port map(
            clk => clk,
            Rx => Rx,
            data_ready => data_ready,
            parallel_reg => parallel_reg
    );


    transmitting: sci_transmitter
        port map(
            --inputs
            clk => clk,
            tx_parallel_reg => print_to_terminal,
            Tx_start => out_tx_start,
            
            --outputs
            Tx_busy => Tx_busy,
            Tx => Tx
    );


    Buffer5x8_inst : entity work.InputBuffer
        port map (
        clk         => clk,
        rst_buff    => out_reset_buffer,
        -- from RX
        rx_byte     => parallel_reg,
        rx_rdy      => data_ready,
        -- outputs (5 stored chars + status)
        guess0      => guess0,
        guess1      => guess1,
        guess2      => guess2,
        guess3      => guess3,
        guess4      => guess4,
        wptr_out    => wptr,
        guess_ready => guess_ready
    );


    controller : entity work.wordle_controller
        Port map (
            --input
            clk_port => clk,
            take_guess_port => guess_ready,
            take_guess_check_done => out_guess_check_done,
            take_win => out_win,
            take_done_printing => out_done_printing,
            take_print_win => out_printed_win_result,
            take_print_lose => out_printed_lose_result,
            take_max_guesses_reached => out_max_guesses_reached,

            --control outputs:
            load_guess  => load_guess,
            check_guess => check_guess,
            check_result => check_result,
            game_over => game_over,
            send_result_to_terminal => send_result_to_terminal,
            print_win => print_win,
            print_lose => print_lose,
            echo_enable => echo_enable,
            out_reset_buffer => out_reset_buffer
        );


    datapath : entity work.wordle_datapath
        port map (
            --inputs
            clk_port        => clk,
            load_guess_port => load_guess,
            check_guess_port => check_guess, 
            check_result_port => check_result,
            game_over_port => game_over,
            guess_port_1      => guess0,
            guess_port_2      => guess1,
            guess_port_3      => guess2,
            guess_port_4      => guess3,
            guess_port_5      => guess4,
            take_tx_busy      => Tx_busy,
            take_print_win          => print_win,
            take_print_lose         => print_lose,
            take_data_ready      => data_ready,
            take_parallel_reg    => parallel_reg,
            take_echo_enable     => echo_enable,
            take_reset_buffer    => out_reset_buffer,

            --outputs
            print_to_terminal  => print_to_terminal,
            out_guess_check_done   => out_guess_check_done,
            out_win                  => out_win,
            out_done_printing        => out_done_printing,
            out_tx_start             => out_tx_start,
            out_printed_win_result   => out_printed_win_result,
            out_printed_lose_result  => out_printed_lose_result,
            out_max_guesses_reached    => out_max_guesses_reached
    );

end Behavioral;