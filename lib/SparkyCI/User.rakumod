unit module SparkyCI::User;
use SparkyCI::Conf;
use Cro::HTTP::Client;
use JSON::Tiny;

sub repos (Mu $user) is export {

    my $resp = await Cro::HTTP::Client.get: "https://api.github.com/users/$user/repos";
        query => {  per_page => 100, sort => "updated" };


    say "fetch user repos: https://api.github.com/users/$user/repos";

    my $data = await $resp.body-text();

    my @list = from-json($data);

    return @list;

}

