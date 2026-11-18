
library ieee;
use ieee.std_logic_1164.all;

entity mc_hex_decoder is
    port (
        symbol : in  natural range 0 to 23;
        hex    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of mc_hex_decoder is

    type segment_table_t is array (0 to 23) of
        std_logic_vector(6 downto 0);

    constant SEGMENT_TABLE : segment_table_t := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000", -- 9
        "0001000", -- A
        "0000011", -- b
        "1000110", -- C
        "0100001", -- d
        "0000110", -- E
        "0001110", -- F
        "0001001", -- H
        "1000111", -- L
        "0100011", -- o
        "0001100", -- P
        "0101111", -- r
        "0010010", -- S
        "0000111", -- t
        "1111111"  -- Blank
    );

begin

    hex <= '1' & SEGMENT_TABLE(symbol);

end architecture;
