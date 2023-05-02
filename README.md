# cp_muscle_cocontraction

This repository contains sample code and data to compute muscle co-contraction as described in the manuscript "MUSCLE COACTIVATION 
DURING GAIT IN CHILDREN WITH AND WITHOUT CEREBRAL PALSY" (under review)

## Dataset
As we are unable to share the patient dataset associated with the 
paper, here we demonstrate the code with a subset of control data 
(typically developping children), see ``cp_muscle_cocontraction/data`` folder


## Prerequisites
- Requires biomechZoo repository (tested using v 1.9.8): https://github.com/PhilD001/biomechZoo
- This repository, stored at https://github.com/PhilD001/cp_muscle_cocontraction

## How to run
- Add the biomechZoo toolbox to your Matlab path
- Add this repository to your Matlab path
- Run the file ``cp_muscle_cocontraction/code/cocontraction_process.m``

## Outputs
- After running the code, a spreadsheet will be available at:
``cp_muscle_cocontraction/Statistics/eventval.xls``
