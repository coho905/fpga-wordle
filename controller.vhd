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
entity wordle_controller is
    Port (
        --timing:
        clk_port            : in std_logic;
        take_guess_port     : in std_logic;
        take_guess_check_done : in std_logic;
        take_win            : in std_logic;
        take_done_printing  : in std_logic;
        take_print_win      : in std_logic;
        take_print_lose     : in std_logic;
        --control outputs:
        load_guess          : out std_logic;
        check_guess         : out std_logic;
        game_over           : out std_logic;
        check_result        : out std_logic;
        send_result_to_terminal : out std_logic;
        print_win           : out std_logic;
        print_lose          : out std_logic;
        echo_enable         : out std_logic;
        out_reset_buffer    : out std_logic;
        take_max_guesses_reached : in std_logic
        );
end wordle_controller;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of wordle_controller is
    --=============================================================================
    --Signal Declarations: 
    --=============================================================================

    -- fill in your state names
    type state is (IDLE, GUESS, CHECK, RESULT, WIN, LOSE, ENDGAME); --define states
    signal current_state : state := IDLE;
    signal next_state : state := IDLE;
    signal num_guesses : integer := 0;
    --=============================================================================
    --Processes: 
    --=============================================================================
begin
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Update the current state (synchronous):
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    StateUpdate: process(clk_port)
    begin
        if rising_edge(clk_port) then
            current_state <= next_state;
            if current_state = CHECK then
            end if;
        end if;
        -- add spot for reset eventually
    end process StateUpdate;

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Next State Logic (asynchronous):
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NextStateLogic: process(current_state, take_guess_port, num_guesses, take_win, take_guess_check_done, take_done_printing, take_print_win, take_print_lose)
    begin
        next_state <= current_state;
        
        case current_state is

            ----------------IDLE state-------------------
            when IDLE =>
                if take_guess_port = '1' then
                    next_state <= GUESS;
                end if;
             ----------------GUESS state-------------------
            when GUESS =>
                next_state <= CHECK;

             ----------------CHECK state-------------------
            when CHECK =>
                if take_guess_check_done = '1' then
                    next_state <= RESULT;
                end if;
            ----------------RESULT state-------------------
            when RESULT =>
                if take_win = '1' then
                    next_state <= WIN;
                elsif take_max_guesses_reached = '1' then
                    next_state <= LOSE;
                elsif take_done_printing = '1' then
                    next_state <= ENDGAME;
                end if;
             ----------------WIN state-------------------
            when WIN =>
                if take_print_win = '1' then
                    next_state <= ENDGAME;
                end if;
            ----------------LOSE state-------------------
            when LOSE =>
                if take_print_lose = '1' then
                    next_state <= ENDGAME;
                end if;
            ----------------ENDGAME state-------------------
            when ENDGAME =>
                 next_state <= IDLE;
            when others =>
                 next_state <= IDLE;
        end case;
    end process;

    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --Output Logic (asynchronous):
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    OutputLogic: process(current_state)
    begin
        -- Default outputs
        load_guess <= '0';
        check_guess <= '0';
        check_result <= '0';
        print_win <= '0';
        print_lose <= '0';

        case current_state is
            when IDLE =>
                echo_enable <= '1';
                load_guess <= '0';
                check_guess <= '0';
                check_result <= '0';
                print_win <= '0';
                print_lose <= '0';
                out_reset_buffer <= '0';
            when GUESS =>
                echo_enable <= '0';
                load_guess <= '1';
            when CHECK =>
                load_guess <= '0';
                check_guess <= '1';
            when RESULT =>
                check_guess <= '0';
                check_result <= '1';
            when WIN =>
                check_result <= '0';
                print_win <= '1';
            when LOSE =>
                check_result <= '0';
                print_lose <= '1';
            when ENDGAME =>
                out_reset_buffer <= '1';
            when others =>
                load_guess <= '0';
                check_guess <= '0';
                check_result <= '0';
        end case;
    end process;

end behavioral_architecture;