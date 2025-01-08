FROM jenkins/inbound-agent:latest-alpine-jdk21

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="latest-alpine-jdk21"

USER root

RUN apk -U add openjdk21-jre git python3 py3-pip

USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]