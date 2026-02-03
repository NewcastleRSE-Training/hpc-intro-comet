---
title: Running a parallel job (alternative episode)
teaching: 30
exercises: 60
---



::::::::::::::::::::::::::::::::::::::: objectives

- Distinguish between job arrays and MPI
- Download prime generator program
- Prepare a job submission script for the parallel executable.
- Launch jobs with parallel execution.
- Record and summarize the timing and accuracy of jobs.
- Describe the relationship between job parallelism and performance.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- What is the difference between array jobs and MPI?
- What benefits arise from parallel execution?
- What are the limits of gains from execution in parallel?

::::::::::::::::::::::::::::::::::::::::::::::::::

In the previous episode we mentioned the use of the Message Passing Interface (MPI)
to accomplish parallelisation. While array jobs allow us to launch several instances
of the same program, but with different data, across several nodes, MPI allows
a single task to be distributed over several CPU cores.

It is thus possible to use array jobs in conjunction with MPI. 

:::::::::::::::::::::::::::::::::::::::::  callout

## What is MPI?

The Message Passing Interface is a set of tools which allow multiple tasks
running simultaneously to communicate with each other.
Typically, a single executable is run multiple times, possibly on different
machines, and the MPI tools are used to inform each instance of the
executable about its sibling processes, and which instance it is.
MPI also provides tools to allow communication between instances to
coordinate work, exchange information about elements of the task, or to
transfer data.
An MPI instance typically has its own copy of all the local variables.

::::::::::::::::::::::::::::::::::::::::::::::::::

In this episode we will use two small programs, written in C, to 
calculate the number of primes found between two given numbers. One of
the programs calculates prime and by using MPI spreads the job over several 
CPU cores while the other program doesn't. After running both these programs
one can compare their output to see the difference in efficiency.

If you disconnected, log back in to the cluster.

```bash
[you@laptop:~]$ ssh yourUsername@cluster.hpc-carpentry.org
```

:::: instructor

Ideally the code for this episode should be pre-compiled and made available for
students to download. We have found that expecting students to write or even 
compile code causes information overload and confusion. 

