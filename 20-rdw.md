---
title: Using the Research Data Warehouse
teaching: 15
exercises: 15
---



::::::::::::::::::::::::::::::::::::::: objectives

- Understand how to use Newcastle University's Research Data Warehouse (aka, RDW and Campus Filestore) with Comet HPC

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How do I transfer files to (and from) the cluster?
- What is the best way to back up research data?

::::::::::::::::::::::::::::::::::::::::::::::::::


## Transferring files to and from Campus Storage for Research Data (RDW)
RDW (Research Data Warehouse) is mounted on Comet at `/rdw` so you can access it just like any local filesystem.
Research project owners can request their own share on RDW for safe storage of research data.
Although RDW is a separate physical system, it's located in the same data centre as Comet and connected via fast ethernet.
You can use `cp` and `rsync` to transfer data to RDW in the same way as copying to any other directory on Comet.
  
- RDW is intended for data storage and NOT suitable for interactive use or software installation.  
- Working data should be in your home or project directory.
- User installed software should be in your home directory.

We can practice making a backup of the amdahl software we uploaded in the last episode.

### Using cp to copy to RDW
Because `/rdw` is a mounted filesystem, we can use `cp` instead of `scp`.  
Let's make our own directory inside the RDW share belonging to comet_training:

```bash
[user@cometlogin01(comet) ~] pwd
```
```output
/mnt/nfs/home/user
```

```bash
[user@cometlogin01(comet) ~] ls /rdw/04/rse-training/
[user@cometlogin01(comet) ~] mkdir /rdw/04/rse-training/user
[user@cometlogin01(comet) ~] cp example-job.sh /rdw/04/rse-training/user/
[user@cometlogin01(comet) ~] cd /rdw/04/rse-training/user/
[user@cometlogin02(comet) rse-training]$ pwd
```

```output
/rdw/04/rse-training/user
```
```bash
[user@cometlogin02(comet) user]$ ls
```
```output
example-job.sh
```

### Using rsync to copy to RDW

As you gain experience with transferring files, you may find the `cp` and `scp`
commands limiting. The [rsync](https://rsync.samba.org/) utility provides
advanced features for file transfer and is typically faster compared to both
`scp` and `sftp` (see below). It is especially useful for transferring large
and/or many files and creating synced backup folders.
The syntax is similar to `cp` and `scp`.  Rsync can be used on a locally mounted filesystem or a remote filesystem.

Transfer *to* RDW from your home directory on Comet

#### Try out a dry run:


```bash
[user@cometlogin01(comet) ~] cd ~
[user@cometlogin01(comet) ~] rsync -rltv amdahl /rdw/04/rse-training/user/ --dry-run
```
```output
sending incremental file list
amdahl/
amdahl/.gitignore
amdahl/LICENSE
amdahl/README.md
amdahl/pyproject.toml
amdahl/.github/
amdahl/.github/workflows/
amdahl/.github/workflows/python-publish.yml
amdahl/.github/workflows/test.yml
amdahl/amdahl/
amdahl/amdahl/__init__.py
amdahl/amdahl/__main__.py
amdahl/amdahl/amdahl.py

sent 361 bytes  received 59 bytes  840.00 bytes/sec
total size is 21,987  speedup is 52.35 (DRY RUN)
```

#### Run ‘for real’:


```bash
[user@cometlogin01(comet) ~] rsync -rltv amdahl /rdw/04/rse-training/user/
```
```output
sending incremental file list
amdahl/
amdahl/.gitignore
amdahl/LICENSE
amdahl/README.md
amdahl/pyproject.toml
amdahl/.github/
amdahl/.github/workflows/
amdahl/.github/workflows/python-publish.yml
amdahl/.github/workflows/test.yml
amdahl/amdahl/
amdahl/amdahl/__init__.py
amdahl/amdahl/__main__.py
amdahl/amdahl/amdahl.py

sent 22,716 bytes  received 211 bytes  45,854.00 bytes/sec
total size is 21,987  speedup is 0.96
```
and check the result


```bash
[user@cometlogin01(comet) ~] ls /rdw/04/rse-training/user/
```
```output
amdahl  example-job.sh
```

```bash
[user@cometlogin01(comet) ~] ls /rdw/04/rse-training/user/amdahl/
```
```output
amdahl  LICENSE  pyproject.toml  README.md
```

    
:::::::::::::::::::::::::::::::::::::::::  callout

## Common options for `rsync`
The usual format for an `rsync` command is:

`rsync -av source/directory/path destination/directory/path`

The `-a` (archive) option is equivalent to -rlptgoD. It is a quick way of saying you want to recurse through directories and to preserve almost everything, including permissions. 
Use `man rsync` or `rsync --help` to find out more. 
Because permission groups on RDW are set outside of Comet, we use a subset of `-a`

For Comet and RDW, replace `-av` with `-rltv`  
`-r` = recurse through subdirectories    
`-l` = copy symlinks    
`-t` = preserve timestamps   
`-v` = verbose

::::::::::::::::::::::::::::::::::::::::::::::::::


## `rsync` for large data copies
When copying large amounts of data, rsync really comes into its own. When you're copying a lot of data, it's important to keep track in case the copy is interrupted.  
Rsync can pick up where it left off after an interruption, rather than starting the copy all over again.  

### Additional Options
- `-z` compresses the files before transfer, speeding up transfers on slow networks but using unnecessary resources for fast connections.
- `--size-only` can speed up transfers by skipping the checksum step
- `--stats` and `--progress` can help you check that the transfer went as expected.
- `--inplace` saves resources by not creating temporary files
- `--size-only` saves time by only checking whether a file's size has changed (and not its last-modified time) 
- `--log-file=` sends the output to a file so you can see what was transferred and find any errors that need to be addressed.
- `--delete` is an option that is very useful for tidying up when files have been duplicated.  

#### `--delete` should be used with care!  
Perhaps a collaborator has placed additional files in the destination directory. These could accidentally be deleted if you use `rsync --delete` to make the destination match your source.
 
- Use `--dry-run --progress --stats` to check before you run.
- Accidental deletions on RDW can be rolled back using Windows File Explorer.  Log a ticket with NUIT for help with rollback.
- see `man rsync` and https://rsync.samba.org/ for more examples

### Fast Connections
Transfers from Comet to RDW don’t leave our fast data centre network.  If you're using rsync with a fast network or disk to disk in the same machine:

- DON'T use compression `-z`
- DO use `--inplace`

Why?  compression uses lots of CPU, and `rsync` usually creates a temp file on disk before copying.  
For fast connections, this places unnecessary load on the CPU and hard drive. 
`--inplace` tells rsync not to create the temp file but send the data straight away.  
It doesn’t matter if the connection is interrupted, because rsync keeps track and tries again.  
Always re-run the transfer command to ensure nothing was missed.  
The second run should be very fast, just listing all the files and not copying anything.

### Slow Connections
For a slow connection like the internet:
 
- DO use compression `-z` 
- DON’T use `--inplace`


:::::::::::::::::::::::::::::::::::::::: keypoints

- `cp` and `rsync` transfer files in or between mounted filesystems
- `scp` and `rsync` transfer files between remote filesystems
- RDW shares have a pre-set group of campus users
- group permissions on RDW can't be changed from linux
- try a dry-run of rsync to avoid accidental duplications or deletions
- re-run large rsync commands to confirm success
- RDW has a roll-back feature in case of accidents

Find out more about where to store data on Comet:
https://hpc.researchcomputing.ncl.ac.uk/dokuwiki/doku.php?id=started:filesystems


::::::::::::::::::::::::::::::::::::::::::::::::::
