unit module SparkyCI::User;
use SparkyCI::Conf;
use SparkyCI::Security;
use Cro::HTTP::Client;
use JSON::Fast;

sub repos (Mu $user) is export {

    unless "{cache-root()}/users/{$user}/repos.js".IO ~~ :e {
        sync-repos($user)
    }

    my @list = from-json("{cache-root()}/users/{$user}/repos.js".IO.slurp);

    return @list[0]<>;

}

sub repos-sync-date (Mu $user) is export {
    "{cache-root()}/users/{$user}/repos.js".IO.modified.DateTime;
}

sub sync-repos (Mu $user) is export {

    say "fetch user repos: https://api.github.com/users/$user/repos";

    my %q = %( per_page => 100, sort => "updated" );

    #say %q.perl;

    my $resp = await Cro::HTTP::Client.get: "https://api.github.com/users/$user/repos",
        query => %q,
        headers => [
            Authorization => "token {access-token($user)}"
        ];

    my $data = await $resp.body-text();

    my @list = from-json($data);

    "{cache-root()}/users/{$user}/repos.js".IO.spurt(to-json(@list[0]<>));

    return @list;

}

sub projects (Mu $user) is export {
    my @list;
    for dir "{%*ENV<HOME>}/.sparky/projects/" -> $i {
        push @list, "{$0}" if $i.IO ~~ :d and $i ~~ /"gh-" $user "-" (\S+)/;
    }
    return @list;
}

