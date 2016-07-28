unit class OAuth2::Client::Google;
use HTTP::UserAgent;
use JSON::Fast;

# Reference:
# https://developers.google.com/identity/protocols/OAuth2WebServer

has $.config;
has $.redirect-uri is required;
has $.response-type = 'code';
has $.prompt = 'consent'; #| or none or select_account or "consent select_account";
has $.include-granted-scopes = 'true';
has $.scope is required;
has $.state = "";
has $.login-hint = "";
has $.access-type = ""; # online offline

method !client-id { $.config<web><client_id> }
method !client-secret { $.config<web><client_secret> }

method auth-uri {
    my $web-config = $.config<web>;
    die "missing client_id" unless $web-config<client_id>;
    return $web-config<auth_uri> ~ '?' ~
     ( response_type          => $.response-type,
        client_id              => self!client-id,
        redirect_uri           => $.redirect-uri,
        scope                  => $.scope,
        state                  => $.state,
        access_type            => $.access-type,
        prompt                 => $.prompt,
        login_hint             => $.login-hint,
        include_granted_scopes => $.include-granted-scopes,
     ).sort.map({ "{.key}={.value}" }).join('&');
}

#| Send a request to <https://www.googleapis.com/oauth2/v4/token>.
#|
#| Returns:
#|
#| access_token  The token that can be sent to a Google API.
#| refresh_token A token that may be used to obtain a new access
#|                 token. Refresh tokens are valid until the user revokes access.
#|                 This field is only present if access_type=offline is included
#!                 in the authorization code request.
#| expires_in 	 The remaining lifetime of the access token.
#| token_type 	 Identifies the type of token returned.
#|                 At this time, this field will always have the value Bearer.
#| or
#|    error
#|    error_description
#|
method code-to-token(:$code!) {
    my %payload =
        code => $code,
        client_id => self!client-id,
        client_secret => self!client-secret,
        redirect_uri => $.redirect-uri,
        grant_type => 'authorization_code';
    my $ua = HTTP::UserAgent.new;
    my $res = $ua.post("https://www.googleapis.com/oauth2/v4/token", %payload);
    $res.is-success or return { error => $res.status-line };
    return from-json($res.content);
}

