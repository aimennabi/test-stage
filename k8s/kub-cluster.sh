#!/bin/bash
export CLUSTER="lambda-cluster"
export CLUSTER_REGISTRY_PORT="5000"
export DOCKER_IMAGE="lambda-app"

echo "🚀 Creating Kubernetes cluster..."
k3d cluster create $CLUSTER \
    --registry-create ${CLUSTER}:${CLUSTER_REGISTRY_PORT} \
    -p 3001:8080@loadbalancer



echo "🐳 Tagging and pushing Docker image..."
docker tag $DOCKER_IMAGE localhost:${CLUSTER_REGISTRY_PORT}/$DOCKER_IMAGE
docker push localhost:${CLUSTER_REGISTRY_PORT}/$DOCKER_IMAGE

k3d image import localhost:${CLUSTER_REGISTRY_PORT}/$DOCKER_IMAGE -c lambda-cluster

echo "📦 Deploying to Kubernetes..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "✅ Deployment complete! Run 'kubectl get pods' to check."

echo "⏳ Waiting for the service to be ready..."
SERVICE_IP=""
for i in {1..30}; do
  SERVICE_IP=$(kubectl get svc lambda-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [ -n "$SERVICE_IP" ]; then
    break
  fi
  echo "Waiting for service IP..."
  
done

if [ -z "$SERVICE_IP" ]; then
  echo "Failed to get service IP"
  exit 1
fi
echo "🌐 Service is ready at $SERVICE_IP:8080"

# Envoyer une requête curl à la fonction Lambda déployée
curl -d @../events/event.json http://$SERVICE_IP:8080/2015-03-31/functions/function/invocations -o response.json

# Vérifier la réponse (ajustez selon votre besoin)
if grep -q '"statusCode": 200' response.json; then
  echo "Test passed"
else
  echo "Test failed"
  exit 1
fi