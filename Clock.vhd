library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity Clock is
    generic(
        CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100 := 10;	-- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000 := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)
        
        NUM_OF_SWS		        :	INTEGER	    RANGE	1 TO 16 := 16	-- Number of input switches  
    );
        Port (
            reset                : in std_logic;
            clk                  : in std_logic;

            input_sw          	 : in  STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);-- input received from the board
            clock_out            : out std_logic 
        );
end Clock;

architecture Behavioral of Clock is

    --division is done in pre-processing, doesn't affect board usage
    constant counter_max : integer := (MIN_KITT_CAR_STEP_MS*1000000 / CLK_PERIOD_NS); --auxiliary constant, could be avoided
    constant counter_max_half : integer := counter_max/2;
    constant counter_bits : integer := integer(log2(real(counter_max_half)))+ 1;
      
    signal counter : unsigned(counter_bits-1 DOWNTO 0) := (others => '0') ;
    signal counter_effective : unsigned(NUM_OF_SWS-1 DOWNTO 0) := (others => '0');
   -- signal clock_aux : std_logic := '0'; -- auxiliary clock signal
    signal clock_out_signal : std_logic := '0'; --output clock signal'
    
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

                if to_integer(counter_effective) = to_integer(unsigned(input_sw)) then
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



    -- inside_clock : process(clk,reset)
    
    -- begin
    
    --     if reset = '1' then
    --          counter  <= to_unsigned(0, counter'LENGTH);
    --          --dobbiamo resettare anche gli altri signal?
                  
    --     elsif rising_edge(clk) then
            
    --         if counter = counter_effective then
    --             clock_aux <= not clock_aux;
    --             counter <= (others => '0');

    --         else 
    --         counter  <= counter + 1;
    --         end if;

    --     end if;
    
    -- end process;

    -- out_clock: process(clock_aux)

    -- begin
        
    --     if counter_effective =  unsigned(input_sw) then
    --         clock_out <= not clock_out;
    --         counter_effective <= (others => '0');

    --     else 
    --         counter_effective <= counter_effective + 1;
    --     end if;

    -- end process;

    -- clock_out <= clock_out_signal;

end Behavioral;
