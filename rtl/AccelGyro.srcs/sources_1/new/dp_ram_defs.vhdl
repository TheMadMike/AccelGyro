library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package dp_ram_defs is

    type dp_ram_in is record
        data : std_logic_vector(7 downto 0);
        address : unsigned(3 downto 0);
        we : std_logic;
    end record dp_ram_in;

    type ram_block is array (natural range<>) of std_logic_vector(7 downto 0);

end package;