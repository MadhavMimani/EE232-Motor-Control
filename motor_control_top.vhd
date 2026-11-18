
library ieee;
use ieee.std_logic_1164.all;

entity motor_control_top is
    generic (
        G_PWM_PERIOD     : positive := 2500;
        G_RAMP_TICK      : positive := 500000;
        G_REV_WAIT_TICK  : positive := 500000
    );
    port (
        MAX10_CLK1_50 : in  std_logic;
        KEY           : in  std_logic_vector(1 downto 0);
        SW            : in  std_logic_vector(9 downto 0);
        LEDR          : out std_logic_vector(9 downto 0);

        HEX0          : out std_logic_vector(7 downto 0);
        HEX1          : out std_logic_vector(7 downto 0);
        HEX2          : out std_logic_vector(7 downto 0);
        HEX3          : out std_logic_vector(7 downto 0);
        HEX4          : out std_logic_vector(7 downto 0);
        HEX5          : out std_logic_vector(7 downto 0);

        MOTOR_PWM     : out std_logic;
        MOTOR_IN1     : out std_logic;
        MOTOR_IN2     : out std_logic
    );
end entity;

architecture structural of motor_control_top is

    signal sw_clean : std_logic_vector(9 downto 0);

    signal start_pulse, reset_pulse : std_logic;

    signal fault_now : std_logic;
    signal fault_id : natural range 0 to 4;

    signal state_code : std_logic_vector(2 downto 0);
    signal duty : natural range 0 to 100;
    signal direction : std_logic;

    signal fault_code : natural range 0 to 4;
    signal fault_history : std_logic;

    signal motor_active : std_logic;
    signal pwm_signal : std_logic;

    signal reversing : std_logic;

begin


    U_INPUTS: entity work.mc_input_sync
        port map (
            clk          => MAX10_CLK1_50,
            switches_in  => SW,
            keys_n_in    => KEY,
            switches_out => sw_clean,
            start_pulse  => start_pulse,
            reset_pulse  => reset_pulse
        );



    U_FAULTS: entity work.mc_fault_unit
        port map (
            switches  => sw_clean,
            fault_now => fault_now,
            fault_id  => fault_id
        );



    U_CONTROL: entity work.mc_fsm_controller
        generic map (
            G_RAMP_TICK     => G_RAMP_TICK,
            G_REV_WAIT_TICK => G_REV_WAIT_TICK
        )
        port map (
            clk            => MAX10_CLK1_50,
            start_pulse    => start_pulse,
            reset_pulse    => reset_pulse,
            switches       => sw_clean,
            fault_now      => fault_now,
            fault_id       => fault_id,
            state_code     => state_code,
            duty_out       => duty,
            direction_out  => direction,
            fault_code_out => fault_code,
            fault_history  => fault_history
        );



    motor_active <= '1' when
        state_code = "001" or
        state_code = "010" or
        state_code = "011" or
        state_code = "101" or
        state_code = "110" or
        state_code = "111"
        else '0';


    
    -- PWM GENERATOR
    

    U_PWM: entity work.mc_pwm_core
        generic map (
            G_PWM_PERIOD => G_PWM_PERIOD
        )
        port map (
            clk     => MAX10_CLK1_50,
            enable  => motor_active and (not fault_now),
            duty    => duty,
            pwm_out => pwm_signal
        );



    MOTOR_IN1 <= pwm_signal when
        direction = '0' and
        motor_active = '1' and
        fault_now = '0'
        else '0';

    MOTOR_IN2 <= pwm_signal when
        direction = '1' and
        motor_active = '1' and
        fault_now = '0'
        else '0';


    MOTOR_PWM <= pwm_signal;


    
    -- LED INDICATORS
    

    LEDR(0) <= pwm_signal;

    
    LEDR(1) <= '1' when
        motor_active = '1' and
        direction = '0' and
        fault_now = '0'
        else '0';

  
    LEDR(2) <= '1' when
        motor_active = '1' and
        direction = '1' and
        fault_now = '0'
        else '0';

  
    LEDR(3) <= '1' when state_code = "001" else '0';
    LEDR(4) <= '1' when state_code = "000" else '0';
    LEDR(5) <= '1' when state_code = "010" else '0';
    LEDR(6) <= '1' when state_code = "011" else '0';
    LEDR(7) <= '1' when state_code = "100" else '0';

 
    LEDR(8) <= fault_history;

   
    reversing <= '1' when
        state_code = "101" or
        state_code = "110" or
        state_code = "111"
        else '0';

    LEDR(9) <= reversing;


 
    -- SEVEN-SEGMENT DISPLAY


    U_DISPLAY: entity work.mc_display_unit
        port map (
            state_code => state_code,
            duty       => duty,
            direction  => direction,
            fault_code => fault_code,
            HEX0       => HEX0,
            HEX1       => HEX1,
            HEX2       => HEX2,
            HEX3       => HEX3,
            HEX4       => HEX4,
            HEX5       => HEX5
        );

end architecture;
