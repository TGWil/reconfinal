library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.brick_pkg.all;


entity Final is
    port 
    (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        rst_l : in std_logic;
        new_ball : in std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        VGA_VS : out std_logic;
        VGA_HS : out std_logic;
        ARDUINO_IO : in std_logic_vector(15 downto 0);
        ARDUINO_RESET_N : in std_logic;
        buzz_out : out std_logic
    );
end entity; 


architecture behavioral of Final is 
    signal cstate, nstate : state_type;
    signal paddle : paddle_array;
    signal cball_pos, paddle_pos, nball_pos : pos;
    signal cx_vel, cy_vel, nx_vel, ny_vel : integer := 0;
    signal temp_pos : integer range 0 to 599 := 0;
    signal ADC_out : std_logic_vector(11 downto 0);
    -- signal ball_speed : natural := 1000001;
    signal cbricks, nbricks : brick_array := (others => (others => '1'));
    signal nbricks_act, cbricks_act : brick_array2 := (others => (others => '1'));
    signal row_count : integer range 0 to 29 := 0;
    signal col_count : integer range 0 to 40 := 0;
    signal cballs, nballs : integer range 0 to 5 := 0;
    signal buzzer_en, random_en : std_logic := '0';
    signal count : integer range 0 to 999999 := 0;
    signal random_out : unsigned(9 downto 0);
    signal sound : sound_type;
    signal loopi, loopj, srloopi, srloopj : integer := 0;
    signal srball_pos_top_row, srball_pos_left_col, srball_pos_bottom_row, srball_pos_right_col, srball_pos_mid_row, srball_pos_mid_col : integer := 0;
    signal areset, inclk0, clk, locked : std_logic;

    component VGA 
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            ball_pos: in pos;
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
    end component;

    component Lab7
        port
        (
            ADC_CLK_10 : in std_logic;
            rst_l : in std_logic;
            ADC_out : out std_logic_vector(11 downto 0);
            ARDUINO_IO : in std_logic_vector(15 downto 0);
            ARDUINO_RESET_N : in std_logic
        );
    end component;

    component random 
        port
        (
            MAX10_CLK1_50 : in std_logic;
            rst_l : in std_logic;
            go : in std_logic;
            out1 : out unsigned(9 downto 0)
        );
    end component;

    component buzzer
        port 
        (
            MAX10_CLK1_50 : in std_logic;
            sound : in sound_type;
            buzzer_en : in std_logic;
            buzz_out : out std_logic
        );
    end component;

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

    vga_inst : VGA 
        port map 
        (
            clk => clk,
            rst_l => rst_l,
            ball_pos => cball_pos,
            paddle_pos => paddle_pos,
            bricks => cbricks_act,
            row_count_out => row_count,
            col_count_out => col_count,
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            VGA_VS => VGA_VS,
            VGA_HS => VGA_HS
        );

    adc_inst : Lab7
        port map
        (
            ADC_CLK_10 => ADC_CLK_10,
            rst_l => rst_l,
            ADC_out => ADC_out,
            ARDUINO_IO => ARDUINO_IO,
            ARDUINO_RESET_N => ARDUINO_RESET_N
        );

    rand_inst : random
        port map
        (
            MAX10_CLK1_50 => MAX10_CLK1_50,
            rst_l => rst_l,
            go => random_en,
            out1 => random_out
        );

    buzzer_inst : buzzer
        port map 
        (
            MAX10_CLK1_50 => MAX10_CLK1_50,
            sound => sound,
            buzzer_en => buzzer_en,
            buzz_out => buzz_out
        );


