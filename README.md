# ASAP: Reconciling Asynchronous Real-Time Operations and Proofs of Execution in Simple Embedded Systems

##### ASAP paper (DAC '22)

Embedded devices are increasingly ubiquitous and their importance is hard to overestimate. While they often support safety-critical functions (e.g., in medical devices and sensor-alarm combinations), they are usually implemented under strict cost/energy budgets, using low-end microcontroller units (MCUs) that lack sophisticated security mechanisms. Motivated by this issue, recent work developed architectures capable of generating Proofs of Execution (PoX) for the correct/expected software in potentially compromised low-end MCUs.

In practice, this capability can be leveraged to provide ``integrity from birth'' to sensor data, by binding the sensed results/outputs to an unforgeable cryptographic proof of execution of the expected sensing process. Despite this significant progress, current PoX schemes for low-end MCUs ignore the real-time needs of many applications. In particular, security of current PoX schemes precludes any interrupts during the execution being proved.
We argue that lack of asynchronous capabilities (i.e., interrupts within PoX) can obscure PoX usefulness, as several applications require processing real-time and asynchronous events.

To bridge this gap, we propose, implement, and evaluate an (A)rchitecture for (S)ecure (A)synchronous (P)rocessing in PoX. ASAP is secure under full software compromise, enables asynchronous \PoX, and incurs less hardware overhead than prior work.

## Built upon APEX

ASAP builds upon existing Architecture for Proof of Execution (APEX) and makes important modifications to allow asynchronous capabilities. Instructions to build and simulate ASAP are the same as APEX: https://github.com/sprout-uci/apex