library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    component top is
    port (
        sysclk : in std_logic;
        start : in std_logic;
        --tx_we : in std_logic;
        ready : out std_logic;

        mosi : out std_logic;
        miso : in std_logic;
        sck : out std_logic;
        cs : out std_logic
    );  
    end component;

    signal sysclk, start, tx_we, miso : std_logic := '0';
    signal ready, mosi, sck, cs : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    uut: entity work.top port map (
        sysclk, start, ready, mosi, miso, sck, cs
    );

    sysclk <= not sysclk after CLK_PERIOD / 2;
    
    process
    begin
        tx_we <= '1';
        wait for 32 * CLK_PERIOD;
        tx_we <= '0';
        start <= '1';
        wait for 16 * CLK_PERIOD;
        start <= '0';
        wait for 64 * CLK_PERIOD;
        wait;
    end process;

end Behavioral;
