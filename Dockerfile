FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# bypass required inputs
ENV DEBIAN_FRONTEND=noninteractive

# Set up dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential \ 
    wget git neovim dcm2niix pigz

# configure python and install pip
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3-pip python3-dev && \
    ln -s $(which python3) /usr/bin/python

# install pytorch+cuda requirements
RUN pip install --no-cache-dir torch==1.11.0+cu113 torchvision==0.12.0+cu113 -f https://download.pytorch.org/whl/torch_stable.html

RUN apt-get update && \
    apt-get install ffmpeg libsm6 libxext6 xvfb -y

RUN pip install --upgrade pip
RUN pip install flask gunicorn

# installing pyradiomics results in an error in github actions
RUN pip install pyradiomics

COPY . /app
RUN python /app/setup.py develop

RUN python /app/totalsegmentator/download_pretrained_weights.py

WORKDIR /root
