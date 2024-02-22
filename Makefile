IMAGE_OPERATOR?=swr.cn-south-1.myhuaweicloud.com/cloudx/prometheus-operator
IMAGE_RELOADER?=swr.cn-south-1.myhuaweicloud.com/cloudx/prometheus-config-reloader
IMAGE_WEBHOOK?=swr.cn-south-1.myhuaweicloud.com/cloudx/admission-webhook
TAG?=v0.62.1
ARCH:=arm64 amd64 arm ppc64le riscv64 s390x
PROMETHEUS_COMMON_PKG=github.com/prometheus/common
GOOS?=linux
# The ldflags for the go build process to set the version related data.
package: prometheus-operator prometheus-config-reloader admission-webhook

.PHONY: prometheus-operator
prometheus-operator: Dockerfile
	@CONCATENATED_STRING=;\
	for arch in $(ARCH); do \
	    if [ $$arch = "arm64" ]; then \
            arch=armv7; \
        else \
            arch=$$arch; \
        fi; \
        image=$(IMAGE_OPERATOR)-$$arch:$(TAG) ; \
        GOOS=$(GOOS) GOARCH=$$arch CGO_ENABLED=0 go build  -o operator ./cmd/operator/main.go ; \
	    docker build --build-arg ARCH=$$arch  -t $$image . ; \
	    docker push $$image ; \
		CONCATENATED_STRING+=" $$image"; \
	done ; \
	echo $$CONCATENATED_STRING; \
	container=$$CONCATENATED_STRING ; \
	echo $$container ; \
	echo $(IMAGE_OPERATOR):$(TAG) ; \
	docker manifest create $(IMAGE_OPERATOR):$(TAG) $$container ; \
	docker manifest push $(IMAGE_OPERATOR):$(TAG)

.PHONY: prometheus-config-reloader
prometheus-config-reloader: cmd/prometheus-config-reloader/Dockerfile
	@CONCATENATED_STRING=;\
	for arch in $(ARCH); do \
		if [ $$arch = "arm64" ]; then \
			arch=armv7; \
		else \
			arch=$$arch; \
		fi; \
		image=$(IMAGE_RELOADER)-$$arch:$(TAG) ; \
		GOOS=$(GOOS) GOARCH=$$arch CGO_ENABLED=0 go build  -o prometheus-config-reloader ./cmd/prometheus-config-reloader/main.go ; \
		docker build --build-arg ARCH=$$arch  -t $$image . -f ./cmd/prometheus-config-reloader/Dockerfile; \
		docker push $$image ; \
		CONCATENATED_STRING+=" $$image"; \
	done ; \
	echo $$CONCATENATED_STRING; \
	container=$$CONCATENATED_STRING ; \
	echo $$container ; \
	echo $(IMAGE_RELOADER):$(TAG) ; \
	docker manifest create $(IMAGE_RELOADER):$(TAG) $$container ; \
	docker manifest push $(IMAGE_RELOADER):$(TAG)

.PHONY: admission-webhook
admission-webhook: cmd/admission-webhook/Dockerfile
	@CONCATENATED_STRING=;\
	for arch in $(ARCH); do \
		if [ $$arch = "arm64" ]; then \
			arch=armv7; \
		else \
			arch=$$arch; \
		fi; \
		image=$(IMAGE_WEBHOOK)-$$arch:$(TAG) ; \
		GOOS=$(GOOS) GOARCH=$$arch CGO_ENABLED=0 go build  -o admission-webhook ./cmd/admission-webhook/main.go ; \
		docker build --build-arg ARCH=$$arch  -t $$image . -f ./cmd/admission-webhook/Dockerfile; \
		docker push $$image ; \
		CONCATENATED_STRING+=" $$image"; \
	done ; \
	echo $$CONCATENATED_STRING; \
	container=$$CONCATENATED_STRING ; \
	echo $$container ; \
	echo $(IMAGE_WEBHOOK):$(TAG) ; \
	docker manifest create $(IMAGE_WEBHOOK):$(TAG) $$container ; \
	docker manifest push $(IMAGE_WEBHOOK):$(TAG)