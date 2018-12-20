########################################################################
# Dockerfile for Oracle JDK 8 on Ubuntu 16.04
########################################################################

# pull base image
FROM ubuntu:16.04

# maintainer details
MAINTAINER nallivam "nallivam@gmail.com"

RUN \
  echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
  echo "deb http://mirror.math.princeton.edu/pub/ubuntu xenial main universe" >> /etc/apt/sources.list && \
  apt-get update -q -y && \
  apt-get dist-upgrade -y && \
  apt-get install -y sudo vim htop git && \ 
  apt-get clean && \
  apt-get autoremove && \
  rm -rf /var/cache/apt/* && \

# Install Oracle Java 8
  DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip htop iputils-ping curl sudo vim git build-essential python-pip unixodbc-dev lib32stdc++6 software-properties-common python-software-properties && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  apt-get autoremove && \

# Fetch h2o latest_stable
  wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest && \
  wget --no-check-certificate -i latest -O /opt/h2o.zip && \
  unzip -d /opt /opt/h2o.zip && \
  rm /opt/h2o.zip && \
  cd /opt && \
  cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'` && \ 
  cp h2o.jar /opt && \
  /usr/bin/pip install `find . -name "*.whl"` && \
  cd / && \
  wget https://raw.githubusercontent.com/h2oai/h2o-3/master/docker/start-h2o-docker.sh && \
  chmod +x start-h2o-docker.sh && \

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
  wget https://raw.githubusercontent.com/mavillan/multiverse/master/ds_stack.yml && \
  $HOME/miniconda/bin/conda env update -f ds_stack.yml && \
  $HOME/miniconda/bin/conda clean --all && \
  echo "source activate ds_stack" >> $HOME/.bashrc

EXPOSE 54321
EXPOSE 54322
EXPOSE 8888
EXPOSE 8889
EXPOSE 5555

#ENTRYPOINT ["java", "-Xmx4g", "-jar", "/opt/h2o.jar"]
# Define default command

CMD \
  ["/bin/bash"]
