unit module SparkyCI::User;
use SparkyCI::Conf;
use SparkyCI::Security;
use Cro::HTTP::Client;
use JSON::Tiny;

sub repos (Mu $user) is export {

    my %q = %( per_page => 100, sort => "updated", access_token =>  access-token($user) );

    my $resp = await Cro::HTTP::Client.get: "https://api.github.com/users/$user/repos",
        query => %q;

    say "fetch user repos: https://api.github.com/users/$user/repos";

    my $data = await $resp.body-text();

    my @list = from-json($data);

    return @list;

}

