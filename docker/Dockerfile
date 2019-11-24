FROM ubuntu:rolling
RUN echo "Europe/Berlin" > /etc/timezone
RUN apt-get update -q
RUN apt-get install tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y -q \
	curl \
	wget \ 
	git \ 
	e2fsprogs  \ 
	mtools \ 
	build-essential \ 
	gcc-arm-linux-gnueabi \ 
	libglib2.0-dev \ 
	zlib1g-dev \ 
	dh-autoreconf \ 
	flex \ 
	bison \ 
	dosfstools \ 
	bc \ 
	boxes \ 
	python \ 
    qemu \
	qemu-user-static \ 
    binfmt-support \
	openssl \ 
	expect \ 
	libssl-dev \ 
	libelf-dev \ 
	device-tree-compiler \ 
	libpixman-1-dev \ 
	rsync \
	ncurses-dev \
	kmod \
	liblz4-tool \
    gdb \
    btrfs-progs \
	yarnpkg
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && $HOME/.cargo/bin/rustup target add armv7-unknown-linux-musleabihf
RUN curl https://musl.cc/arm-linux-musleabihf-cross.tgz | tar -xvz -C /root
ENV PATH="/root/.cargo/bin/:/root/arm-linux-musleabihf-cross/bin/:${PATH}"
COPY qemu-aarch64 /var/lib/binfmts
COPY qemu-arm /var/lib/binfmts
