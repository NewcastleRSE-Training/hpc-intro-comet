---
title: Accessing software via Modules
teaching: 30
exercises: 15
---



::::::::::::::::::::::::::::::::::::::: objectives

- Load and use a software package.
- Explain how the shell environment changes when the module mechanism loads or unloads packages.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How do we load and unload software packages?

::::::::::::::::::::::::::::::::::::::::::::::::::

On a high-performance computing system, it is seldom the case that the software
we want to use is available when we log in. It is installed, but we will need
to "load" it before it can run.

Before we start using individual software packages, however, we should
understand the reasoning behind this approach. The three biggest factors are:

- software incompatibilities
- versioning
- dependencies

Software incompatibility is a major headache for programmers. Sometimes the
presence (or absence) of a software package will break others that depend on
it. Two well known examples are Python and C compiler versions.
Python 3 famously provides a `python` command that conflicts with that provided
by Python 2. Software compiled against a newer version of the C libraries and
then run on a machine that has older C libraries installed will result in an
opaque `'GLIBCXX_3.4.20' not found` error.

Software versioning is another common issue. A team might depend on a certain
package version for their research project -- if the software version was to
change (for instance, if a package was updated), it might affect their results.
Having access to multiple software versions allows a set of researchers to
prevent software versioning issues from affecting their results.

Dependencies are where a particular software package (or even a particular
version) depends on having access to another software package (or even a
particular version of another software package). For example, the VASP
materials science software may require a particular version of the
FFTW (Fastest Fourier Transform in the West) software library available for it
to work.

## Environment Modules

Environment modules are the solution to these problems. A *module* is a
self-contained description of a software package -- it contains the
settings required to run a software package and, usually, encodes required
dependencies on other software packages.

There are a number of different environment module implementations commonly
used on HPC systems: the two most common are *TCL modules* and *Lmod*. Both of
these use similar syntax and the concepts are the same so learning to use one
will allow you to use whichever is installed on the system you are using. In
both implementations the `module` command is used to interact with environment
modules. An additional subcommand is usually added to the command to specify
what you want to do. For a list of subcommands you can use `module -h` or
`module help`. As for all commands, you can access the full help on the *man*
pages with `man module`.

On login you may start out with a default set of modules loaded or you may
start out with an empty environment; this depends on the setup of the system
you are using.

### Listing Available Modules

To see available software modules, use `module avail`:


```bash
[user@cometlogin01(comet) ~] module avail | less
```

```output
------------------------------------------------------------------------------------------ /opt/slurm/modules/el9 -------------------------------------------------------------------------------------------
   nvidia-cuda/12.1.1    pmix/2.2.5    pmix/3.2.5    pmix/4.2.9    pmix/5.0.3 (D)    slurm/24.05.3 (S,L)

------------------------------------------------------------------------------------ /opt/software/easybuild/modules/all ------------------------------------------------------------------------------------
   AFNI/24.0.02-foss-2023a                               M4/1.4.19-GCCcore-11.2.0                          XZ/5.4.5-GCCcore-13.3.0                           libgd/2.3.3-GCCcore-12.3.0
   AOCC-TC/5.0.0-GCCcore-14.2.0                          M4/1.4.19-GCCcore-11.3.0                          XZ/5.6.3-GCCcore-14.2.0                    (D)    libgd/2.3.3-GCCcore-13.3.0                 (D)
   AOCC/4.2.0-GCCcore-13.3.0                             M4/1.4.19-GCCcore-12.2.0                          Xvfb/21.1.8-GCCcore-12.3.0                        libgit2/1.7.1-GCCcore-12.3.0
   AOCC/5.0.0-GCCcore-14.2.0                             M4/1.4.19-GCCcore-12.3.0                          Yasm/1.3.0-GCCcore-12.3.0                         libgit2/1.8.1-GCCcore-13.3.0               (D)
   ATK/2.38.0-GCCcore-12.3.0                             M4/1.4.19-GCCcore-13.2.0                          Yasm/1.3.0-GCCcore-13.2.0                  (D)    libglvnd/1.3.3-GCCcore-10.3.0
   Abseil/20230125.3-GCCcore-12.3.0                      M4/1.4.19-GCCcore-13.3.0                          Z3/4.13.0-GCCcore-13.2.0                          libglvnd/1.6.0-GCCcore-12.3.0
   Abseil/20240116.1-GCCcore-13.2.0            (D)       M4/1.4.19-GCCcore-14.2.0                          Z3/4.13.0-GCCcore-13.3.0                   (D)    libglvnd/1.7.0-GCCcore-13.2.0
   Archive-Zip/1.68-GCCcore-13.3.0             (D)       M4/1.4.19                                  (D)    ZeroMQ/4.3.5-GCCcore-13.3.0                (D)    libglvnd/1.7.0-GCCcore-13.3.0              (D)

[removed most of the output here for clarity]
```

