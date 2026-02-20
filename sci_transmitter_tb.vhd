library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;entity sci_tx_tb is end sci_tx_tb;

architecture testbench of sci_tx_tb is
  component SCI_Tx is
    generic ( BAUD_PERIOD_G : integer := 10416 );
    port    ( clk : in std_logic; Parallel_in : in std_logic_vector(7 downto 0);
              New_data : in std_logic; Tx : out std_logic );
  end component;

  constant CLK_PERIOD     : time := 10 ns;
  constant FAST_BAUD_CYC  : integer := 16;
  constant BIT_TIME       : time := CLK_PERIOD * FAST_BAUD_CYC;

  signal clk_s      : std_logic := '0';
  signal new_data_s : std_logic := '0';
  signal parallel_s : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_s       : std_logic;
begin
  uut: SCI_Tx
    generic map ( BAUD_PERIOD_G => FAST_BAUD_CYC )
    port map ( clk => clk_s, Parallel_in => parallel_s, New_data => new_data_s, Tx => tx_s );

  clk_proc : process
  begin
    clk_s <= '0'; wait for CLK_PERIOD/2;
    clk_s <= '1'; wait for CLK_PERIOD/2;
  end process;

  stimulus_proc : process
  begin
    wait for 20*CLK_PERIOD;

    parallel_s <= x"41";         -- 'A'
    new_data_s <= '1'; wait for CLK_PERIOD; new_data_s <= '0';
    wait for 12*BIT_TIME;

    parallel_s <= x"5A";         -- 'Z'
    new_data_s <= '1'; wait for CLK_PERIOD; new_data_s <= '0';
    wait for 12*BIT_TIME;

    parallel_s <= x"00";
    new_data_s <= '1'; wait for CLK_PERIOD; new_data_s <= '0';
    wait for 12*BIT_TIME;

    report "TB finished" severity note;
    std.env.stop;
    wait;
  end process;
end testbench;