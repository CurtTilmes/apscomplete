use JSON::Fast;
use LibCurl::Easy;
use URI::Template;
use YAML;
use APS::Software;
use APS::File;

my $runuri = URI::Template.new(template => 'run/{runid}{?project,state}');

enum JobState <NEW OK FAIL>;

class Job
{
    has $.runid;
    has $.project;
    has $.archiveset;
    has $.image;
    has $.command;
    has @.args;
    has $.software;
    has $.inputs;
    has $.outputs;
    has $.statistics = %();

    submethod BUILD(:$!runid)
    {
        with yaml.load("$*APSDIR/$!runid.input".IO.slurp)
        {
            $!project = .<Project>;
            $!image = .<Image>;
            $!archiveset = .<Archiveset>;
            $!command = .<Command>;
            @!args = .<Args>;
            $!software = SoftwareList.new(:$!project, list => .<Software>);
            $!inputs = FileList.new(:$!project, list => .<Input>);
        }
        else
        {
            die "Can't parse $!runid.input";
        }
    }

    method archive-outputs()
    {
        $!outputs = FileList.new(:$!project, :$!archiveset)
    }

    method origin-update-run(JobState $state)
    {
        my $body = do given $state
        {
            when 'NEW'  { %( software => $!software.?hashlist,
                             inputs   => $!inputs.?hashlist) }

            when 'OK'   { %( software => $!software.?hashlist,
                             inputs   => $!inputs.?hashlist,
                             outputs  => $!outputs.?hashlist ) }

            when 'FAIL' { %( ) }
        };

        LibCurl::Easy.new(URL => "http://$*host:$*port/" ~
                                 $runuri.process(:$!runid, :$!project, :$state),
                          Content-Type => 'application/json',
                          send => to-json($body),
                          customrequest => 'POST', :failonerror).perform
    }
}
