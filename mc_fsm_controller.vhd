
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mc_fsm_controller is
    generic (
        G_RAMP_TICK     : positive := 500000;
        G_REV_WAIT_TICK : positive := 500000
    );
    port (
        clk            : in  std_logic;
        start_pulse    : in  std_logic;
        reset_pulse    : in  std_logic;
        switches       : in  std_logic_vector(9 downto 0);
        fault_now      : in  std_logic;
        fault_id       : in  natural range 0 to 4;
        state_code     : out std_logic_vector(2 downto 0);
        duty_out       : out natural range 0 to 100;
        direction_out  : out std_logic;
        fault_code_out : out natural range 0 to 4;
        fault_history  : out std_logic
    );
end entity;

architecture rtl of mc_fsm_controller is

    type state_t is (
        IDLE,
        STARTING,
        RUNNING,
        STOPPING,
        FAULT,
        REVERSING_DOWN,
        REVERSING_WAIT,
        REVERSING_UP
    );

    signal state : state_t := IDLE;

    signal ramp_count : natural range 0 to G_RAMP_TICK-1 := 0;
    signal wait_count : natural range 0 to G_REV_WAIT_TICK-1 := 0;

    signal target_duty  : natural range 25 to 100 := 25;
    signal current_duty : natural range 0 to 100 := 0;

    signal direction_reg : std_logic := '0';

    signal fault_code : natural range 0 to 4 := 0;
    signal last_fault : natural range 0 to 4 := 0;

begin

    process(clk)
        variable ramp_tick : boolean;
    begin
        if rising_edge(clk) then

            case switches(1 downto 0) is
                when "00" =>
                    target_duty <= 25;
                when "01" =>
                    target_duty <= 50;
                when "10" =>
                    target_duty <= 75;
                when others =>
                    target_duty <= 100;
            end case;

            if ramp_count = G_RAMP_TICK-1 then
                ramp_count <= 0;
                ramp_tick := true;
            else
                ramp_count <= ramp_count + 1;
                ramp_tick := false;
            end if;

            if fault_now = '1' then

                if state /= FAULT then
                    fault_code <= fault_id;
                    last_fault <= fault_id;
                end if;

                state <= FAULT;
                current_duty <= 0;
                ramp_count <= 0;
                wait_count <= 0;

            elsif state = FAULT then

                current_duty <= 0;
                ramp_count <= 0;
                wait_count <= 0;

                if reset_pulse = '1' then
                    state <= IDLE;
                    fault_code <= 0;
                end if;

            else

                case state is

                    when IDLE =>

                        current_duty <= 0;
                        ramp_count <= 0;
                        wait_count <= 0;

                        if start_pulse = '1' then
                            direction_reg <= switches(2);
                            state <= STARTING;
                        end if;


                    when STARTING =>

							 if start_pulse = '1' then
								  state <= STOPPING;

							 elsif switches(2) /= direction_reg then
								  state <= REVERSING_DOWN;

							 elsif current_duty = target_duty then
								  state <= RUNNING;

							 elsif ramp_tick then

								  if current_duty < target_duty then
										current_duty <= current_duty + 1;

								  elsif current_duty > target_duty then
										current_duty <= current_duty - 1;
								  end if;

							 end if;


                    when RUNNING =>

                        if start_pulse = '1' then
                            state <= STOPPING;

                        elsif switches(2) /= direction_reg then
                            state <= REVERSING_DOWN;

                        elsif ramp_tick then

                            if current_duty < target_duty then
                                current_duty <= current_duty + 1;

                            elsif current_duty > target_duty then
                                current_duty <= current_duty - 1;
                            end if;

                        end if;


                    when REVERSING_DOWN =>

                        if start_pulse = '1' then
                            state <= STOPPING;

                        elsif switches(2) = direction_reg then
                            state <= REVERSING_UP;

                        elsif ramp_tick then

                            if current_duty > 1 then
                                current_duty <= current_duty - 1;

                            else
                                current_duty <= 0;
                                wait_count <= 0;
                                state <= REVERSING_WAIT;
                            end if;

                        end if;


							 when REVERSING_WAIT =>

							 current_duty <= 0;
							 ramp_count <= 0;

							 if start_pulse = '1' then
								  state <= IDLE;
								  wait_count <= 0;

							 elsif wait_count = G_REV_WAIT_TICK-1 then

								  wait_count <= 0;
								  direction_reg <= switches(2);
								  state <= REVERSING_UP;

							 else
								  wait_count <= wait_count + 1;
							 end if;


                    when REVERSING_UP =>

                        if start_pulse = '1' then
                            state <= STOPPING;

                        elsif switches(2) /= direction_reg then
                            state <= REVERSING_DOWN;

                        elsif ramp_tick then

                            if current_duty < target_duty then
                                current_duty <= current_duty + 1;

                            elsif current_duty > target_duty then
                                current_duty <= current_duty - 1;

                            else
                                state <= RUNNING;
                            end if;

                        end if;


                    when STOPPING =>

                        if ramp_tick then

                            if current_duty > 1 then
                                current_duty <= current_duty - 1;

                            else
                                current_duty <= 0;
                                state <= IDLE;
                            end if;

                        end if;


                    when others =>

                        state <= IDLE;
                        current_duty <= 0;
                        ramp_count <= 0;
                        wait_count <= 0;

                end case;
            end if;
        end if;
    end process;


    with state select state_code <=
        "000" when IDLE,
        "001" when STARTING,
        "010" when RUNNING,
        "011" when STOPPING,
        "100" when FAULT,
        "101" when REVERSING_DOWN,
        "110" when REVERSING_WAIT,
        "111" when REVERSING_UP;

    duty_out <= current_duty;
    direction_out <= direction_reg;
    fault_code_out <= fault_code;

    fault_history <= '1' when last_fault /= 0 else '0';

end architecture;
