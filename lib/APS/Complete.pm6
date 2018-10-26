use JSON::Fast;
use URI::Template;
use LibCurl::Easy;

my $runuri = URI::Template.new(template => 'run/{runid}{?project,state}');

enum JobState <NEW OK FAIL>;

sub origin-run-complete($job, JobState $state) is export
{
    with $job
    {
        my %body;
        %body<software> = .software.hashlist if .software;
        %body<inputs>   = .inputs.hashlist if .inputs;
        %body<outputs>  = .outputs.hashlist if .outputs;

        LibCurl::Easy.new(URL => "http://$*host:$*port/" ~
                          $runuri.process(runid => .runid,
                                          project => .project,
                                          :$state),
                          Content-Type => 'application/json',
                          send => to-json(%body),
                          customrequest => 'POST',
                          :failonerror).perform
    }
}
