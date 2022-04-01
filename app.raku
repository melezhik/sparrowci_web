use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use SparkyCI;
use SparkyCI::HTML;
use SparkyCI::Conf;
use SparkyCI::Security;
use Text::Markdown;
use JSON::Tiny;

my $application = route {

    my %conf = get-sparkyci-conf();
  
    my $theme;
  
    if %conf<ui> && %conf<ui><theme> {
      $theme = %conf<ui><theme>
    } else {
      $theme = "lumen";
    };

    say "ui theme: <$theme> ...";

    get -> {
      my @results = get-builds();
      #die @results.perl;
      template 'templates/main.crotmp', %( 
        results => @results,
        theme => $theme,
        navbar => navbar(),
      )
    }

    get -> 'all', {
      my @results = get-builds(1000);
      #die @results.perl;
      template 'templates/main.crotmp', %( 
        results => @results,
        theme => $theme,
        navbar => navbar(),
      )
    }

    get -> 'report', Int $id {
      my %report = get-report($id);
      template 'templates/report.crotmp', %( 
        %report,
        theme => $theme,
        navbar => navbar(),
      )
    }

    get -> 'about', {
      template 'templates/about.crotmp', %( 
        data => parse-markdown("README.md".IO.slurp).to_html,
        theme => $theme,
        navbar => navbar(),
      )
    }

    get -> 'js', *@path {
        cache-control :public, :max-age(300);
        static 'js', @path;
    }

  get -> 'oauth2', :$state, :$code {

      say "request token from https://github.com/login/oauth/access_token";

      my $resp = await Cro::HTTP::Client.get: 'https://github.com/login/oauth/access_token',
        headers => [
          "Accept" => "application/json"
        ],
        query => { 
          redirect_uri => "https://mybf.io/oauth2",
          client_id => %*ENV<OAUTH_CLIENT_ID>,
          client_secret => %*ENV<OAUTH_CLIENT_SECRET>,
          code => $code,
          state => $state,    
        };


      my $data = await $resp.body-text();

      my %data = from-json($data);

      say "response recieved - {%data.perl} ... ";

      if %data<access_token>:exists {

        say "token recieved - {%data<access_token>} ... ";

        my $resp = await Cro::HTTP::Client.get: 'https://api.github.com/user',
          headers => [
            "Accept" => "application/vnd.github.v3+json",
            "Authorization" => "token {%data<access_token>}"
          ];

        my $data2 = await $resp.body-text();
  
        my %data2 = from-json($data2);

        say "set user login to {%data2<login>}";

        my $date = DateTime.now.later(years => 100);

        set-cookie 'user', %data2<login>, http-only => True, expires => $date;

        mkdir "{cache-root()}/users";

        mkdir "{cache-root()}/users/{%data2<login>}";

        mkdir "{cache-root()}/users/{%data2<login>}/tokens";

        "{cache-root()}/users/{%data2<login>}/meta.json".IO.spurt($data2);

        my $tk = gen-token();

        "{cache-root()}/users/{%data2<login>}/tokens/{$tk}".IO.spurt("");

        say "set user token to {$tk}";

        set-cookie 'token', $tk, http-only => True, expires => $date;

        redirect :see-other, "{sparkyci-http-root()}/?message=user logged in";

      } else {

        redirect :see-other, "{sparkyci-http-root()}/?message=issues with login";

      }
       
  } 

}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<0.0.0.0>, :port<2222>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}

