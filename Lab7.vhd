library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Lab7 is 
    port (
        ADC_CLK_10 : in std_logic;
        rst_l : in std_logic;
        ADC_out : out std_logic_vector(11 downto 0);
        ARDUINO_IO : in std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : in std_logic
    );
end entity Lab7;

architecture behavioral of Lab7 is
    signal adc_pll_clock_clk, adc_pll_locked_export, command_valid, command_startofpacket, command_endofpacket, command_ready, reset_sink_reset_n, response_valid,  response_startofpacket, response_endofpacket : std_logic;
    signal command_channel, response_channel : std_logic_vector(4 downto 0);
    signal response_data : std_logic_vector(11 downto 0);
    signal adc_sample_data : std_logic_vector(11 downto 0);
    signal cur_adc_ch : std_logic_vector(4 downto 0);
    signal count : natural := 0;
    signal areset, inclk0, clk, locked, done : std_logic;
    

    component ADC_PLL 
        port
        (
            areset : IN STD_LOGIC  := '0';
            inclk0 : IN STD_LOGIC  := '0';
            c0 : OUT STD_LOGIC ;
            locked : OUT STD_LOGIC 
        );
    end component ADC_PLL;

    component ADC
        port (
            adc_pll_clock_clk      : in  std_logic                     := '0';             --  adc_pll_clock.clk
            adc_pll_locked_export  : in  std_logic                     := '0';             -- adc_pll_locked.export
            clock_clk              : in  std_logic                     := '0';             --          clock.clk
            command_valid          : in  std_logic                     := '0';             --        command.valid
            command_channel        : in  std_logic_vector(4 downto 0)  := (others => '0'); --               .channel
            command_startofpacket  : in  std_logic                     := '0';             --               .startofpacket
            command_endofpacket    : in  std_logic                     := '0';             --               .endofpacket
            command_ready          : out std_logic;                                        --               .ready
            reset_sink_reset_n     : in  std_logic                     := '0';             --     reset_sink.reset_n
            response_valid         : out std_logic;                                        --       response.valid
            response_channel       : out std_logic_vector(4 downto 0);                     --               .channel
            response_data          : out std_logic_vector(11 downto 0);                    --               .data
            response_startofpacket : out std_logic;                                        --               .startofpacket
            response_endofpacket   : out std_logic                    
        );
    end component ADC;
    
begin

    PLL_inst : ADC_PLL PORT MAP (
		areset	 => areset,
		inclk0	 => ADC_CLK_10,
		c0	 => clk,
		locked	 => locked
	);

    ADC_inst : ADC PORT MAP (
        adc_pll_clock_clk => clk,
        adc_pll_locked_export => locked,
        clock_clk => ADC_CLK_10,        
        command_valid => '1',
        command_channel => "00010",
        command_startofpacket => '1',
        command_endofpacket => '1',
        command_ready => command_ready,
        reset_sink_reset_n => '1',
        response_valid => response_valid,
        response_channel => response_channel,
        response_data => response_data,
        response_startofpacket => response_startofpacket,
        response_endofpacket => response_endofpacket
    );
        
process (ADC_CLK_10, rst_l) begin
    if rising_edge(ADC_CLK_10) then
        if (rst_l = '0') then
            adc_sample_data <= (others => '0');
            count <= 0;
            done <= '0';
        end if;

        if(count = 999999) then
            count <= 0;
            done <= '1';
        elsif(response_valid = '1' and done = '1')then
            adc_sample_data <= response_data;
            done <= '0';
        else
            count <= count + 1;
        end if;
    end if;

end process;

    ADC_out <= adc_sample_data(11 downto 0);
end architecture behavioral;