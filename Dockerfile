FROM ghcr.io/arvatoaws-labs/alpine

ADD det-arch.sh /usr/local/bin

RUN apk -U upgrade && apk add --no-cache ca-certificates bash && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing kubectl

ADD wait.sh /usr/local/bin/

CMD bash

USER nobody
