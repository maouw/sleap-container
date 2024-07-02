[Training and inference on an example dataset — SLEAP (v1.3.3)](https://sleap.ai/notebooks/Training_and_inference_on_an_example_dataset.html)

```bash
wget -O dataset.zip https://github.com/talmolab/sleap-datasets/releases/download/dm-courtship-v1/drosophila-melanogaster-courtship.zip
mkdir dataset
unzip dataset.zip -d dataset
```


## Train models

For the top-down pipeline, we'll need train two models: a centroid model and a centered-instance model.

Using the command-line interface, we'll first train a model for centroids using the default **training profile**. The training profile determines the model architecture, the learning rate, and other parameters.

When you start training, you'll first see the training parameters and then the training and validation loss for each training epoch.

As soon as you're satisfied with the validation loss you see for an epoch during training, you're welcome to stop training by clicking the stop button. The version of the model with the lowest validation loss is saved during training, and that's what will be used for inference.

If you don't stop training, it will run for 200 epochs or until validation loss fails to improve for some number of epochs (controlled by the `early_stopping` fields in the training profile).

```bash
salloc --job-name sleap-train-test --account escience --partition gpu-a40 -N1 -n1 --mem 96GB --cpus-per-task 16 --gpus 1 --time 24:00:00
```

```bash
export APPTAINER_CLEANENV=1 APPTAINER_NV=1 APPTAINER_WRITABLE_TMPFS=1 APPTAINER_BIND=/gscratch
SLEAP="/mmfs1/gscratch/escience/altan/sleap/sleap-container_latest.sif"
```

```bash
apptainer run $SLEAP python -c "import sleap; sleap.system_summary()"
```


```bash
srun apptainer run $SLEAP sleap-train baseline.centroid.json "dataset/drosophila-melanogaster-courtship/courtship_labels.slp" --run_name "courtship.centroid" --video-paths "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4"
```

Let's now train a centered-instance model.
```bash
srun apptainer run $SLEAP sleap-train baseline_medium_rf.topdown.json "dataset/drosophila-melanogaster-courtship/courtship_labels.slp" --run_name "courtship.topdown_confmaps" --video-paths "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4"
```


## Inference

Lets run inference with our trained models for centroids and centered instances.

```bash
srun apptainer run $SLEAP sleap-track "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4" --frames 0-100 -m "models/courtship.centroid" -m "models/courtship.topdown_confmaps"
```

```bash
find dataset/drosophila-melanogaster-courtship
```

You can inspect your predictions file using `sleap-inspect`

```bash
srun apptainer run $SLEAP sleap-inspect dataset/drosophila-melanogaster-courtship/20190128_113421.mp4.predictions.slp
```

## Job script

The following script downloads the dataset, trains the models, and runs inference:

```bash
#!/usr/bin/env bash

wget -O dataset.zip https://github.com/talmolab/sleap-datasets/releases/download/dm-courtship-v1/drosophila-melanogaster-courtship.zip
mkdir dataset
unzip dataset.zip -d dataset
export APPTAINER_CLEANENV=1 APPTAINER_NV=1 APPTAINER_WRITABLE_TMPFS=1 APPTAINER_BIND=/gscratch
SLEAP="/mmfs1/gscratch/escience/altan/sleap/sleap-container_latest.sif"
apptainer run $SLEAP python -c "import sleap; sleap.system_summary()"
apptainer run $SLEAP sleap-train baseline.centroid.json "dataset/drosophila-melanogaster-courtship/courtship_labels.slp" --run_name "courtship.centroid" --video-paths "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4"
srun apptainer run $SLEAP sleap-train baseline_medium_rf.topdown.json "dataset/drosophila-melanogaster-courtship/courtship_labels.slp" --run_name "courtship.topdown_confmaps" --video-paths "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4"
srun apptainer run $SLEAP sleap-track "dataset/drosophila-melanogaster-courtship/20190128_113421.mp4" --frames 0-100 -m "models/courtship.centroid" -m "models/courtship.topdown_confmaps"
```

For a more complete example, see:

- [`sbatch-train.job`](./sbatch-train.job) for a job script that trains the models.
- [`sbatch-infer.job`](./sbatch-infer.job) for a job script that runs inference.
- [`sbatch-infer-with-rclone.job`](./sbatch-infer-with-rclone.job) for a job script that uses `rclone` to access data from an SMB share and runs inference as an array job.

