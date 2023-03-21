library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_ShiftPWM is
--  Port ( );
end tb_ShiftPWM;

architecture Behavioral of tb_ShiftPWM is

    component ShiftPWM is
        Generic(
            NUM_OF_LEDS		:	INTEGER	RANGE   1 TO 16;
            TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16  
        );
        Port ( 
            ---------- Reset/Clock ----------
            reset   :   IN  STD_LOGIC;
            clk     :   IN  STD_LOGIC;
            clock_slow : IN STD_LOGIC;
            ------------- Data --------------
            led_out  :   OUT   STD_LOGIC_VECTOR(0 to NUM_OF_LEDS-1)
        );
    end component;


    constant DUT_NUM_OF_LEDS : INTEGER := 16;
    constant DUT_TAIL_LENGHT : INTEGER := 4;
    --constant DUT_NUM_OF_LEDS : INTEGER := 16;


    constant GIVEN_CLK : time := 1 ms;
    constant RESET_WND : time := 5 ms;
    constant CLK_PERIOD : time := 10 ns;
    

    signal reset : STD_LOGIC := '0';
    signal clk : STD_LOGIC := '0';
    signal clk_slow : STD_LOGIC := '0';
    signal led_out_sign : STD_LOGIC_VECTOR(0 to DUT_NUM_OF_LEDS-1) := ((others => '0') );
    
    



begin

    ShiftPWM_inst : ShiftPWM
    generic map (
        NUM_OF_LEDS => DUT_NUM_OF_LEDS,
        TAIL_LENGTH => DUT_TAIL_LENGHT
    )
    port map (
        reset => reset,
        clk => clk,
        clock_slow => clk_slow,

        led_out => led_out_sign
    );
        
    ----------clk generation------------

    clk <= not clk after CLK_PERIOD/2;
    clk_slow <= not clk_slow after GIVEN_CLK/2;

--------------------------------------

 -- TB Reset Generation
 reset_wave : process
 begin
 
     reset <= '1';
     wait for RESET_WND;
     
     reset <= '0';
    wait;
     
 end process;


end Behavioral;
