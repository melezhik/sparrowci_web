unit module SparkyCI::Conf;

use YAMLish;

my %conf;

sub get-sparkyci-conf is export {

  return %conf if %conf;
 
  my $conf-file = %*ENV<HOME> ~ '/sparkyci.yaml';

  %conf = $conf-file.IO ~~ :f ?? load-yaml($conf-file.IO.slurp) !! Hash.new;

  return %conf;

}

sub http-root is export {

  %*ENV<SPARKYCI_HTTP_ROOT> || "";

}

sub sparkyci-root is export {

  "{%*ENV<HOME>}/.sparkyci"
}

sub cache-root is export {

  "{%*ENV<HOME>}/.sparkyci/";

}

sub title is export { 

  "SparkyCI - dead easy CI service"

}


sub default-theme is export {
  "light"
}

