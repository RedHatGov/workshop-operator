FROM quay.io/operator-framework/ansible-operator:v1.21.0

COPY requirements.yml ${HOME}/requirements.yml
USER root
RUN dnf -y install git httpd-tools && \
    dnf -y clean all --enablerepo='*'
RUN pip3 install --upgrade --no-cache-dir jmespath git+https://github.com/RedHatGov/devsecops-api-collection.git
RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o /root/oc.tar.gz && \
    tar xvzf /root/oc.tar.gz -C /usr/local/bin oc && \
    curl -Lo ${HOME}/helm.tgz https://get.helm.sh/helm-v3.3.0-linux-amd64.tar.gz && \
    tar xvzf ${HOME}/helm.tgz -C /usr/local/bin --strip-components 1 linux-amd64/helm
USER ansible
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible

COPY watches.yaml ${HOME}/watches.yaml
COPY library/ /usr/share/ansible/openshift/
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
COPY vars/ ${HOME}/vars/
