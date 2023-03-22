library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


entity tb_clock is
--  Port ( );
end tb_clock;

architecture Behavioral of tb_clock is
 
    constant BOARD_CLK : time := 10 ns;
    constant RESET_WND : time := 100 ns;
    constant CLK_PERIOD_NS : POSITIVE := 10;
    constant MIN_KITT_CAR_STEP_MS : POSITIVE := 1;
    constant NUM_OF_SWS : INTEGER := 16;

    component Clock is
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
    end component;
 
    
    signal  reset                :   STD_LOGIC := '0';
    signal  clk                  :   STD_LOGIC := '1';
    signal  input_sw          	 :   STD_LOGIC_VECTOR(NUM_OF_SWS-1 downto 0) :=(others => '0');-- input received from the board
    signal  clock_out            :   std_logic;

begin

    clock_inst : clock
        generic map (
            CLK_PERIOD_NS => CLK_PERIOD_NS,
            MIN_KITT_CAR_STEP_MS => MIN_KITT_CAR_STEP_MS,
            NUM_OF_SWS => NUM_OF_SWS
        )
        port map (
            reset => reset,
            clk => clk,
            input_sw => input_sw,
            clock_out => clock_out
        );
        
    ---------- Clk generation ------------

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


end Behavioral;
