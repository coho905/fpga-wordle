library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity InputBuffer is
  port (
    clk              : in  std_logic;
    rst_buff         : in  std_logic;  -- sync reset for the buffer only (optional)

    -- from UART RX
    rx_byte     : in  std_logic_vector(7 downto 0);
    rx_rdy      : in  std_logic;  -- 1-cycle pulse when rx_byte is valid

    -- outputs
    guess0      : out std_logic_vector(7 downto 0);
    guess1      : out std_logic_vector(7 downto 0);
    guess2      : out std_logic_vector(7 downto 0);
    guess3      : out std_logic_vector(7 downto 0);
    guess4      : out std_logic_vector(7 downto 0);
    wptr_out    : out unsigned(2 downto 0);  -- 0..5 for debugging/UI
    guess_ready : out std_logic              -- 1-cycle pulse when enter & wptr=5
  );
end entity;

architecture behavioral of InputBuffer is
  type char5_array is array (0 to 4) of std_logic_vector(7 downto 0);
  signal guess : char5_array := (others => (others => '0'));
  signal wptr  : unsigned(2 downto 0) := (others => '0'); -- 0..5
  signal ready_p : std_logic := '0';

begin
  process(clk)
  begin
    if rising_edge(clk) then
      -- defaults
      ready_p <= '0';

      if rst_buff = '1' then
        guess <= (others => (others => '0'));
        wptr  <= (others => '0');

      else
        if rx_rdy = '1' then
          -- BACKSPACE
          if rx_byte = x"08" or rx_byte = x"7F" then
            if wptr > 0 then
              wptr <= wptr - 1;
              guess(to_integer(wptr - 1)) <= (others => '0');
            end if;
          -- ENTER
          elsif rx_byte = x"0D" or rx_byte = x"0A" then
            if wptr = 5 then
              ready_p <= '1';          -- full word captured
            end if;
          -- NEW BYTE FROM UART
          else
            if wptr < 5 then
              guess(to_integer(wptr)) <= rx_byte;
              wptr <= wptr + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- outputs
  guess0      <= guess(0);
  guess1      <= guess(1);
  guess2      <= guess(2);
  guess3      <= guess(3);
  guess4      <= guess(4);
  wptr_out    <= wptr;
  guess_ready <= ready_p;
end architecture;
