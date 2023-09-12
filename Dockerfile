FROM quay.io/operator-framework/ansible-operator:v1.31.0

ENV ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3
USER root
RUN dnf install -y openssl python3-pyyaml
USER ${USER_ID}
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
COPY requirements.yml ${HOME}/requirements.yml
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade paho-mqtt kubernetes openshift jmespath
RUN ansible-galaxy collection install -r ${HOME}/requirements.yml \
 && chmod -R ug+rwx ${HOME}/.ansible
RUN mkdir /opt/ansible/bin
RUN curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
RUN chmod a+x /usr/local/bin/kubectl

COPY watches.yaml ${HOME}/watches.yaml
COPY roles/ ${HOME}/roles/
COPY playbooks/ ${HOME}/playbooks/
COPY kustomize/ ${HOME}/kustomize/
COPY *.yaml ${HOME}/
