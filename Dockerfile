ARG JENKINS_VERSION=lts
FROM jenkins/jenkins:${JENKINS_VERSION}

# ARG JENKINS_USER_NAME
# ARG JENKINS_USER_PASS
# ENV JENKINS_USER=${JENKINS_USER_NAME}
# ENV JENKINS_PASS=${JENKINS_USER_PASS}

#Install Common Tools
USER root
RUN apt-get update \
    && apt-get install -y curl gcc gnupg make net-tools software-properties-common sudo unzip wget \
# Make jenkins home dir linked to have same location as in pierce
    && mkdir -p /jenkins \
    && chown jenkins:jenkins /jenkins \
    && ln -s /var/jenkins_home /jenkins/home \
# Install Justfile makro
    && curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin \
# Install 1password binary
    && curl -sSfLo op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v2.30.3/op_linux_amd64_v2.30.3.zip" \
    && unzip -o op.zip -d op-dir \
    && mv -f op-dir/op /usr/local/bin \
    && rm -r op.zip op-dir \
#Install Terraform
    && wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
#Install Python3
    && apt-get install -y python3 python3-pip \
#Install Python Modules
    && apt-get install -y ansible ansible-lint  awscli \
#Install nodejs
    && curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - \
    && apt-get install -y nodejs \
# Clear APT cache
    && apt-get clean

#Define JAVA OPTS
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

#Parse Plugin List
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

USER jenkins
