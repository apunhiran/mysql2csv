#!/usr/local/bin/perl -w

=head1 NAME

mysql2csv: Perl script to export mysql table/sql into CSV file

=head1 SYNOPSIS

mysql2csv.pl -h <hostname> -port <port number> -d <DB name> -u <username> -p <password> -s <sql file> | -t <table name> -o <output filename>

=head1 DESCRIPTION

This script was build out of necessity. Mysql utilities like mysqldump and OUTFILE creates files on the mysql database host.
The requiement was to dump the data on the client system.
Perl Modules Used: DBI, DBD::mysql, Getopt::Long & Pod::Usage

=head1 ARGUMENTS

mysql_2_csv takes the following arguments:

=over 4

=item help

  -help

(Optional.) Displays the usage message.

=item man

  -man

(Optional.) Displays all documentation.

=item h

        -h - hostname of the mysql DB server.

=item port

        -port - port to connect to mysql database.

=item d

        -d - name from the mysql database/schema.

=item u

        -u - username to connect to mysql instance.

=item p

        -p - password for the username specified under -u argument.

=item s

        -s - file containing the select query, whose output has to be dumped as csv.

=item t

        -t - name of the table to be dump as csv.

=item o

        -o - name of the csv file to be created.

=back

=head1 AUTHOR

Apun Hiran, apunh@yahoo-inc.com

=head1 COPYRIGHT

This program is distributed under the Artistic License.

=head1 DATE

15-Jan-2014

=cut

#Perl modules used
use strict;
use DBI;
use DBD::mysql;
use Getopt::Long;
use Pod::Usage;

# Input related VARIABLES
my (
    $help, $man, $database, $host,    $port, $user,
    $pw,       $sqlfile, $table, $outname
);
my %args;

Getopt::Long::GetOptions(
    \%args,
    'help'       => \$help,
    'man'        => \$man,
        'h=s'    => \$host,
    'port=i' => \$port,
    'd=s'    => \$database,
    'u=s'    => \$user,
    'p=s'    => \$pw,
    's:s'    => \$sqlfile,
    't:s'    => \$table,
    'o=s'    => \$outname,
) || die "Incorrect usage!\n" && Pod::Usage::pod2usage( -exitstatus => 2 );

Pod::Usage::pod2usage( -verbose => 1 ) if ( $help );
Pod::Usage::pod2usage( -exitstatus => 0, -verbose => 2 ) if ( $man  );

# Checking if variables have been defined.
unless ( defined ($host) && defined ($port) && defined ($database) && defined ($user) && defined ($pw) && defined ($outname)) { Pod::Usage::pod2usage( -exitstatus => 2 ); }

my $sql;

if ( defined $table && defined $sqlfile ) {
    print
"Invalid options!!! Correct Usage:\n $0 -h <hostname> -port <port number> -d <DB name> -u <username> -p <password> -s <sql file> | -t <table name> -o <output filename>\n";
    exit;
}
elsif ( defined $table ) {
    $sql = "select * from $table";
}
else {
    open( FILE, '<', $sqlfile ) or die "cannot open file $sqlfile";
    $sql = <FILE>;
    close(FILE);
}

# Variables from processing the data and connection.

my ( $dbh, $sth, $re, $header );

#Generating DATA SOURCE NAME using the input received.
my $dsn = "dbi:mysql:$database:$host:$port";

#Setting up connection to MySQL Database.

$dbh = DBI->connect( $dsn, $user, $pw, { AutoCommit => 0, RaiseError => 1 } )
  or die "Unable to connect to mysql DB_NAME on host $host: $dbh->err\n";

#Preparing and executing the SQL.

$sth = $dbh->prepare($sql) or die "Unable to prepare $sql\n";

$sth->execute();

#This is to avoid "uninitialized" errors when column is NULL

no warnings 'uninitialized';

#Opening the file to save CSV data.

open( OUT, ">$outname" )
  or die "Unable to open $outname for writing\n";
#Getting Column names for the table.
$header = $sth->{NAME};
#Writing 1st row as column names in the file.
print OUT join( "\x01", @$header ), "\n";
#Getting number of columns for the table.
my $fields = $sth->{NUM_OF_FIELDS};

my $index=0;
my $coldata;

while ( my @row = $sth->fetchrow_array ) {
    while ( $index < $fields ) {
        $coldata = $row[$index];
# Removing newline characters present in row data.
        $coldata =~ s/\n//g;
# Removing Control characters in the row data.
        $coldata =~ s/[\000-\037]//g;
        print OUT "$coldata\x01";
        $index++;
    }
    print OUT "\n";
    $index = 0;
}

close(OUT);

$sth->finish;

$dbh->disconnect;
