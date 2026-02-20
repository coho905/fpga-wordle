--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity wordle_datapath is
    Port (
        clk_port             : in std_logic;
        load_guess_port      : in std_logic;
        check_guess_port     : in std_logic;
        check_result_port    : in std_logic;
        game_over_port       : in std_logic;
        guess_port_1         : in std_logic_vector(7 downto 0);
        guess_port_2         : in std_logic_vector(7 downto 0);
        guess_port_3         : in std_logic_vector(7 downto 0);
        guess_port_4         : in std_logic_vector(7 downto 0);
        guess_port_5         : in std_logic_vector(7 downto 0);
        take_tx_busy         : in std_logic;
        take_print_win       : in std_logic;
        take_print_lose      : in std_logic;
        take_data_ready      : in std_logic;
        take_parallel_reg    : in std_logic_vector(7 downto 0);
        take_echo_enable     : in std_logic;
        take_reset_buffer    : in std_logic;

        --datapath outputs:
        print_to_terminal     : out std_logic_vector(7 downto 0);
        out_guess_check_done     : out std_logic;
        out_win                  : out std_logic := '0';
        out_done_printing        : out std_logic := '0';
        out_tx_start             : out std_logic := '0';
        out_printed_win_result   : out std_logic := '0';
        out_printed_lose_result  : out std_logic := '0';
        out_max_guesses_reached    : out std_logic := '0'

    );
end wordle_datapath;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of wordle_datapath is
    --=============================================================================
    --Signal Declarations: 
    --=============================================================================
    signal guess_1 : std_logic_vector(7 downto 0);
    signal guess_2 : std_logic_vector(7 downto 0);
    signal guess_3 : std_logic_vector(7 downto 0);
    signal guess_4 : std_logic_vector(7 downto 0);
    signal guess_5 : std_logic_vector(7 downto 0);

    signal result_port_1 : std_logic_vector(7 downto 0);
    signal result_port_2 : std_logic_vector(7 downto 0);
    signal result_port_3 : std_logic_vector(7 downto 0);
    signal result_port_4 : std_logic_vector(7 downto 0);
    signal result_port_5 : std_logic_vector(7 downto 0);
    
    constant target_1 : std_logic_vector(7 downto 0) := x"48"; -- 'H'
    constant target_2 : std_logic_vector(7 downto 0) := x"45"; -- 'E'
    constant target_3 : std_logic_vector(7 downto 0) := x"4C"; -- 'L'
    constant target_4 : std_logic_vector(7 downto 0) := x"4C"; -- 'L'
    constant target_5 : std_logic_vector(7 downto 0) := x"4F"; -- 'O'
    
    signal r1 : std_logic_vector(1 downto 0);
    signal r2 : std_logic_vector(1 downto 0);
    signal r3 : std_logic_vector(1 downto 0);
    signal r4 : std_logic_vector(1 downto 0);
    signal r5 : std_logic_vector(1 downto 0);
    
    signal used_letters : std_logic_vector(4 downto 0);

    signal send_result_to_terminal : std_logic := '0';

    signal counter : integer range 0 to 9:= 0;

    signal counter_flag0 : std_logic := '0';
    signal counter_flag1 : std_logic := '0';
    signal counter_flag2 : std_logic := '0';
    signal counter_flag3 : std_logic := '0';
    signal counter_flag4 : std_logic := '0';
    signal counter_flag5 : std_logic := '0';
    signal counter_flag6 : std_logic := '0';
    signal counter_flag7 : std_logic := '0';
    signal counter_flag8 : std_logic := '0';
    signal counter_flag9 : std_logic := '0';

    signal send_active : std_logic := '0';
    signal wait_one_cycle : std_logic := '0';
    signal print : std_logic := '0';

    signal guess_count : integer range 0 to 5 := 0;

    --=============================================================================
    --Processes: 
    --=============================================================================

