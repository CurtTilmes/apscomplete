#!/usr/bin/env perl6

use APS::Job;

proto MAIN(|)
{
    my $*APSROOT = '/tis';
    my $*APSDIR = "$*APSROOT/aps";

    my $*host = %*ENV<ORIGINHOST> // 'origin';
    my $*port = %*ENV<ORIGINPORT> // 3000;

    {*}
}

multi MAIN('success', Str:D $runid)
{
    my $job = Job.new(:$runid);

    $job.archive-outputs;

    $job.origin-update-run(OK);
}

multi MAIN('fail', Str:D $runid)
{
    my $job = Job.new(:$runid);

    $job.origin-update-run(FAIL);
}
