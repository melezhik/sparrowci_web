use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use SparkyCI::DB;
use SparkyCI::HTML;
use SparkyCI::Conf;
use SparkyCI::Security;
use Text::Markdown;
use JSON::Tiny;
use Cro::HTTP::Client;

my $application = route {

    my %conf = get-sparkyci-conf();
  
    get -> :$message, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my @results = get-builds();
      #die @results.perl;
      template 'templates/main.crotmp', %(
        message => $message,
        title => title(),   
        results => @results,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'all', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my @results = get-builds(1000);
      #die @results.perl;
      template 'templates/main.crotmp', %( 
        title => title(),   
        results => @results,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'report', Int $id, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my %report = get-report($id);
      template 'templates/report.crotmp', %( 
        title => title(),   
        %report,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'about', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      template 'templates/about.crotmp', %( 
        title => title(),   
        data => parse-markdown("README.md".IO.slurp).to_html,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'tc', Int $id, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my %report = get-report($id);
      template 'templates/tc.crotmp', %( 
        title => title(),   
        %report,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'js', *@path {
        cache-control :public, :max-age(300);
        static 'js', @path;
    }

    get -> 'icons', *@path {

      cache-control :public, :max-age(3000);

      static 'icons', @path;

    }

    get -> 'set-theme', :$message, :$theme, :$user is cookie, :$token is cookie {

      my $date = DateTime.now.later(years => 100);

      set-cookie 'theme', $theme, http-only => True, expires => $date;

      redirect :see-other, "{http-root()}/?message=theme set to {$theme}";

    }
    get -> 'login' {

      if %*ENV<MB_DEBUG_MODE> {

          say "MB_DEBUG_MODE is set, you need to set MB_DEBUG_USER var as well"
            unless %*ENV<MB_DEBUG_USER>;

          my $user = %*ENV<MB_DEBUG_USER>;

          say "set user login to {$user}";

          set-cookie 'user', $user;

          mkdir "{cache-root()}/users";

          mkdir "{cache-root()}/users/{$user}";

          mkdir "{cache-root()}/users/{$user}/tokens";

          "{cache-root()}/users/{$user}/meta.json".IO.spurt('{}');

          my $tk = gen-token();

          "{cache-root()}/users/$user/tokens/{$tk}".IO.spurt("");

          say "set user token to {$tk}";

          set-cookie 'token', $tk;

          redirect :see-other, "{http-root()}/?message=user logged in";

      } else  {

        redirect :see-other,
          "https://github.com/login/oauth/authorize?client_id={%*ENV<OAUTH_CLIENT_ID>}&state={%*ENV<OAUTH_STATE>}"
      }
    }

    get -> 'logout', :$user is cookie, :$token is cookie {

      set-cookie 'user', Nil;
      set-cookie 'token', Nil;

      if ( $user && $token && "{cache-root()}/users/{$user}/tokens/{$token}".IO ~~ :e ) {

        unlink "{cache-root()}/users/{$user}/tokens/{$token}";
        say "unlink user token - {cache-root()}/users/{$user}/tokens/{$token}";

      }

      redirect :see-other, "{http-root()}/?message=user logged out";
    } 

    get -> 'oauth2', :$state, :$code {

        say "request token from https://github.com/login/oauth/access_token";

        my $resp = await Cro::HTTP::Client.get: 'https://github.com/login/oauth/access_token',
          headers => [
            "Accept" => "application/json"
          ],
          query => { 
            redirect_uri => "http://sparrowhub.io:2222/oauth2",
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

          redirect :see-other, "{http-root()}/?message=user logged in";

        } else {

          redirect :see-other, "{http-root()}/?message=issues with login";

        }
        
    }

    get -> 'login-page', :$message, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {

      template 'templates/login-page.crotmp', {
        title => title(),
        http-root => http-root(),
        message => $message || "sign in using your github account",
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
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

