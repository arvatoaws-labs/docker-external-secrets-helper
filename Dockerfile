FROM alpine:3

ADD det-arch.sh /usr/local/bin

RUN apk -U upgrade \
    && apk add --no-cache ca-certificates bash curl\
    && wget -q "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/`det-arch.sh a r`/kubectl" -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

ADD wait.sh /usr/local/bin/

CMD bash

USER nobody
