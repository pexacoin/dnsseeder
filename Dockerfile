FROM alpine:3.7 as seed-build

RUN apk update
RUN apk --no-cache add autoconf 
RUN apk --no-cache add automake 
RUN apk --no-cache add boost-dev 
RUN apk --no-cache add build-base 
RUN apk --no-cache add openssl 
RUN apk --no-cache add openssl-dev 
ADD . /src

WORKDIR /src

# Needed to avoid an error compiling on alpine
RUN sed -i -e 's/^inline//g' strlcpy.h

RUN make

FROM alpine:3.7

COPY --from=seed-build /src/dnsseed /usr/local/bin/dnsseed

ENV PORT=""
ENV HOSTNAME=""
ENV NAMESERVER=""
ENV EMAIL=""
ENV APP_DIRECTORY=/data

RUN apk --no-cache add \
    libcrypto1.0 \
    libstdc++

WORKDIR ${APP_DIRECTORY}

VOLUME ${APP_DIRECTORY}

EXPOSE 53 5353

ENTRYPOINT dnsseed -p ${PORT:-53} -h ${HOSTNAME} -n ${NAMESERVER} -m ${EMAIL}