library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


entity tb_KittCar_entity is
--  Port ( );
end tb_KittCar_entity;

architecture Behavioral of tb_KittCar_entity is


    component ShiftPWM is
        Generic(
            NUM_OF_LEDS		:	INTEGER	RANGE   1 TO 16;
            TAIL_LENGTH		:	INTEGER	RANGE	1 TO 16  
        );
        Port ( 
            ---------- Reset/Clock ----------
            reset   :   IN  STD_LOGIC;
            clk     :   IN  STD_LOGIC;
            ------------- Data --------------
            led_out  :   OUT   STD_LOGIC_VECTOR(0 to NUM_OF_LEDS-1)
        );
    end component;

    constant BOARD_CLK : time := 10 ns;
    constant RESET_WND : time := 100 ns;

    constant TAIL_LENGTH : INTEGER := 4;
    constant NUM_OF_LEDS : INTEGER := 16;
    
    signal reset                :   STD_LOGIC := '0';
    signal clk                  :   STD_LOGIC := '1';
    signal led_out               :   STD_LOGIC_VECTOR(0 to NUM_OF_LEDS-1);

    

begin

    shiftPWM_isnt : ShiftPWM
    Generic map(
            NUM_OF_LEDS	=> NUM_OF_LEDS,
            TAIL_LENGTH	=> TAIL_LENGTH 
        )
        Port map ( 
            ---------- Reset/Clock ----------
            reset  => reset,
            clk  => clk, 
            ------------- Data --------------
            led_out => led_out
        );
        
    ----------clk generation------------

    clk <= not clk after BOARD_CLK/2;

    --------------------------------------

    -- TB Reset Generation
    reset_wave : process
    begin
    
        reset <= '1';
        wait for RESET_WND;
        
        reset <= '0';
        wait;
        
    end process;

    dut_shiftPWM : process 
        
        begin

    end process;


end Behavioral;