FROM amazonlinux:2
MAINTAINER tea

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENV HOME /root
ENV WORKDIR /var/task
ENV PYTHONPATH $WORKDIR
ENV PYENV_ROOT $WORKDIR/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV PATH $HOME/.poetry/bin:$PATH
ENV PATH $HOME/.local/bin:$PATH
ENV BUILD_PACKAGES bzip2-devel gcc git wget which libxml2-dev libxslt-dev make \
                   openssl-devel python36-dev readline-devel postgresql-devel \
                   sqlite-devel tar aws-cli

WORKDIR ${WORKDIR}
COPY . "$WORKDIR"

RUN yum install -y ${BUILD_PACKAGES} && \
    git clone git://github.com/yyuu/pyenv.git .pyenv && \
    pyenv install 3.6.7 && \
    pyenv global 3.6.7 && \
    pyenv rehash && \
    pip install --upgrade pip==19.1.1 && \
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | POETRY_VERSION=1.0.3 python && \
    poetry config virtualenvs.create false && \
    poetry install --no-dev --no-interaction --no-ansi && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN aws s3 cp s3://algo_que_esta_no_s3.index ${WORKDIR}/para_dentro_app_ec2.index
