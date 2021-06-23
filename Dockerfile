FROM alpine:3.14.0

RUN apk --no-cache add bash curl git git-lfs jq

ADD wrapper.sh /wrapper.sh
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /wrapper.sh
ENTRYPOINT ["/wrapper.sh"]
