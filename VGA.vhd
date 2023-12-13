library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.brick_pkg.all;

entity VGA is 
    port (
        MAX10_CLK1_50 : in std_logic;
        rst_l : in std_logic;
        ball_pos : in pos;
        paddle_pos : in pos;
        bricks : in brick_array2;
        row_count_out : out integer range 0 to 29;
        col_count_out : out integer range 0 to 40;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        VGA_VS : out std_logic;
        VGA_HS : out std_logic
    );
end entity;


architecture behavioral of VGA is
    signal areset, inclk0, clk, locked : std_logic;
    signal row, column : natural;
    signal drow, dcol, srdrow, srdcol : integer := 0;
    signal de : std_logic := '1';
    signal row_count : integer range 0 to 29 := 0;
    signal col_count : integer range 0 to 40 := 0;
    -- signal bricks : brick_array := (others => (others => '1'));


    component VGA_PLL 
        port
        (
            areset : IN STD_LOGIC  := '0';
            inclk0 : IN STD_LOGIC  := '0';
            c0 : OUT STD_LOGIC ;
            locked : OUT STD_LOGIC 
        );
    end component VGA_PLL;
    

begin 

    PLL_inst : VGA_PLL PORT MAP (
		areset	 => areset,
		inclk0	 => MAX10_CLK1_50,
		c0	 => clk,
		locked	 => locked
	);
    
    process(clk, rst_l) begin -- column tracking
        if rising_edge(clk) then
            if rst_l = '0' then
                column <= 0;
                row <= 0;
                VGA_R <= (others => '0');
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');
                VGA_HS <= '1';
            end if;
            if column < 16 then
                VGA_R <= (others => '0');
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');
                VGA_HS <= '1';
            elsif column >= 16 and column < 112 then
                VGA_R <= (others => '0');
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');
                VGA_HS <= '0';
            elsif column >= 112 and column < 160 then
                VGA_R <= (others => '0');
                VGA_G <= (others => '0');
                VGA_B <= (others => '0');
                VGA_HS <= '1';
            elsif row >= 45 and row < 525 and column >= 160 then -- Display driver starts here
                drow <= row-45;
                dcol <= column-160;

                row_count_out <= row_count;
                col_count_out <= col_count;

                if row_count > 29 then 
                    row_count <= 0;
                end if;
                if col_count > 40 then
                    col_count <= 0;
                end if;


                -- bricks_out <= bricks;
                -- row_count, col_count
                -- drow, dcol
                -- srdrow, srdcol

                -- Display stuff here
