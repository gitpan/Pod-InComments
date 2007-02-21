use Test::More tests => 9;

use_ok('Pod::InComments');

my $podparser = Pod::InComments->new( comment => ';' );
isa_ok( $podparser, 'Pod::InComments');

my $raw_pod = $podparser->ParseFile( './t/test.cnf' );
like ( $raw_pod, qr/=head1 section/, 'raw pod returned');

# do we remember the config file?
is( $podparser->{file}, './t/test.cnf', 'Config file stored ok');

# try to dump the pod into a file
$podparser->SavePod('./t/test.pod');
ok( -e './t/test.pod', 'pod file saved to disk');

# now convert pod into a hash
my $pod_hash = $podparser->Pod2Hash();
like ( $pod_hash->{'section'}, qr/Section is here for testing and showing/, 'Section pod found');

# and try to get the text for a certain key
my $text = $podparser->Pod4Section('section', 'key');
like ($text, qr/key shows us/, 'found helptext for section/key');

$text = $podparser->Pod4Section('very long section name' );
like ($text, qr/as you can see/, 'found helptext for section alone');

# non existing
$text = $podparser->Pod4Section('doesnotexist' );
is($text, '', 'empty string for non existing section');

