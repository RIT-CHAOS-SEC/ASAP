# ASAP: Reconciling Asynchronous Real-Time Operations and Proofs of Execution in Simple Embedded Systems:

##### ASAP paper (DAC '22): https://arxiv.org/abs/2206.02894

Embedded devices are increasingly ubiquitous and their importance is hard to overestimate. While they often support safety-critical functions (e.g., in medical devices and sensor-alarm combinations), they are usually implemented under strict cost/energy budgets, using low-end microcontroller units (MCUs) that lack sophisticated security mechanisms. Motivated by this issue, recent work developed architectures capable of generating Proofs of Execution (PoX) for the correct/expected software in potentially compromised low-end MCUs. In practice, this capability can be leveraged to provide "integrity from birth" to sensor data, by binding the sensed results/outputs to an unforgeable cryptographic proof of execution of the expected sensing process. Despite this significant progress, current PoX schemes for low-end MCUs ignore the real-time needs of many applications. In particular, security of current PoX schemes precludes any interrupts during the execution being proved. We argue that lack of asynchronous capabilities (i.e., interrupts within PoX) can obscure PoX usefulness, as several applications require processing real-time and asynchronous events. To bridge this gap, we propose, implement, and evaluate an Architecture for Secure Asynchronous Processing in PoX (ASAP). ASAP is secure under full software compromise, enables asynchronous PoX, and incurs less hardware overhead than prior work. 

## Dependencies Installation

Environment (processor and OS) used for development and verification:
Intel i7-3770
Ubuntu 18.04.3 LTS

Dependencies on Ubuntu:

		sudo apt-get install bison pkg-config gawk clang flex gcc-msp430 iverilog tcl-dev
		cd scripts
		sudo make install

## Building ASAP Software
To generate the Microcontroller program memory configuration containing VRASED trusted software (SW-Att) and sample applications we are going to use the Makefile inside the scripts directory:

        cd scripts

This repository accompanies 3 test-cases: test_valid_ISR, test_invalid_ISR, test_write_IVT. (See [Description of Provided test-cases] for details on each test-case)
These test-cases correspond to one successfull proof of execution (PoX) and 3 cases where PoX fails due to a violation that could be used to attack the correctness of the execution.
To build ASAP for a specific test-case run:

        make "name of test-case"

For instance:

        make test_valid_ISR

to build the software including the binaries of test_valid_ISR test-case.
Note that this step will not run any simulation, but simply generate the MSP430 binaries corresponding to the test-case of choice.
As a result of the build, two files pmem.mem and smem.mem should be created inside msp_bin directory:

- pmem.mem program memory contents corresponding the application binaries

- smem.mem contains SW-Att binaries.

In the next steps, during synthesis, these files will be loaded to the MSP430 memory when we either: deploy ASAP on the FPGA or run ASAP simulation using VIVADO simulation tools.

If you want to clean the built files run:

        make clean

        Note: Latest Build tested using msp430-gcc (GCC) 4.6.3 2012-03-01

To test ASAP with a different application you will need to repeat these steps to generate the new "pmem.mem" file and re-run synthesis.

## Creating an ASAP project on Vivado and Running Synthesis

This is an example of how to synthesize and prototype ASAP using Basys3 FPGA and XILINX Vivado v2019.2 (64-bit) IDE for Linux

- Vivado IDE is available to download at: https://www.xilinx.com/support/download.html

- Basys3 Reference/Documentation is available at: https://reference.digilentinc.com/basys3/refmanual

#### Creating a Vivado Project for ASAP

1 - Clone this repository;

