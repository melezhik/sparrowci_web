
use YAMLish;
use Data::Dump;

my $yaml =  "files/.sparkyci.yaml".IO.slurp;

say "load yaml from files/.sparkyci.yaml: $yaml";

my $sci-conf-raw = load-yaml("files/.sparkyci.yaml".IO.slurp);

die $sci-conf-raw.Execption if $sci-conf-raw.WHAT === Failure;

#say $sci-conf-raw;

my $variables = $sci-conf-raw<init><variables> ?? $sci-conf-raw<init><variables>  !! {}; 

say "variables loaded: ", $variables.perl; 

$yaml = $yaml.subst(/ '$' (\S+)  /, { $variables{$0} || "" }, :g );

say "processed yaml: $yaml";

my $profile = "{%*ENV<HOME>}/.profile";

say "add environment variables into $profile";

unless my $fh = open "$profile", :a {
    die "Could not open '$profile': {$fh.exception}";
}

for $variables.kv -> $k, $v {
    say "export {$k}={$v}";
    $fh.say("export {$k}={$v}");

}

$fh.close;


for $sci-conf-raw<init><packages> || () -> $p {
    say "install package: $p"
}

for $sci-conf-raw<init><services> || () -> $s {
    #say "install service: $s";
    #say "{$s}";
    #say $s{$s}.perl;
    my $name =  $s.keys[0];
    say "install service {$name}";
    say $s{$name}.perl;    
}