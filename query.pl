#!/usr/bin/perl

use LWP::Simple;
use HTTP::Request;
use JSON;

my $token = shift;

$token =~ s/^\-/\\-/;

open(USERPASS, "userpass.txt") || die $!;
my $user = <USERPASS>; chop $user;
my $pass = <USERPASS>; chop $pass;
close(USERPASS);

my $url = "https://kibana.shared.us-west-2.prod.mozaws.net:444/_search?q=token:${token}&size=500&pretty";

my $ua = LWP::UserAgent->new;

# Unfortunately, this server does not use a known CA.
# Ideally, we'd form a ca-bundle.crt that pins the cert
# down, but that's going to take some research.
$ua->ssl_opts(verify_hostname=>0);
#$ua->ssl_opts(SSL_ca_file=>'ca-bundle.crt');

# Get error codes
my $req = new HTTP::Request 'GET' => 'https://raw.githubusercontent.com/mozilla-services/loop-server/master/loop/errno.json';
my $response = $ua->request($req);
if (!$response->is_success) {
  warn "Could not get error codes: ".$response->status_line;
}
my $errno = decode_json $response->decoded_content;
foreach $n (keys %$errno) {
  $errno[$$errno{$n}] = $n;
}

$req = new HTTP::Request 'GET' => $url;
$req->authorization_basic($user,$pass);
$response = $ua->request($req);
if (!$response->is_success) {
  die $response->status_line;
}


my $guest = 0;
my $owner = 0;
my $last_date = '';
my $sessionIdPrinted = 0;

#print $response->decoded_content."\n";
my $result = decode_json $response->decoded_content."\n";
my $hits = $result->{hits}->{hits};
foreach $hit (sort {$a->{"_source"}->{"Timestamp"} cmp $b->{"_source"}->{"Timestamp"}} @$hits) {
  my $row = $hit->{"_source"};

  $action = $row->{method};
  if ($action eq 'post') { $action = $row->{action}; }

  $client = $row->{user_agent_browser}."_".
            $row->{user_agent_version}."_".
            $row->{user_agent_os}."_".
            $row->{lang};
  $client =~ s/[^a-zA-Z0-9]/_/g;

  $row->{Timestamp} =~ /(.*)T(.*)Z/;
  my $date = $1;
  my $time = $2;
  if ($date ne $last_date) {
    push (@actions, "note/l/$date\n");
    $last_date = $date;
  }

  if (!$name{$client}) {
    $name{$client} = ($row->{lang} =~ /q=/)?("Guest ".(++$guest)):("Owner ".(++$owner));
    $name{$client} .= "^".$row->{user_agent_os};
    $name{$client} .= "^".$row->{user_agent_browser};
    $name{$client} .= " ".$row->{user_agent_version};
    if ($name{$client} =~ /Owner/) {
      push (@owner_guys, "guy/$client/$name{$client}\n");
    } else {
      push (@guest_guys, "guy/$client/$name{$client}\n");
    }
  }

  if (!$sessionIdPrinted && $row->{sessionId}) {
    warn ($row->{sessionId}."\n");
    $sessionIdPrinted = 1;
  }
  if ($action eq 'status') {
    push (@actions, "note/${client}/$time ".
          $row->{state}." (".
          $row->{sendStreams}."->".$row->{recvStreams}.")^".
          $row->{event}."\n");
  } else {
    my $code = $row->{code};
    if ($row->{errno}) {
      $code .= ";".$row->{errno}." ".$errno[$row->{errno}];
    }
    push (@actions, "${client}->l/$time $action/$code\n");
  }
}

print <<EOT
opt/columnPitch/24
opt/linePitch/3
opt/messageNumbering/false
EOT
;
print join "",@owner_guys;
print "guy/l/Loop Server\n";
print join "",@guest_guys;
print "\n";
print join "",@actions;
