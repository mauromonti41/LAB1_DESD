library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.math_real.all;

entity ShiftPWM is
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
end ShiftPWM;

architecture Behavioral of ShiftPWM is

    component PWM is
        Generic(

		BIT_LENGTH	:	INTEGER;		        -- Bit used  inside PWM

		T_ON_INIT	:	POSITIVE;		        -- Init of Ton
		PERIOD_INIT	:	POSITIVE;		        -- Init of Periof

		PWM_INIT	:	STD_LOGIC   			-- Init of PWM     --e' un pwm al contrario???
	);
        Port(
            reset	:	IN	STD_LOGIC;
            clk		:	IN	STD_LOGIC;
            -------- Duty Cycle ----------
            Ton		:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk at PWM = '1'
            Period	:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk per period of PWM
    
            PWM		:	OUT	STD_LOGIC		-- PWM signal
            );
    end component;

    ----------------------- Constants Declaration -------------------------
    
    ----- Initialization in SLV ----
    constant SR_WIDTH : integer := integer(log2(real(TAIL_LENGTH)));
    
    -------------------------- Types Declaration --------------------------
    
    ------------ Memory  ------------
    type    MEM_ARRAY_TYPE_1  is  array(0 TO NUM_OF_LEDS-1) of std_logic_vector(SR_WIDTH-1 downto 0);
    type    MEM_ARRAY_TYPE_2  is  array(1 TO NUM_OF_LEDS-2) of std_logic_vector(SR_WIDTH-1 downto 0);
    ---------------------------------

    ------------------------- Signal Declaration -------------------------
    
    ------------ Memory  ------------
    signal  mem_1   :   MEM_ARRAY_TYPE_1 := (Others  =>(others => '0'));
    signal  mem_2   :   MEM_ARRAY_TYPE_2 := (Others  =>(others => '0'));
    signal  mem_fin :   MEM_ARRAY_TYPE_1 := (Others  =>(others => '0'));
    
    ---------------------------------    
   --- signal counter : unsigned( DOWNTO 0) := ((others => '0'));     IMPORTANTE : rivedi quanto è grande perchè dipende dalla tail e dopo cambia l'hard coding dell'inizializzazione
    ----------------------------------------------------------------------


begin

    inst_pwm: for I in 0 to NUM_OF_LEDS-1 generate
        
        pwm_inst_I: PWM
        -- generic map (
        --     --BIT_LENGTH <= ???;		        -- Bit used  inside PWM

        --     -- Init of PWM     --e' un pwm al contrario???
        -- );
        port map (
            reset => reset,
            clk => clk,

            Ton => mem_fin(I),
            --Period => ???,

            PWM => led_out (I)
        );

   end generate;

    shift_reg  :  process(reset, clk)
    begin
    
        if (reset = '1') then

            mem_fin <= (Others => INIT_SLV);
            mem_fin(0) <= "100";  
            mem_1 <= (Others => INIT_SLV);
            mem_2 <= (Others => INIT_SLV);
            counter <= "00";
            
            elsif rising_edge(clk) then
            
                if counter = "00" then
                    mem_fin(1) <= "100";
                    mem_fin(0) <= "011";
                    counter <= counter + 1;
                elsif counter = "01" then
                    mem_fin(2) <= "100";
                    mem_fin(1) <= "011";
                    mem_fin(0) <= "010";
                    counter <= counter + 1;
                elsif counter = "02" then
                    mem_fin(3) <= "100";
                    mem_fin(2) <= "011";
                    mem_fin(1) <= "010";
                    mem_fin(0) <= "001";
                    counter <= counter + 1;
                else

                mem_1  <=  mem_2(1) & mem(0 TO NUM_OF_LEDS-2);
                mem_2  <=  mem_2(2 TO NUM_OF_LEDS-2) & mem_1(NUM_OF_LEDS-1);

                for I in 0 to NUM_OF_LEDS-1 loop
                    if I=0 or I=1 or I=2 or I=NUM_OF_LEDS-1 or I=NUM_OF_LEDS-2 or I=NUM_OF_LEDS-3  then                    
                    if mem_1(I) > mem_2(I) then
                            mem_fin(I) <= mem_1(I);
                    else
                            mem_fin(I) <= mem_2(I);
                    else
                        mem_fin <= mem_1(I) or mem_2(I);

                    end if;
            end loop;
       end if;
    
    end process;

end Behavioral;