2 - Follow the steps in [Building ASAP Software](#building-ASAP-software) to generate .mem files for the application of your choice.

2- Start Vivado. On the upper left select: File -> New Project

3- Follow the wizard, select a project name and location. In project type, select RTL Project and click Next.

4- In the "Add Sources" window, select Add Files and add all *.v and *.mem files contained in the following directories of this reposiroty:

        openmsp430/fpga
        openmsp430/msp_core
        openmsp430/msp_memory
        openmsp430/msp_periph
        /vrased/hw-mod
        /msp_bin

and select Next.

Note that /msp_bin contains the pmem.mem and smem.mem binaries, generated in step [Building ASAP Software].

5- In the "Add Constraints" window, select add files and add the file

        openmsp430/contraints_fpga/Basys-3-Master.xdc

and select Next.

        Note: this file needs to be modified accordingly if you are running ASAP in a different FPGA.

6- In the "Default Part" window select "Boards", search for Basys3, select it, and click Next.

        Note: if you don't see Basys3 as an option you may need to download Basys3 to your Vivado installation.

7- Select "Finish". This will conclude the creation of a Vivado Project for ASAP.

Now we need to configure the project for systhesis.

8- In the PROJECT MANAGER "Sources" window, search for openMSP430_fpga (openMSP430_fpga.v) file, right click it and select "Set as Top".
This will make openMSP430_fpga.v the top module in the project hierarchy. Now its name should appear in bold letters.

9- In the same "Sources" window, search for openMSP430_defines.v file, right click it and select Set File Type and, from the dropdown menu select "Verilog Header".

Now we are ready to synthesize openmsp430 with ASAP hardware the following step might take several minutes.

10- On the left menu of the PROJECT MANAGER click "Run Synthesis", select execution parameters (e.g, number of CPUs used for synthesis) according to your PC's capabilities.

11- If synthesis succeeds, you will be prompted with the next step to "Run Implementation". You *do not* to "Run Implementation" if you only want simulate ASAP.
"Run implementation" is only necessary if your purpose is to deploy ASAP on an FPGA.

If you want to deploy ASAP on an FPGA, continue following the instructions on [Deploying ASAP on Basys3 FPGA].

If you want to simulate ASAP using VIVADO sim-tools, continue following the instructions on [Running ASAP on Vivado Simulation Tools].

## Running ASAP on Vivado Simulation Tools

After completing the steps 1-10 in [Creating a Vivado Project for ASAP]:

1- In Vivado, click "Add Sources" (Alt-A), then select "Add or create simulation sources", click "Add Files", and select everything inside openmsp430/simulation.

2- Now, navigate "Sources" window in Vivado. Search for "tb_openMSP430_fpga", and *In "Simulation Sources" tab*, right-click "tb_openMSP430_fpga.v" and set its file type as top module.

3- Go back to Vivado window and in the "Flow Navigator" tab (on the left-most part of Vivado's window), click "Run Simulation", then "Run Behavioral Simulation".

4- On the newly opened simulation window, select a time span for your simulation to run (see times for each default test-case below) and the press "Shift+F2" to run.

5- In the green wave window you will see values for several signals. The imporant ones are "exec", and "pc[15:0]". pc cointains the program counter value. exec corresponds to the value of ASAP's exec flag, as described in the paper.

In Vivado simulation, for all test-cases provided by default, the final value of pc[0:15] should correspond to the instruction address inside "success" function (i.e., the program should halt inside "success" function).

To determine the address of an instruction, e.g, addresses of the "success" function as well start and end addresses of ER (values of ER_min and ER_max, per ASAP's paper) one can check the compilation file at scripts/tmp-build/XX/vrased.lst  (where XX is the name of the test-case, i.e., if you ran "make simple_app", XX=simple_app). In this file search for the name of the function of interest, e.g., "success" or "dummy_function", etc.

#### NOTE: To simulate a different test-case you need to re-run "make test-case_name" to generate the corresponding pmem.mem file and re-run the synthesis step (step 10 in [Creating a Vivado Project for ASAP]) on Vivado. 

## Deploying ASAP on Basys3 FPGA

1- After Step 10 in [Creating a Vivado Project for ASAP], select "Run Implementation" and wait until this process completes (typically takes around 1 hour).

2- If implementation succeeds, you will be prompted with another window, select option "Generate Bitstream" in this window. This will generate the bitstream that is used to step up the FPGA according to VRASED hardware and software.

3- After the bitstream is generated, select "Open Hardware Manager", connect the FPGA to you computer's USB port and click "Auto-Connect".
Your FPGA should be now displayed on the hardware manager menu.

        Note: if you don't see your FPGA after auto-connect you might need to download Basys3 drivers to your computer.

4- Right-click your FPGA and select "Program Device" to program the FPGA.

## Description of Provided test-cases

	For details on how ASAP controls the exec flag to generate unforgeable proofs of execution (PoX) please check ASAP paper. 

#### 1- test_valid_ISR:

Corresponds to the test that the BTN0 ISR is valid and is selectively linked into the ER region. When a BTN0 interrupt occurs, no violation occurs.

#### 2- test_invalid_ISR:

For this test case the BTN0 ISR is not expected since it is not selectively linked. When a BTN0 interrupt occurs in this case, a violation occurs and is detected by ASAP hardware.

#### 3- test_write_IVT:

In the final case, a violation occurs due to an attempt to modify the interrupt vector table (IVT). When this occurs, a voilation occurs and is detected by ASAP hardware.

## Running ASAP Verification

To check HW-Mod against VRASED and ASAP LTL subproperties using NuSMV run:

        make verify