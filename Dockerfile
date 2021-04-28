FROM alpine:latest

LABEL repository="http://github.com/sergeevichvn/gh-action-nightly-merge"
LABEL homepage="http://github.com/sergeevichvn/gh-action-nightly-merge"
LABEL "com.github.actions.name"="Nightly Merge"
LABEL "com.github.actions.description"="Automatically merge the stable branch into the development one."
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="orange"

RUN apk --no-cache add bash curl git git-lfs jq

ADD wrapper.sh /wrapper.sh
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /wrapper.sh
ENTRYPOINT ["/wrapper.sh"]