begin

    process(clk_port)
        variable result_1, result_2, result_3, result_4, result_5: std_logic_vector(1 downto 0);
        variable used: std_logic_vector(4 downto 0);
    begin
        if rising_edge(clk_port) then

            ----------------------------------------LOAD STATE----------------------------------------
            -- Load new guess
            if load_guess_port = '1' then
                guess_1 <= guess_port_1;
                guess_2 <= guess_port_2;
                guess_3 <= guess_port_3;
                guess_4 <= guess_port_4;
                guess_5 <= guess_port_5;
            end if;
            
            ----------------------------------------CHECK STATE----------------------------------------
            -- WORDLE Algorithm
            -- Check for correct letters in correct positions
            if check_guess_port = '1' then

                --Default all results to "00"
                result_1 := "00";
                result_2 := "00";
                result_3 := "00";
                result_4 := "00";
                result_5 := "00";
                -- check for exact matches
                -- Used is for making sure we dont double count correct letters
                -- When a letter may be correct but in wrong postion
                -- This is essentially the first check of algorithm
                used := "00000";
                if guess_1 = target_1 then
                    result_1 := "11";
                    used(0) := '1';
                else
                    result_1 := "00";
                end if;
                
                if guess_2 = target_2 then
                    result_2 := "11";
                    used(1) := '1';
                else
                    result_2 := "00";
                end if;
                
                if guess_3 = target_3 then
                    result_3 := "11";
                    used(2) := '1';
                else
                    result_3 := "00";
                end if;
                
                if guess_4 = target_4 then
                    result_4 := "11";
                    used(3) := '1';
                else
                    result_4 := "00";
                end if;
                
                if guess_5 = target_5 then
                    result_5 := "11";
                    used(4) := '1';
                else
                    result_5 := "00";
                end if;

                -- Second Check
                -- check for letters in wrong positions (if not already correct)
                if result_1 = "00" then
                    if (guess_1 = target_2 and used(1) = '0') then
                        result_1 := "01";
                        used(1) := '1';
                    elsif (guess_1 = target_3 and used(2) = '0') then
                        result_1 := "01";
                        used(2) := '1';
                    elsif (guess_1 = target_4 and used(3) = '0') then
                        result_1 := "01";
                        used(3) := '1';
                    elsif (guess_1 = target_5 and used(4) = '0') then
                        result_1 := "01";
                        used(4) := '1';
                    end if;
                end if;

                if result_2 = "00" then
                    if (guess_2 = target_1 and used(0) = '0') then
                        result_2 := "01";
                        used(0) := '1';
                    elsif (guess_2 = target_3 and used(2) = '0') then
                        result_2 := "01";
                        used(2) := '1';
                    elsif (guess_2 = target_4 and used(3) = '0') then
                        result_2 := "01";
                        used(3) := '1';
                    elsif (guess_2 = target_5 and used(4) = '0') then
                        result_2 := "01";
                        used(4) := '1';
                    end if;
                end if;

                if result_3 = "00" then
                    if (guess_3 = target_1 and used(0) = '0') then
                        result_3 := "01";
                        used(0) := '1';
                    elsif (guess_3 = target_2 and used(1) = '0') then
                        result_3 := "01";
                        used(1) := '1';
                    elsif (guess_3 = target_4 and used(3) = '0') then
                        result_3 := "01";
                        used(3) := '1';
                    elsif (guess_3 = target_5 and used(4) = '0') then
                        result_3 := "01";
                        used(4) := '1';
                    end if;
                end if;

                if result_4 = "00" then
                    if (guess_4 = target_1 and used(0) = '0') then
                        result_4 := "01";
                        used(0) := '1';
                    elsif (guess_4 = target_2 and used(1) = '0') then
                        result_4 := "01";
                        used(1) := '1';
                    elsif (guess_4 = target_3 and used(2) = '0') then
                        result_4 := "01";
                        used(2) := '1';
                    elsif (guess_4 = target_5 and used(4) = '0') then
                        result_4 := "01";
                        used(4) := '1';
                    end if;
                end if;

                if result_5 = "00" then
                    if (guess_5 = target_1 and used(0) = '0') then
                        result_5 := "01";
                        used(0) := '1';
                    elsif (guess_5 = target_2 and used(1) = '0') then
                        result_5 := "01";
                        used(1) := '1';
                    elsif (guess_5 = target_3 and used(2) = '0') then
                        result_5 := "01";
                        used(2) := '1';
                    elsif (guess_5 = target_4 and used(3) = '0') then
                        result_5 := "01";
                        used(3) := '1';
                    end if;
                end if;
                --Assignment
                r1 <= result_1;
                r2 <= result_2;
                r3 <= result_3;
                r4 <= result_4;
                r5 <= result_5;
                -- Indicate that the guess check is done
                -- Signal Data Path to move to next state
                out_guess_check_done <= '1';
            else
                --Default signal low
                out_guess_check_done <= '0';
            end if;
        end if;
    end process;