Use `module spider` to find all possible modules and extensions.
Use `module keyword key1 key2 ...` to search for all possible modules matching
any of the "keys".

Note that piping the output through `less` allows us to search within the output using the <kbd>/</kbd> key.

### Listing Currently Loaded Modules

You can use the `module list` command to see which modules you currently have
loaded in your environment. If you have no modules loaded, you will see a
message telling you so.

```bash
[user@cometlogin01(comet) ~] module list
```

```output
No Modulefiles Currently Loaded.
```

## Loading and Unloading Software

To load a software module, use `module load`.

In this example we will use Python 3. Initially, it is not loaded.
We can test this by using the `which` command. `which` looks for
programs the same way that Bash does, so we can use it to tell us
where a particular piece of software is stored.

```bash
[user@cometlogin01(comet) ~] which python3
```


If the `python3` command was unavailable, we would see output like

```output
/usr/bin/which: no python3 in (/cvmfs/pilot.eessi-hpc.org/2020.12/compat/linux/x86_64/usr/bin:/opt/software/slurm/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/puppetlabs/bin:/home/user/.local/bin:/home/user/bin)
```

Note that this wall of text is really a list, with values separated
by the `:` character. The output is telling us that the `which` command
searched the following directories for `python3`, without success:

```output
/cvmfs/pilot.eessi-hpc.org/2020.12/compat/linux/x86_64/usr/bin
/opt/software/slurm/bin
/usr/local/bin
/usr/bin
/usr/local/sbin
/usr/sbin
/opt/puppetlabs/bin
/home/user/.local/bin
/home/user/bin
```

However, in our case we do have an existing `python3` available so we see

```output
/cvmfs/pilot.eessi-hpc.org/2020.12/compat/linux/x86_64/usr/bin/python3
```

We need a different Python than the system provided one though, so let us load
a module to access it.

We can load the `python3` command with `module load`:


```bash
[user@cometlogin01(comet) ~] module load Python
[user@cometlogin01(comet) ~] which python3
```

```output
/usr/bin/python3
```

So, what just happened?

To understand the output, first we need to understand the nature of the `$PATH`
environment variable. `$PATH` is a special environment variable that controls
where a UNIX system looks for software. Specifically `$PATH` is a list of
directories (separated by `:`) that the OS searches through for a command
before giving up and telling us it can't find it. As with all environment
variables we can print it out using `echo`.

```bash
[user@cometlogin01(comet) ~] echo $PATH
```

```output
/opt/software/manual/apps/Python/3.14.0/bin:/mnt/nfs/home/ncb176/.sdkman/candidates/java/current/bin:/mnt/nfs/home/ncb176/.local/bin:/mnt/nfs/home/ncb176/bin:/usr/share/lmod/lmod/libexec:/opt/slurm/24.05.3/el9/bin:/opt/slurm/24.05.3/el9/sbin:/opt/slurm/dmtcp/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
(OSS 2410.0) [ncb176@cometlogin02(comet) ~]$
```

You'll notice a similarity to the output of the `which` command. In this case,
there's only one difference: the different directory at the beginning. When we
ran the `module load` command, it added a directory to the beginning of our
`$PATH` -- or "prepended to PATH". Let's examine what's there:


```bash
[user@cometlogin01(comet) ~] ls ls /opt/software/manual/apps/Python/3.14.0/bin

```

```output
idle3     pip3     pydoc3     python3     python3.14-config
idle3.14  pip3.14  pydoc3.14  python3.14  python3-config
```

Taking this to its conclusion, `module load` will add software to your `$PATH`.
It "loads" software. A special note on this - depending on which version of the
`module` program that is installed at your site, `module load` will also load
required software dependencies.


To demonstrate, let's use `module list`. `module list` shows all loaded
software modules.

```bash
[user@cometlogin01(comet) ~] module list
```

```output
Currently Loaded Modules:
  1) slurm/24.05.3 (S)   2) lmod (S)   3) Python/3.14.0

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```

```bash
[user@cometlogin01(comet) ~] module load GROMACS
[user@cometlogin01(comet) ~] module list
```

```output
Currently Loaded Modules:
  1) slurm/24.05.3 (S)   3) Python/3.14.0   5) GROMACS/2025.2
  2) lmod          (S)   4) GCC/14.3.0

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```

So in this case, loading the `GROMACS` module (a bioinformatics software
package), also loaded `GCC/14.3.0`.
Let's try unloading the
`GROMACS` package.

```bash
[user@cometlogin01(comet) ~] module unload GROMACS
[user@cometlogin01(comet) ~] module list
```

```output
Currently Loaded Modules:
  1) slurm/24.05.3 (S)   2) lmod (S)   3) Python/3.14.0

  Where:
   S:  Module is Sticky, requires --force to unload or purge
```
So using `module unload` "un-loads" a module, and depending on how a site is
configured it may also unload all of the dependencies (in our case it does
not). If we wanted to unload everything at once, we could run `module purge`
(unloads everything).

