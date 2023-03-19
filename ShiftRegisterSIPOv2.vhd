library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.NUMERIC_STD.ALL;

entity ShiftRegisterSIPOv2 is
	Generic(
        SR_WIDTH   :   NATURAL   := 8;  -- commento di prova
        SR_DEPTH   :   POSITIVE  := 1;
        SR_INIT    :   INTEGER   := 1 
    );
	Port(
		reset	: in std_logic;
		clk		: in std_logic;

		data_in		: in std_logic;
		
		data_out	: out std_logic_vector (SR_WIDTH-1 downto 0)
	);
end ShiftRegisterSIPOv2;

architecture Behavioral of ShiftRegisterSIPOv2 is

	constant   INIT_SLV : STD_LOGIC_VECTOR(SR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(SR_INIT,SR_WIDTH));

	signal data_out_internal : std_logic_vector(data_out'RANGE) := INIT_SLV;

	
    
begin

	data_out <= data_out_internal;

	process (clk, reset)
	begin
		if reset = '1' then
			data_out_internal <= INIT_SLV;
		elsif rising_edge(clk) then
			data_out_internal <= data_in & data_out_internal(data_out_internal'LEFT DOWNTO 1);
			
			
		end if;
	end process;

end Behavioral;
