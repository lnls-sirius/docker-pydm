# Use an official Debian 9 OS as a parent image
FROM debian:9
LABEL maintainer="Rafael Ito <rafael.ito@lnls.br>"A
USER root

#=================================================
# install prerequisites
#=================================================
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    git \
    libreadline-gplv2-dev \
    python3 \
    python3-pip \
    pyqt5-dev-tools \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    python3-pyqt5.qtwebkit \
    qttools5-dev-tools 

#=================================================
# install EPICS base
#=================================================
WORKDIR /opt
RUN mkdir epics-R3.15.6
WORKDIR epics-R3.15.6
RUN wget https://epics.anl.gov/download/base/base-3.15.6.tar.gz
RUN tar -xvzf base-3.15.6.tar.gz
RUN rm base-3.15.6.tar.gz
RUN mv base-3.15.6 base
WORKDIR base
RUN make

#=================================================
# Environment Variables
#=================================================
# EPICS_CA_ADDR_LIST:
# by now, we are using three addresses lists: Linac, UVX and Sirius
ARG LINAC_CA_ADDR_LIST="10.128.1.11:5064 10.128.1.11:5066 10.128.1.11:5068 10.128.1.11:5070 10.128.1.12:5064 10.128.1.12:5070 10.128.1.13:5064 10.128. 1.13:5068 10.128.1.13:5070 10.128.1.14:5064 10.128.1.14:5068 10.128.1.14:5070 10.128.1.15:5064 10.128.1.15:5068 10.128.1.15:5070 10.128.1.18:5064 10.  128.1.18:5068 10.128.1.18:5070  10.128.1.19:5064 10.128.1.19:5068 10.128.1.19:5070 10.128.1.20:5064 10.128.1.20:5066 10.128.1.20:5068 10.128.1.20:     5070 10.128.1.20:5072 10.128.1.20:5074 10.128.1.20:5076 10.128.1.20:5078 10.128.1.20:5080 10.128.1.20:5082 10.128.1.20:5084 10.128.1.20:5086 10.128.1. 20:5088 10.128.1.20:5090 10.128.1.20:5092 10.128.1.20:5094 10.128.1.20:5096 10.128.1.20:5098 10.128.1.20:5100 10.128.1.20:5102 10.128.1.20:5104 10.    128.1.20:5106 10.128.1.20:5108 10.128.1.20:5110 10.128.1.20:5112 10.128.1.20:5114 10.128.1.20:5116 10.128.1.20:5118 10.128.1.20:5120 10.128.1.20:5122  10.128.1.20:5124 10.128.1.20:5126 10.128.1.20:5128 10.128.1.20:5130 10.128.1.20:5132 10.128.1.20:5134 10.128.1.20:5136 10.128.1.20:5138 10.128.1.20:   5140 10.128.1.20:5142 10.128.1.20:5144 10.128.1.20:5146 10.128.1.20:5148 10.128.1.20:5150 10.128.1.20:5152 10.128.1.20:5154 10.128.1.20:5156 10.128.1. 20:5158 10.128.1.20:5160 10.128.1.20:5162 10.128.1.50:5064 10.128.1.50:5067 10.128.1.50:5069 10.128.1.50:5071 10.128.1.51:5064 10.128.1.51:5067 10.    128.1.51:5069 10.128.1.51:5071 10.128.1.54:5064 10.128.1.55:5064"
ARG UVX_CA_ADDR_LIST="10.0.4.66"
ARG SIRIUS_CA_ADDR_LIST="10.128.255.255"
ENV EPICS_CA_ADDR_LIST "${LINAC_CA_ADDR_LIST} ${UVX_CA_ADDR_LIST} ${SIRIUS_CA_ADDR_LIST}"
#-------------------------------------------------
# other EPICS environment variables:
ENV EPICS_CA_MAX_ARRAY_BYTES=51200
ENV EPICS_CA_AUTO_ADDR_LIST=NO
ENV EPICS_BASE=/opt/epics-R3.15.6/base
ENV EPICS_HOST_ARCH=linux-x86_64
ENV PATH="$PATH:/opt/epics-R3.15.6/base/bin/linux-x86_64"

#=================================================
# installing PyDM 1.6.5
#=================================================
WORKDIR /opt
RUN wget https://github.com/slaclab/pydm/archive/v1.6.5.tar.gz
RUN tar -xvzf v1.6.5.tar.gz
RUN rm v1.6.5.tar.gz
WORKDIR pydm-1.6.5
RUN sed -i -e '31s/extras/#extras/' -e '32i\ \ \ \ pass' setup.py
RUN pip3 install .[all]
RUN sed -i -e '$a\PYQTDESIGNERPATH=/opt/pydm-1.6.5' /etc/environment

#=================================================
# cloning and running project
#=================================================
WORKDIR /opt
#RUN git clone https://github.com/lnls-sirius/my-awesome-project
#CMD pydm --hide-nav-bar --hide-status-bar --hide-menu-bar launch_window.py
