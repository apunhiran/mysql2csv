# mysql2csv: 
###### Perl script to export mysql table/sql into CSV file

## USAGE: 
```mysql2csv.pl -h <hostname> -port <port number> -d <DB name> -u <username> -p <password> -s <sql file> | -t <table name> -o <output filename>```

### Description:
This script was build out of necessity. Mysql utilities like mysqldump and OUTFILE creates files on the mysql database host.
The requiement was to dump the data on the client system.

### Perl Modules Used: 
- DBI 
- DBD::mysql 
- Getopt::Long
- Pod::Usage

### Arguments:
* -help (Optional.) Displays the usage message.
*   -man (Optional.) Displays all documentation.
*   -h hostname of the mysql DB server.
*   -port port to connect to mysql database.
*   -d name from the mysql database/schema.
*   -u username to connect to mysql instance.
*   -p password for the username specified under -u argument.
*   -s file containing the select query, whose output has to be dumped as csv.
*   -t name of the table to be dump as csv.
*   -o name of the csv file to be created.

### Example:
* Exporting table ad from the moneyball database:

```mysql2csv -h gq1-mb-db2.data.gq1.yahoo.com -port 3306 -d mb -u uad -p <xyz> -t ad -o ad_2014011518.csv```

* Export the output of a sql:

```-bash-4.1$ more site.sql
select publisher_id,name,status from site```

```mysql2csv.pl -h gq1-mb-db2.data.gq1.yahoo.com -port 3306 -d mb -u uad -p <xyz> -s site.sql -o site.csv```
