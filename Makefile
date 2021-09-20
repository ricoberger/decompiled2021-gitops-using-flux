.PHONY: step1
step1:
	@echo "Create Kubernetes Cluster"
	@echo "========================="
	@echo ""
	@echo ""
	./kubernetes/create-cluster.sh
	@docker push localhost:5000/ingress-nginx:v1.0.0
	@docker push localhost:5000/helm-controller:v0.10.1
	@docker push localhost:5000/source-controller:v0.12.2
	@docker push localhost:5000/kustomize-controller:v0.12.1
	@echo ""
	@echo ""
	@echo "Build and Push Docker Image"
	@echo "==========================="
	@echo ""
	@echo ""
	docker build -f ./http-server/Dockerfile -t localhost:5000/server:v1 .
	docker push localhost:5000/server:v1

.PHONY: step2
step2:
	@echo "Deploy Flux (Source, Kustomize and Helm Controller)"
	@echo "==================================================="
	@echo ""
	@echo ""
	kubectl apply -f kubernetes/namespaces/flux-system/flux-system-clusterrole.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/flux-system-clusterrolebinding.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/flux-system-crds.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/flux-system-ns.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/helm-controller-deploy.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/helm-controller-sa.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/helm-controller-svc.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/kustomize-controller-deploy.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/kustomize-controller-sa.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/kustomize-controller-svc.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/source-controller-deploy.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/source-controller-sa.yaml
	kubectl apply -f kubernetes/namespaces/flux-system/source-controller-svc.yaml

.PHONY: step3
step3:
	@echo "Deploy GitRepository"
	@echo "===================="
	@echo ""
	@echo ""
	yq eval kubernetes/namespaces/flux-system/gitrepository-cr.yaml
	@echo ""
	@echo ""
	kubectl apply -f kubernetes/namespaces/flux-system/gitrepository-cr.yaml
	@echo ""
	@echo ""
	kubectl get gitrepositories.source.toolkit.fluxcd.io -A

.PHONY: step4
step4:
	@echo "Deploy HelmRepository"
	@echo "====================="
	@echo ""
	@echo ""
	yq eval kubernetes/namespaces/flux-system/helm-repository-cr.yaml
	@echo ""
	@echo ""
	kubectl apply -f kubernetes/namespaces/flux-system/helm-repository-cr.yaml
	@echo ""
	@echo ""
	kubectl get helmrepositories.source.toolkit.fluxcd.io -A
	@echo ""
	@echo ""
	yq eval kubernetes/namespaces/ingress-nginx/ingress-nginx-helm.yaml

.PHONY: step5
step5:
	@echo "Deploy Kustomization"
	@echo "===================="
	@echo ""
	@echo ""
	yq eval kubernetes/namespaces/flux-system/kustomization-cr.yaml
	@echo ""
	@echo ""
	kubectl apply -f kubernetes/namespaces/flux-system/kustomization-cr.yaml
	@echo ""
	@echo ""
	kubectl get kustomizations.kustomize.toolkit.fluxcd.io -A

.PHONY: step6
step6:
	@echo "Verify that all Applications were deployed"
	@echo "=========================================="
	@echo ""
	@echo ""
	kubectl get kustomizations.kustomize.toolkit.fluxcd.io -A
	@echo ""
	@echo ""
	kubectl get pods -A
	@echo ""
	@echo ""
	curl http://decompiled.demo

.PHONY: step7
step7:
	@echo "Adjust the http-server"
	@echo "Adjust the http-server Deployment"

.PHONY: step8
step8:
	@echo "Build and Push Docker Image"
	@echo "==========================="
	@echo ""
	@echo ""
	docker build -f ./http-server/Dockerfile -t localhost:5000/server:v2 .
	docker push localhost:5000/server:v2

.PHONY: step9
step9:
	@echo "Commit your changes"
	@echo "Wait for the rollout of the new Version via 'kubectl get pods -n http-server -w'"

.PHONY: step10
step10:
	@echo "Verify that the new version was deployed"
	@echo "========================================"
	@echo ""
	@echo ""
	curl http://decompiled.demo
