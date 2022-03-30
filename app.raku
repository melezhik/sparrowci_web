use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::WebApp::Template;
use SparkyCI;
use SparkyCI::HTML;
use Text::Markdown;

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

}

my Cro::Service $service = Cro::HTTP::Server.new:
    :host<0.0.0.0>, :port<2222>, :$application;

$service.start;

react whenever signal(SIGINT) {
    $service.stop;
    exit;
}

