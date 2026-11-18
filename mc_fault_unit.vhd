library ieee;
use ieee.std_logic_1164.all;

entity mc_fault_unit is
    port (
        switches  : in  std_logic_vector(9 downto 0);
        fault_now : out std_logic;
        fault_id  : out natural range 0 to 4
    );
end entity;

architecture rtl of mc_fault_unit is
begin
    process(switches)
    begin
        -- Priority: emergency stop, overcurrent, overtemperature, undervoltage.
        if switches(3) = '1' then
            fault_id <= 1;
        elsif switches(4) = '1' then
            fault_id <= 2;
        elsif switches(5) = '1' then
            fault_id <= 3;
        elsif switches(6) = '1' then
            fault_id <= 4;
        else
            fault_id <= 0;
        end if;
    end process;

    fault_now <= '1' when switches(6 downto 3) /= "0000" else '0';
end architecture;
