FROM cirrusci/flutter:stable

WORKDIR /app
COPY . /app

RUN flutter doctor
