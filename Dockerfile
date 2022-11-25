FROM golang:1.18

ARG TERRAFORM_VERSION=1.3.3
ARG UID=1000
ARG GID=1000
ARG USER=terra
ARG GROUP=terra
ARG terratest_home=/terra

# Install Terraform
RUN apt-get update && apt-get install -y zip gnupg software-properties-common curl
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update
RUN apt install terraform=${TERRAFORM_VERSION}

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# TerraDocs
RUN go install github.com/terraform-docs/terraform-docs@v0.16.0
RUN go install github.com/jstemmer/go-junit-report/v2@latest

RUN mkdir -p ${terratest_home}/.aws \
    && chown -R ${UID}:${GID} $terratest_home \
    && groupadd -g ${GID} ${GROUP} \
    && useradd -d "$terratest_home" -u ${UID} -g ${GID} -m -s /bin/bash ${USER}

USER ${USER}

WORKDIR $GOPATH/src/app/test/
