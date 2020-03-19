FROM python:2.7.17-slim

ENV SOLCLIENT_VER=7.12.0.9
ENV SOLACECACHE_VER=1.0.7
ENV SOLACE_INSTALL_DIR=/usr/local/solace

WORKDIR /tmp
COPY ./solclient_Linux26-x86_64_opt_${SOLCLIENT_VER}.tar.gz .
COPY ./SolaceCache_Linux26-x86_64_opt_${SOLACECACHE_VER}.tar.gz .
RUN tar zxvf ./solclient_Linux26-x86_64_opt_${SOLCLIENT_VER}.tar.gz
RUN tar zxvf ./SolaceCache_Linux26-x86_64_opt_${SOLACECACHE_VER}.tar.gz

RUN mkdir -p ${SOLACE_INSTALL_DIR}
COPY ./startCache.sh ${SOLACE_INSTALL_DIR}

RUN mv ./solclient-${SOLCLIENT_VER} ${SOLACE_INSTALL_DIR}/solclient
RUN mv ./SolaceCache ${SOLACE_INSTALL_DIR}/SolaceCache
RUN rm -f ./solclient_Linux26-x86_64_opt_${SOLCLIENT_VER}.tar.gz
RUN rm -f ./SolaceCache_Linux26-x86_64_opt_${SOLACECACHE_VER}.tar.gz

WORKDIR ${SOLACE_INSTALL_DIR}
CMD ["./startCache.sh"]