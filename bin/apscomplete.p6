#!/usr/bin/env perl6

use APS::Job;
use APS::Complete;

proto MAIN(|)
{
    my $*APSROOT = '/aps';
    my $*APSDIR = "$*APSROOT/jobs";

    my $*host = %*ENV<ORIGINHOST> // 'origin';
    my $*port = %*ENV<ORIGINPORT> // 3000;

    {*}
}

multi MAIN('success', Str:D $runid)
{
    my $job = read-input-job($runid);

    $job.read-output;

    try archive($job, "$*APSROOT/$job.project()/data".IO);

    .message.say with $!;

    my $state = $! ?? FAIL !! OK;

    "$*APSDIR/$job.runid().output".IO.spurt: ~$job;

    origin-run-complete($job, $state);
}

multi MAIN('fail', Str:D $runid)
{
    my $job = read-input-job($runid);

    origin-run-complete($job, FAIL)
}
