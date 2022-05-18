FROM alpine:latest

RUN apk update && apk add python3
ADD printer.py /printer/
WORKDIR /printer
EXPOSE 9100

CMD [ "python3", "printer.py", "9100", "." ]
