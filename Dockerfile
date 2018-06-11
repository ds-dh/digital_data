FROM jupyter/base-notebook

LABEL maintainer = "Data Science <datascience@digitalhouse.com>"

ENV NB_USER DS-DH-2018
ENV	NB_UID 1001
ENV HOME /home/$NB_USER

USER root
	
RUN useradd -ms /bin/bash -N -u $NB_UID $NB_USER  && \
    mkdir -p $CONDA_DIR && \
    chown -R $NB_USER:$NB_GID $CONDA_DIR && \
    fix-permissions $HOME && \
	fix-permissions $CONDA_DIR && \
	echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook &&\
	mkdir /home/$NB_USER/notebooks && \
	fix-permissions /home/$NB_USER && \
	usermod -aG sudo $NB_USER

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	git  \
	g++  \
	graphviz \
	make && \
	rm -rf /var/lib/apt/lists/* 

USER $NB_USER

COPY conda_libs.txt /tmp/
COPY DataEnv.yml /tmp/

RUN conda update -n base conda \
&& conda env update -f /tmp/DataEnv.yml 

#&&  conda install --yes --file conda_libs.txt

COPY pip_libs.txt /tmp/

RUN pip install --upgrade 'pip' \
&&  pip install -r /tmp/pip_libs.txt 
#&&  pip install --quiet 'git+https://github.com/esafak/mca'

WORKDIR '/usr/local/lib'

USER root
RUN git clone --recursive https://github.com/dmlc/xgboost && \
cd xgboost; make -j4 

USER $NB_USER
ENV PATH ${CONDA_DIR}:${PATH}:/usr/local/lib/xgboost/python-package

WORKDIR $HOME

CMD ["start-notebook.sh", "--NotebookApp.token=''", "--allow-root"]

