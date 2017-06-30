use v6;
use lib 'lib';
use Test;

use OAuth2::Client::Google;

my $sample-config =
{
  "web" => {
    "redirect_uris" => [
      "http://localhost:3334/oauth",
    ],
    "client_secret" => "some_secret",
    "auth_provider_x509_cert_url" => "https://example.com/certs",
    "token_uri" => "https://accounts.google.com/o/oauth2/token",
    "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
    "project_id" => "some-projectid-1234",
    "client_id" => "some-client-id"
  }
}

my $o = OAuth2::Client::Google.new(
    config => $sample-config,
    redirect-uri => 'http://example.com/here',
    scope => 'email',
);

#Check if the save function works properly.
lives-ok { $o.save };
isa-ok $o.save, 'Str';

#Check loading info from one object to another.
my $o2 = OAuth2::Client::Google.load($o.save);
is-deeply $o2, $o;


done-testing;
