-- ADC.vhd

-- Generated using ACDS version 18.1 625

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ADC is
	port (
		adc_pll_clock_clk          : in  std_logic                     := '0';             --    adc_pll_clock.clk
		adc_pll_locked_export      : in  std_logic                     := '0';             --   adc_pll_locked.export
		clock_clk                  : in  std_logic                     := '0';             --            clock.clk
		reset_sink_reset_n         : in  std_logic                     := '0';             --       reset_sink.reset_n
		sample_store_csr_address   : in  std_logic_vector(6 downto 0)  := (others => '0'); -- sample_store_csr.address
		sample_store_csr_read      : in  std_logic                     := '0';             --                 .read
		sample_store_csr_write     : in  std_logic                     := '0';             --                 .write
		sample_store_csr_writedata : in  std_logic_vector(31 downto 0) := (others => '0'); --                 .writedata
		sample_store_csr_readdata  : out std_logic_vector(31 downto 0);                    --                 .readdata
		sample_store_irq_irq       : out std_logic;                                        -- sample_store_irq.irq
		sequencer_csr_address      : in  std_logic                     := '0';             --    sequencer_csr.address
		sequencer_csr_read         : in  std_logic                     := '0';             --                 .read
		sequencer_csr_write        : in  std_logic                     := '0';             --                 .write
		sequencer_csr_writedata    : in  std_logic_vector(31 downto 0) := (others => '0'); --                 .writedata
		sequencer_csr_readdata     : out std_logic_vector(31 downto 0)                     --                 .readdata
	);
end entity ADC;

architecture rtl of ADC is
	component ADC_modular_adc_0 is
		generic (
			is_this_first_or_second_adc : integer := 1
		);
		port (
			clock_clk                  : in  std_logic                     := 'X';             -- clk
			reset_sink_reset_n         : in  std_logic                     := 'X';             -- reset_n
			adc_pll_clock_clk          : in  std_logic                     := 'X';             -- clk
			adc_pll_locked_export      : in  std_logic                     := 'X';             -- export
			sequencer_csr_address      : in  std_logic                     := 'X';             -- address
			sequencer_csr_read         : in  std_logic                     := 'X';             -- read
			sequencer_csr_write        : in  std_logic                     := 'X';             -- write
			sequencer_csr_writedata    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			sequencer_csr_readdata     : out std_logic_vector(31 downto 0);                    -- readdata
			sample_store_csr_address   : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			sample_store_csr_read      : in  std_logic                     := 'X';             -- read
			sample_store_csr_write     : in  std_logic                     := 'X';             -- write
			sample_store_csr_writedata : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			sample_store_csr_readdata  : out std_logic_vector(31 downto 0);                    -- readdata
			sample_store_irq_irq       : out std_logic                                         -- irq
		);
	end component ADC_modular_adc_0;

begin

	modular_adc_0 : component ADC_modular_adc_0
		generic map (
			is_this_first_or_second_adc => 1
		)
		port map (
			clock_clk                  => clock_clk,                  --            clock.clk
			reset_sink_reset_n         => reset_sink_reset_n,         --       reset_sink.reset_n
			adc_pll_clock_clk          => adc_pll_clock_clk,          --    adc_pll_clock.clk
			adc_pll_locked_export      => adc_pll_locked_export,      --   adc_pll_locked.export
			sequencer_csr_address      => sequencer_csr_address,      --    sequencer_csr.address
			sequencer_csr_read         => sequencer_csr_read,         --                 .read
			sequencer_csr_write        => sequencer_csr_write,        --                 .write
			sequencer_csr_writedata    => sequencer_csr_writedata,    --                 .writedata
			sequencer_csr_readdata     => sequencer_csr_readdata,     --                 .readdata
			sample_store_csr_address   => sample_store_csr_address,   -- sample_store_csr.address
			sample_store_csr_read      => sample_store_csr_read,      --                 .read
			sample_store_csr_write     => sample_store_csr_write,     --                 .write
			sample_store_csr_writedata => sample_store_csr_writedata, --                 .writedata
			sample_store_csr_readdata  => sample_store_csr_readdata,  --                 .readdata
			sample_store_irq_irq       => sample_store_irq_irq        -- sample_store_irq.irq
		);

end architecture rtl; -- of ADC