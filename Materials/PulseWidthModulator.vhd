---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.MATH_REAL.all;
------------------------------------

entity PulseWidthModulator is
	Generic(

		BIT_LENGTH	  :	INTEGER	RANGE 1 TO 16 := 8;			-- Bit used  inside PWM

		T_ON_INIT	  :	POSITIVE			  := 64;		-- Init of Ton
		PERIOD_INIT   :	POSITIVE	          := 128;		-- Init of Period

		PWM_INIT	  :	STD_LOGIC             := '1';		-- Init of PWM 

	-------Parameters for PWM COUNTER_MAX setting------
		PERIOD_VALUE  : POSITIVE   			  := 3				      			
	---------------------------------------------------
			
	);

	Port (

		------- Reset/Clock --------
		reset	:	IN	STD_LOGIC;
		clk		:	IN	STD_LOGIC;
		----------------------------

		-------- Duty Cycle ----------
		Ton		:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk at PWM = '1'
		Period	:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk per period of PWM

		PWM		:	OUT	STD_LOGIC									-- PWM signal
		----------------------------

	);
end PulseWidthModulator;

architecture Behavioral of PulseWidthModulator is

	------------------ CONSTANT DECLARATION -------------------------

	---------- INIT ------------
	constant	T_ON_INIT_UNS	:	UNSIGNED(BIT_LENGTH-1 downto 0)	:= to_unsigned(T_ON_INIT-1, BIT_LENGTH);
	constant	PERIOD_INIT_UNS	:	UNSIGNED(BIT_LENGTH-1 downto 0) := to_unsigned(PERIOD_INIT -1, BIT_LENGTH);
	----------------------------


	---------------------CLOCK SLOW DOWN-----------------------------
	
	--value 10k works for any clock_value between the given range
	constant counter_2_max  : INTEGER := 10000/PERIOD_VALUE;
	
	---------------------------- SIGNALS ----------------------------

	------ Sync Process --------
	signal	Ton_reg		    :	UNSIGNED(BIT_LENGTH-1 downto 0)	:= T_ON_INIT_UNS;
	signal	Period_reg	    :	UNSIGNED(BIT_LENGTH-1 downto 0)	:= PERIOD_INIT_UNS;

	signal	count		    :	UNSIGNED(BIT_LENGTH-1 downto 0)	:= (Others => '0');
	signal	counter_2	    :	UNSIGNED(BIT_LENGTH-1 downto 0)	:= (Others => '0');

	signal	pwm_reg		    :	STD_LOGIC						:= PWM_INIT;

	----------------------------

	----------------------------------------------------------------

begin

	----------------------------- DATA FLOW ---------------------------
	PWM	<= pwm_reg;
	-------------------------------------------------------------------

	----------------------------- PROCESS ------------------------------

	------ Sync Process --------
	process(reset, clk)

	begin

		-- Reset
		if reset = '1' then

			Ton_reg		<= T_ON_INIT_UNS;
			Period_reg	<= PERIOD_INIT_UNS;

			count		<= (Others => '0');
			pwm_reg		<= PWM_INIT;

		elsif rising_edge(clk) then

			if counter_2 = to_unsigned(counter_2_max, counter_2'length) then -- tail_length = bit_length check
			
				counter_2 <= (others => '0') ;
					
				-- Count the clock pulses
				count	<= count + 1;

				-- Define the period (Period +1 clk pulses)
				if count = unsigned(Period_reg) then

					-- Reset count
					count		<= (Others => '0');

					-- Toggle the output (set on)
					pwm_reg	    <= PWM_INIT;

					-- Sample Period and Ton to guarantee glitch-less behavior inside a period and on rising_edge(clk)
					Period_reg	<=	unsigned(Period);
					Ton_reg		<=	unsigned(Ton);

				end if;

				-- Define the duty cycle (Ton clk pulses), (* required if Ton = 2**BIT_LENGTH -1)
				if count = Ton_reg-1 then

					-- Toggle the output
					pwm_reg	<= not PWM_INIT;

				end if;

				-- If duty cycle = 0
				if Ton_reg = 0 then
					pwm_reg	<= not PWM_INIT;
				end if;

				-- if duty cycle = 1
				if Ton_reg > Period_reg then
					pwm_reg	<= PWM_INIT;
				end if;

			else 
				counter_2 <= counter_2 +1;
			end if;

		end if;

	end process;

end Behavioral;
