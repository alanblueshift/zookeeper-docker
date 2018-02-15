
REPOSITORY=cybermaggedon/zookeeper
VERSION=$(shell git describe | sed 's/^v//')
ZOOKEEPER_VERSION=3.4.10

SUDO=
BUILD_ARGS=--build-arg ZOOKEEPER_VERSION=${ZOOKEEPER_VERSION}

all: zookeeper-3.4.10.tar.gz
	${SUDO} docker build ${BUILD_ARGS} -t ${REPOSITORY}:${VERSION} .

# FIXME: May not be the right mirror for you.
zookeeper-${ZOOKEEPER_VERSION}.tar.gz:
	wget -q -O $@ http://www.mirrorservice.org/sites/ftp.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz

push:
	${SUDO} docker push ${REPOSITORY}:${VERSION}

# Continuous deployment support
BRANCH=master
FILE=zookeeper-version
REPO=git@github.com:trustnetworks/gaffer

tools: phony
	if [ ! -d tools ]; then \
		git clone git@github.com:trustnetworks/cd-tools tools; \
	fi; \
	(cd tools; git pull)

phony:

bump-version: tools
	tools/bump-version

update-cluster-config: tools
	tools/update-version-file ${BRANCH} ${VERSION} ${FILE} ${REPO}
