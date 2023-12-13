library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random is 
    port (
        MAX10_CLK1_50 : in std_logic;
        rst_l : in std_logic;
        go : in std_logic;
        out1 : out unsigned(9 downto 0)
    );
end entity random;


architecture behavioral of random is
    signal LFSR : unsigned (19 downto 0);
    signal out_bits : unsigned (19 downto 0);
    signal START : unsigned(19 downto 0);
    -- signal out1 : unsigned(3 downto 0);
    -- signal out2 : unsigned(3 downto 0);

begin

    process (MAX10_CLK1_50, rst_l,go)
    begin
        START <= "00000000000110100100";
        if rst_l = '0' then
            LFSR <= START;
        elsif rising_edge(MAX10_CLK1_50) then
            if go = '0' then
                LFSR(19) <= LFSR(0);
                LFSR(18) <= LFSR(19);
                LFSR(17) <= LFSR(18);
                LFSR(16) <= LFSR(17);
                LFSR(15) <= LFSR(16);
                LFSR(14) <= LFSR(15);
                LFSR(13) <= LFSR(14);
                LFSR(12) <= LFSR(13);
                LFSR(11) <= LFSR(12);
                LFSR(10) <= LFSR(11) xor LFSR(0);
                LFSR(9) <= LFSR(10);
                LFSR(8) <= LFSR(9);
                LFSR(7) <= LFSR(8);
                LFSR(6) <= LFSR(7);
                LFSR(5) <= LFSR(6);
                LFSR(4) <= LFSR(5);
                LFSR(3) <= LFSR(4);
                LFSR(2) <= LFSR(3);
                LFSR(1) <= LFSR(2);
                LFSR(0) <= LFSR(1);
            end if;
        end if;
    end process;
    out_bits <= LFSR;
    out1 <= out_bits(7) & out_bits(12) & out_bits(19) & out_bits(0) & out_bits(6) & out_bits(5) & out_bits(13) & out_bits(8) & out_bits(3) & out_bits(2);
end architecture behavioral;