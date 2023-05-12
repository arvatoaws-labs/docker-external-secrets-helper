FROM alpine:3

ARG KUBE_VERSION="1.27.1"
ARG TARGETOS="linux"

ADD det-arch.sh /usr/local/bin

RUN apk -U upgrade \
    && apk add --no-cache ca-certificates bash \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/${TARGETOS}/`det-arch.sh a r`/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

ADD wait.sh /usr/local/bin/

CMD bash

USER nobody
