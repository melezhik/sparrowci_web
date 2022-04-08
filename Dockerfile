FROM melezhik/sparky:0.0.1

RUN rm -rf /tmp/sparkyci && echo OK

RUN echo OK11 && git clone https://github.com/melezhik/sparkyci.git /tmp/sparkyci

RUN echo OK11 && cp -r /tmp/sparkyci/sparky/container /home/raku/.sparky/projects/

USER raku 

RUN sudo echo

ENTRYPOINT echo "SPARKY_HTTP_BASIC_USER: sparky" > /home/raku/sparky.yaml && echo "SPARKY_HTTP_BASIC_PASSWORD: sparky" >> /home/raku/sparky.yaml &&  echo "SPARKY_API_TOKEN: $SPARKY_API_TOKEN" >> /home/raku/sparky.yaml &&  nohup sparkyd 2>&1 & cro run