```bash
[user@cometlogin01(comet) ~] module purge
[user@cometlogin01(comet) ~] module list
```

```output
No modules loaded
```

Note that `module purge` is informative. It will also let us know if a default
set of "sticky" packages cannot be unloaded (and how to actually unload these
if we truly so desired).

Note that this module loading process happens principally through
the manipulation of environment variables like `$PATH`. There
is usually little or no data transfer involved.

The module loading process manipulates other special environment
variables as well, including variables that influence where the
system looks for software libraries, and sometimes variables which
tell commercial software packages where to find license servers.

The module command also restores these shell environment variables
to their previous state when a module is unloaded.

## Software Versioning

So far, we've learned how to load and unload software packages. This is very
useful. However, we have not yet addressed the issue of software versioning. At
some point or other, you will run into issues where only one particular version
of some software will be suitable. Perhaps a key bugfix only happened in a
certain version, or version X broke compatibility with a file format you use.
In either of these example cases, it helps to be very specific about what
software is loaded.

Let's examine the output of `module avail` more closely, using the pager since
there may be reams of output:


```bash
[user@cometlogin01(comet) ~] module avail | less
```

```output
------------------------------------------------------------------------------------------ /opt/slurm/modules/el9 -------------------------------------------------------------------------------------------
   nvidia-cuda/12.1.1    pmix/2.2.5    pmix/3.2.5    pmix/4.2.9    pmix/5.0.3 (D)    slurm/24.05.3 (S,L)

------------------------------------------------------------------------------------ /opt/software/easybuild/modules/all ------------------------------------------------------------------------------------
   AFNI/24.0.02-foss-2023a                               M4/1.4.19-GCCcore-11.2.0                          XZ/5.4.5-GCCcore-13.3.0                           libgd/2.3.3-GCCcore-12.3.0
   AOCC-TC/5.0.0-GCCcore-14.2.0                          M4/1.4.19-GCCcore-11.3.0                          XZ/5.6.3-GCCcore-14.2.0                    (D)    libgd/2.3.3-GCCcore-13.3.0                 (D)
   AOCC/4.2.0-GCCcore-13.3.0                             M4/1.4.19-GCCcore-12.2.0                          Xvfb/21.1.8-GCCcore-12.3.0                        libgit2/1.7.1-GCCcore-12.3.0
   AOCC/5.0.0-GCCcore-14.2.0                             M4/1.4.19-GCCcore-12.3.0                          Yasm/1.3.0-GCCcore-12.3.0                         libgit2/1.8.1-GCCcore-13.3.0               (D)
   ATK/2.38.0-GCCcore-12.3.0                             M4/1.4.19-GCCcore-13.2.0                          Yasm/1.3.0-GCCcore-13.2.0                  (D)    libglvnd/1.3.3-GCCcore-10.3.0
   Abseil/20230125.3-GCCcore-12.3.0                      M4/1.4.19-GCCcore-13.3.0                          Z3/4.13.0-GCCcore-13.2.0                          libglvnd/1.6.0-GCCcore-12.3.0
   Abseil/20240116.1-GCCcore-13.2.0            (D)       M4/1.4.19-GCCcore-14.2.0                          Z3/4.13.0-GCCcore-13.3.0                   (D)    libglvnd/1.7.0-GCCcore-13.2.0
   Archive-Zip/1.68-GCCcore-13.3.0             (D)       M4/1.4.19                                  (D)    ZeroMQ/4.3.5-GCCcore-13.3.0                (D)    libglvnd/1.7.0-GCCcore-13.3.0              (D)

[removed most of the output here for clarity]
```

Use `module spider` to find all possible modules and extensions.
Use `module keyword key1 key2 ...` to search for all possible modules matching
any of the "keys".

If the software your Slurm script runs requires on a specific version
of a dependency, make sure you use the full name of the module, rather
than the _default_ loaded when you give only its name (up to the first
slash).

:::::::::::::::::::::::::::::::::::::::  challenge

## Using Software Modules in Scripts

Create a job that is able to run `python3 --version`. Remember, no software
is loaded by default! Running a job is just like logging on to the system
(you should not assume a module loaded on the login node is loaded on a
compute node).

:::::::::::::::  solution

## Solution

```bash
[user@cometlogin01(comet) ~] nano python-module.sh
[user@cometlogin01(comet) ~] cat python-module.sh
```

```output
#!/bin/bash
#SBATCH 
r config$sched$comment` -t 00:00:30

module load Python

python3 --version
```

```bash
[user@cometlogin01(comet) ~] sbatch --partition=short_free --account=comet_training python-module.sh
```

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::: keypoints

- Load software with `module load softwareName`.
- Unload software with `module unload`
- The module system handles software versioning and package conflicts for you automatically.

::::::::::::::::::::::::::::::::::::::::::::::::::
