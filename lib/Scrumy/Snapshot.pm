package Scrumy::Snapshot;

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

foreach ('hours_remaining', 'hours_total', 'snapshot_date') {
    has $_ => (
               is      => 'rw',
               lazy    => 1,
               builder => "_build_$_",
              );
}

sub _build
{
    my $self = shift;

    my $response = $self->api->_call_api(path => 'stories/' . $self->id);

    $self->hours_remaining($response->{'task'}{'hours_remaining'});
    $self->hours_total($response->{'task'}{'hours_total'});
    $self->snapshot_date($response->{'task'}{'snapshot_date'}{'name'});

    return 0;
}

sub _build_hours_remaining
{
    my $self = shift;
    $self->_build;
    return $self->hours_remaining;
}

sub _build_hours_total
{
    my $self = shift;
    $self->_build;
    return $self->hours_total;
}

sub _build_snapshot_date
{
    my $self = shift;
    $self->_build;
    return $self->snapshot_date;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy::Snapshot - A Scrumy Snapshot

=head1 SYNOPSIS

Snapshots are created nightly as data changes.  They can be used to create burndown charts

use Scrumy;

my $project = Scrumy->new(project => "my_project", password => "my_password");

my $sprint = $projects->sprints[0];

print "Burndown\n";
foreach my $snapshot (@{$sprint->snapshots}) {
	print $snapshot->snapshot_date . ": " . $snapshot->hours_remaining . "/" . $snapshot->hours_total . "\n";
}

=head1 METHODS

=over 4

=item id

=over 4

The scrumy sprint ID

=back

=item hours_remaining

=over 4

The number of hours (i.e. tasks) remaining in the sprint

=back

=item hours_total

=over 4

The number of hours (i.e. tasks) total in the sprint

=back

=item snapshot_date

=over 4

The date the snapshot was taken

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

1;    # End of Scrumy::Snapshot
