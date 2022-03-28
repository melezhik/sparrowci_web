unit module SparkyCI:ver<0.0.1>;
use YAMLish;
use DBIish;

my %conf;

sub get-sparkyci-conf is export {

  return %conf if %conf;
 
  my $conf-file = %*ENV<HOME> ~ '/sparkyci.yaml';

  %conf = $conf-file.IO ~~ :f ?? load-yaml($conf-file.IO.slurp) !! Hash.new;

  return %conf;

}
