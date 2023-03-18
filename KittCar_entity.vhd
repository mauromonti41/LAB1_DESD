---------- DEFAULT LIBRARY ---------
library IEEE;
	use IEEE.STD_LOGIC_1164.all;
	use IEEE.NUMERIC_STD.ALL;
	use IEEE.math_real.all;
------------------------------------

entity KittCar is
	Generic (

		CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100     := 10;	-- clk period in nanoseconds
		MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

		NUM_OF_SWS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of input switches
		NUM_OF_LEDS		:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of output LEDs


		NUM_OF_BITS     :	INTEGER RANGE 	1 TO 16 := 1    -- we created it to define the width of shif registers 
	);
	Port (

		------- Reset/Clock --------
		reset	:	IN	STD_LOGIC;
		clk		:	IN	STD_LOGIC;
		----------------------------

		-------- LEDs/SWs ----------
		sw		:	IN	STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);	-- Switches avaiable on Basys3
		leds	:	OUT	STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0)	-- LEDs avaiable on Basys3
		----------------------------

	);
end KittCar;

architecture Behavioral of KittCar is

signal My_clock : std_logic;
signal vect_slv_1 : std_logic_vector(NUM_OF_LEDS-1 downto o); --vector which feeds the leds 
signal vect_slv_2 : std_logic_vector(NUM_OF_BITS-3 downto o); --vectore which feeds the leds 

	component clock is
	port(
		reset : in std_logic;
		clk : in std_logic;

		input_sw : in std_logic_vector(NUM_OF_SWS-1 downto 0);
		clock_out : out std_logic
	);
	end component;

	component ShiftRegisterSIPOv2 is
		Port(
			reset	: in std_logic;
			clk		: in std_logic;
	
			data_in		: in std_logic;
			
			data_out	: out std_logic_vector (SR_WIDTH-1 downto 0)
		);
	end component;

begin

	clock_inst : clock
	generic map (
		CLK_PERIOD_NS => CLK_PERIOD_NS 					-- Share the generic parameter with the top-level entity
		MIN_KITT_CAR_STEP_MS => MIN_KITT_CAR_STEP_MS
	)
	port map(
		reset => reset,
		clk => clk,
		input_sw => input_sw,
		clock_out => My_clock
	);

	shift_register_sipo_1 : ShiftRegisterSIPOv2
	generic map(
		SR_WIDTH => NUM_OF_LEDS   
        SR_DEPTH => NUM_OF_BITS --now we don't need it because the sipo has SR-DEPTH words of 1 bit   
        SR_INIT => 1     
	)
	port map(
		reset => reset,
		clk	 => My_clock
		data_in	=> vect_slv_2(SR_WIDTH-3)
		data_out =>vect_slv_1
	),
		
	shift_register_sipo_2 : ShiftRegisterSIPOv2
	generic map(
		SR_WIDTH => NUM_OF_LEDS-2   
        SR_DEPTH => NUM_OF_BITS --now we don't need it because the sipo has SR-DEPTH words of 1 bit   
        SR_INIT => 1 
	)
	port map(
		reset => reset,
		clk	 => My_clock
		data_in	=> vect_slv_1(SR_WIDTH-1)
		data_out =>vect_slv_2
	),

end Behavioral;


