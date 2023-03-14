library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_master_tb is
end spi_master_tb;

architecture Behavioral of spi_master_tb is
    component spi_master
    generic (
        DATA_LENGTH : natural
    );
    port (
        --- internal
        clk : in std_logic;
        ce : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        tx_we : in std_logic;
        ready : out std_logic;
        rx_data : out std_logic_vector(DATA_LENGTH-1 downto 0);
        tx_data : in std_logic_vector(DATA_LENGTH-1 downto 0);

        --- external
        mosi : out std_logic;
        miso : in std_logic;
        sck : out std_logic;
        cs : out std_logic
    );
    end component;

    signal clk, ce, reset, start, tx_we, miso : std_logic := '0';
    signal mosi, sck, cs, ready : std_logic;
    signal tx_data, rx_data : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    uut: entity work.spi_master generic map (8) port map (
        clk => clk,
        ce => ce,
        reset => reset,
        start => start,
        tx_we => tx_we,
        ready => ready,
        rx_data => rx_data,
        tx_data => tx_data,
        mosi => mosi,
        miso => miso,
        sck => sck,
        cs => cs
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        miso <= '1';
        tx_data <= x"AA";
        tx_we <= '1';
        ce <= '1';
        wait for CLK_PERIOD;
        tx_we <= '0';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait for 8 * CLK_PERIOD;
        wait;
    end process;

end Behavioral;
