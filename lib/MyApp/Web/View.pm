package MyApp::Web::View;
use strict;
use warnings;
use utf8;
use Carp ();
use File::Spec ();

use File::ShareDir;

use YATT::Lite::Factory -as_base;
use YATT::Lite qw/Entity/;
use MyApp::Web::ViewFunctions ();

# setup view class
sub make_instance {
    my ($class, $context) = @_;
    Carp::croak("Usage: MyApp::Web::View->make_instance(\$context_class)") if @_!=2;

    my $view_conf = $context->config->{'YATT::Lite'} || +{};
    unless (exists $view_conf->{doc_root}) {
        my $tmpl_path = File::Spec->catdir($context->base_dir(), 'ytmpl');
        if ( -d $tmpl_path ) {
            # tmpl
            $view_conf->{doc_root} = $tmpl_path;
        } else {
            my $share_tmpl_path = eval { File::Spec->catdir(File::ShareDir::dist_dir('MyApp'), 'ytmpl') };
            if ($share_tmpl_path) {
                # This application was installed to system.
                $view_conf->{doc_root} = $share_tmpl_path;
            } else {
                Carp::croak("Can't find template directory. tmpl Is not available.");
            }
        }
    }
    # MyApp is used in Amon2, so YATT::Lite should move to safe namespace.
    my $view = MY->new(app_ns => join("::", __PACKAGE__, 'YATT'), %$view_conf);
    return $view;
}

#========================================

for my $func_name ( @MyApp::Web::ViewFunctions::EXPORT ) {
    my $sub = MyApp::Web::ViewFunctions->can($func_name);
    Entity $func_name => sub { shift; $sub->(@_); };
}

1;
