package HTTP::Headers::ActionPack;
# ABSTRACT: HTTP Action, Adventure and Excitement

use strict;
use warnings;

use Carp            qw[ confess ];
use Module::Runtime qw[ use_module ];

my %DEFAULT_MAPPINGS = (
    'link'                => 'HTTP::Headers::ActionPack::LinkList',
    'content-type'        => 'HTTP::Headers::ActionPack::MediaType',
    'accept'              => 'HTTP::Headers::ActionPack::MediaTypeList',
    'accept-charset'      => 'HTTP::Headers::ActionPack::PriorityList',
    'accept-encoding'     => 'HTTP::Headers::ActionPack::PriorityList',
    'accept-language'     => 'HTTP::Headers::ActionPack::PriorityList',
    'date'                => 'HTTP::Headers::ActionPack::DateHeader',
    'expires'             => 'HTTP::Headers::ActionPack::DateHeader',
    'last-modified'       => 'HTTP::Headers::ActionPack::DateHeader',
    'if-unmodified-since' => 'HTTP::Headers::ActionPack::DateHeader',
    'if-modified-since'   => 'HTTP::Headers::ActionPack::DateHeader',
);

sub new {
    my $class = shift;
    bless {
        mappings => { %DEFAULT_MAPPINGS, @_ }
    } => $class;
}

sub create {
    my ($self, $header_name, $header_value) = @_;

    my $class = $self->{'mappings'}->{ lc $header_name };

    (defined $class)
        || confess "Could not find mapping for '$header_name'";

    use_module( $class )->new_from_string( $header_value );
}

1;

__END__

=head1 SYNOPSIS

  use HTTP::Headers::ActionPack;

  my $pack       = HTTP::Headers::ActionPack->new;
  my $media_type = $pack->create( 'Content-Type' => 'application/xml;charset=UTF-8' );

=head1 DESCRIPTION

=head2 Plack Compatability

We have a test in the suite that checks to make sure that
any inflated header objects will pass between L<HTTP::Request>
and L<HTTP::Response> objects as well as L<Plack::Request>
and L<Plack::Response> objects.

A simple survey of most of the L<Plack::Handler> subclasses
shows that most of them will end up properly stringifying
these header objects before sending them out. The notable
exceptions were the Apache handlers.

At the time of this writing, the solution for this would be
for you to either stringify these objects prior to returning
your Plack::Response, or to write a simple middleware component
that would do that for you. In future versions we might provide
just such a middleware (it would likely inflate the header objects
on the request side as well).

=back

