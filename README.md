Purpose
=============
This is the code the challenge"CHALEARN Gesture Challenge“.
https://www.kaggle.com/c/GestureChallenge
******************************************************************************************************
Gist:Extended MHI + MSE
******************************************************************************************************
by Di WU: stevenwudi@gmail.com, 2012/03/27




******************************************************************************************************

Dependency:
******************************************************************************************************
(1) mmread folder: this folder is in the original sample code to read video files which can be downloaded at: http://www.kaggle.com/c/GestureChallenge/Data
					(may not be necessary for newer version of matlab
			
Train
-------
run_this.m is the m-file to run, simply change data_dir and resu_file to the desirable directories

Usage Instructions
-------
To change the development or validation batches, change the line 32 &33 in prepare_final_resu.m.


Note
-------
- whether to use the lossi-compressed data or the quasi-lossless compressed data
We used the quasi-lossless compressed data downloaded from the kaggle website.



Running Time
-------
Our experiments were done on a Intel 2-core 3.0 GHz, 4GB memory desktop in a single thread running MATLAB
and the average training and testing time for a single batch is around 1000 seconds (including the preprocessing for
the denoise of depth images).
	
