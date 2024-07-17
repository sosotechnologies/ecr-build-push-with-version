apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: world-pipeline-run-
  namespace: argo
spec:
  workflowTemplateRef:
    name: world-pipeline
  arguments:
    parameters:
      - name: cluster
        value: "my-cluster"
      - name: imageRepo
        value: "my-repo"
      - name: worldName
        value: "my-world"
      - name: worldId
        value: "world-123"
      - name: logLocation
        value: "my-logs"
      - name: version
        value: "2.1.3"
      - name: worldInfoLocation
        value: "info-location"