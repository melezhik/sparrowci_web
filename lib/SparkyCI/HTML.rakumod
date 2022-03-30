unit module SparkyCI::HTML;

use SparkyCI;

sub navbar is export {

  qq:to /HERE/
    <nav class="navbar" role="navigation" aria-label="main navigation">
      <div class="navbar-brand">
        <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>
      <div id="navbarBasicExample" class="navbar-menu">
        <div class="navbar-start">
          <a class="navbar-item" href="{sparkyci-http-root()}/">
            Home
          </a>
          <a class="navbar-item" href="{sparkyci-http-root()}/all">
            All Builds
          </a>
          <div class="navbar-item has-dropdown is-hoverable">
            <a class="navbar-link">
              More
            </a>
            <div class="navbar-dropdown">
              <a class="navbar-item" href="{sparkyci-http-root()}/about">
                About
              </a>
              <a class="navbar-item" href="https://github.com/melezhik/sparkyci">
                GitHub Page
              </a>
              <a class="navbar-item" href="https://sparrowhub.io:4000">
                Sparky Admin
              </a>
            </div>
          </div>
        </div>
      </div>
    </nav>
  HERE

}
