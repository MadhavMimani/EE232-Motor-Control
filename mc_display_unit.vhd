
library ieee;
use ieee.std_logic_1164.all;

entity mc_display_unit is
    port (
        state_code : in  std_logic_vector(2 downto 0);
        duty       : in  natural range 0 to 100;
        direction  : in  std_logic;
        fault_code : in  natural range 0 to 4;

        HEX0 : out std_logic_vector(7 downto 0);
        HEX1 : out std_logic_vector(7 downto 0);
        HEX2 : out std_logic_vector(7 downto 0);
        HEX3 : out std_logic_vector(7 downto 0);
        HEX4 : out std_logic_vector(7 downto 0);
        HEX5 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture structural of mc_display_unit is

    signal s0, s1, s2, s3, s4, s5 :
        natural range 0 to 23 := 23;

begin

    process(state_code, duty, direction, fault_code)
        variable h, t, u : natural;
    begin

        s0 <= 23;
        s1 <= 23;
        s2 <= 23;
        s3 <= 23;
        s4 <= 23;
        s5 <= 23;

        h := duty / 100;
        t := (duty mod 100) / 10;
        u := duty mod 10;

        case state_code is

            when "000" =>
                s4 <= 16; -- H
                s3 <= 14; -- E
                s2 <= 17; -- L
                s1 <= 17; -- L
                s0 <= 18; -- o


            when "001" =>
                s5 <= 21; -- S
                s4 <= 22; -- t
                s3 <= 10; -- A
                s2 <= 20; -- r


            when "010" | "101" | "110" | "111" =>

                if direction = '0' then
                    s5 <= 15; -- F: Forward
                else
                    s5 <= 20; -- r: Reverse
                end if;

                s4 <= 19; -- P

                s3 <= h;  -- Hundreds
                s2 <= t;  -- Tens
                s1 <= u;  -- Units


            when "011" =>
                s5 <= 21; -- S
                s4 <= 22; -- t
                s3 <= 18; -- o
                s2 <= 19; -- P


            
            when "100" =>
                s5 <= 15; -- F
                s1 <= 0;  -- 0
                s0 <= fault_code;


            when others =>
                null;

        end case;

    end process;


    U0: entity work.mc_hex_decoder
        port map(symbol => s0, hex => HEX0);

    U1: entity work.mc_hex_decoder
        port map(symbol => s1, hex => HEX1);

    U2: entity work.mc_hex_decoder
        port map(symbol => s2, hex => HEX2);

    U3: entity work.mc_hex_decoder
        port map(symbol => s3, hex => HEX3);

    U4: entity work.mc_hex_decoder
        port map(symbol => s4, hex => HEX4);

    U5: entity work.mc_hex_decoder
        port map(symbol => s5, hex => HEX5);

end architecture;
