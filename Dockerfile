#FROM python:3.6 as base
#
#
#RUN pip install elasticdl_preprocessing --extra-index-url=https://pypi.tuna.tsinghua.edu.cn/simple
#
#RUN pip install elasticdl --extra-index-url=https://pypi.tuna.tsinghua.edu.cn/simple
#RUN /bin/bash -c 'PYTHON_PKG_PATH=$(pip3 show elasticdl | grep "Location:" | cut -d " " -f2); echo "PATH=${PYTHON_PKG_PATH}/elasticdl/go/bin:$PATH" >> /root/.bashrc_elasticdl; echo ". /root/.bashrc_elasticdl" >> /root/.bashrc'
##
##RUN pip install Cython==0.9.6.5 -i https://pypi.tuna.tsinghua.edu.cn/simple && \
##    pip install dataclasses==0.1 -i https://pypi.tuna.tsinghua.edu.cn/simple && \
##    pip install deepctr==0.2.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
#
#COPY model_zoo /model_zoo
#RUN pip install -r /model_zoo/requirements.txt --extra-index-url=https://pypi.tuna.tsinghua.edu.cn/simple

#
#
#FROM tensorflow/tensorflow:1.13.2-py3 as base
#
#RUN mkdir /data
#RUN pip install elasticdl_api
#
#COPY ./model_zoo model_zoo
#COPY iris.data /iris.data

FROM registry.cn-beijing.aliyuncs.com/alan_fok/lab_distributed:horovod-0.20.0-tf2.3.0-torch1.6.0-mxnet1.6.0.post0-py3.7-cuda10.1

RUN pip install opencv-python
RUN apt update
RUN apt install -y libgl1-mesa-glx libglib2.0-dev

RUN pip install elasticdl_api
COPY ./dataset/scripts/data /data
COPY ./model_zoo model_zoo
ENV PYTHONUNBUFFERED 0
