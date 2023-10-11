# sleap-container

Container for SLEAP

## Build instructions

Make the container with `make`:

```bash
make container
```

This will create a container called `sleap.sif` in the `containers` directory.

## Usage

 This guide assumes that you are running SLEAP on your own machine, with an open SLEAP project that you are ready to start training on. If you need help creating a SLEAP project, consult the [SLEAP documentation](https://sleap.ai/tutorials/tutorial.html).

To start training your model on the cluster, you must first create a *training package*:

> A self-contained **training job package** contains a .slp file with labeled data and images which will be used for training, as well as .json training configuration file(s). [*](https://sleap.ai/notebooks/Training_and_inference_using_Google_Drive.html)

### Exporting a training package

You can create a training job package in the `sleap-label` GUI by following the `Run Training...` option under the `Predict` menu:
![SLEAP GUI: Main Window Run Training](./docs/screenshots/01-main_dropdown_predict_run_training.png)

Set the parameters for your training job (refer to [SLEAP documentation](https://sleap.ai/tutorials/initial-training.html) if you're not sure), and click `Export training job package` once you're done:
![SLEAP GUI: Run Training Dialog](./docs/screenshots/02-run_training_dialog.png)

Next, you should see a dialog that says, `Created training job package.` Click `Show Details...`:
![SLEAP GUI: Created training job package](./docs/screenshots/03-created_training_job_package.png)

The full file path to the training package will be displayed (e.g., `/home/me/sleap/my_training_job.zip`). Select and copy this path:
![SLEAP GUI: Run Training Dialog](./docs/screenshots/04-created_training_job_package_details.png)

### Uploading a training package to the cluster

Now you must use the terminal on your computer to upload the training package to the Hyak cluster. You can find instructions on how to set up your terminal to access Hyak [here](https://uw-psych.github.io/compute_docs/hyak/start/connect-ssh.html).

Open a terminal window and enter the following command to copy the training package to your home directory (`~`) on the cluster:

```bash
scp /home/me/sleap/my_training_job.zip klone.hyak.uw.edu:
```

*NOTE: You may need to log in with your UW NetID and two-factor authentication.*

### Runnning the training package on the cluster

Once the file has been copied, log in to the cluster via SSH:

```bash
ssh klone.hyak.uw.edu
```

#### Extracting the training package

The training package should be located in your home directory. You can check by running `ls`:

```bash
ls *.zip
# Should display all ZIP files in directory, including `my_training_job.zip`
```

Unzip the package file to a new directory. Let's call it `training_job`:

```bash
unzip my_training_job.zip -d training_job
```

#### Allocating a node on the cluster

We are almost ready to launch the container. First, though, we need to allocate a job on the cluster. We will use the `salloc` command to do this.

The following command will allocate a job on one node with 4 GPUs, 64 GB of memory, and 8 CPUs for 24 hours on the `gpu-a40` partition available to the `escience` account. You can adjust these parameters as needed. For more information on the `salloc` command, see [this page](hhttps://uw-psych.github.io/compute_docs/hyak/compute/slurm/slurm.html) and the [salloc documentation](https://slurm.schedmd.com/salloc.html).

```bash
salloc --job-name sleap-train-test --account escience --partition gpu-a40 --gpus 4 --ntasks 1
--gpus-per-task=4 --mem 64G --cpus-per-task 4 --time 24:00:00
```

When the allocation is ready, it will tell you what node it is running on, e.g.:

```text
salloc: Granted job allocation 15001744
salloc: Waiting for resource configuration
salloc: Nodes g3052 are ready for job
```

Take note of the node, in this case `g3052`. We will need it in the next step.

If you forget, you can run `squeue` to see the status of your job:

```bash
 squeue --me | grep sleap
 ```

This will show you the status of your job, including the node it is running on:

```text
15001744   gpu-a40 sleap-tr    altan  R       5:26      1 g3052
```

#### Running SLEAP on the job node

Now we are ready to start SLEAP. First, we need to connect to the node where our job is running. We do this with the `ssh` command to the node we noted earlier (in this example, `g3052`):

```bash
ssh g3052
```

##### Verifying GPU access

Once you are connected to the node, you can verify that the SLEAP container has access to the GPUs by running the following command:

```bash
apptainer run --nv ~/sleap.sif python -c "import sleap; sleap.system_summary()"
```

You should get output that looks something like this:

```text
GPUs: 4/4 available
  Device: /physical_device:GPU:0
         Available: True
        Initalized: False
     Memory growth: None
  Device: /physical_device:GPU:1
         Available: True
        Initalized: False
     Memory growth: None
  Device: /physical_device:GPU:2
         Available: True
        Initalized: False
     Memory growth: None
  Device: /physical_device:GPU:3
         Available: True
        Initalized: False
     Memory growth: None
6.40s user 6.24s system 88% cpu 14.277s total
```

##### Training the model

Now, navigate to the directory where you unzipped the training package:

```bash
cd ~/training_job
```

The next step is to launch the container:

```bash
apptainer run --nv ~/sleap.sif bash train-script.sh
```

We are launching the container by instructing `apptainer` to launch the container
at `~/sleap.sif` with the option `--nv` to enable Nvidia GPU support. Once the container has launched, it will instruct `bash` to run the script `train-script.sh`. This script will start the training job.

Once the job has started, you will see a lot of output in the terminal. After some time, if training is successful, the last of the output should look something similar to this:

```text
INFO:sleap.nn.evals:Saved predictions: models/231009_165437.centered_instance/labels_pr.train.slp
INFO:sleap.nn.evals:Saved metrics: models/231009_165437.centered_instance/metrics.train.npz
INFO:sleap.nn.evals:OKS mAP: 0.205979
Predicting... ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% ETA: 0:00:00 3.3 FPS
INFO:sleap.nn.evals:Saved predictions: models/231009_165437.centered_instance/labels_pr.val.slp
INFO:sleap.nn.evals:Saved metrics: models/231009_165437.centered_instance/metrics.val.npz
INFO:sleap.nn.evals:OKS mAP: 0.064026
229.63s user 44.64s system 77% cpu 5:53.45s total
```

Once training finishes, you'll see a new directory (or two new directories for top-down training pipeline) containing all the model files SLEAP needs to use for inference:

```bash
ls models
```

```text
231009_165437.centered_instance  231009_165437.centroid
```

You can use these model files to run inference on your own computer, or you can run inference on the cluster (consult the [SLEAP documentation](https://sleap.ai/guides/remote.html) for more information).

### Downloading the model

To copy the model files back to your computer, compress the model directory with `zip`:

```bash
cd ~/training_job
zip -r trained_models.zip models
```

Then, in a new terminal window *on your own computer*, use the `scp` command to copy the model files back to your computer:

```bash
scp klone.hyak.uw.edu:~/training_job/trained_models.zip .
```

This will copy the file `trained_models.zip` to your current directory. You can then unzip the file and use the model files for inference on your own computer. Consult the [SLEAP documentation](https://sleap.ai/guides/remote.html) for more information on running inference with a trained model.

### Ending the cluster job

**Be sure to end your cluster job when you are done!** This will free up resources for other users and potentially prevent you from being charged for time you are not using.

To do this, go back to the terminal where you were running SLEAP on the cluster. (If you closed the terminal, you can log back in to the cluster with `ssh klone.hyak.uw.edu`.)

**If you're still logged in to the job node**, exit:

```bash
exit
```

Cancel the job allocation with the `scancel` command:

```bash
scancel --me --jobname sleap-train-test
```

Finally, exit the cluster:

```bash
exit
```

SLEAP well!
