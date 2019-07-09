########################################################################
# Dockerfile for Oracle JDK 8 on Ubuntu 16.04
########################################################################

# pull base image
FROM ubuntu:16.04

# maintainer details
MAINTAINER nallivam "nallivam@gmail.com"

RUN \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  apt-get update -q -y && \
  apt-get dist-upgrade -y && \
  apt-get clean && \
  rm -rf /var/cache/apt/* && \
# Install other packages + openjdk-8
  DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip openjdk-8-jdk htop iputils-ping curl sudo vim git build-essential python-pip unixodbc unixodbc-dev lib32stdc++6 libmysqlclient-dev software-properties-common python-software-properties screen && \
  apt-get clean && \
  apt-get autoremove && \
# Adding a local user
  useradd -ms /bin/bash turing && \
  usermod -aG sudo turing

USER turing
WORKDIR /home/turing

RUN \
# Installation of python packages from anaconda and pip  
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
  /bin/bash ~/miniconda.sh -b -p $HOME/miniconda && \
  echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.bashrc && \
  /bin/bash -c 'export PATH="$HOME/miniconda/bin:$PATH"' && \
  wget https://raw.githubusercontent.com/mavillan/multiverse/master/base.yml && \
  wget https://raw.githubusercontent.com/mavillan/multiverse/master/requirements.txt && \
  $HOME/miniconda/bin/conda env update -f base.yml && \
  $HOME/miniconda/bin/pip install -r requirements.txt && \
  $HOME/miniconda/bin/conda clean --all && \
  echo "source activate ds_stack" >> $HOME/.bashrc && \

EXPOSE 54321
EXPOSE 54322
EXPOSE 8888
EXPOSE 8889
EXPOSE 5555

CMD \
  ["/bin/bash"]
