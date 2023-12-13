-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- use work.brick_pkg.all;


-- entity buzzer is 
--     port 
--     (
--         MAX10_CLK1_50 : in std_logic;
--         sound : in sound_type;
--         buzzer_en : in std_logic;
--         buzz_out : buffer std_logic
--     );
-- end entity;


-- architecture behavioral of buzzer is 
-- signal count : integer := 0;
-- signal nbuzz_out : std_logic;

-- begin

-- process (MAX10_CLK1_50) begin
--     if buzzer_en = '0' then
--         count <= 0;
--     elsif count > 100000 then
--         count <= 0;
--     else 
--         buzz_out <= nbuzz_out;
--     end if;

--     case sound is
    
--         when DIE => 
--             if count = 26315 then 
--                 nbuzz_out <= not buzz_out;
--                 count <= 0;
--             else 
--                 count <= count + 1;
--             end if;
--         when PAD => 
--             if count = 40160 then 
--                 nbuzz_out <= not buzz_out;
--                 count <= 0;
--             else 
--                 count <= count + 1;
--             end if;
--         when TOP => 
--             if count = 35760 then 
--                 nbuzz_out <= not buzz_out;
--                 count <= 0;
--             else 
--                 count <= count + 1;
--             end if;
--         when BREAK => 
--             if count = 47801 then 
--                 nbuzz_out <= not buzz_out;
--                 count <= 0;
--             else 
--                 count <= count + 1;
--             end if;

--     end case;

-- end process;

-- end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.brick_pkg.all;


entity Buzzer is
	port (
        MAX10_CLK1_50 : in std_logic;
        sound : in sound_type;
        buzzer_en : in std_logic;
        buzz_out : buffer std_logic
	);
end entity Buzzer;

architecture behavioral of Buzzer is
type state is (init, buzzing, finished);
signal current_state, next_state : state := init;
signal count : integer := 0;
signal buzz_count : integer := 0;

begin

process(MAX10_CLK1_50)
begin
	if rising_edge(MAX10_CLK1_50) then
		case current_state is
			when init =>
				if buzzer_en = '1' then
					current_state <= buzzing;
					buzz_count <= 0;
					count <= 0;
				end if;
			when buzzing =>
				if buzz_count < 1500000 then
					buzz_count <= buzz_count + 1;
					if sound = TOP then
						if count = 35760 then
							buzz_out <= not buzz_out;
							count <= 0;
						else count <= count + 1;
						end if;
					elsif sound = PAD then
						if count = 40160 then
							buzz_out <= not buzz_out;
							count <= 0;
						else count <= count + 1;
						end if;
					elsif sound = BREAK then
						if count = 47801 then
							buzz_out <= not buzz_out;
							count <= 0;
						else count <= count + 1;
						end if;
					elsif sound = DIE then
						if count = 26315 then
							buzz_out <= not buzz_out;
							count <= 0;
						else count <= count + 1;
						end if;
					end if;
				else current_state <= finished;
				end if;
			when finished =>
				current_state <= init;
		end case;
	end if;
end process;
end architecture behavioral;