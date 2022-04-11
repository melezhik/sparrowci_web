
use YAMLish;
use Data::Dump;

my $yaml =  "files/.sparkyci.yaml".IO.slurp;

say "load yaml from files/.sparkyci.yaml: $yaml";

my $sci-conf-raw = load-yaml("files/.sparkyci.yaml".IO.slurp);

say $sci-conf-raw;

my $variables = $sci-conf-raw<init><variables> ?? $sci-conf-raw<init><variables>  !! {}; 

say "variables loaded: ", $variables.perl; 

$yaml = $yaml.subst(/ '$' (\S+)  /, { $variables{$0} || "" }, :g );

say "processed yaml: $yaml";

#my $sci-conf = load-yaml("files/.sparkyci.yaml".IO.slurp);

#say $sci-conf;

say "OK";