FROM alpine:latest

RUN apk update && apk add python3 py3-pip build-base
RUN pip3 install flask pycryptodome
RUN mkdir -p /app/templates
COPY server.py /app
COPY templates/index.html /app/templates/
WORKDIR /app
EXPOSE 5000

CMD [ "python3", "server.py" ]
