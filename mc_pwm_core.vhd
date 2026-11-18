library ieee;
use ieee.std_logic_1164.all;

entity mc_pwm_core is
    generic (
        G_PWM_PERIOD : positive := 2500 -- 50 MHz / 20 kHz
    );
    port (
        clk       : in  std_logic;
        enable    : in  std_logic;
        duty      : in  natural range 0 to 100;
        pwm_out   : out std_logic
    );
end entity;

architecture rtl of mc_pwm_core is
    signal count : natural range 0 to G_PWM_PERIOD-1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if count = G_PWM_PERIOD-1 then
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    pwm_out <= '1' when enable = '1' and duty > 0 and
                        count < ((duty * G_PWM_PERIOD) / 100)
               else '0';
end architecture;
