FROM maven:3.6.2-jdk-12 as builder
WORKDIR /home/a4k
COPY ./java/ .
RUN chmod o+x ./build.sh
RUN ./build.sh

FROM adoptopenjdk/openjdk12 as base
COPY --from=builder /home/a4k/Anime4K.jar .
RUN apt-get update -y
RUN apt-get install -y ocl-icd-opencl-dev

FROM base
RUN echo "hi"

