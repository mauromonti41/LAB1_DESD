library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;

entity ShiftPWM is
    Generic(
        NUM_OF_LEDS		:	INTEGER	RANGE 1 TO 16;
        SR_DEPTH        :   POSITIVE := 3;
        
        SR_INIT         :   INTEGER    
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
    constant   INIT_SLV :    STD_LOGIC_VECTOR(NUM_OF_LEDS-1 downto 0) := STD_LOGIC_VECTOR(to_unsigned(SR_INIT,SR_WIDTH));
    ---------------------------------    
        
    ----------------------------------------------------------------------



    -------------------------- Types Declaration --------------------------
    
    ------------ Memory  ------------
    type    MEM_ARRAY_TYPE_1  is  array(0 TO NUM_OF_LEDS-1) of std_logic_vector(SR_WIDTH-1 downto 0);
    type    MEM_ARRAY_TYPE_2  is  array(1 TO NUM_OF_LEDS-2) of std_logic_vector(SR_WIDTH-1 downto 0);
    ---------------------------------    
        
    ----------------------------------------------------------------------


    ------------------------- Signal Declaration -------------------------
    
    ------------ Memory  ------------
    signal  mem_1  :   MEM_ARRAY_TYPE_1 := ( Others  => INIT_SLV);
    signal  mem_2  :   MEM_ARRAY_TYPE_2 := ( Others  => INIT_SLV);
    
    ---------------------------------    
    signal counter : unsigned(1 DOWNTO 0) := "00";
    ----------------------------------------------------------------------


begin
  
	--dout    <=  mem(SR_DEPTH-1);

    inst_pwm: for I in 0 to NUM_OF_LEDS-1 generate
       
    -- edge_pwm : if I=0 or I=1 or I=2 or I=NUM_OF_LEDS-1 or I=NUM_OF_LEDS-2 or I=NUM_OF_LEDS-3 generate
        
        pwm_inst_I: PWM
        generic map (
            
        );
        port map (
            reset => reset,
            clk => clk,

            Ton => mem_fin(I);
            Period => '3';

            PWM => led_out (I)
                );
       --end generate;    
        
    --     central_inst_I : if I /= 0 generate
            
    --         pwm_inst_I: PWM
    --         port map (
    --             reset => reset,
    --             clk => clk,
                
    --             Ton => mem_1(I) or mem_2(I));
    --             Period => '3';

    --             PWM => led_out (I)
    --             );
    --    end generate;
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
