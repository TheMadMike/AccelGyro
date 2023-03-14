library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dp_ram_defs.all;

entity dp_ram_tb is
end dp_ram_tb;

architecture tb of dp_ram_tb is

    component dp_ram
        port (clk   : in std_logic;
              ce    : in std_logic;
              a_in  : in dp_ram_in (address(3 downto 0));
              b_in  : in dp_ram_in (address(3 downto 0));
              a_out : out std_logic_vector (7 downto 0);
              b_out : out std_logic_vector (7 downto 0));
    end component;

    signal clk   : std_logic := '0';
    signal ce    : std_logic := '1';
    signal a_data, b_data : std_logic_vector(7 downto 0) := x"00";
    signal a_addr, b_addr : unsigned(3 downto 0) := (others => '0');
    signal a_we, b_we : std_logic := '0';

    signal a_out : std_logic_vector (7 downto 0);
    signal b_out : std_logic_vector (7 downto 0);

begin

    uut : entity work.dp_ram
    port map (clk   => clk,
              ce    => ce,
              a_in  => (
                data => a_data,
                address => a_addr,
                we => a_we
              ),
              b_in  => (
                data => b_data,
                address => b_addr,
                we => b_we
              ),
              a_out => a_out,
              b_out => b_out);

    -- Clock generation
    clk <= not clk after 25 ns;

    process
    begin
        -- perform a write on port A
        a_addr <= b"0001";
        a_data <= x"11";
        a_we <= '1';
        wait for 100 ns;
        a_addr <= b"0010";
        wait for 100 ns;
        a_we <= '0';
        a_addr <= b"0011";
        b_addr <= b"0001";
        wait for 100 ns;
        b_addr <= b"0010";
        wait;
    end process;

end tb;