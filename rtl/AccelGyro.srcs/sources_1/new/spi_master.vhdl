library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- full duplex, MSB first, CPOL=0, CPHA=0
entity spi_master is
    generic (
        DATA_LENGTH : natural := 8
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
end entity;

architecture Behavioral of spi_master is
    -- FSM
    type state_type is (IDLE, RUNNING);
    signal state : state_type := IDLE;
    signal next_state : state_type := IDLE;
    
    -- counter used to count transmitted/received bits
    signal counter : unsigned(DATA_LENGTH-1 downto 0) := (others => '0');
    constant COUNTER_TOP : unsigned(DATA_LENGTH-1 downto 0) := to_unsigned(DATA_LENGTH, DATA_LENGTH);

    -- buffers
    signal rx_buffer, tx_buffer : std_logic_vector(DATA_LENGTH-1 downto 0) := (others => '0');

    signal cs_internal : std_logic;
begin
    cs_internal <= '0' when state = RUNNING and counter(3) = '0' else '1';

    -- no clock dividing
    sck <= not clk when cs_internal = '0' else 'Z';
    -- chip select is pulled down only transmittion
    cs <= cs_internal;
    mosi <= tx_buffer(DATA_LENGTH-1) when cs_internal = '0' else 'Z';
    ready <= '1' when (counter = COUNTER_TOP) else '0';
    rx_data <= rx_buffer;

    process (clk, ce, reset, next_state)
    begin
        if rising_edge(clk) and ce = '1' then
            if reset = '1' then
                state <= IDLE;
            else
                state <= next_state;
            end if;
        end if;
    end process;

    process (clk, ce, reset, counter, state)
    begin
        if rising_edge(clk) and ce = '1' then
            if reset = '1' or counter = COUNTER_TOP then
                counter <= (others => '0'); 
            elsif state = RUNNING then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process (clk, ce, counter, start, next_state)
    begin
        if rising_edge(clk) and ce = '1' then
            case state is
                when IDLE =>
                    if start = '1' then
                        next_state <= RUNNING;
                    end if;

                when RUNNING => 
                    if counter = (COUNTER_TOP-1) then
                        next_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    process (clk, ce, tx_buffer, state, counter, tx_we)
    begin
        if rising_edge(clk) and ce = '1' then 
            if state = RUNNING and counter(3) = '0' then
                -- shift left
                tx_buffer <= tx_buffer(DATA_LENGTH-2 downto 0) & '0';
            elsif tx_we = '1' then
                tx_buffer <= tx_data;
            end if;
        end if;
    end process;

    process (clk, ce, miso, counter, rx_buffer, state)
    begin
        if rising_edge(clk) and ce = '1' and state = RUNNING and counter(3) = '0' then
            -- shift right and append the value of miso at MSB
            rx_buffer <= miso & rx_buffer(DATA_LENGTH-1 downto 1);
        end if;
    end process;

end architecture;