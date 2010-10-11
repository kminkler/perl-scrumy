package Scrumy::Task;

use warnings;
use strict;
use Moose;
use Carp qw(croak confess);

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

foreach ('story_id', 'state', 'scrumer', 'created_at', 'updated_at', 'title', 'seq') {
    has $_ => (
               is      => 'rw',
               lazy    => 1,
               builder => "_build_$_",
              );
}

sub _build
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'tasks/' . $self->id);

    $self->story_id($response->{'task'}{'story_id'});
    $self->state($response->{'task'}{'state'});
    $self->scrumer($response->{'task'}{'scrumer'}{'name'});
    $self->created_at($response->{'task'}{'created_at'});
    $self->updated_at($response->{'task'}{'updated_at'});
    $self->title($response->{'task'}{'title'});
    $self->seq($response->{'task'}{'seq'});

    return 0;
}

sub _build_story_id
{
    my $self = shift;
    $self->_build;
    return $self->story_id;
}

sub _build_state
{
    my $self = shift;
    $self->_build;
    return $self->state;
}

sub _build_scrumer
{
    my $self = shift;
    $self->_build;
    return $self->scrumer;
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

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy::Task - A Scrumy Task

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

=item story_id

=over 4

The scrumy story ID this task is associated with

=back

=item state

=over 4

The task state (inprogress, etc)

=back

=item created_at

=over 4

The sprint created time

=back

=item updated_at

=over 4

The sprint updated time

=back

=item scrumer

=over 4

The name the scrumer working on the task

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

1;    # End of Scrumy::Task
