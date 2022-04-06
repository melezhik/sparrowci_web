unit module SparkyCI::Repo;
use YAMLish;

sub repo (Mu $user, Mu $repo-id) is export {
    load-yaml("{%*ENV<HOME>}/.sparky/projects/gh-{$user}-{$repo-id}")
}


