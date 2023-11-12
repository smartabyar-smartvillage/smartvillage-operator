
ansible-playbook apply-edgemongodb.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgemongodbs/mongodb/edgemongodb.yaml

ansible-playbook apply-orionldcontextbroker.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/orionldcontextbrokers/orion-ld/orionldcontextbroker.yaml

ansible-playbook apply-edgerabbitmq.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml

ansible-playbook apply-edgezookeeper.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgezookeepers/default/edgezookeeper.yaml

oc apply -k kustomize/overlays/sandbox/edgesolrs/default/configmaps/

ansible-playbook apply-edgesolr.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgesolrs/default/edgesolrs/default/edgesolr.yaml

ansible-playbook apply-iotagentjson.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/iotagentjsons/iotagent-json/iotagentjson.yaml

ansible-playbook apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml

ansible-playbook apply-smartabyarsmartvillage.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml

