library ieee;
use ieee.std_logic_1164.all;

entity mc_input_sync is
    port (
        clk          : in  std_logic;
        switches_in  : in  std_logic_vector(9 downto 0);
        keys_n_in    : in  std_logic_vector(1 downto 0);
        switches_out : out std_logic_vector(9 downto 0);
        start_pulse  : out std_logic;
        reset_pulse  : out std_logic
    );
end entity;

architecture rtl of mc_input_sync is
    signal sw_meta, sw_sync : std_logic_vector(9 downto 0) := (others => '0');
    signal key_meta, key_sync, key_prev : std_logic_vector(1 downto 0) := (others => '1');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sw_meta  <= switches_in;
            sw_sync  <= sw_meta;
            key_meta <= keys_n_in;
            key_sync <= key_meta;
            key_prev <= key_sync;
        end if;
    end process;

    switches_out <= sw_sync;
    start_pulse <= '1' when key_sync(0) = '0' and key_prev(0) = '1' else '0';
    reset_pulse <= '1' when key_sync(1) = '0' and key_prev(1) = '1' else '0';
end architecture;