process(MAX10_CLK1_50, rst_l) 
begin
    if rising_edge(MAX10_CLK1_50) then
        if rst_l = '0' then 
            cstate <= IDLE;
            count <= 0;
            cx_vel <= 1;
            cy_vel <= 1;
            cball_pos(0) <= 315;
            cball_pos(1) <= 245;
            cballs <= 0;
            buzzer_en <= '0';
            cbricks <= (others => (others => '1'));
            cbricks_act <= (others => (others => '1'));
        else 
            cbricks <= nbricks;
            cbricks_act <= nbricks_act;
            cstate <= nstate;
            cx_vel <= nx_vel;
            cy_vel <= ny_vel;
            cball_pos <= nball_pos;
            cballs <= nballs;
        end if;

        case cstate is 
            when IDLE => 
                nbricks_act <= cbricks_act;
                nx_vel <= cx_vel;
                ny_vel <= cy_vel;
                nball_pos <= cball_pos;
                nballs <= cballs;
                nball_pos(0) <= 315;
                nball_pos(1) <= 245;
                nstate <= DROP;
            
            when DROP => 
                nbricks_act <= cbricks_act;
                nx_vel <= cx_vel;
                ny_vel <= cy_vel;
                nball_pos <= cball_pos;
                nballs <= cballs;
                if new_ball = '0' and cballs < 5 then
                    nballs <= cballs + 1;
                    random_en <= '1';
                    nstate <= GEN;
                elsif cballs = 5 then
                    nstate <= LOSE;
                else 
                    nstate <= DROP;
                end if;

            when GEN => 
                nbricks_act <= cbricks_act;
                nx_vel <= cx_vel;
                ny_vel <= cy_vel;
                nball_pos <= cball_pos;
                nballs <= cballs;
                if random_out < 625 then 
                    nball_pos(1) <= 250;
                    nball_pos(0) <= to_integer(random_out);
                else 
                    nball_pos(1) <= 250;
                    nball_pos(0) <= to_integer(random_out srl 1);
                end if;
                nx_vel <= 1;
                ny_vel <= 1;
                random_en <= '0';
                nstate <= PLAY;
            
            when PLAY =>
                nbricks_act <= cbricks_act;
                nx_vel <= cx_vel;
                ny_vel <= cy_vel;
                nball_pos <= cball_pos;
                nballs <= cballs;
                -- nball_pos(0) <= cball_pos(0);
                -- nball_pos(1) <= cball_pos(1);
                -- ball_pos(0) <= ball_pos(0);
                -- ball_pos(1) <= ball_pos(1);

                if count = 10 then 
                    buzzer_en <= '0';
                end if;

                if count = 499000 then
                    nball_pos(0) <= cball_pos(0) + cx_vel;
                    nball_pos(1) <= cball_pos(1) + cy_vel;

                    if cball_pos(1) >= 463 and cball_pos(0) > paddle_pos(0) and cball_pos(0) < paddle_pos(0)+40 then
                        nball_pos(1) <= 460;
                        sound <= PAD;
                        buzzer_en <= '1';
                        ny_vel <= -cy_vel;
                    elsif cball_pos(1) <= 0 then
                        sound <= TOP;
                        buzzer_en <= '1';
                        nball_pos(1) <= 1;
                        ny_vel <= 1;
                    elsif cball_pos(1) > 480 then
                        sound <= DIE;
                        buzzer_en <= '1';
                        nx_vel <= 0;
                        ny_vel <= 0;
                        count <= 0;
                        nstate <= DROP;
                    end if;
                
                    if cball_pos(0) <= 0 then
                        nball_pos(0) <= 1;
                        sound <= TOP;
                        buzzer_en <= '1';
                        nx_vel <= -cx_vel;
                    elsif cball_pos(0) >= 640 then
                        nball_pos(0) <= 625;
                        sound <= TOP;
                        buzzer_en <= '1';
                        nx_vel <= -cx_vel;
                    elsif cball_pos(1) < 245 then

                        sound <= BREAK;

                        if cbricks_act(srball_pos_top_row, srball_pos_mid_col) = '1' then
                            buzzer_en <= '1';
                            nbricks_act(srball_pos_top_row, srball_pos_mid_col) <= '0';
                            ny_vel <= -cy_vel; 

                        elsif cbricks_act(srball_pos_mid_row, srball_pos_left_col) = '1' then
                            buzzer_en <= '1';
                            nbricks_act(srball_pos_mid_row, srball_pos_left_col) <= '0';
                            nx_vel <= -cx_vel;

                        elsif cbricks_act(srball_pos_bottom_row, srball_pos_mid_col) = '1' then
                            buzzer_en <= '1';
                            nbricks_act(srball_pos_bottom_row, srball_pos_mid_col) <= '0';
                            ny_vel <= -cy_vel;

                        elsif cbricks_act(srball_pos_mid_row, srball_pos_right_col) = '1' then
                            buzzer_en <= '1';
                            nbricks_act(srball_pos_mid_row, srball_pos_right_col) <= '0';
                            nx_vel <= -cx_vel;

                        else 
                            nx_vel <= cx_vel;
                            ny_vel <= cy_vel;
                        end if;

                    end if;
    
                    count <= 0;
                else 
                    count <= count + 1;
                end if;

            when LOSE =>
                nbricks_act <= cbricks_act;
                nx_vel <= cx_vel;
                ny_vel <= cy_vel;
                nball_pos <= cball_pos;
                nballs <= cballs;
                sound <= DIE;
                buzzer_en <= '1';
                nstate <= IDLE;

        end case;

    end if;

end process;



srball_pos_top_row <= to_integer((to_unsigned(cball_pos(1),5) srl 3));
srball_pos_mid_row <= to_integer((to_unsigned(cball_pos(1)+5,5) srl 3));
srball_pos_bottom_row <= to_integer((to_unsigned(cball_pos(1)+9,5) srl 3));
srball_pos_mid_col <= to_integer((to_unsigned(cball_pos(0)+5,6) srl 4));
srball_pos_left_col <= to_integer((to_unsigned(cball_pos(0),6) srl 4)) when to_unsigned(srball_pos_mid_row,5)(0) = '0' else to_integer((to_unsigned(cball_pos(0)+8,6) srl 4));
srball_pos_right_col <= to_integer((to_unsigned(cball_pos(0)+9,6) srl 4)) when to_unsigned(srball_pos_mid_row,5)(0) = '0' else to_integer((to_unsigned(cball_pos(0)+17,6) srl 4));



process (ADC_out, rst_l) 
begin
    if rst_l = '0' then
        paddle_pos(0) <= 300;
        paddle_pos(1) <= 473;
        temp_pos <= 300;
    else 
        paddle_pos(0) <= temp_pos;
        paddle_pos(1) <= 473;

        temp_pos <= to_integer(unsigned(ADC_out) srl 2);
        if temp_pos > 599 then 
            paddle_pos(0) <= 599;
        elsif temp_pos < 0 then
            paddle_pos(0) <= 0;
        end if;

    end if;

end process;


end architecture;