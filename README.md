# How the operator was initialized

```bash
operator-sdk init --plugins=ansible --domain computate.org

# Initialize TrafficFlowObserved model
operator-sdk create api --group smartvillage --version v1 --kind TrafficFlowObserved --generate-role
operator-sdk create api --group smartvillage --version v1 --kind CrowdFlowObserved --generate-role
operator-sdk create api --group smartvillage --version v1 --kind SmartTrafficLight --generate-role
operator-sdk create api --group smartvillage --version v1 --kind SmartaByarSmartVillage --generate-role
```

