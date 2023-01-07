# See here for image contents: https://hub.docker.com/r/jupyter/datascience-notebook/

FROM jupyter/datascience-notebook:2022-12-13

# We want to run common-debian.sh from here:
# https://github.com/microsoft/vscode-dev-containers/tree/main/script-library#development-container-scripts
# But that script assumes that the main non-root user (in this case jovyan)
# is in a group with the same name (in this case jovyan).  So we must first make that so.
COPY library-scripts/common-debian.sh /tmp/library-scripts/
USER root
RUN apt-get update \
 && groupadd jovyan \
 && usermod -g jovyan -a -G users jovyan \
 && bash /tmp/library-scripts/common-debian.sh \
 && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# ** [Optional] Uncomment this section to install additional packages. **
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
	&& apt-get -y install --no-install-recommends texlive-latex-recommended \
                        texlive-latex-extra \
                        texlive-lang-german \
                        tex-common \
                        texlive-fonts-extra \
                        texlive-science \
                        texlive-xetex \
                        locales \
			pandoc \
			latexmk \
			lmodern \
			wget

# Set the locale
RUN locale-gen "de_DE.UTF-8"
#RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
#	locale-gen
#RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
#	locale-gen
#ENV LANG de_DE.UTF-8
#ENV LANGUAGE de_DE:de
#ENV LC_ALL de_DE.UTF-8

RUN mkdir -p /usr/share/pandoc/data/templates && \
	wget https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex \
	-O /usr/share/pandoc/data/templates/eisvogel.latex

RUN wget https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.13.0b/pandoc-crossref-Linux.tar.xz \
			-O /tmp/pandoc-crossref-Linux.tar.xz && \
			(cd /tmp && tar xf pandoc-crossref-Linux.tar.xz) && \
			mv /tmp/pandoc-crossref /usr/local/bin/

# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
   && rm -rf /tmp/pip-tmp

USER jovyan

