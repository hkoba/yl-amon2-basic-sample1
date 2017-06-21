use strict;
use warnings;
use Test::More;


use MyApp;
use MyApp::Web;
use MyApp::Web::ViewYATT;
use MyApp::Web::ViewFunctions;

use MyApp::DB::Schema;
use MyApp::Web::Dispatcher;


pass "All modules can load.";

done_testing;
