#!/usr/bin/perl

use strict;
use Getopt::Long;
use Carp;
use Pod::InComments;

my $config_file = '';
my $comment     = ';';

GetOptions ( 'config_file|config|conf|file=s' => \$config_file,
             'comment=s'                      => \$comment );


# let's try to catch user errors
croak "$0 --file config_file --comment \"comment_char\" " unless ($config_file && $comment);

my $parser = Pod::InComments->new( comment => $comment );
my $pod = $parser->ParseFile($config_file);
$parser->DisplayPod();

__END__

=head1 NAME

config2pod.pl

=head1 SYNOPSIS

config2pod.pl --file config_file --comment ";"

=head1 DESCRIPTION

This small utility will extract the POD documentation you have hidden in the comments of your config file.
If you want to learn more about this, do: perldoc Pod::InComments

=head1 AUTHOR

Jaap Voets, E<lt>narked@xperience-automatisering.nlE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jaap Voets

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut

