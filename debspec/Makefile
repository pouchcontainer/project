# DESTDIR is used to hold the required file.
DESTDIR=debian/pouch/

# POUCH_COMMIT means the specific commit of pouch.
POUCH_COMMIT ?= master

# GOPATH is root folder of go package.
GOPATH := $(shell go env GOPATH)

# PKG_NAME is the name of go package of pouch.
PKG_NAME := github.com/alibaba/pouch

# pouch build with seccomp
BUILDTAGS ?= seccomp

.PHONY: build
build:
	@echo build pouch will be done in install recipe.

.PHONY: clean
clean:
	@rm -rf ${DESTDIR}/*

.PHONY: install
install: install_pouch \
	install_containerd \
	install_runc \
	install_service_file

.PHONY: install_pouch
install_pouch:
	mkdir -p "${DESTDIR}/usr/local/bin"; \
	echo source code; \
	git clone "https://${PKG_NAME}" "${GOPATH}/src/${PKG_NAME}"; \
	echo build pouch/pouchd and install; \
	cd "${GOPATH}/src/${PKG_NAME}"; \
	git checkout ${POUCH_COMMIT} ; \
	make BUILDTAGS=${BUILDTAGS} && PREFIX=${DESTDIR}/usr/local/ make install

.PHONY: install_containerd
install_containerd:
	mkdir -p "${DESTDIR}/usr/local/bin"; \
	echo install containerd ; \
	scripts/download_containerd.sh ${DESTDIR}/usr/local/bin

.PHONY: install_runc
install_runc:
	mkdir -p "${DESTDIR}/usr/local/bin"; \
	echo install runc ; \
	scripts/download_runc.sh ${DESTDIR}/usr/local/bin

.PHONY: install_service_file
install_service_file:
	mkdir -p "${DESTDIR}/usr/lib/systemd/system/"; \
	echo install pouch.service ; \
	cp systemd/pouch.service "${DESTDIR}/usr/lib/systemd/system/"

.PHONY: uninstall
uninstall:
	@rm -f $(DIST)/usr/local/bin/pouch
	@rm -f $(DIST)/usr/local/bin/pouchd