-- new row logic
                if bricks(srdrow, srdcol) = '0' then 
                    VGA_R <= (others => '0');
                    VGA_G <= (others => '0');
                    VGA_B <= (others => '0');

                    if drow < 240 and ((to_unsigned(drow,12) and "000000000111") = "000000000000") then
                        row_count <= row_count + 1;
                    end if;
                    if dcol < 639 and drow < 240 and ((to_unsigned(dcol-8,12) and "000000001111") = "000000000000") then
                        col_count <= col_count + 1;
                    end if;

                elsif bricks(srdrow, srdcol) = '1' then

                    if drow < 240 and ((to_unsigned(drow,12) and "000000000111") = "000000000000") then
                        VGA_R <= (others => '1');
                        VGA_G <= (others => '1');
                        VGA_B <= (others => '1');
                        row_count <= row_count + 1;
                    elsif drow < 240 then
                        VGA_R <= (others => '1');
                        VGA_G <= (others => '0');
                        VGA_B <= (others => '0'); 
                    else 
                        VGA_R <= (others => '0');
                        VGA_G <= (others => '0');
                        VGA_B <= (others => '0');
                    end if;

                    if ((to_unsigned(row_count,5) and "00001") = "1") then
                        if dcol < 639 and drow < 240 and ((to_unsigned(dcol-8,12) and "000000001111") = "000000000000") then
                            VGA_R <= (others => '1');
                            VGA_G <= (others => '1');
                            VGA_B <= (others => '1');
                            col_count <= col_count + 1;
                        end if;
                    elsif ((to_unsigned(row_count,5) and "00001") = "0") then
                        if dcol < 639 and drow < 240 and ((to_unsigned(dcol,12) and "000000001111") = "000000000000") then
                            VGA_R <= (others => '1');
                            VGA_G <= (others => '1');
                            VGA_B <= (others => '1');
                            col_count <= col_count + 1;
                        end if;
                    end if;

                -- elsif bricks(row_count, col_count) = '0' then
                --     -- if drow < 240 and bricks(row_count, col_count) = '0' and ((to_unsigned(drow,12) and "000000000111") = "000000000000") then
                --     if drow < 240 and ((to_unsigned(drow,12) and "000000000111") = "000000000000") then
                --         VGA_R <= (others => '0');
                --         VGA_G <= (others => '0');
                --         VGA_B <= (others => '0');
                --         row_count <= row_count + 1;
                --     elsif drow < 240 then
                --         VGA_R <= (others => '0');
                --         VGA_G <= (others => '0');
                --         VGA_B <= (others => '0'); 
                --     else 
                --         VGA_R <= (others => '0');
                --         VGA_G <= (others => '0');
                --         VGA_B <= (others => '0');
                --     end if;

                --     if ((to_unsigned(row_count,5) and "00001") = "1") then
                --         -- if dcol < 639 and drow < 240 and bricks(row_count, col_count) = '0' and ((to_unsigned(dcol-8,12) and "000000001111") = "000000000000") then
                --             if dcol < 639 and drow < 240 and ((to_unsigned(dcol-8,12) and "000000001111") = "000000000000") then
                --             VGA_R <= (others => '0');
                --             VGA_G <= (others => '0');
                --             VGA_B <= (others => '0');
                --             col_count <= col_count + 1;
                --         end if;
                --     elsif ((to_unsigned(row_count,5) and "00001") = "0") then
                --         -- if dcol < 639 and drow < 240 and bricks(row_count, col_count) = '0' and ((to_unsigned(dcol,12) and "000000001111") = "000000000000") then
                --             if dcol < 639 and drow < 240 and ((to_unsigned(dcol,12) and "000000001111") = "000000000000") then
                --             VGA_R <= (others => '0');
                --             VGA_G <= (others => '0');
                --             VGA_B <= (others => '0');
                --             col_count <= col_count + 1;
                --         end if;
                --     end if;
                else 
                    VGA_R <= (others => '0');
                    VGA_G <= (others => '0');
                    VGA_B <= (others => '0');
                end if;
                

-- paddle and ball display logic
                    
                if column-160 >= ball_pos(0) and column-160 < ball_pos(0)+10 and row-45 >= ball_pos(1) and row-45 < ball_pos(1)+10 then
                    VGA_R <= (others => '1');
                    VGA_G <= (others => '1');
                    VGA_B <= (others => '1');
                end if;

                if column-160 >= paddle_pos(0) and column-160 < paddle_pos(0)+40 and row-45 >= paddle_pos(1) and row-45 < paddle_pos(1)+5 then
                    VGA_R <= "0111";
                    VGA_G <= "0011";
                    VGA_B <= "0000";
                end if;

                  
-- end of vga display area
			end if;
            if  column = 800 then
                column <= 0;
                row <= row + 1;
            else
                column <= column + 1;
            end if;
            if row = 525 then
                row <= 0;
            end if;
        end if;
    end process;


    srdrow <= to_integer(to_unsigned(drow,6) srl 3);
    srdcol <= to_integer(to_unsigned(dcol,6) srl 4);

    process(row) begin --Vertical syncing
      if row > 9 and row < 12 then
          VGA_VS <= '0';
      else
          VGA_VS <= '1';
		end if;
    end process;

end architecture;