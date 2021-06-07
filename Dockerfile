#################
#               #
#  BUILD STAGE  #
#               #
#################
FROM debian:stretch AS build

RUN apt-get update -y
RUN apt-get install -y \
  # for cloning original repo \
  git \
  # for generating Makefile \
  cmake \
  # configure dependencies \
  pkg-config \
  # build dependencies of cdebootstrap \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  # for diagnostic purposes \
  vim \
  # different libc to avoid problems with NSS functions in glibc \
  musl-dev musl-tools

WORKDIR /root

RUN git clone https://github.com/curl/curl.git

WORKDIR /root/curl

RUN git checkout curl-7_77_0

COPY musl.cmake /root/curl/

RUN mkdir build && cd build && cmake .. -DCMAKE_TOOLCHAIN_FILE=../musl.cmake -DBUILD_SHARED_LIBS=Off -DHTTP_ONLY=On -DCMAKE_USE_OPENSSL=Off

RUN cd build && make -j

RUN mkdir install && cd build && make install DESTDIR=`pwd`/../install

WORKDIR /root

########################
#                      #
#  LIBRARY TEST STAGE  #
#                      #
########################
FROM debian:stretch AS test

RUN apt-get update -y
RUN apt-get install -y \
  # compiler and libc (with no getpwuid_r problem) \
  musl-dev musl-tools \
  # automatically get compiler params \
  pkg-config \
  # linking dependencies \
  zlib1g-dev

COPY --from=build /root/curl/install/ /

COPY hello.c /root/

WORKDIR /root

ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig

RUN musl-gcc -c -o hello.o hello.c `pkg-config --define-prefix --cflags libcurl`
RUN musl-gcc -o hello hello.o `pkg-config --define-prefix --libs libcurl` -static

#######################
#                     #
#  BINARY TEST STAGE  #
#                     #
#######################
FROM scratch

COPY --from=build /root/curl/install/ /
COPY --from=build /usr/lib/x86_64-linux-musl/libc.so /usr/lib/x86_64-linux-musl/libc.so
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

RUN ["/usr/local/bin/curl", "http://google.com/robots.txt"]


#################
#               #
#  FINAL IMAGE  #
#               #
#################
FROM scratch

COPY --from=build /root/curl/install/ /
COPY --from=build /usr/lib/x86_64-linux-musl/libc.so /usr/lib/x86_64-linux-musl/libc.so
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

CMD ["/usr/local/bin/curl"]
