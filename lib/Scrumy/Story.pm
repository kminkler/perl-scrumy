package Scrumy::Story;

use warnings;
use strict;
use Moose;
use Carp qw(croak confess);

use Scrumy::Task;

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

foreach ('priority', 'sprint_id', 'created_at', 'scrumy_url', 'updated_at', 'title', 'seq') {
    has $_ => (
               is      => 'rw',
               lazy    => 1,
               builder => "_build_$_",
              );
}

has 'tasks' => (
                is      => 'ro',
                lazy    => 1,
                builder => '_build_tasks',
               );

sub _build
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'stories/' . $self->id);

    $self->priority($response->{'story'}{'priority'});
    $self->sprint_id($response->{'story'}{'sprint_id'});
    $self->created_at($response->{'story'}{'created_at'});
    $self->scrumy_url($response->{'story'}{'scrumy_url'});
    $self->updated_at($response->{'story'}{'updated_at'});
    $self->title($response->{'story'}{'title'});
    $self->seq($response->{'story'}{'seq'});

    return 0;
}

sub _build_priority
{
    my $self = shift;
    $self->_build;
    return $self->priority;
}

sub _build_sprint_id
{
    my $self = shift;
    $self->_build;
    return $self->sprint_id;
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

sub _build_title
{
    my $self = shift;
    $self->_build;
    return $self->title;
}

sub _build_seq
{
    my $self = shift;
    $self->_build;
    return $self->seq;
}

sub _build_tasks
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'stories/' . $self->id . '/tasks');

    my @tasks;
    foreach my $task (@$response) {
        push(@tasks, Scrumy::Task->new(api => $self->api, %{$task->{'task'}}));
    }

    return \@tasks;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy::Story - A Scrumy Story

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

=item priority

=over 4

The story priority

=back

=item sprint_id

=over 4

The sprint ID this story belongs to

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

=item title

=over 4

The title of the story

=back

=item seq

=over 4

The order of the stories (relative to each other)

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

1;    # End of Scrumy::Story
