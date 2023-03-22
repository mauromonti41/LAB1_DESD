library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


entity tb_KittCar_entity is
--  Port ( );
end tb_KittCar_entity;

architecture Behavioral of tb_KittCar_entity is

    -------- Constants to simulare clk and reset-----
    constant BOARD_CLK : time := 10 ns;
    constant RESET_WND : time := 100 ns;
    -------------------------------------------------

    ----- Constants to use in generics -----
    constant CLK_PERIOD_NS : POSITIVE := 10; 
    constant MIN_KITT_CAR_STEP_MS : POSITIVE:= 1;
    constant NUM_OF_SWS : INTEGER := 16;
    constant NUM_OF_LEDS : INTEGER := 16;
    constant TAIL_LENGTH : INTEGER := 4;
    -------------------------------------------------

    component KittCar_entity is
        Generic (

            CLK_PERIOD_NS			:	POSITIVE	RANGE	1	TO	100     := 10;	-- clk period in nanoseconds
            MIN_KITT_CAR_STEP_MS	:	POSITIVE	RANGE	1	TO	2000    := 1;	-- Minimum step period in milliseconds (i.e., value in milliseconds of Delta_t)

            NUM_OF_SWS				:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of input switches
            NUM_OF_LEDS				:	INTEGER	RANGE	1 TO 16 := 16;	-- Number of output LEDs

            TAIL_LENGTH				:	INTEGER	RANGE	1 TO 16	:= 4	-- Tail length
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
    end component;
    
    -------- Signals for inputs and output of Kittcar_entity -------
    signal reset                 :   STD_LOGIC := '0';
    signal clk                   :   STD_LOGIC := '1';
    signal sw                    :   STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0);
    signal led_out               :   STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0);
    ---------------------------------------------------------------------------

begin

    KittCarPWM_inst : KittCar_entity 
        generic map ( 

            CLK_PERIOD_NS => CLK_PERIOD_NS,	
            MIN_KITT_CAR_STEP_MS => MIN_KITT_CAR_STEP_MS,

            NUM_OF_SWS => NUM_OF_SWS,		
            NUM_OF_LEDS => NUM_OF_LEDS,				
            TAIL_LENGTH => TAIL_LENGTH		
        )
        Port map (

            ------- Reset/Clock --------
            reset => reset,	
            clk => clk,
            ----------------------------

            -------- LEDs/SWs ----------
            sw => sw,
            led => led_out
            ----------------------------

        );
        
    ---------- Clk generation ------------

    clk <= not clk after BOARD_CLK/2;

    --------------------------------------

    --- TB Reset Generation --------------
    reset_wave : process
    begin
    
        reset <= '1';
        wait for RESET_WND;
        
        reset <= '0';
        wait;
        
    end process;
    ---------------------------------------

    ------- Sets switches to minimum value(all switches to 0) ----
    sw <= (others => '0');
    ---------------------------------------

end Behavioral;