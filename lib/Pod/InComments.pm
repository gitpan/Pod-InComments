package Pod::InComments;

use Pod::POM;
use Pod::POM::View::HTML;
use Pod::POM::View::Text;
use Carp;
use strict;

our $VERSION = '0.8';

# constructor
sub new {
    my $class  = shift;
    my %params = @_;
    
    my $self = {};
    bless( $self, $class );

    # comment symbol where pod is hidden in
    $self->{comment} = $params{comment} || ';';
    $self->{view}    = 'Pod::POM::View::Text';  # the 
    
    # return empty string when section/key is missing
    # or shall we croak on it?
    if (exists $params{ignoremising} ) {
        $self->{ignoremissing} = $params{ignoremissing};
    } else {
        $self->{ignoremissing} = 1;
    }
    return $self;
}

# parse a file and extract the pod from it
sub ParseFile {
    my $self = shift;
    my $file = shift;

    croak "Please specify a file to parse" unless ($file);
    $self->{file} = $file;

    my $pod;
    open(IN, $file) || croak "Can't read $file";
    while (my $line = <IN>) {
        if ($line =~ /^$self->{comment}/) {
            $line =~ s/^$self->{comment}\s*//;
            $line .= "\n" if ! $line;
            $pod .= $line ;  
        }
    }
    
    close(IN);
    $self->{pod} = $pod;
    return $pod;
}

# save the pod found
sub SavePod {
    my $self = shift;
    my $file = shift;

    # sanity check
    if (! $self->{pod} ) {
        croak "There is no POD to save! Did you run ParseFile?";
    }
    # if no file give, use original filename + .pod
    if (! $file ) {
        if ( $self->{file} ) {
            $file = $self->{file} . '.pod';
        } else {
            croak "Please specify a filename to save POD to!";
        }
    }
    open(OUT, ">$file") || croak "Can't write to file $file";
    print OUT $self->{pod};
    close(OUT);
}

# transform a pod to hash
# keys of the hash are the head1 elements
# with possible head2 subkeys
sub Pod2Hash {
    my $self = shift;
       
    if (! $self->{pod} ) {
        croak "There is no POD to transform into POM!";
    }

    my $parser = Pod::POM->new();
    my $pom    = $parser->parse_text( $self->{pod} ) || croak $parser->error();
    $self->{pom} = $pom;

    my %store;
    foreach my $section ( $pom->head1() ) {
        my $title = $section->title();

        # store the head1 section
        $self->{podhash}->{$title} = $self->{view}->view_head1( $section );

        foreach my $key ( $section->head2() ) {
            my $subtitle = $key->title(); 
            $self->{podhash}->{"$title::$subtitle"} = $self->{view}->view_head2( $key );
        }
    }
    return $self->{podhash};
}

# display a section or even subsection of the POD
sub Pod4Section {
    my $self = shift;
    my ($section, $key) = @_;

    if (! $self->{podhash} ) {
        croak "Did you run Pod2Hash?";
    }
    
    if (! exists $self->{podhash}->{$section} ) {
        if ($self->{ignoremissing}) {
            return '';
        }    
        croak "Section $section not found!";
    }
    my $pod = '';
    if ( $key ) {
        if (! exists $self->{podhash}->{"$section::$key"} ) {
            if ($self->{ignoremissing}) {
                return '';
            }    
            croak "Key $key not found in section $section!";
        }
        $pod = $self->{podhash}->{"$section::$key"};
         
    } else {
        $pod = $self->{podhash}->{$section};
    } 
    return $pod; 
}

# display entire pod
sub DisplayPod {
    my $self = shift;

    if (! $self->{pom} ) {
        # not parsed yet
        $self->Pod2Hash();
    }
    $self->{view}->print( $self->{pom} );
}


1;
__END__

=head1 Pod::InComments

Pod::InComments - Perl extension for extracting POD documentation from comments in config file 

=head1 SYNOPSIS

  use Pod::InComments;
  my $podparser = Pod::InComments->new( comment => ';' );
  $podparser->ParseFile( $my_config_file );
  $podparser->Pod2Hash();

  my $helptext = $podparser->Pod4Section( $section , $key );

   
=head1 DESCRIPTION

This module was written to solve the problem of describing numerous parameters in a config file.
When you add comments to the config file, it becomes a mess quickly. And no-one will take the time to properly read them. You can not add POD directly. So..... here is Pod::InComments.

It was developed when using Config::IniFiles format, so let's take that as the basis.
The Config::IniFiles module let's you use config files in the form of the popular windows ini file. That is, they look like

  [section]
  param1=some value
  param2 = another value
  param3=20.00

  ; this is a comment
  [operating system]
  preferred=Linux
  using=Windows XP Pro

=head1 METHODS

=over 4

=item new( comment => '#' )

Constructor of the class. Specify the comment character(s) used in the config file.
Defaults to ';'. You can use whatever you like here. So '####' is valid as well, but requires more typing in the config.

=item ParseFile( $config_file )

Parses the $config_file and extracts all the comment lines. The comment character(s) are stripped of each line. It returns a string with all the POD.

=item Pod2Hash()

After parsing a config file, you will need to call this function to convert the POD into a hash. The keys of the hash are the head1 titles. If head2 elements are present, they will be subkeys of the hash.

=item Pod4Section( $section, $param )

Returns the POD belonging to the $section, or to $param of $section.

E.g., when your config file looks like:
  
  ;=head1 cpu
  ;
  ;Specifies cpu settings for normal boxes
  ;note that these will override factory settings!
  ;
  ;=head2 maxload
  ;
  ;The maxload setting gives an upperbound on how hard
  ;the CPU can be pushed.

  [cpu]
  maxload=4.0


then doing:  

  my $pod = $podparser->Pod4Section( 'cpu', 'maxload' );
  will give you:

 The maxload setting gives an upperbound on how hard
 the CPU can be pushed.


=item SavePod( $file )

Saves the extracted pod to the $file. If you omit a file name, it will append '.pod' to the config file you parsed and saves to that file.

=item DisplayPod()

Prints the entire extracted POD documentation to STDOUT.

=back

=head2 EXPORT

None by default.

=head1 AUTHOR

Jaap Voets, E<lt>narked@xperience-automatisering.nlE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jaap Voets

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
