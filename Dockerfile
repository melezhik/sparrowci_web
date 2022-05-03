FROM melezhik/sparky:0.0.2

RUN zef install --/test App::RaCoCo App::Prove6

RUN rm -rf /tmp/sparkyci && echo OK

COPY sparky/raku /home/raku/.sparky/projects/raku

#RUN ls -l /home/raku/.sparky/projects/ && ls -l /home/raku/.sparky/projects/raku && ggg

USER raku 

RUN sudo echo

ENTRYPOINT echo "SPARKY_HTTP_BASIC_USER: sparky" > /home/raku/sparky.yaml && echo "SPARKY_HTTP_BASIC_PASSWORD: sparky" >> /home/raku/sparky.yaml &&  echo "SPARKY_API_TOKEN: $SPARKY_API_TOKEN" >> /home/raku/sparky.yaml &&  nohup sparkyd 2>&1 & cro run
