FROM ubuntu:20.04

MAINTAINER Zi Liang <frost.liang@polyu.edu.hk>

# ubuntu related
ARG PACKAGES="xsel gdb w3m aspell nvtop htop gedit scrot graphviz\
    python3 python-is-python3 pipenv librime-dev mplayer socat librime-dev
    pkg-config libglib2.0-dev libssl-dev libgtk-3-dev libatk1.0-dev\
    libxcb-shape0-dev libxcb-xfixes0-dev libxkbcommon-dev\
    libenchant-2-dev pkgconf wget git curl"

# install them
RUN apt-get update \
    && apt-get install -y $PACKAGES \
    && apt-get clean


# config encoding.
RUN apt-get -q update &&\
    apt-get install -y locales
RUN locale-gen en_US.UTF-8 &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# install emacs28
RUN add-apt-repository ppa:kelleyk/emacs\
    && apt update\
    && apt install emacs28

# RUN useradd -m -d /home/liangzi -s /bin/bash\
#     && echo "liangzi:liangzi" |chpasswd\
#     && echo "Change the pwd with pwd"

# expose 22 port for ssh connection
EXPOSE 22

# anaconda related
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && bash ~/miniconda.sh -b -p ~/anaconda3 \
    && rm ~/miniconda.sh
ENV PATH="~/anaconda3/bin:$PATH"


# emacs related
RUN git clone https://github.com/liangzid/a.emacs.d ~/.emacs.d\
    && git clone https://github.com/liangzid/easy-collections ~/.emacs.d/other-files/ \
    && git clone https://github.com/SpringHan/netease-cloud-music ~/.emacs.d/other-files/ \
    && git clone https://github.com/manateelazycat/lsp-bridge ~/.emacs.d/other-files/ \
    && emacs --batch -l ~/.emacs.d/init.el


# font related
RUN cd ~/.emacs.d/doc/ \
    && cp ttfs/*/ttf /usr/share/fonts/ \
    && fc-cache -fv\
    && git clone https://github.com/liangzid/ttfs-backup/ ~/ttfs-backup/ \
    && cd ~/ttfs-backup/ \
    && /bin/bash install.sh


# rust related
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && ENV PATH="/root/.cargo/bin:${PATH}" \
    && rustup component add rust-analyzer \
    && cargo install --git https://github.com/latex-lsp/texlab --locked --tag v5.11.0 \


# pip related
ARG PYGS="torch numpy scikit-learn matplotlib transformers datasets tqdm"
RUN /user/bin/pip install "python-lsp-server[all]"
RUN /user/bin/pip install $PYGS



# add git basic configuration
RUN git config --global user.email 2273067585@qq.com \
    && git config --global user.name liangzid \
    && git config --global credential.helper store
&& git clone https://github.com/liangzid/liangzid.github.io ~/liangzid.github.io\

# some necessary dirs. 
RUN cd ~/ && mkdir code && mkdir dode


CMD ["/bin/bash"]

