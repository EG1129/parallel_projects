SEE "ISSUES" FOR OUTPUT SCREENSHOTS

Set of projects designed for CMPT 471-Parallel computing using CUDA and MPi to improve performance

includes:
Password cracker designed serially with c++ and then parallely with MPI. Overall results indicate that using MPI and 4 cores improves performance by about 3.5x.

Parallelization of matrix multiplication using CUDA. For the 2000×200 matrix multiplication, the serial version took 100,000 ms, while the CUDA implementation completed the same operation in just 341 ms. This corresponds to an enormous speedup of about 293×, meaning the GPU is nearly 300 times faster than the CPU for this workload.

Parallelization of Dijkstra algorithm using CUDA. The CUDA version achieved a 1.5× speedup over the serial implementation, reducing execution time from 600 ms to 400 ms. This represents a 50% performance improvement.”