The code and scripts to compile can be downloaded from [https://github.com/NewcastleRSE-Training/HPC_Training_Example_Jobs](https://github.com/NewcastleRSE-Training/HPC_Training_Example_Jobs).
After compiling the two versions of the program, copy it to a place where students
can copy or download it from.

The binaries of the two programs will be very small so the fact that there would
be duplication if all the students copy the binaries to their own working directories
should not really matter. In doing it this way, students will also get the 
opportunity to submit a job where the program they are using is in their local 
directory (rather than loading a module).

::::

:::: spoiler

## Compiling the prime calculator from code

Only do this if pre-compiled binaries of the programs have not been made available to you.

### Requirements
- GCC

### Steps
- Download code
- Compile code
- Copy binaries to home directory

If you disconnected, log back in to the cluster.

```bash
[you@laptop:~]$ ssh yourUsername@cluster.hpc-carpentry.org
```

Clone the repository

```bash
[you@laptop:~]$ git clone git@github.com:NewcastleRSE-Training/HPC_Training_Example_Jobs.git
```

Compile the code.

```bash
[you@laptop:~]$ cd HPC_Training_Example/c
[you@laptop:~]$ module load GCC
[you@laptop:~]$ ./compile.sh
```

```output
Compiling primes.c function...
Compiling single process version...
Creating executable binary...
-rwxr-x--- 1 username group 17472 Jan 23 11:14 single_gcc

Compiling primes.c function...
Compiling single process version...
Creating executable binary...
-rwxr-x--- 1 username group 7176 Jan 23 11:14 single_aocc

Compiling primes.c function...
Compiling MPI multi-process version...
Creating executable binary...
-rwxr-x--- 1 username group 17096 Jan 23 11:14 multi
[you@laptop:~]$ 

```

Move (or copy) the binaries to your home directory


::::


## Copying the programs into your local directory

Make sure you are in your home directory. 

```bash
[you@laptop:~]$ cd ~
```

You will need to amend the from-directory in the instruction below if you did not
compile the code yourself according to the above challenge:

```bash
[you@laptop:~]$ mkdir primes
[you@laptop:~]$ cd primes
[you@laptop:~]$ cp ~/HPC_Training_Example_Jobs/c/multi ~/HPC_Training_Example_Jobs/c/single_gcc .
[you@laptop:~]$ 

```



## Help!

Many command-line programs include a "help" message. Try it with `single_gcc`:

```bash
[yourUsername@login1 ~]$ ./single_gcc
```

```output
You must enter two positive numbers in the range 1 - 2^32
```

This message doesn't tell us much about what the program *does*, but it does
tell us that we need to provide two numbers that specify the beginning and
the end of a range that lies between 1 and 2^32.

:::: callout 

### The `time` command

You will notice in the batch scripts that we will be creating we will be using
the `time` command before the name of the program. For example:

```bash
[yourUsername@login1 ~]$ time ./single_gcc
```

```output
You must enter two positive numbers in the range 2 - 2^32

real	0m0.005s
user	0m0.000s
sys	0m0.002s
```
The very first line of the output is the output of the program we want to run, 
i.e. `single_gcc`. After that `time` returns three times. `real` is wall clock 
time. If you ran a stopwatch, that is how long it would have taken. The `user` 
time is the amount of CPU time it has taken. `sys` is kernel/system call time. 
That is the time the code spent doing things that were not part of your code, 
but essential stuff like interrupts, time the kernel spent setting up processes 
and memory.

:::::

## Running the Job on a Compute Node

Create a submission file, requesting one task on a single node, then launch it.


``` error
Error in `snippets()`:
! Snippet not found: parallel/job_single.Rmd
Main: /home/runner/work/hpc-intro-comet/hpc-intro-comet/site/built/files/customization/HPCC_MagicCastle_slurm/snippets/parallel/job_single.Rmd
Fallback: /home/runner/work/hpc-intro-comet/hpc-intro-comet/site/built/files/customization/HPCC_MagicCastle_slurm/snippets/parallel/job_single.Rmd
```


Use the Slurm status commands to check whether your job
is running and when it ends:

```bash
[yourUsername@login1 ~]$ squeue --me
```

Use `ls` to locate the output file. The `-t` flag sorts in
reverse-chronological order: newest first. What was the output?

:::::::::::::::  spoiler

## Read the Job Output

The cluster output should be written to a file in the folder you launched the
job from. For example,

```bash
[yourUsername@login1 ~]$ ls -t
```

```output
slurm-1177272.out  job_single.sh  job_multi.sh  single_gcc  multi
```

```bash
[yourUsername@login1 ~]$ cat slurm-1177272.out
```

```output
Starting single process primes calculation (2 - 10000000)
=====================
main: Calculating primes in the range 2 - 10000000
primeCount: Calculating primes 2 - 10000000
primeCount: Found 664579 primes
main: Found a total of 664579 primes

real	0m34.476s
user	0m34.247s
sys	0m0.002s
=====================
Primes calculation complete

```

:::::::::::::::::::::::::

While MPI-aware executables can generally be run as stand-alone programs, in
order for them to run in parallel they must use an MPI *run-time environment*,
which is a specific implementation of the MPI *standard*.
To activate the MPI environment, the program should be started via a command
such as `mpiexec` (or `mpirun`, or `srun`, etc. depending on the MPI run-time
you need to use), which will ensure that the appropriate run-time support for
parallelism is included.

## Running the Parallel Job

The program `multi` uses the Message Passing Interface (MPI) for parallelism.
-- this is a common tool on HPC systems.


:::::::::::::::::::::::::::::::::::::::::  callout

## MPI Runtime Arguments

On their own, commands such as `mpiexec` can take many arguments specifying
how many machines will participate in the execution,
and you might need these if you would like to run an MPI program on your
own (for example, on your laptop).
In the context of a queuing system, however, it is frequently the case that
MPI run-time will obtain the necessary parameters from the queuing system,
by examining the environment variables set when the job is launched.

::::::::::::::::::::::::::::::::::::::::::::::::::

Let's modify the job script to request more cores and use the MPI run-time.


``` error
Error in `snippets()`:
! Snippet not found: parallel/job_multi.Rmd
Main: /home/runner/work/hpc-intro-comet/hpc-intro-comet/site/built/files/customization/HPCC_MagicCastle_slurm/snippets/parallel/job_multi.Rmd
Fallback: /home/runner/work/hpc-intro-comet/hpc-intro-comet/site/built/files/customization/HPCC_MagicCastle_slurm/snippets/parallel/job_multi.Rmd
```

:::::::::::::::::::::::::::::::::::::::  challenge

## Is it 4× faster?

The parallel job received 4× more processors than the serial job:
does that mean it finished in ¼ the time?

:::::::::::::::  solution

## Solution

The parallel job did take *less* time: 11 seconds is better than 30!
But it is only a 2.7× improvement, not 4×.

Look at the job output:

- While "process 0" did serial work, processes 1 through 3 did their
  parallel work.
- While process 0 caught up on its parallel work,
  the rest did nothing at all.

Process 0 always has to finish its serial task before it can start on the
parallel work. This sets a lower limit on the amount of time this job will
take, no matter how many cores you throw at it.

This is the basic principle behind [Amdahl's Law][amdahl], which is one way
of predicting improvements in execution time for a **fixed** workload that
can be subdivided and run in parallel to some extent.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

## How Much Does Parallel Execution Improve Performance?

In theory, dividing up a perfectly parallel calculation among *n* MPI processes
should produce a decrease in total run time by a factor of *n*.
As we have just seen, real programs need some time for the MPI processes to
communicate and coordinate, and some types of calculations can't be subdivided:
they only run effectively on a single CPU.

Additionally, if the MPI processes operate on different physical CPUs in the
computer, or across multiple compute nodes, even more time is required for
communication than it takes when all processes operate on a single CPU.

In practice, it's common to evaluate the parallelism of an MPI program by

- running the program across a range of CPU counts,
- recording the execution time on each run,
- comparing each execution time to the time when using a single CPU.

Since "more is better" -- improvement is easier to interpret from increases in
some quantity than decreases -- comparisons are made using the speedup factor
*S*, which is calculated as the single-CPU execution time divided by the multi-CPU
execution time. For a perfectly parallel program, a plot of the speedup *S*
versus the number of CPUs *n* would give a straight line, *S* = *n*.

Let's run one more job, so we can see how close to a straight line our `amdahl`
code gets.


```bash
[yourUsername@login1 ~]$ nano parallel-job.sh
[yourUsername@login1 ~]$ cat parallel-job.sh
```

```bash
#!/bin/bash
#SBATCH -J parallel-job
#SBATCH -p cpubase_bycore_b1
#SBATCH -N 1
#SBATCH -n 8

# Load the computing environment we need
# (mpi4py and numpy are in SciPy-bundle)
module load Python
module load SciPy-bundle

# Execute the task
mpiexec amdahl
```

Then submit your job. Note that the submission command has not really changed
from how we submitted the serial job: all the parallel settings are in the
batch file rather than the command line.

```bash
[yourUsername@login1 ~]$ sbatch parallel-job.sh
```

As before, use the status commands to check when your job runs.

```bash
[yourUsername@login1 ~]$ ls -t
```

```output
slurm-347271.out  parallel-job.sh  slurm-347178.out  slurm-347087.out  serial-job.sh  amdahl  README.md  LICENSE.txt
```

```bash
[yourUsername@login1 ~]$ cat slurm-347178.out
```

```output
which should take 7.688 seconds with 0.850 parallel proportion of the workload.

  Hello, World! I am process 4 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 0 of 8 on smnode1. I will do all the serial 'work' for 4.500 seconds.
  Hello, World! I am process 2 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 1 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 3 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 5 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 6 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 7 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.
  Hello, World! I am process 0 of 8 on smnode1. I will do parallel 'work' for 3.188 seconds.

Total execution time (according to rank 0): 7.697 seconds
```

::::::::::::::::::::::::::::::::::::::  discussion

## Non-Linear Output

When we ran the job with 4 parallel workers, the serial job wrote its output
first, then the parallel processes wrote their output, with process 0 coming
in first and last.

With 8 workers, this is not the case: since the parallel workers take less
time than the serial work, it is hard to say which process will write its
output first, except that it will *not* be process 0!

::::::::::::::::::::::::::::::::::::::::::::::::::

Now, let's summarize the amount of time it took each job to run:

| Number of CPUs | Runtime (sec) |
| -------------- | ------------- |
| 1              | 30\.033        |
| 4              | 10\.888        |
| 8              | 7\.697         |

Then, use the first row to compute speedups $S$, using Python as a command-line
calculator and the formula

$$
S(t_{n}) = \frac{t_{1}}{t_{n}}
$$

```bash
[yourUsername@login1 ~]$ for n in 30.033 10.888 7.697; do python3 -c "print(30.033 / $n)"; done
```

| Number of CPUs | Speedup       | Ideal |
| -------------- | ------------- | ----- |
| 1              | 1\.0           | 1     |
| 4              | 2\.75          | 4     |
| 8              | 3\.90          | 8     |

The job output files have been telling us that this program is performing 85%
of its work in parallel, leaving 15% to run in serial. This seems reasonably
high, but our quick study of speedup shows that in order to get a 4× speedup,
we have to use 8 or 9 processors in parallel. In real programs, the speedup
factor is influenced by

- CPU design
- communication network between compute nodes
- MPI library implementations
- details of the MPI program itself

Using Amdahl's Law, you can prove that with this program, it is *impossible*
to reach 8× speedup, no matter how many processors you have on hand. Details of
that analysis, with results to back it up, are left for the next class in the
HPC Carpentry workshop, *HPC Workflows*.

In an HPC environment, we try to reduce the execution time for all types of
jobs, and MPI is an extremely common way to combine dozens, hundreds, or
thousands of CPUs into solving a single problem. To learn more about
parallelization, see the [parallel novice lesson][parallel-novice] lesson.


[amdahl]: https://en.wikipedia.org/wiki/Amdahl\'s_law
[parallel-novice]: https://www.hpc-carpentry.org/hpc-parallel-novice/


:::::::::::::::::::::::::::::::::::::::: keypoints

- Parallel programming allows applications to take advantage of parallel hardware.
- The queuing system facilitates executing parallel tasks.
- Performance improvements from parallel execution do not scale linearly.

::::::::::::::::::::::::::::::::::::::::::::::::::
