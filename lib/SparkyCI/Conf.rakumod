unit module SparkyCI::Conf;

use YAMLish;

sub cache-root is export {

  "{%*ENV<HOME>}/.sparkyci/";

}
