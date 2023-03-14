library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use work.dp_ram_defs.all;

-- dual port, byte-addressed RAM
entity dp_ram is
    generic (
        SIZE : natural := 64
    );
    port (
        clk : in std_logic;
        ce : in std_logic;
        
        a_in : in dp_ram_in;
        b_in : in dp_ram_in;

        a_out : out std_logic_vector(7 downto 0);
        b_out : out std_logic_vector(7 downto 0)
    );
end dp_ram;

architecture Behavioral of dp_ram is
    signal data : ram_block(SIZE-1 downto 0) := (others => (others => 'L'));
    
begin
    a_out <= data(to_integer(a_in.address));
    b_out <= data(to_integer(b_in.address));

    -- port A write
    process (clk, ce, a_in.address, a_in.we)
    begin
        if rising_edge(clk) and ce = '1' and a_in.we = '1' then
            data(to_integer(a_in.address)) <= a_in.data;
        end if;
    end process;

    -- port B write
    process (clk, ce, b_in.address, b_in.we)
    begin
        if rising_edge(clk) and ce = '1' and a_in.we = '1' then
            data(to_integer(b_in.address)) <= b_in.data;
        end if;
    end process;

end Behavioral;
