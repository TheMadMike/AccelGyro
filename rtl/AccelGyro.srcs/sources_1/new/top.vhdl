library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity top is
    port(
        sysclk : in std_logic;
        start : in std_logic;
        --tx_we : in std_logic;
        ready : out std_logic;

        -- SPI esp32
        mosi : out std_logic;
        miso : in std_logic;
        sck : out std_logic;
        cs : out std_logic
    );
end top;

architecture Behavioral of top is
    signal clk_div_counter : unsigned(7 downto 0) := (others => '1');
    -- spi clock
    signal clk : std_logic := '1';
    signal rx_data : std_logic_vector(7 downto 0);
    signal start_inverted : std_logic;
    signal mosi_internal, cs_internal : std_logic;
begin
    start_inverted <= not start;
    
    mosi <= mosi_internal;
    cs <= cs_internal;

    process (sysclk, clk_div_counter)
    begin
        if rising_edge(sysclk) then
            clk_div_counter <= clk_div_counter + 1;
        end if;
    end process;

    process (sysclk, clk_div_counter, clk)
    begin
        if rising_edge(sysclk) and clk_div_counter = x"00" then
            clk <= not clk;
        end if;
    end process;

    spi_master_0: entity work.spi_master generic map (8) port map (
        clk => clk,
        ce => '1',
        reset => '0',
        start => start_inverted,
        tx_we => '1',
        ready => ready,
        rx_data => rx_data,
        tx_data => x"41",
        mosi => mosi_internal,
        miso => miso,
        sck => sck,
        cs => cs_internal
    );
end Behavioral;
