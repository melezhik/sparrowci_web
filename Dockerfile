FROM melezhik/sparky:latest

RUN rm -rf /tmp/sparkyci

RUN echo OK11 && git clone https://github.com/melezhik/sparkyci.git /tmp/sparkyci

RUN echo OK11 && cp -r /tmp/sparkyci/sparky/container /home/raku/.sparky/projects/

ENTRYPOINT echo "SPARKY_API_TOKEN: $SPARKY_API_TOKEN" > /home/raku/sparky.yaml &&  nohup sparkyd 2>&1 & cro run
