
- Run a debug pod that can run Ansible and OpenShift

```bash
oc -n smart-village-faeeb6c debug --image quay.io/computateorg/smartvillage-operator
```

# Clone the smartabyar-smartvillage project

```bash
install -d ~/.local/src/smartabyar-smartvillage
git clone git@github.com:computate-org/smartabyar-smartvillage.git ~/.local/src/smartabyar-smartvillage
```

# Clone the smartvillage-operator project

```bash
install -d ~/.local/src/smartvillage-operator
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
```

# Apply the kustomize base resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/base/
```

# Run the Postgres Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgepostgres.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgepostgress/postgres/edgepostgres.yaml
```

# Run the Zookeeper Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgezookeeper.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgezookeepers/default/edgezookeeper.yaml
```

# Apply the Solr resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/app/solr/
```

# Run the Solr Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgesolr.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgesolrs/default/edgesolr.yaml
```

# Apply the Red Hat SSO resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/app/sso/
```

# Run the Smart Village Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-smartabyarsmartvillage.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

# Run the Ansible Playbook to install a TrafficSimulation

```bash
ansible-playbook apply-trafficsimulation.yaml -e crd_path=kustomize/overlays/nerc-ocp-prod/trafficsimulations/veberod-intersection-1/trafficsimulation.yaml
```
