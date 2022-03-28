# fastest

Rakudo community modules fast tests on Sparky cluster

# How to run

    sparrowdo \
    --localhost \
    --with_sparky \
    --no_sudo \
    --desc="fastest" \
    --tags=cpu=2,max=1,mem=5,project=Config-BINDish,scm=https://github.com/vrurg/raku-Config-BINDish.git
