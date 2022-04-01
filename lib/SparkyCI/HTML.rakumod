unit module SparkyCI::HTML;

use SparkyCI::Conf;
use SparkyCI::Security;

sub css (Mu $theme) is export {

  my %conf = get-sparkyci-conf();

  my $bulma-theme ;

  if $theme eq "dark" {

    if %conf<ui> && %conf<ui><theme><dark> {
      $bulma-theme = %conf<ui><theme><dark>
    } else {
      $bulma-theme = "nuclear";
    }

  } elsif $theme eq "light" {

    if %conf<ui> && %conf<ui><theme><light> {
      $bulma-theme = %conf<ui><theme><light>
    } else {
      $bulma-theme = "flatly";
    }

  } else {

    $bulma-theme = "cerulean";

  }

  qq:to /HERE/
  <meta charset="utf-8">
  <link rel="stylesheet" href="https://unpkg.com/bulmaswatch/$bulma-theme/bulmaswatch.min.css">
  <script defer src="https://use.fontawesome.com/releases/v5.14.0/js/all.js"></script>
  HERE

}

sub login-logout (Mu $user, Mu $token) {

  if check-user($user,$token) == True {

    "<a href=\"{sparkyci-http-root()}/logout?q=123\">
      Log out
    </a>"

  } else {

    "<a href=\"{sparkyci-http-root()}/login-page?q=123\">
      Log In
    </a>"
  }

}

sub theme-link (Mu $theme) {

  if $theme eq "light" {

    "<a href=\"{sparkyci-http-root()}/set-theme?theme=dark\">
      Dark Theme
    </a>"

  } else {

    "<a href=\"{sparkyci-http-root()}/set-theme?theme=light\">
      Light Theme
    </a>"

  }

}
sub navbar (Mu $user, Mu $token, Mu $theme) is export {
  qq:to /HERE/
      <div class="panel-block">
        <p class="control">
            <a href="{sparkyci-http-root()}/">Home</a> |
            <a href="{sparkyci-http-root()}/all"> Add builds </a> |
            <a href="{sparkyci-http-root()}/about">About</a> |
            <a href="https://sparrowhub.io:4000">Admin</a> |
            {theme-link($theme)} |
            <a href="https://github.com/melezhik/sparkyci" target="_blank">Github</a> |
            {login-logout($user, $token)}
        </p>
      </div>
  HERE

}

