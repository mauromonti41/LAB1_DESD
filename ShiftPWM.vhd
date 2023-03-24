library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    use IEEE.math_real.all;

entity ShiftPWM is
    Generic(
        NUM_OF_LEDS		  :	INTEGER	RANGE   1 TO 16;
        TAIL_LENGTH		  :	INTEGER	RANGE	1 TO 16

    );
    Port ( 
        ---------- Reset/Clock ----------
        reset      :   IN  STD_LOGIC;
        clk        :   IN  STD_LOGIC;
        clock_slow :   IN  STD_LOGIC; -- slow clock needed to work the PWM at a lower freq in order to use the leds under the cut-frequency
        ------------- Data --------------
        led_out    :   OUT STD_LOGIC_VECTOR (0 to NUM_OF_LEDS-1)
    );
end ShiftPWM;

architecture Behavioral of ShiftPWM is
    
    component PulseWidthModulator is
        Generic(

		BIT_LENGTH	:	INTEGER	RANGE	1 TO 16 := 8;	-- Bit used  inside PWM
		T_ON_INIT	:	POSITIVE	:= 64;				-- Init of Ton
		PERIOD_INIT	:	POSITIVE	:= 128;				-- Init of Period

		PWM_INIT	:	STD_LOGIC:= '1';				-- Init of PWM 

	 -------Parameters for COUNTER_MAX setting------
		PERIOD_VALUE      : POSITIVE := 3			      			
	 -----------------------------------------------	
			
	    );
	    Port (

		------- Reset/Clock --------
		reset	:	IN	STD_LOGIC;
		clk		:	IN	STD_LOGIC;
		----------------------------

		-------- Duty Cycle ----------
		Ton		:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk at PWM = '1'
		Period	:	IN	STD_LOGIC_VECTOR(BIT_LENGTH-1 downto 0);	-- clk per period of PWM

		PWM		:	OUT	STD_LOGIC		-- PWM signal
		----------------------------

	    );
    end component;

    
    ----------------------- Constants Declaration ------------------------
    
    ----- Initialization in SLV ----
    constant SR_WIDTH : integer := integer(ceil(log2(real(TAIL_LENGTH+1))));
    --constant PWM_BIT  : integer := integer(ceil(log2(real(TAIL_LENGTH+1))));
    
    -------------------------- Types Declaration --------------------------
    
    ------------ Memory  ------------
    type    MEM_ARRAY_TYPE_1  is  array(0 TO NUM_OF_LEDS-1) of std_logic_vector(SR_WIDTH-1 downto 0);
    type    MEM_ARRAY_TYPE_2  is  array(1 TO NUM_OF_LEDS-2) of std_logic_vector(SR_WIDTH-1 downto 0);
    
    type    MEM_ARRAY_TYPE_3  is  array(0 TO TAIL_LENGTH-1) of std_logic_vector(SR_WIDTH-1 downto 0);  -- tipo che usiamo per shift register di inizializzazione
    ---------------------------------

    ------------------------- Signal Declaration -------------------------
    
    ------------ Memory  ------------
    signal  mem_1   :               MEM_ARRAY_TYPE_1 := (Others  =>(others => '0'));
    signal  mem_2   :               MEM_ARRAY_TYPE_2 := (Others  =>(others => '0'));
    signal  mem_fin :               MEM_ARRAY_TYPE_1 := (Others  =>(others => '0'));

    signal  mem_ini :               MEM_ARRAY_TYPE_3 := (Others  =>(others => '0'));

    signal clock_count :            UNSIGNED(SR_WIDTH-1 DOWNTO 0) := ((others => '0'));
    signal clock_value_old :        STD_LOGIC := '0';
    
    ---------------------------------    
   --- signal counter : unsigned( DOWNTO 0) := ((others => '0'));     IMPORTANTE : rivedi quanto Ã¨ grande perchÃ¨ dipende dalla tail e dopo cambia l'hard coding dell'inizializzazione
    ----------------------------------------------------------------------


begin

    ini_value : for I in 0 TO TAIL_LENGTH-1 generate
        mem_ini(I) <= std_logic_vector(to_unsigned(TAIL_LENGTH-I, mem_ini(I)'LENGTH));  --initialization of the tail in order to make the leds appear 1 by 1      
    end generate;
            
    inst_pwm: for I in 0 to NUM_OF_LEDS - 1 generate

        pwm_inst_I: PulseWidthModulator
        generic map (
            BIT_LENGTH => SR_WIDTH,	        -- Bit used  inside PWM


--                T_ON_INIT => 0,				-- Init of Ton
--                PERIOD_INIT => 0,			-- Init of Periof
    
            PWM_INIT => '1',		-- Init of PWM     --e' un pwm al contrario???

            PERIOD_VALUE => TAIL_LENGTH-1

        )
        port map (
            reset => reset,
            clk => clk,

            Ton => mem_fin(I),
            Period => std_logic_vector(to_unsigned(TAIL_LENGTH-1, SR_WIDTH)),

            PWM => led_out (I)
        );

   end generate;

    shift_reg  :  process(reset, clk)
    begin
    
        if (reset = '1') then

            mem_fin <= (Others => ((others => '0') ));
           --mem_fin(0) <= std_logic_vector(to_unsigned(TAIL_LENGTH, SR_WIDTH));  
            mem_1 <= (Others => ((others => '0') ));
            mem_2 <= (Others => ((others => '0') ));
            clock_count <= ((others => '0'));
            
        elsif rising_edge(clk) then

            if (clock_value_old = '0' and clock_slow = '1') then

                clock_value_old <= not clock_value_old;
                mem_1  <=  mem_2(1) & mem_1(0 TO NUM_OF_LEDS-2);
                mem_2  <=  mem_2(2 TO NUM_OF_LEDS-2) & mem_1(NUM_OF_LEDS-1);

                
                for I in 0 TO TAIL_LENGTH-1 loop

                    if clock_count = I then
                        mem_1(0) <= mem_ini(I);
                        clock_count <= clock_count + 1;
                    end if;

                end loop;
                

                --------edge cases----------
            
                mem_fin(0) <= mem_1(0);
                mem_fin(NUM_OF_LEDS-1) <= mem_1(NUM_OF_LEDS-1);
            
                ----------------------------

                for I in 1 to NUM_OF_LEDS-2 loop
                    -----tail cases-------
                    if I<TAIL_LENGTH-1 or I>NUM_OF_LEDS-TAIL_LENGTH-1 then                    
                        
                        if mem_1(I) > mem_2(I) then
                            mem_fin(I) <= mem_1(I);
                        else
                            mem_fin(I) <= mem_2(I);
                        end if;
                    ----------------------
                    else    
                        mem_fin(I) <= mem_1(I) or mem_2(I);
                    end if;

                end loop;

            elsif (clock_value_old = '1' and clock_slow = '0') then
                clock_value_old <= clock_slow;
        
            end if;

        end if;
        
    end process;

end Behavioral;
