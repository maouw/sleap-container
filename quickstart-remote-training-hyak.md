# Training and inference on your own data using the Hyak Klone Cluster
In this guide we'll install SLEAP, import training data into Hyak, and run training and inference.

## Install SLEAP
Note: Before installing SLEAP check [SLEAP releases](https://github.com/talmolab/sleap/releases) page for the latest version.
!pip uninstall -qqq -y opencv-python opencv-contrib-python
!pip install -qqq "sleap[pypi]>=1.3.3"

## Import training data into Colab with Google Drive
We'll first prepare and export the training data from SLEAP, then upload it to Google Drive, and then mount Google Drive  into this Colab notebook.
### Create and export the training job package
A self-contained **training job package** contains a .slp file with labeled data and images which will be used for training, as well as .json training configuration file(s).

A training job package can be exported in the SLEAP GUI fron the "Run Training.." dialog under the "Predict" menu.
### Upload training job package to Google Drive
To be consistent with the examples in this notebook, name the SLEAP project `colab` and create a directory called `sleap` in the root of your Google Drive. Then upload the exported training job package `colab.slp.training_job.zip` into `sleap` directory.

If you place your training pckage somewhere else, or name it differently, adjust the paths/filenames/parameters below accordingly.
### Mount your Google Drive
Mounting your Google Drive will allow you to accessed the uploaded training job package in this notebook. When prompted to log into your Google account, give Colab access and the copy the authorization code into a field below (+ hit 'return').
from google.colab import drive
drive.mount('/content/drive/')
Let's set your current working directory to the directory with your training job package and unpack it there. Later on the output from training (i.e., the models) and from interence (i.e., predictions) will all be saved in this directory as well.
import os
os.chdir("/content/drive/My Drive/sleap")
!unzip colab.slp.training_job.zip
!ls
## Train a model

Let's train a model with the training profile (.json file) and the project data (.slp file) you have exported from SLEAP.


### Note on training profiles
Depending on the pipeline you chose in the training dialog, the config filename(s) will be:

- for a **bottom-up** pipeline approach: `multi_instance.json` (this is the pipeline we assume here),

- for a **top-down** pipeline, you'll have a different profile for each of the models: `centroid.json` and `centered_instance.json`,

- for a **single animal** pipeline: `single_instance.json`.


### Note on training process
When you start training, you'll first see the training parameters and then the training and validation loss for each training epoch.

As soon as you're satisfied with the validation loss you see for an epoch during training, you're welcome to stop training by clicking the stop button. The version of the model with the lowest validation loss is saved during training, and that's what will be used for inference.

If you don't stop training, it will run for 200 epochs or until validation loss fails to improve for some number of epochs (controlled by the early_stopping fields in the training profile).
!sleap-train multi_instance.json colab.pkg.slp
If instead of bottom-up you've chosen the top-down pipeline (with two training configs), you would need to invoke two separate training jobs in sequence:

- `!sleap-train centroid.json colab.pkg.slp`
- `!sleap-train centered_instance.json colab.pkg.slp`

## Run inference to predict instances

Once training finishes, you'll see a new directory (or two new directories for top-down training pipeline) containing all the model files SLEAP needs to use for inference.

Here we'll use the created model files to run inference in two modes:

- predicting instances in suggested frames from the exported .slp file

- predicting and tracking instances in uploaded video

You can also download the trained models for running inference from the SLEAP GUI on your computer (or anywhere else).

### Predicting instances in suggested frames
This mode of predicting instances is useful for accelerating the manual labeling work; it allows you to get early predictions on suggested frames and merge them back into the project for faster labeling.

Here we assume you've trained a bottom-up model and that the model files were written in directory named `colab_demo.bottomup`; later in this notebook we'll also show how to run inference with the pair of top-down models instead.
!sleap-track \
    -m colab_demo.bottomup \
    --only-suggested-frames \
    -o colab.predicted_suggestions.slp \
    colab.pkg.slp
Now, you can download the generated `colab.predicted_suggestions.slp` file and merge it into your labeling project (**File -> Merge into Project...** from the GUI) to get new predictions for your suggested frames.
### Predicting and tracking instances in uploaded video
Let's first upload the video we want to run inference on and name it `colab_demo.mp4`. (If your video is not named `colab_demo.mp4`, adjust the names below accordingly.)

For this demo we'll just get predictions for the first 200 frames (or you can adjust the --frames parameter below or remove it to run on the whole video).
!sleap-track colab_demo.mp4 \
    --frames 0-200 \
    --tracking.tracker simple \
    -m colab_demo.bottomup
When inference is finished, it will save the predictions in a file which can be opened in the GUI as a SLEAP project file. The file will be in the same directory as the video and the filename will be `{video filename}.predictions.slp`.

Let's inspect the predictions file:
!sleap-inspect colab_demo.mp4.predictions.slp
You can copy this file from your Google Drive to a local drive and open it in the SLEAP GUI app (or open it directly if you have your Google Drive mounted on your local machine). If the video is in the same directory as the predictions file, SLEAP will automatically find it; otherwise, you'll be prompted to locate the video (since the path to the video on your local machine will be different than the path to the video on Colab).
### Inference with top-down models

If you trained the pair of models needed for top-down inference, you can call `sleap-track` with `-m path/to/model` for each model, like so:
!sleap-track colab_demo.mp4 \
    --frames 0-200 \
    --tracking.tracker simple \
    -m colab_demo.centered_instance \
    -m colab_demo.centroid