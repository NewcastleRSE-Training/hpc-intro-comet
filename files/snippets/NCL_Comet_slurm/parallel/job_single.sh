```bash
`r config$remote$prompt` nano job_single.sh
`r config$remote$prompt` cat job_single.sh
```

```bash
#!/bin/bash

#SBATCH --partition=short_free
#SBATCH --account=comet_training
#SBATCH --job-name=single
#SBATCH --ntasks-per-node=16
#SBATCH --nodes=1


PRIMES_START=2
PRIMES_END=10000000

echo "Starting Multi-process primes calculation ($PRIMES_START - $PRIMES_END) x${SLURM_NTASKS}"
echo "====================="

time ./single_gcc $PRIMES_START $PRIMES_END
echo "====================="
echo "Primes calculation complete"
```


```bash
`r config$remote$prompt` `r config$sched$submit$name` job_single.sh
```