with r1 select result_port_1 <= x"58" when "00", x"7E" when "01", x"21" when "11", x"3F" when others;
with r2 select result_port_2 <= x"58" when "00", x"7E" when "01", x"21" when "11", x"3F" when others;
with r3 select result_port_3 <= x"58" when "00", x"7E" when "01", x"21" when "11", x"3F" when others;
with r4 select result_port_4 <= x"58" when "00", x"7E" when "01", x"21" when "11", x"3F" when others;
with r5 select result_port_5 <= x"58" when "00", x"7E" when "01", x"21" when "11", x"3F" when others;
    


printing: process(clk_port)
    begin
        if rising_edge(clk_port) then

            out_tx_start <= '0';
            out_done_printing <= '0'; -- default
            out_printed_win_result <= '0'; -- default
            out_printed_lose_result <= '0'; -- default
            ----------------------------------------IDLE STATE----------------------------------------
            -- Echo logic
            if take_data_ready = '1' and take_tx_busy = '0' AND take_echo_enable = '1' then
                if (take_parallel_reg /= x"0D" and take_parallel_reg /= x"0A") then
                    print_to_terminal <= take_parallel_reg;
                    out_tx_start <= '1';
                end if;
            end if;
            
            ----------------------------------------RESULT STATE----------------------------------------
            --Check If Won 
            if check_result_port = '1' then
                out_tx_start <= '0';
                --If the the result_ports all have ! marking correct answers then player won set
                --win signal high
                if result_port_1 = x"21" AND result_port_2 = x"21" AND result_port_3 = x"21" AND result_port_4 = x"21" AND result_port_5 = x"21" then
                    out_win <= '1';
                --Print the results of the wordle algorithm showing !, ~, or X 
                -- ! means correct letter correct place
                -- ~ means correct letter incorrect place
                -- X means incorrect letter, incorrect place
                else if guess_count = 4 then
                    out_win <= '0';
                    out_max_guesses_reached <= '1';
                    
                else    
                        out_win <= '0';
                        out_tx_start <= '0';

                        --Delay to allow tx_busy to set
                        if send_active = '0' then
                            send_active <= '1';
                            counter <= 0;
                            wait_one_cycle <= '1';
                        end if;
                        
                        --Delay to allow tx_busy to set
                        if send_active = '1' and check_result_port = '1' then
                            if wait_one_cycle = '1' then
                                if take_tx_busy = '0' then
                                    wait_one_cycle <= '0';
                                end if;
                        else
                            if take_tx_busy = '0' then
                                if counter = 0 then
                                    counter_flag0 <= '1';
                                    print_to_terminal <= x"0D"; -- Carriage return
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 1;
                                elsif counter = 1 then
                                    counter_flag0 <= '0';
                                    counter_flag1 <= '1';
                                    print_to_terminal <= x"0A"; -- Line feed
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 2;
                                elsif counter = 2 then
                                    counter_flag1 <= '0';
                                    counter_flag2 <= '1';
                                    print_to_terminal <= result_port_1;
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 3;
                                elsif counter = 3 then
                                    counter_flag2 <= '0';
                                    counter_flag3 <= '1';
                                    print_to_terminal <= result_port_2;
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 4;
                                elsif counter = 4 then
                                    counter_flag3 <= '0';
                                    counter_flag4 <= '1';
                                    print_to_terminal <= result_port_3;
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 5;
                                elsif counter = 5 then
                                    counter_flag4 <= '0';
                                    counter_flag5 <= '1';
                                    print_to_terminal <= result_port_4;
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 6;
                                elsif counter = 6 then
                                    counter_flag5 <= '0';
                                    counter_flag6 <= '1';
                                    print_to_terminal <= result_port_5;
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 7;
                                elsif counter = 7 then
                                    counter_flag6 <= '0';
                                    counter_flag7 <= '1';
                                    print_to_terminal <= x"0D"; -- Carriage return
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 8;
                                elsif counter = 8 then
                                    counter_flag7 <= '0';
                                    counter_flag8 <= '1';
                                    print_to_terminal <= x"0A"; -- Line feed
                                    out_tx_start <= '1';
                                    wait_one_cycle <= '1';
                                    counter <= 9;
                                elsif counter = 9 then
                                    counter_flag8 <= '0';
                                    counter_flag9 <= '1';
                                    out_done_printing <= '1';
                                    wait_one_cycle <= '1';
                                    send_active <= '0';
                                    guess_count <= guess_count + 1;
                                    counter <= 0;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;


            ----------------------------------------WIN STATE----------------------------------------
            -- Print win result, Signal came from data path in Win State
            if take_print_win = '1' then
                out_tx_start <= '0';
                out_printed_win_result <= '0'; -- default

                --Delay to allow tx_busy to set
                if take_print_win = '1' then
                    out_tx_start <= '0';
                    if send_active = '0' then
                        send_active <= '1';
                        counter <= 0;
                        wait_one_cycle <= '1';
                    end if;
                end if;
            
                --Delay to allow tx_busy to set
                if send_active = '1' and take_print_win = '1' then
                    if wait_one_cycle = '1' then
                        if take_tx_busy = '0' then
                            wait_one_cycle <= '0';
                        end if;
                    else
                        if take_tx_busy = '0' then
                            if counter = 0 then
                                counter_flag0 <= '1';
                                print_to_terminal <= x"0D"; -- Carriage return
                                out_tx_start <= '1';
                                counter <= 1;
                                wait_one_cycle <= '1';
                            elsif counter = 1 then
                                counter_flag0 <= '0';
                                counter_flag1 <= '1';
                                print_to_terminal <= x"0A"; -- Line feed
                                out_tx_start <= '1';
                                counter <= 2;
                                wait_one_cycle <= '1';
                            elsif counter = 2 then
                                counter_flag1 <= '0';
                                counter_flag2 <= '1';
                                print_to_terminal <= x"57"; -- 'W'
                                out_tx_start <= '1';
                                counter <= 3;
                                wait_one_cycle <= '1';
                            elsif counter = 3 then
                                counter_flag2 <= '0';
                                counter_flag3 <= '1';
                                print_to_terminal <= x"49"; -- 'I'
                                out_tx_start <= '1';
                                counter <= 4;
                                wait_one_cycle <= '1';
                            elsif counter = 4 then
                                counter_flag3 <= '0';
                                counter_flag4 <= '1';
                                print_to_terminal <= x"4E"; -- 'N'
                                out_tx_start <= '1';
                                counter <= 5;
                                wait_one_cycle <= '1';
                            elsif counter = 5 then
                                counter_flag4 <= '0';
                                counter_flag5 <= '1';
                                print_to_terminal <= x"21";
                                out_tx_start <= '1';
                                counter <= 6;
                                wait_one_cycle <= '1';
                            elsif counter = 6 then
                                counter_flag5 <= '0';
                                counter_flag6 <= '1';
                                print_to_terminal <= x"21";
                                out_tx_start <= '1';
                                counter <= 7;
                                wait_one_cycle <= '1';
                            elsif counter = 7 then
                                counter_flag6 <= '0';
                                counter_flag7 <= '1';
                                print_to_terminal <= x"0D"; -- Carriage return
                                out_tx_start <= '1';
                                counter <= 8;
                                wait_one_cycle <= '1';
                            elsif counter = 8 then
                                counter_flag7 <= '0';
                                counter_flag8 <= '1';
                                print_to_terminal <= x"0A"; -- Line feed
                                out_tx_start <= '1';
                                counter <= 9;
                                wait_one_cycle <= '1';
                            elsif counter = 9 then
                                counter_flag8 <= '0';
                                counter_flag9 <= '1';
                                out_printed_win_result <= '1';
                                send_active <= '0';
                                counter <= 0;
                                wait_one_cycle <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;

            ----------------------------------------LOSE STATE----------------------------------------
            -- Print lose result, Signal came from data path in Lose State
            if take_print_lose = '1' then
                out_tx_start <= '0';
                out_printed_lose_result <= '0'; -- default

                --Delay to allow tx_busy to set
                if take_print_lose = '1' then
                    out_tx_start <= '0';
                    if send_active = '0' then
                        send_active <= '1';
                        counter <= 0;
                        wait_one_cycle <= '1';
                    end if;
                end if;

                --Delay to allow tx_busy to set
                if send_active = '1' and take_print_lose = '1' then
                    if wait_one_cycle = '1' then
                        if take_tx_busy = '0' then
                            wait_one_cycle <= '0';
                        end if;
                    else
                        if take_tx_busy = '0' then
                            if counter = 0 then
                                counter_flag0 <= '1';
                                print_to_terminal <= x"0D"; -- Carriage return
                                out_tx_start <= '1';
                                counter <= 1;
                                wait_one_cycle <= '1';
                            elsif counter = 1 then
                                counter_flag0 <= '0';
                                counter_flag1 <= '1';
                                print_to_terminal <= x"0A"; -- Line feed
                                out_tx_start <= '1';
                                counter <= 2;
                                wait_one_cycle <= '1';
                            elsif counter = 2 then
                                counter_flag1 <= '0';
                                counter_flag2 <= '1';
                                print_to_terminal <= x"4C"; -- 'L'
                                out_tx_start <= '1';
                                counter <= 3;
                                wait_one_cycle <= '1';
                            elsif counter = 3 then
                                counter_flag2 <= '0';
                                counter_flag3 <= '1';
                                print_to_terminal <= x"4F"; -- 'O'
                                out_tx_start <= '1';
                                counter <= 4;
                                wait_one_cycle <= '1';
                            elsif counter = 4 then
                                counter_flag3 <= '0';
                                counter_flag4 <= '1';
                                print_to_terminal <= x"53"; -- 'S'
                                out_tx_start <= '1';
                                counter <= 5;
                                wait_one_cycle <= '1';
                            elsif counter = 5 then
                                counter_flag4 <= '0';
                                counter_flag5 <= '1';
                                print_to_terminal <= x"45"; -- 'E'
                                out_tx_start <= '1';
                                counter <= 6;
                                wait_one_cycle <= '1';
                            elsif counter = 6 then
                                counter_flag5 <= '0';
                                counter_flag6 <= '1';
                                print_to_terminal <= x"52"; -- 'R'
                                out_tx_start <= '1';
                                counter <= 7;
                                wait_one_cycle <= '1';
                            elsif counter = 7 then
                                counter_flag6 <= '0';
                                counter_flag7 <= '1';
                                print_to_terminal <= x"0D"; -- Carriage return
                                out_tx_start <= '1';
                                counter <= 8;
                                wait_one_cycle <= '1';
                            elsif counter = 8 then
                                counter_flag7 <= '0';
                                counter_flag8 <= '1';
                                print_to_terminal <= x"0A"; -- Line feed
                                out_tx_start <= '1';
                                counter <= 9;
                                wait_one_cycle <= '1';
                            elsif counter = 9 then
                                counter_flag8 <= '0';
                                counter_flag9 <= '1';
                                out_printed_lose_result <= '1';
                                send_active <= '0';
                                counter <= 0;
                                wait_one_cycle <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process printing;

end behavioral_architecture;