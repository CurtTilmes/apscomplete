#!/usr/bin/env perl6

use APS::Job;
use APS::Complete;

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
    my $job = read-input-job($runid);

    $job.read-output;

    my $archdir = "$*APSROOT/$job.project()/data".IO;

    exit note "Missing archive dir $archdir" unless $archdir.d;

    for $job.outputs.file
    {
        my $dest = $archdir.add(.basename);
        exit note "$dest already exists!" if $dest.f;
        .file.copy($dest)
    }

    "$*APSDIR/$job.runid().output".IO.spurt: ~$job;

    origin-run-complete($job, OK)
}

multi MAIN('fail', Str:D $runid)
{
    my $job = read-input-job($runid);

    origin-run-complete($job, FAIL)
}
