# $stdout.sync = true
require './web'
run Sinatra::Application
$stdout.sync = true
