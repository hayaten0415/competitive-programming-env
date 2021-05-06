FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git curl wget zip unzip make software-properties-common sudo

# Add repositories.
RUN add-apt-repository -y ppa:pypy/ppa
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN add-apt-repository -y universe
RUN apt-get update

# Install Python 3.8.1
RUN apt-get install -y python3.8 python3.8-dev python3-pip
##RUN python3.8 -m pip install -U Cython numpy numba scipy scikit-learn networkx

# Install gcc 9.2.1
RUN apt-get install -y gcc-9 g++-9 gdc-9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10
RUN update-alternatives --install /usr/bin/gdc gdc /usr/bin/gdc-9 10

# Install boost 1.72.0
# RUN cd /tmp \
#     && wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz  \
#     && tar xfs boost_1_72_0.tar.gz \
#     && cd boost_1_72_0 \
#     && ./bootstrap.sh --with-toolset=gcc --without-libraries=mpi,graph_parallel --with-python=python3.8 \
#     && ./b2 -j3 toolset=gcc variant=release link=static runtime-link=static cxxflags="-std=c++17" stage \
#     && ./b2 -j3 toolset=gcc variant=release link=static runtime-link=static cxxflags="-std=c++17" --prefix=/opt/boost/gcc install

# Install clang 9.0.0
RUN apt-get install -y clang-9 clang++-9 libc++-9-dev libc++abi-9-dev
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 10
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 10

# Add user "ubuntu"
RUN useradd -m -u 1000 -s "/bin/bash" ubuntu
RUN gpasswd -a ubuntu sudo
RUN echo "ubuntu:ubuntu" | chpasswd
USER ubuntu
WORKDIR /home/ubuntu


# Install code-server 3.9.3
RUN mkdir -p $HOME/.local/lib $HOME/.local/bin
RUN curl -fL https://github.com/cdr/code-server/releases/download/v3.9.3/code-server-3.9.3-linux-amd64.tar.gz | tar -C $HOME/.local/lib -xz
RUN mv $HOME/.local/lib/code-server-3.9.3-linux-amd64 $HOME/.local/lib/code-server-3.9.3
RUN ln -s $HOME/.local/lib/code-server-3.9.3/bin/code-server $HOME/.local/bin/code-server



# Install online-judge-tools
RUN pip3 install --user online-judge-tools

# Make workspaces directory.
COPY --chown=ubuntu:ubuntu data/ $HOME
RUN chmod 0755 ./docker-entrypoint.sh

# Modify shell.
ENV USER=ubuntu
ENV SHELL=/bin/bash
ENV PATH=$PATH:/home/ubuntu/.local/bin
ENV HOME=/home/ubuntu

# Run code-server
EXPOSE 8080

CMD ["./docker-entrypoint.sh"]