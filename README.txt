Group name: xiaozhuwudi
Author:Wudi, Zhufan
Release date: March 20th, 2012
----------------------------------------------------


Submission instructions:
- installation instructions
    run_this.m is the m-file to run, simply change data_dir and resu_file
to the desirable directories

- usage instructions
    To change the development or validation batches, change the line 32 &33 in
prepare_final_resu.m.

- whether to use the lossi-compressed data or the quasi-lossless compressed data
We used the quasi-lossless compressed data downloaded from the kaggle website.

- compute power you used (processors, memory, disk space) and how long it 
took to process the validation and final evaluation data
Our experiments were done on a Intel 2-core 3.0 GHz,
4GB memory desktop in a single thread running MATLAB
and the average training and testing time for a single batch is
around 1000 seconds (including the preprocessing for the denoise of depth images).
