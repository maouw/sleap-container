# sleap-container
Container for SLEAP

## Build instructions

Make the container with `make`:

```bash
```

## Usage

### Running a training package

Exporting your training job package in the SLEAP GUI from the menu  `Predict > Run Training > Export
training job package`. 

When you get the message "Created training job package," click  `Show Details...` and copy the full path to the package file, e.g.:
`/home/me/sleap/my_training_job.zip`.

Next, upload the training package from your computer to `hyak` like so:

upload the training package from your computer to hyak using:

```bash
scp /home/me/sleap/my_training_job.zip klone.hyak.uw.edu:
```

Next, log in to `hyak` via SSH:

```bash
ssh klone.hyak.uw.edu
```

Then unzip the package file to a new directory, here called `training_job`:

```bash
unzip my_training_job.zip -d training_job
```

Then, obtain a SLURM job allocation with support for 4 GPUs:

```bash
salloc --job-name sleap-train-test --account escience --partition gpu-a40 -G 4
--gpus-per-task=4 --mem 64G -c 4 --time 24:00:00
```

When the allocation is ready, it will launch a shell for you to enter in the
remaining commands.


Now let's go to the directory where we unzipped the training package:

```bash
cd ~/training_job
```

The next step is to launch the container:

```bash
apptainer run --nv ~/containers/sleap.sif bash train-script.sh
```

We are launching the container by instructing `apptainer` to launch the container
at `~/containers/sleap.sif` with the option `--nv` to enable Nvidia GPU support.

Once the container has launched, this command runs "bash" with the input script
`train-script.sh`
