# Biquad-Filter-Verilog
A double precision biquad filter (IIR) designed in Verilog HDL.<br>
1 floating point multiplication and 1 floating point adder IP cores are used for biquad equation calculation<br>
Simulation scripts are included. To help you making editions and doing simulations, all signals and registers involved in biquad calculation steps are defined as output of the module, so you can easily check what's going on inside the state machine.
## How to use
To use this filter directly or making editions, just open `iir_design_waveSim.xpr` in Vivado.<br>
`biquadDesignHelper.ipynb` is a notebook written in Python which can help you check whether the filter module can output the correct value as we expected
## State transfer graph (draft)
![State_Transfer_Graph](images/state_transfer_draft.jpg)
## Simulation screenshots
![calculation_simulation](images/calculation_simulation.jpg)
![calculation_simulation2](images/calculation_simulation2.jpg)
![waveform_sim](images/waveform_sim.jpg)
![waveform_sim2](images/waveform_sim2.jpg)
