package Scrumy::Sprint;

use warnings;
use strict;
use Moose;
use Carp qw(croak confess);

use Scrumy::Story;
use Scrumy::Snapshot;

has 'api' => (
              is       => 'ro',
              isa      => 'Scrumy',
              required => 1,
             );

has 'id' => (
             is       => 'ro',
             isa      => 'Int',
             required => 1,
            );

foreach ('start_date', 'created_at', 'updated_at', 'scrumy_url') {
    has $_ => (
               is      => 'rw',
               isa     => 'Str',
               lazy    => 1,
               builder => "_build_$_",
              );
}

has 'stories' => (
                  is      => 'ro',
                  lazy    => 1,
                  builder => '_build_stories',
                 );

has 'snapshots' => (
                  is      => 'ro',
                  lazy    => 1,
                  builder => '_build_snapshots',
                 );

sub _build
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'sprints/' . $self->id);

    $self->start_date($response->{'sprint'}{'start_date'});
    $self->created_at($response->{'sprint'}{'created_at'});
    $self->updated_at($response->{'sprint'}{'updated_at'});
    $self->scrumy_url($response->{'sprint'}{'scrumy_url'});

    return 0;
}

sub _build_start_date
{
    my $self = shift;
    $self->_build;
    return $self->start_date;
}

sub _build_created_at
{
    my $self = shift;
    $self->_build;
    return $self->created_at;
}

sub _build_updated_at
{
    my $self = shift;
    $self->_build;
    return $self->updated_at;
}

sub _build_scrumy_url
{
    my $self = shift;
    $self->_build;
    return $self->scrumy_url;
}

sub _build_stories
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'sprints/' . $self->id . '/stories');

    my @stories;
    foreach my $story (@$response) {
        push(@stories, Scrumy::Story->new(api => $self->api, %{$story->{'story'}}));
    }

    return \@stories;
}

sub _build_snapshots
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'sprints/' . $self->id . '/snapshots');

    my @snapshots;
    foreach my $snapshot (@$response) {
        push(@snapshots, Scrumy::Snapshot->new(api => $self->api, %{$snapshot->{'snapshot'}}));
    }

    return \@snapshots;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy::Sprint - A Scrumy Sprint

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

=item id

=over 4

The scrumy sprint ID

=back

=item start_date

=over 4

The sprint start date

=back

=item created_at

=over 4

The sprint created time

=back

=item updated_at

=over 4

The sprint updated time

=back

=item scrumy_url

=over 4

The project name the sprint belongs to

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

1;    # End of Scrumy::Sprint
