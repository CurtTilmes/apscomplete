use JSON::Fast;
use URI::Template;
use LibCurl::Easy;

my $runuri = URI::Template.new(template => 'run/{runid}{?project,state}');

enum JobState <NEW OK FAIL>;

# Upload run to Origin, noting OK or FAIL
sub origin-run-complete($job, JobState $state) is export
{
    with $job
    {
        my %body;
        %body<software> = .software.hashlist if .software;
        %body<inputs>   = .inputs.hashlist if .inputs;
        %body<outputs>  = .outputs.hashlist if .outputs && $state ~~ OK;

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

# Copy all output files from $job to $destdir
sub archive($job, IO::Path:D $destdir) is export
{
    die "Missing archive dir $destdir" unless $destdir.d;

    for $job.outputs.files
    {
        with $destdir.add(.file.basename)
        {
            die "$_ already exists" if .f
        }
    }

    for $job.outputs.files
    {
        .file.copy: $destdir.add: .file.basename
    }
}
