---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.all;
------------------------------------

entity KittCar_entity is
	Generic (

		CLK_PERIOD_NS			:	POSITIVE RANGE	1	TO	100     := 10;	-- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	:	POSITIVE RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

		NUM_OF_SWS				:	INTEGER	 RANGE	1   TO 16       := 16;	-- Number of input switches
		NUM_OF_LEDS				:	INTEGER	 RANGE	1   TO 16       := 16;	-- Number of output LEDs

		TAIL_LENGTH				:	INTEGER	 RANGE	1   TO 16	    := 4	-- Tail length

	);
	Port (

		------- Reset/Clock --------
		reset	:	IN	STD_LOGIC ;
		clk		:	IN	STD_LOGIC;
		----------------------------

		-------- LEDs/SWs ----------
		sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	
		led		:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	
		----------------------------

	);
end KittCar_entity;

architecture Behavioral of KittCar_entity is

	
	signal clock_slow : std_logic := '0';		-- signal used to feed the output of the Clock entity and for the input of the ShiftPWM

	component clock is
		generic(
			CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100  := 10;	-- clk period in nanoseconds
			MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000 := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)
			
			NUM_OF_SWS		        :	INTEGER	    RANGE	1   TO  16   := 16	-- Number of input switches  
		);
		port(
			reset     : in std_logic;
			clk       : in std_logic;
			input_sw  : in std_logic_vector(NUM_OF_SWS-1 downto 0);

			clock_out : out std_logic
		);
	end component;
	
	component ShiftPWM is
		
		Generic(
			NUM_OF_LEDS		  :	INTEGER	RANGE   1 TO 16;
			TAIL_LENGTH		  :	INTEGER	RANGE	1 TO 16

		);
		port(
			reset      : in std_logic;
			clk        : in std_logic;
			clock_slow : in std_logic;

			led_out    : out std_logic_vector(0 to NUM_OF_LEDS-1)
		);
	end component;

begin

	exception_for_one_led: if  NUM_OF_LEDS = 1 generate --check if the num of leds is 1
        led <= (others => '1'); 
	end generate;

	standard_behaviour: if NUM_OF_LEDS /= 1 generate

		clock_inst : clock
			generic map ( 				-- Share the generics parameters with the top-level entity

				CLK_PERIOD_NS => CLK_PERIOD_NS,	
				MIN_KITT_CAR_STEP_MS => MIN_KITT_CAR_STEP_MS,
				NUM_OF_SWS => NUM_OF_SWS
			)
			port map(
				reset => reset,
				clk => clk,
				input_sw => sw, 
				clock_out => clock_slow
			);

		shift_PWM_inst : ShiftPWM
			generic map (
				NUM_OF_LEDS	=> NUM_OF_LEDS,
				TAIL_LENGTH	=> TAIL_LENGTH
			)
			port map(
				reset => reset,
				clk => clk,
				clock_slow => clock_slow,
				led_out => led
			);

	end generate;
			
end Behavioral;