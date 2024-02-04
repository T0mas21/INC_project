-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Name Surname (xlogin00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal state        : std_logic_vector(1 downto 0);
    signal cnt16        : std_logic_vector(4 downto 0);
    signal cnt8         : std_logic_vector(3 downto 0);
    signal tmp_dout     : std_logic_vector(7 downto 0);
    signal prev_state   : std_logic_vector(1 downto 0);
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        state => state,
        cnt16 => cnt16,
        cnt8 => cnt8,
        DIN => DIN,
        prev_state => prev_state
    );

    process(CLK, RST, DIN)
    begin
        if (RST = '1') then
            DOUT <= (others => '0');
            DOUT_VLD <= '0';
            cnt16 <= (others=>'0');
            cnt8 <= (others=>'0');
            prev_state <= "00";
        elsif (CLK'event) and (CLK = '1') then
            case(state) is
                when "00" => -- nothing
                    cnt16 <= (others=>'0');
                    cnt8 <= (others=>'0');
                    DOUT <= (others=>'0');
                    DOUT_VLD <= '0';
                    prev_state <= "00";

                when "01" => -- start bit
                    cnt16 <= cnt16 + 1;
                    if (cnt16 = "01111") then
                        cnt16 <= (others=>'0');
                        prev_state <= "01";
                    end if;
                    
                when "10" => -- read
                    cnt16 <= cnt16 + 1;
                    if (cnt16 = "00111") then -- read middle of bit
                        tmp_dout(to_integer(unsigned(cnt8))) <= DIN;
                    end if;
                    
                    if (cnt16 = "01111") then   -- bit counter
                        cnt16 <= (others=>'0');
                        cnt8 <= cnt8 + 1;
                    end if;

                    if (cnt8 = "1000") then
                        cnt16 <= (others=>'0');
                        cnt8 <= (others=>'0');
                        prev_state <= "10";
                    end if;

                when "11" => -- end
                    cnt16 <= cnt16 + 1;
                    if (cnt16 = "01111") then
                        cnt16 <= (others=>'0');
                        DOUT_VLD <= '1';
                        DOUT <= tmp_dout;
                        prev_state <= "11";
                    end if;

                when others =>

            end case;
        end if;
    end process;


    --DOUT <= (others => '0');
    --DOUT_VLD <= '0';

end architecture;
