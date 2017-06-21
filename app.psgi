#!perl
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/lib";
use Plack::Builder;

use MyApp::Web;
use MyApp;
use URI::Escape;
use File::Path ();

use MyApp::Web::ViewYATT;

my $app = builder {
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/static/)},
        root => $FindBin::Bin;
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => "$FindBin::Bin/static";
    enable 'Plack::Middleware::ReverseProxy';

    MyApp::Web->to_app();
};

return MyApp::Web->create_view if MyApp::Web::ViewYATT->want_object;

unless (caller) {
    my $port        = 5000;
    my $host        = '127.0.0.1';
    my $max_workers = 4;

    require Getopt::Long;
    require Plack::Loader;
    my $p = Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    );
    $p->getoptions(
        'p|port=i'      => \$port,
        'host=s'        => \$host,
        'max-workers=i' => \$max_workers,
        'version!'      => \my $version,
        'c|config=s'    => \my $config_file,
    );
    if ($version) {
        print "MyApp: $MyApp::VERSION\n";
        exit 0;
    }
    if ($config_file) {
        my $config = do $config_file;
        Carp::croak("$config_file: $@") if $@;
        Carp::croak("$config_file: $!") unless defined $config;
        unless ( ref($config) eq 'HASH' ) {
            Carp::croak("$config_file does not return HashRef.");
        }
        no warnings 'redefine';
        no warnings 'once';
        *MyApp::load_config = sub { $config }
    }

    print "MyApp: http://${host}:${port}/\n";

    my $loader = Plack::Loader->load('Starlet',
        port        => $port,
        host        => $host,
        max_workers => $max_workers,
    );
    return $loader->run($app);
}
return $app;
