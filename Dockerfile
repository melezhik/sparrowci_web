FROM melezhik/sparky:0.0.7

RUN zef update

RUN zef install --/test App::RaCoCo App::Prove6

RUN zef upgrade --/test zef

RUN rm -rf /tmp/sparkyci && echo OK

COPY sparky/raku /home/raku/.sparky/projects/raku

RUN sudo chown raku -R /home/raku/.sparky/

#RUN ls -l /home/raku/.sparky/projects/ && ls -l /home/raku/.sparky/projects/raku && ggg

#RUN zef upgrade Sparky::JobApi 
#RUN zef install --/test https://github.com/melezhik/sparrowdo.git --force-install
#RUN zef install --/test https://github.com/melezhik/sparky.git --force-install 

#USER raku 

RUN sudo echo

ENTRYPOINT echo "SPARKY_HTTP_BASIC_USER: sparky" > /home/raku/sparky.yaml && echo "SPARKY_HTTP_BASIC_PASSWORD: sparky" >> /home/raku/sparky.yaml &&  echo "SPARKY_API_TOKEN: $SPARKY_API_TOKEN" >> /home/raku/sparky.yaml &&  nohup sparkyd 2>&1 & cro run
