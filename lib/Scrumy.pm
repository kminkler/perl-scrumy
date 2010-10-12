package Scrumy;

use warnings;
use strict;
use LWP::UserAgent;
use Moose;
use Carp qw(croak confess);
use JSON qw(from_json);

use Scrumy::Sprint;
use Scrumy::Story;

our $VERSION = '0.1.0';

has 'project' => (
                  is       => 'rw',
                  isa      => 'Str',
                  required => 1,
                 );

has 'password' => (
                   is       => 'rw',
                   isa      => 'Str',
                   required => 1,
                  );
has 'lwp' => (
              is      => 'ro',
              isa     => 'LWP::UserAgent',
              default => sub { my $ua = LWP::UserAgent->new(); $ua->agent("perl-scrumy/$VERSION"); $ua; },
             );

has 'info' => (
               is      => 'ro',
               lazy    => 1,
               builder => '_build_info',
              );

has 'sprints' => (
                  is      => 'ro',
                  lazy    => 1,
                  builder => '_build_sprints',
                 );

has 'backlog' => (
                  is      => 'ro',
                  lazy    => 1,
                  builder => '_build_backlog',
                 );

sub _call_api
{
    my ($self, %options) = @_;

    croak("Missing path") unless exists($options{'path'});

    $self->lwp->credentials("scrumy.com:443", "Application", $self->project, $self->password);

    my $response = $self->lwp->get('https://scrumy.com/api/' . $options{'path'} . '.json');

    confess("Bad response code (" . $response->code() . ") from API") unless $response->is_success();

    return from_json($response->content);
}

sub _build_info
{
    my $self = shift;

    my $response = $self->_call_api(path => 'scrumies/' . $self->project);

    return $response->{'scrumy'};
}

sub _build_sprints
{
    my $self = shift;

    my $response = $self->_call_api(path => 'scrumies/' . $self->project . '/sprints');

    my @sprints;
    foreach my $sprint (@$response) {
        push(@sprints, Scrumy::Sprint->new(api => $self, %{$sprint->{'sprint'}}));
    }

    return \@sprints;
}

sub _build_backlog
{
	my $self = shift;

	my $response = $self->_call_api(path => 'scrumies/' . $self->project . '/backlog');

	my @stories;
	foreach my $story (@$response) {
		push(@stories, Scrumy::Story->new(api => $self, %{$story->{'story'}}));
	}

	@stories = sort { $b->priority <=> $a->priority } @stories;

	return \@stories;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy - A perl API to the Scrumy REST API

=head1 SYNOPSIS

use Scrumy;

my $project = Scrumy->new(project => "my_project", password => "my_password");

foreach my $sprint (@{$project->sprints}) {
	print "Sprint " . $sprint->id . " starts " . $sprint->start_date . "\n";

	foreach my $story (@{$sprint->stories}) {
		print "\tStory (" . $story->id . ") " . $story->title . "\n";

		foreach my $task (@{$story->tasks}) {
			print "\t\tTask (" . $task->id . ") " . $task->title . "(" . $task->state . ")\n";
		}
	}
}

=head1 METHODS

=over 4

=item sprints

=over 4

Returns an array reference of Scrumy::Sprint objects.

=back

=item info

=over 4

Returns a hash references of project info.

=back

=back

=head1 AUTHOR

Keith Minkler, C<< <kminkler at synacor.com> >>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2010 Keith Minkler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=cut

1;    # End of Scrumy
