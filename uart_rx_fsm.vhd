-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;



entity UART_RX_FSM is
    port(
       CLK          : in std_logic;
       RST          : in std_logic;
       state        : out std_logic_vector(1 downto 0) := (others => '0');
       prev_state   : in std_logic_vector(1 downto 0) := (others => '0');
       cnt8         : in std_logic_vector(3 downto 0);
       cnt16        : in std_logic_vector(4 downto 0);
       DIN          : in std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is

    --signal state    : std_logic_vector(1 downto 0) := (others => '0');
    --signal cnt16    : std_logic_vector(4 downto 0) := (others => '0');
    --signal cnt8     : std_logic_vector(3 downto 0) := (others => '0');
    --signal tmp_dout : std_logic_vector(7 downto 0);

begin

    
    --FSM
    states: process(CLK, RST, DIN)
    begin
        if (RST = '1') then
            state <= "00";
        elsif (CLK'event) and (CLK = '1') then
                if (DIN = '0' and ( prev_state = "00" or  prev_state = "11" )) then -- nothing
                    state <= "01"; -- -> start bit 
                end if;

                if (cnt16 = "01111" and prev_state = "00" ) then    -- start bit
                    state <= "10";  -- -> read
                end if;

                if (cnt8 = "1000" and prev_state = "01" ) then -- read
                    state <= "11"; -- -> end bit
                end if;

                if (cnt16 = "01111" and prev_state = "10" ) then -- end bit
                    state <= "00"; -- -> nothing
                end if;

        end if;
    end process states;
    --FSM


end architecture;
