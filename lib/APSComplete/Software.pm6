
class Software
{
    has $.project;
    has $.name;
    has $.version;

    multi submethod BUILD(Str:D :$item, Str:D :$project)
    {
        self.BUILD: :$project, item => %( name => $item)
    }

    multi submethod BUILD(:%item, Str:D :$project)
    {
        given %item
        {
            $!project = .<project> // $project;
            die "Must specify Software name" unless .<name>;
            my @parts = .<name>.comb(/<-[/]>+/);
            if @parts.elems == 3
            {
                die "Software can't have project in name and project $_"
                    if .<project>:exists;
                die "Software can't have version in name and version $_"
                    if .<version>:exists;
                $!project = @parts[0];
                $!name    = @parts[1];
                $!version = @parts[2];
            }
            elsif @parts.elems == 2
            {
                die "Software can't have version in name and version, $_"
                    if .<version>:exists;
                $!project = .<project> // $project;
                $!name    = @parts[0];
                $!version = @parts[1];
            }
            elsif @parts.elems == 1
            {
                $!name = .<name>;
                $!version = .<version> // die "Must specify version, $_";
            }
            else
            {
                die "Bad software $_";
            }
        }
    }

    method hash() { %( :$!project, :$!name, :$!version ) }
}

class SoftwareList
{
    has Software @.software;

    submethod BUILD(Str:D :$project, :@list)
    {
        @!software = Software.new(:$project, item => $_) for @list
    }

    method hashlist() { @!software».hash }
}
