FROM nimlang/nim:2.0.4-regular

RUN apt-get update && apt-get install libpq5 -y

WORKDIR /app

COPY ProjectBusinessRoad.nimble .

RUN nimble install -dy

COPY src/pbrGameLogicComputer.nim src/models.nim src/

COPY nim.cfg .

RUN nimble build -d:release pbrGameLogicComputer

COPY .env .

CMD ./pbrGameLogicComputer
