unit module SparkyCI::Security;

sub gen-token is export {

  ("a".."z","A".."Z",0..9).flat.roll(8).join

}
