package Scrumy::ToConfluence;

use warnings;
use strict;
use Carp qw(croak);
use Scrumy;
use Confluence;
use Date::Format qw(time2str);

our $VERSION = '0.0.1';

use Moose;

has 'project' => (
                  is       => 'rw',
                  isa      => 'Scrumy',
                  required => 1,
                 );

has ['username', 'password', 'confluence_url', 'space', 'parent'] => (
                                                                      is       => 'rw',
                                                                      isa      => 'Str',
                                                                      required => 1,
                                                                     );

sub import_project
{
    my $self = shift;

    my $wiki = Confluence->new($self->confluence_url, $self->username, $self->password);

    croak($wiki->lastError()) if $wiki->lastError();

    my $parent = $wiki->getPage($self->space, $self->parent);
    croak($wiki->lastError()) if $wiki->lastError();

    my $page;

    my $project_parent = $self->_get_or_create_page($wiki, $parent, $self->project->project . " project");

	my $backlog = "h3. Backlog\n{table-plus:sortColumn=1|sortDescending=true}\n||Priority||Description||\n";
	foreach my $story (@{$self->project->backlog}) {
		$backlog .= "|" . $story->priority . "|" . $story->title . "|\n";
	}
	$backlog .= "{table-plus}";
		
    $project_parent->{'content'} = 'This is the project container page for the ' . $self->project->project . ' page.

This project is hosted at [Scrumy|http://www.scrumy.com], a web-based Scrum management tool.

if you have a login, you may visit the ['
      . $self->project->project
      . ' scrumy project page|http://www.scrumy.com/'
      . $self->project->project
      . '] to view or change any sprint data.
	
h3. Sprints
';

    use Data::Dumper;
    foreach my $sprint (@{$self->project->sprints}) {
        $project_parent->{'content'} .=
            "* [Sprint starting "
          . $sprint->start_date . "|"
          . $self->project->project
          . " sprint "
          . $sprint->start_date . "]\n";
    }

    $project_parent->{'content'} .= "\n$backlog" . 
      "\n{note}This page is automatically generated.  Any changes to this page will be reverted.{note}\n";
    my $result = $wiki->updatePage($project_parent);

    foreach my $sprint (@{$self->project->sprints}) {
        $self->_create_sprint_page($wiki, $sprint, $result, $self->project->project . " sprint " . $sprint->start_date);
    }

	return 0;
}

sub _create_sprint_page
{
    my ($self, $wiki, $sprint, $parent, $title) = @_;

    my $page = $self->_get_or_create_page($wiki, $parent, $title);

    my $stories = '';
    my ($tasks, $completed) = (0, 0);
    my $counts = {
                  'Not Started'  => 0,
                  'In Progress'  => 0,
                  'Verification' => 0,
                  'Completed'    => 0,
                 };
    foreach my $story (@{$sprint->stories}) {
        $stories .= 'h4. ' . $story->title . "\n";

        $stories .= "{table-plus:columnTypes=s,s,s|sortColumn=2}\n||owner||status||description||\n";
        foreach my $task (@{$story->tasks}) {
            $tasks++;
            my $status;
            if ($task->state eq 'todo') {
                $status = '(-) Not Started';
                $counts->{'Not Started'}++;
            } elsif ($task->state eq 'inprogress') {
                $status = '(!) In Progress';
                $counts->{'In Progress'}++;
            } elsif ($task->state eq 'verify') {
                $status = '(i) Awaiting Verification';
                $counts->{'Verification'}++;
            } elsif ($task->state eq 'done') {
                $status = '(/) Completed';
                $counts->{'Completed'}++;
                $completed++;
            }
            my ($owner, $title) =
              map { my $tmp = $_; $tmp =~ s/\|/\\\|/; $tmp } ($task->scrumer ? $task->scrumer->{'name'} : ' ', $task->title);
            $stories .= "|$owner|$status|$title|\n";
        }
        $stories .= "{table-plus}\n";
    }

    $stories .= "\n{note}This page is automatically generated.  Any changes to this page will be reverted.{note}\n";

    my $chart_limit = time2str("%Y-%m-%d", time() + (60 * 60 * 24 * 30));

    my $burndown = 'Overall Progress:
{chart:type=bar|colors=red,yellow,blue,green|orientation=horizontal|stacked=true|height=150|width=600|dataOrientation=vertical}
| | Not Started | In Progress | Verification | Completed |
| | '
      . $counts->{'Not Started'} . ' | '
      . $counts->{'In Progress'} . ' | '
      . $counts->{'Verification'} . ' | '
      . $counts->{'Completed'} . ' |
{chart}';

    $burndown .=
      "{chart:type=timeSeries|dateFormat=yyyy-MM-dd|domainaxisrotateticklabel=true|title=Task Burndown|xLabel=Date|yLabel=Tasks Remaining|legend=true|height=300|width=600|dataOrientation=vertical|rangeAxisLowerBound=0|domainAxisUpperBound=$chart_limit}\n|| Date || Total Tasks || Tasks Remaining ||\n";
    foreach my $snapshot (@{$sprint->snapshots}) {
        $burndown .=
          "|" . $snapshot->snapshot_date . "|" . $snapshot->hours_total . "|" . $snapshot->hours_remaining . "|\n";
    }
    $burndown .= "|" . time2str("%Y-%m-%d", time()) . "|$tasks|" . ($tasks - $completed) . "|\n";
    $burndown .= "{chart}";

    $page->{'content'} =
      "This project is managed at scrumy.  Do not edit this page, visit [The project page at scrumy|http://scrumy.com/"
      . $self->project->project
      . "] instead.\n"
      . "{section}{column}${stories}{column}{column}${burndown}{column}{section}";
    return $wiki->updatePage($page);
}

sub _get_or_create_page
{
    my ($self, $wiki, $parent, $title) = @_;

    $wiki->setRaiseError(0);
    my $page = $wiki->getPage($parent->{'space'}, $title);
    if (!$page) {
        $page = {
                 'title'    => $title,
                 'space'    => $parent->{'space'},
                 'parentId' => $parent->{'id'},
                };
    }
    $wiki->setRaiseError(1);

    return $page;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

Scrumy::ToConfluence - Import Scrumy project into Confluence

=head1 SYNOPSIS

use Scrumy::ToConfluence;
use Scrumy;

my $project = Scrumy->new(project => "my_project", password => "my_password");

my $importer = Scrumy::ToConfluence->new(
                                        project        => $project,
                                        confluence_url => 'http://wiki.example.com/rpc/xmlrpc',
                                        username       => 'wiki_username',
                                        password       => 'wiki_password',
                                        space          => 'Example_Space',
									   	parent         => 'Parent_Page'
                                       );
$importer->import_project();

=head1 FUNCTIONS

=over 4

=item import_project()

=over 4

Imports data from the scrumy API and formats as confluence wiki pages.

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

1;    # End of Scrumy::ToConfluence
