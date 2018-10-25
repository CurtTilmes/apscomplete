use YAML;

sub md5sum(IO::Path $f)
{
    run('md5sum', $f.absolute, :out).out.words[0];  # Get this from LVFS/DISHAS
}

class File
{
    has $.project;
    has $.filename;
    has $.filesize;
    has $.md5;
    has $.archiveset;
    has $.key;
    has $.datatime;
    has $.esdt;

    multi submethod BUILD(Str:D :$!project, IO::Path:D :$item,
                          :$!archiveset, :$!esdt, :$!key, :$!datatime)
    {
        $!filename = $item.basename;
        $!filesize = $item.s;
        $!md5 = md5sum($item);
    }

    multi submethod BUILD(Str:D :$project, Str:D :$item)
    {
        self.BUILD: :$project, item => %( filename => $item )
    }

    multi submethod BUILD(:%item, Str:D :$project)
    {
        given %item
        {
            my @parts = .<filename>.comb(/<-[/]>+/);
            if @parts.elems == 2
            {
                die "File can't have project in field and filename: $_"
                    if .<project>.defined;
                $!project = @parts[0];
                $!filename = @parts[1];
            }
            elsif @parts.elems == 1
            {
                $!project = .<project> // $project;
                $!filename = .<filename>;
            }
            else
            {
                die "Bad file: $_"
            }
        }
    }

    method hash()
    {
        %(
             :$!project, :$!filename,
             ( :$!filesize if $!filesize.defined),
             ( :$!md5 if $!md5),
             ( :$!archiveset if $!archiveset),
             ( :$!esdt if $!esdt),
             ( :$!key if $!key),
             ( :$!datatime if $!datatime)
        )
    }
}

class FileList
{
    has File @.files;

    multi submethod BUILD(Str:D :$project, :@list where *.elems)
    {
        @!files = do for @list -> $item { File.new(:$project, :$item) }
    }

    multi submethod BUILD(Str:D :$project, Str :$archiveset)
    {
        my $files = do with 'output'.IO.slurp { yaml.load($_) } else { %() }
        my @list = dir.grep: *.f;
        @!files = do for @list -> $item
        {
            next if $item.basename eq 'output';

            $item.copy("$*APSROOT/$project/data".IO.add($item.basename));

            with $files{$item.basename}
            {
                File.new(:$project, :$item, :$archiveset, esdt => .<esdt>,
                         key => .<key> // .<datatime>, datatime => .<datatime>)
            }
            else
            {
                File.new(:$project, :$item)
            }
        }
    }

    method hashlist() { @!files».hash }
}
