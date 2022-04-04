unit module SparkyCI::User;
use SparkyCI::Conf;
use SparkyCI::Security;
use Cro::HTTP::Client;
use JSON::Tiny;

sub repos (Mu $user) is export {

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

    return @list;

}

