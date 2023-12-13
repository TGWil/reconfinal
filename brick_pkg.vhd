library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package brick_pkg is
    type brick_array is array(0 to 239, 0 to 639) of std_logic;
    type brick_array2 is array(0 to 29, 0 to 40) of std_logic;
    -- type ball_array is array(0 to 639, 0 to 479) of std_logic;
    type paddle_array is array(0 to 639, 0 to 4) of std_logic;
    type pos is array(0 to 1) of integer;
    type state_type is (IDLE, GEN, LOSE, DROP, PLAY);
    type sound_type is (PAD, TOP, BREAK, DIE);
end brick_pkg; 