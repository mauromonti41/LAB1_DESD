library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use ieee.numeric_std.all;
    use IEEE.math_real.all;

entity Clock is
    generic(
        CLK_PERIOD_NS			 :	POSITIVE	RANGE	1	TO	100 := 10;	        -- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	 :	POSITIVE	RANGE	1	TO	2000 := 1;	        -- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)
        
        NUM_OF_SWS		         :	INTEGER	    RANGE	1 TO 16 := 16	            -- Number of input switches  
    );
        Port (
            reset                : in std_logic;
            clk                  : in std_logic;

            input_sw          	 : in  STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);     -- input received from the board
            clock_out            : out std_logic 
        );
end Clock;

architecture Behavioral of Clock is

    ------CONSTANTS FOR PREPROCESSING--------
    constant counter_max      : integer := (MIN_KITT_CAR_STEP_MS*1000000 / CLK_PERIOD_NS); -- Number of clock periods for highest frequency
    constant counter_max_half : integer := counter_max/2;                                  -- this is to count half the period
    constant counter_bits     : integer := integer(log2(real(counter_max_half)))+ 1;       -- number of bits needed to count half the period to range the counter's range of the signal defined right below
    -----------------------------------------

    -------SIGNALS AND COUNTERS INIT---------
    signal counter           : unsigned(counter_bits-1 DOWNTO 0) := (others => '0');
    signal counter_effective : unsigned(NUM_OF_SWS-1 DOWNTO 0) := (others => '0');
    signal clock_out_signal  : std_logic := '0'; 
    -----------------------------------------
    
begin
    
    clock_out <= clock_out_signal;
    
    inside_clock : process(clk,reset)
    
    begin
    
        if reset = '1' then
            
            counter  <= (others => '0');
            counter_effective <= (others => '0');
            
            clock_out_signal <= '0';
                  
        elsif rising_edge(clk) then
            
            if counter = to_unsigned(counter_max_half, counter'LENGTH) then
                counter <= (others => '0');

                if to_integer(counter_effective) >= to_integer(unsigned(input_sw)) then
                    counter_effective <= (others => '0');
                    clock_out_signal <= not clock_out_signal;
                else 
                    counter_effective <= counter_effective + 1;
                end if;

            else 
                counter  <= counter + 1;
            end if;

        end if;
    
    end process;

end Behavioral;
