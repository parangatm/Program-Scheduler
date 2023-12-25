# Real-time Multi-Program Scheduler
(Course Project for EC M216A Design of VLSI Circuits and Systems in Fall 2023 taught by Prof. Dejan Markovic)

## Overview
This project addresses the implementation of an Equifilling Program allocation algorithm designed for a Compute Array (128x128). Motivated by the need for a real-time program scheduler within a larger processor, this algorithm efficiently allocates incoming programs, considering varying width and height constraints. The objective is to achieve a power- and area-efficient implementation, subject to a strict processing latency constraint of 8 clock cycles.

## Algorithm
The multi-program placement algorithm divides the 128x128 region into 13 fixed-height strips, accommodating programs with heights ranging from 4 to 16. Leveraging the Equifill algorithm, this heuristic approach optimally fills strips with closer heights alternately, ensuring balanced distribution and reserving space for larger blocks. The algorithm strategically checks the feasibility of program rectangle placement, updating the occupied width array accordingly.

This Equifill algorithm prioritizes mean utilization over best-case utilization, enhancing overall array efficiency. It strategically fills strips, considering the occupied width of adjacent rows and maintaining space for larger blocks towards the right. The placement algorithm ensures a power- and area-efficient solution, while the Equifill search method significantly increases the mean utilization percentage of the array.

## Design Highlights
(More details in the comments in the design)
- Six-stage pipeline to utilize the 8 clock cycle latency, preventing false placement of programs
- Clock and reset controller strategically triggers paired stages, enhancing the frequency
- Memory operations in distinct sequential stages to ensure that data correctness is upheld
- First half of the design (I,A,B,C) samples input, reads memory and prepares for computation
- Second half (D,E,F,O) executes computation, updates memory and samples the output

### Inputs:

- height_i: 5-bit incoming program height (4 to 16)
- width_i: 5-bit incoming program width (4 to 16)
- clk_i: 1-bit clock
- rst_i: 1-bit reset

### Outputs:

- strike_o: 4-bit strike counter
- index_x_o: 8-bit left-bottom index (horizontal)
- index_y_o: 8-bit left-bottom index (vertical)
- Occupied_Width: 8-bit register array with 13 elements indicating the occupied width of all rows

## Performance Summary
| Max f<sub>clk</sub><br>[MHz] 	| Area<br>[um<sup>2</sup>]   	| Energy<br>[pJ] 	| Hold Time Slack<br>[ps] 	|
|-------------------	|-----------------	|----------------	|-------------------------	|
| 6666.67 MHz       	| 3538.192845 um<sup>2</sup> 	| 1.5235 pJ      	| 71.1 ps                 	|
