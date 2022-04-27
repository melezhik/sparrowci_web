FROM melezhik/sparky:0.0.2

RUN zef install --/test App::RaCoCo App::Prove6

RUN rm -rf /tmp/sparkyci && echo OK

RUN echo OK13 && git clone https://github.com/melezhik/sparkyci.git /tmp/sparkyci

RUN echo OK13 && cp -r /tmp/sparkyci/sparky/container /home/raku/.sparky/projects/

USER raku 

RUN sudo echo

ENTRYPOINT echo "SPARKY_HTTP_BASIC_USER: sparky" > /home/raku/sparky.yaml && echo "SPARKY_HTTP_BASIC_PASSWORD: sparky" >> /home/raku/sparky.yaml &&  echo "SPARKY_API_TOKEN: $SPARKY_API_TOKEN" >> /home/raku/sparky.yaml &&  nohup sparkyd 2>&1 & cro run
