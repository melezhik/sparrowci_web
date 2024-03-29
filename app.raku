use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use SparkyCI::DB;
use SparkyCI::User;
use SparkyCI::HTML;
use SparkyCI::Conf;
use SparkyCI::Security;
use SparkyCI::Repo;
use Text::Markdown;
use JSON::Fast;
use Cro::HTTP::Client;
use File::Directory::Tree;

my $application = route {

    my %conf = get-sparkyci-conf();
  
    get -> :$message, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my @results = get-builds();
      #die @results.perl;
      template 'templates/main.crotmp', %(
        page-title => "SparrowCI - super fun and flexible CI system with many programming languages support",
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
        page-title => "All Reports",
        title => title(),   
        results => @results,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> Str $user-id, 'builds', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my @results = get-builds(100,$user-id);
      #die @results.perl;
      template 'templates/main.crotmp', %( 
        page-title => "{$user-id}'s Reports",
        title => title(),   
        results => @results,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'report', Int $id, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {

      my %report = get-report($id);

      my $path =  %report<with-sparrowci>:exists ?? 'templates/report2.crotmp' !! 'templates/report.crotmp';
      my $title = %report<with-sparrowci>:exists ?? "SparrowCI Report - {%report<project>}" !! "SparrowCI Report - {%report<project>}";

      template $path, %( 
        page-title => $title,
        title => title(),   
        %report,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'quickstart', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      template 'templates/quickstart.crotmp', %(
        page-title => "Quick Start", 
        title => title(),   
        data => parse-markdown("README.md".IO.slurp).to_html,
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }

    get -> 'donations', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      template 'templates/donations.crotmp', %(
        page-title => "Support SparrowCI", 
        title => title(),   
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )
    }
    get -> 'repos', :$message, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my $data = gh-repos($user);
        my @projects = projects($user);
        my $repos =  $data<>.map({ ("\"{$_<name>||''}\"") }).join(",");
        template 'templates/repos.crotmp', %(
          page-title => "Repositories", 
          title => title(),
          projects => @projects, 
          gh-repos-js => $repos,
          css => css($theme),
          theme => $theme,
          repos-sync-date => repos-sync-date($user),
          navbar => navbar($user, $token, $theme),
          message => $message,
        )
      } else {
        redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories";
      }  
    }

   post -> 'repo', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my $repo; my $type;
        request-body -> (:$repos,:$typegit) {
          $repo = $repos;
          $type = $typegit ?? "git" !! "gh";
          say "add repo: $repo type: $type";
        }
        my $url = $type eq "git" ?? $repo !! "https://github.com/{$user}/{$repo}.git";
        my $yaml = qq:to/YAML/;
          sparrowdo:
            no_sudo: true
            no_index_update: false
            bootstrap: false
            format: default
            repo: file:///home/sph/repo
            tags: cpu=2,mem=6,SCM_URL=$url
          disabled: false
          keep_builds: 100
          allow_manual_run: true
          scm:
            url: $url
            branch: HEAD
        YAML
        say "yaml: $yaml";

        my $repo-dir = $type eq "git" ?? 
          "{%*ENV<HOME>}/.sparky/projects/git-{$user}-{$repo.split('/').tail}" !!
          "{%*ENV<HOME>}/.sparky/projects/gh-{$user}-$repo";

        say "create repo dir: $repo-dir";

        mkdir $repo-dir;

        "{$repo-dir}/sparky.yaml".IO.spurt($yaml);

        if "{$repo-dir}/sparrowfile".IO ~~ :e {
          say "{$repo-dir}/sparrowfile symlink exists"; 
        } else {
          say "create {$repo-dir}/sparrowfile symlink"; 
          symlink("sparrowfile","{$repo-dir}/sparrowfile");
          redirect :see-other, "{http-root()}/repos?message=repo {$repo} added";
        }
      } else {
         redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories"; 
      }
   }

    post -> 'repos-sync', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my $repo;
        say "sync repos information from GH account for user: $user";
        sync-repos($user);  
        redirect :see-other, "{http-root()}/repos?message=repositories synced from GH account";
      } else {
        redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories";
      }  
    }

    post -> 'repo-build', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my $repo-id; my $repo-type;
        request-body -> (:$repo,:$type) {
          $repo-id = $repo;
          $repo-type = $type;
          say "build repo: $repo type: $type";
        }
        
        my $repo-dir = "{%*ENV<HOME>}/.sparky/projects/{$repo-type}-{$user}-{$repo-id}";

        my $id = "{('a' .. 'z').pick(20).join('')}.{$*PID}";

        my %trigger = %(
          description =>  "triggered by SparrowCI user",
        );

        mkdir "{$repo-dir}/.triggers";

        "{$repo-dir}/.triggers/$id".IO.spurt(%trigger.perl);

        say "queue repo: {$repo-id} type: {$repo-type} to build: {$repo-dir}/.triggers/$id";

        redirect :see-other, "{http-root()}/repos?message=repo {$repo-id} queued to build";

      } else {
        redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories";
      }  
    }

    post -> 'build' {

      my $bid;

      request-body  -> %json {

        my $build = %json;

        my $project = %json<project>;
        my $desc = %json<desc>;
        my $state = %json<state>;
        my $job-id = %json<job-id>;

        say "generate sparkyci build ...";

        $bid = insert-build :$state, :$project, :$desc, :$job-id;

        say "bid: $bid";

        mkdir "{sparkyci-root()}/data/{$bid}";

        $build<id> = $bid;

        "{sparkyci-root()}/data/{$bid}/data.json".IO.spurt(to-json($build));

      }

      content 'application/json', %( build-id => $bid );

    } 

    post -> 'repo-rm', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my $repo-id; my $repo-type;
        request-body -> (:$repo,:$type) {
          $repo-id = $repo;
          $repo-type = $type;
          say "remove repo: $repo type: $type";
        }
        
        my $repo-dir = "{%*ENV<HOME>}/.sparky/projects/{$repo-type}-{$user}-{$repo-id}";

        if "{$repo-dir}".IO ~~ :d {
           say "remove {$repo-dir}";
          rmtree $repo-dir;
        } else {
           say "{$repo-dir} does not exist"; 
        }
        redirect :see-other, "{http-root()}/repos?message=repo {$repo-id} removed";
      } else {
        redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories";
      }  
    }

    get -> 'repo', 'edit', Str $type, Str $repo-id, :$message, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      if check-user($user, $token) == True {
        my %repo = get-repo($user, $repo-id, $type);
        template 'templates/repos-edit.crotmp', %(
          page-title => "Edit Repo - {$repo-id}", 
          title => title(),
          %repo, 
          css => css($theme),
          theme => $theme,
          navbar => navbar($user, $token, $theme),
          message => $message,
        )
      } else {
        redirect :see-other, "{http-root()}/login-page?message=you need to sign in to manage repositories";
      }  
    }

    get -> 'repo', Str $repo-id, 'link', :$type, :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {
      my $repo = get-repo($user,$repo-id,$type);
      if $repo && $repo<scm> && $repo<scm><url> {
        redirect :see-other, $repo<scm><url>;
      } else {
        redirect :see-other, "{http-root()}/repos?message=http link not found";
      }  
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

    get -> 'project', Str $project, 'badge', 'markdown', :$user is cookie, :$token is cookie, :$theme is cookie = default-theme() {

      template 'templates/badge.crotmp', %( 
        page-title => "{$project} badge",  
        title => title(),   
        badge => "[![SparrowCI](https://ci.sparrowhub.io/project/{$project}/badge)](https://ci.sparrowhub.io)",
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      )

    }

    get -> 'project', Str $project, 'badge', {
      my $b = get-last-build($project);
      if $b<state> eq "OK" {
        redirect :see-other, 'https://img.shields.io/static/v1?label=SparrowCI&message=Build+|+OK&color=green'
      } elsif $b<state> eq "FAIL" {
        redirect :see-other, 'https://img.shields.io/static/v1?label=SparrowCI&message=Build+|+FAIL&color=red'
      } elsif $b<state> eq "FAIL" {
        redirect :see-other, 'https://img.shields.io/static/v1?label=SparrowCI&message=Build+|+TIMEOUT&color=yellow'
      } else {
        redirect :see-other, 'https://img.shields.io/static/v1?label=SparrowCI&message=Build+|+UNKOWN&color=gray'
      }
    }

    get -> 'js', *@path {
        cache-control :public, :max-age(300);
        static 'js', @path;
    }

    get -> 'css', *@path {
        cache-control :public, :max-age(300);
        static 'css', @path;
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

    #
    # Authentication methods
    #
    
    get -> 'login' {

      if %*ENV<SC_USER> {

          say "SC_USER is set, you need to set SC_TOKEN var as well"
            unless %*ENV<SC_TOKEN>;

          my $user = %*ENV<SC_USER>;

          say "set user login to {$user}";

          set-cookie 'user', $user;

          mkdir "{cache-root()}/users";

          mkdir "{cache-root()}/users/{$user}";

          mkdir "{cache-root()}/users/{$user}/tokens";

          "{cache-root()}/users/{$user}/meta.json".IO.spurt(
            to-json({ access_token => %*ENV<SC_TOKEN>})
          );

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

        if ( $user && $token && "{cache-root()}/users/{$user}/meta.json".IO ~~ :e ) {

          unlink "{cache-root()}/users/{$user}/meta.json";
          say "unlink user meta - {cache-root()}/users/{$user}/meta.json";

        }

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
            redirect_uri => "https://ci.sparrowhub.io/oauth2",
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

          %data2<access_token> = %data<access_token>;

          say "set user login to {%data2<login>}";

          my $date = DateTime.now.later(years => 100);

          set-cookie 'user', %data2<login>, http-only => True, expires => $date;

          mkdir "{cache-root()}/users";

          mkdir "{cache-root()}/users/{%data2<login>}";

          mkdir "{cache-root()}/users/{%data2<login>}/tokens";

          "{cache-root()}/users/{%data2<login>}/meta.json".IO.spurt(to-json(%data2));

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
        page-title => "Login page",
        title => title(),
        http-root => http-root(),
        message => $message || "sign in using your github account",
        css => css($theme),
        theme => $theme,
        navbar => navbar($user, $token, $theme),
      }
    }

}

(.out-buffer = False for $*OUT, $*ERR);

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<127.0.0.1>, :port<2222>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}

