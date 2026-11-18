# EE232 – FPGA-Based DC Motor Control System

A modular VHDL-based DC motor control system implemented on the **Terasic DE10-Lite FPGA board** using the MAX 10 FPGA and an L298N motor driver.

The project focuses on controlled motor operation, PWM-based speed regulation, gradual acceleration and deceleration, direction reversal, and fault handling.

## Project Overview

This system controls a 12V DC motor through an L298N H-bridge motor driver. The DE10-Lite FPGA generates the control signals and manages the motor's operating states.

The design is divided into independent VHDL modules, making the system easier to understand, test, and maintain.

### Key Features

- PWM-based motor speed control.
- Four selectable duty-cycle levels: 25%, 50%, 75%, and 100%.
- Gradual acceleration and deceleration.
- Forward and reverse motor operation.
- Controlled direction reversal with a zero-duty interval.
- Fault detection and emergency shutdown.
- Fault identification and fault-history indication.
- Six-digit seven-segment status display.
- Modular and reusable VHDL architecture.

## Hardware Used

| Component | Specification |
|---|---|
| FPGA board | Terasic DE10-Lite |
| FPGA device | Intel MAX 10 |
| Clock frequency | 50 MHz |
| Motor driver | L298N |
| Motor | 12V DC motor |
| Motor supply | External 12V supply |

## System Architecture

The design consists of the following functional modules:

| VHDL Module | Function |
|---|---|
| `motor_control_top.vhd` | Top-level module connecting the system components |
| `mc_pwm_core.vhd` | Generates the PWM signal |
| `mc_input_sync.vhd` | Synchronizes switches and push-button inputs |
| `mc_fsm_controller.vhd` | Controls motor states, speed ramping, and direction reversal |
| `mc_fault_unit.vhd` | Detects and identifies fault conditions |
| `mc_display_unit.vhd` | Determines the status information shown on the seven-segment displays |
| `mc_hex_decoder.vhd` | Converts display symbols into seven-segment patterns |

## Motor Speed Control

The PWM module operates using the 50 MHz FPGA clock.

The default PWM period is 2500 clock cycles:

\[
f_{PWM}=\frac{50\,MHz}{2500}=20\,kHz
\]

The motor speed is controlled by changing the PWM duty cycle.

| Switches SW[1:0] | Target Duty Cycle |
|---|---:|
| 00 | 25% |
| 01 | 50% |
| 10 | 75% |
| 11 | 100% |

The controller gradually changes the duty cycle rather than applying the target value instantaneously.

With the default ramp interval of 500,000 clock cycles, each 1% duty-cycle adjustment takes approximately 10 ms.

## Direction Control

The system supports forward and reverse operation.

Direction reversal follows a controlled sequence:

1. Gradually decrease the current duty cycle.
2. Bring the duty cycle down to zero.
3. Wait for a short interval.
4. Change the motor direction.
5. Gradually increase the duty cycle towards the selected target.

This avoids abruptly switching the motor direction while it is operating.

## Fault Handling

The fault unit monitors four simulated fault inputs.

| Switch | Fault Condition | Fault Code |
|---|---|---:|
| SW3 | Emergency stop | 1 |
| SW4 | Overcurrent | 2 |
| SW5 | Overtemperature | 3 |
| SW6 | Undervoltage | 4 |

When a fault is detected, the controller immediately enters the FAULT state and sets the motor duty cycle to zero.

The fault must be cleared before the system can be reset to IDLE.

**Note:** These fault conditions are currently simulated using FPGA switches; they are not measurements from physical current, temperature, or voltage sensors.

## Seven-Segment Display

The display provides information about the current operating state.

| Operating State | Display |
|---|---|
| IDLE | HELLo |
| STARTING | StAr |
| RUNNING – Forward | FP followed by duty value |
| RUNNING – Reverse | rP followed by duty value |
| STOPPING | StOP |
| FAULT | F0 followed by fault code |

The display also indicates the direction and current duty-cycle value during operation and reversal.

## Repository Structure

```text
EE232-Motor-Control/
│
├── motor_control_top.vhd
├── mc_pwm_core.vhd
├── mc_input_sync.vhd
├── mc_fsm_controller.vhd
├── mc_fault_unit.vhd
├── mc_display_unit.vhd
├── mc_hex_decoder.vhd
│
└── README.md
```

Quartus project and constraint files can be added alongside the source files.

## Development Environment

- HDL: VHDL
- FPGA development software: Intel Quartus Prime
- Target board: Terasic DE10-Lite
- Motor driver: L298N

## Future Improvements

- Integrate physical current and temperature sensing.
- Add closed-loop speed control using motor feedback.
- Implement encoder-based RPM measurement.
- Add simulation testbenches for individual modules.
- Document complete FPGA pin assignments and hardware connections.

---

**Project:** EE232 – Motor Control System  
**Platform:** DE10-Lite FPGA  
**HDL:** VHDL
