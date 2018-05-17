#!/usr/bin/perl

use strict;
##use warnings;
use DBI;
use Term::ReadLine;
##use Term::ReadLine::Zoid;

my $db_path = "s-hosts.db";
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path","","", { RaiseError => 1 }) or die $DBI::errstr;
our @arr_clients = ("");
our $chosen_client = undef;

## Functions ##

sub trim($){

        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;

}##sub trim($){

my $WHOAMI = trim(`whoami`);

sub list_client_servers($){

	my $key_word = undef;
	$key_word = shift;
	my ( $query_list, $cols, $id, $client_name, $server_name, $ip_address, $port, $access_return, $user );


        print "\n\nChoose a server to access:\n";
	$query_list = $dbh->prepare( "SELECT * FROM hosts WHERE client_name LIKE ?" )  or die $DBI::errstr;
        $query_list->execute( '%'. $key_word .'%' )  or die $DBI::errstr;
        $query_list->bind_columns( undef, \$id, \$client_name, \$server_name, \$ip_address, \$port, \$user );

	while( $cols = $query_list->fetch()){
		print "$id 	 $server_name ($ip_address)\n\n";
	}##                while( $cols = $query_list->fetch()){

        $query_list->finish();

	if( $id > 0 ) {
	        print "0        Quit the program\n";
		return 1;
        } else { ##        if( $query_list->rows > 0 ){
                return 0;
        }

}##sub list_clients($){


sub list_clients{
        my ( $query_list, $cols, $id, $client_name, $server_name, $ip_address, $port, $access_return );
        my $i = 1;

	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0

        print "\nChoose a client to get a list of its servers:\n";
	$query_list = $dbh->prepare( "SELECT id, client_name FROM hosts GROUP BY client_name" );
        $query_list->execute();
	$query_list->bind_columns( undef, \$id, \$client_name );
        while( $cols = $query_list->fetch()){
		$arr_clients[$i] = $client_name;
                print "$i 	$client_name\n";
       	        $i++;
	}##                while( $cols = $query_list->fetch()){
        $query_list->finish();
	print "0 	Quit the program\n";
}


sub access_server($){
	my $server_id = shift;
	my ( $ip_address, $port, $server_name, $returnCode, $user );
	$ip_address = "";

        my $query_server = $dbh->prepare( "SELECT server_name, ip_address, port, user FROM hosts WHERE id = ?" );
	$query_server->execute( $server_id );
        $query_server->bind_columns( undef, \$server_name, \$ip_address, \$port, \$user );
	$query_server->fetch();

	if( $user ne "") {
		$WHOAMI = $user;
	}

	if( $ip_address ne "" ){
		my $connection_string = $WHOAMI."\@".$ip_address ." -p".$port;
		my $cmd = "ssh -A $connection_string";
		print "Accessing to $server_name...\n";
		$returnCode = system($cmd);
	} else {
		print "\n\nThe chosen server doesn't exit\n";
		$returnCode = 999999;
	}
	$query_server->finish();
##print "returnCode=$returnCode\n";
	return $returnCode;

}##sub access_server($){


sub choose_client{
	list_clients();
##	open(TTY, "+</dev/tty") or die "no tty: $!";
##	system "stty  cbreak </dev/tty >/dev/tty 2>&1";
##	my $client_key = getc(TTY);       # perhaps this works
##      exit(0) if( $client_key == 0 );

        my $term = new Term::ReadLine 'Simple Perl calc';
        my $OUT = $term->OUT || \*STDOUT;
        if ( defined ($_ = $term->readline()) ) {
		my $client_key = eval($_);
                choose_client() if( $client_key eq "" );
                exit(0) if( $client_key == 0 );
                warn $@ if $@;
		if( $@ ){
                	choose_client();
		} else {

			if( !defined $arr_clients[$client_key] ){
				print "\n\nClient doesn't exist or it doesn't have any server.\n\n";
	        	        choose_client();
			}
##print "arr_clients[client_key]=$arr_clients[$client_key]\n";
			$chosen_client = $arr_clients[$client_key];
			my $return_list_client_servers =  list_client_servers( $arr_clients[$client_key] );
			if( $return_list_client_servers == 0 ){
				choose_client();
			} else {
				choose_server();
			}
		}##                if( $@ ){
        }##                if ( defined ($_ = $term->readline()) ) {

}##sub choose_client{


sub choose_server(){
                       
	my $term = new Term::ReadLine 'Simple Perl calc';
        my $access_return = -1;
        while( 1 ){
		my $OUT = $term->OUT || \*STDOUT;
                if ( defined ($_ = $term->readline()) ) {
			my $res = eval($_);
                        choose_client() if( $res eq "" );
			exit(0) if( $res == 0 );
                        warn $@ if $@;
                        ##print $OUT $res, "\n" unless $@;
                        ##$access_return = access_server($res) unless $@;
                        if( $@ ){
                        	choose_client();
			} else {
                        	$access_return = access_server($res) unless $@;
                        }
                        
		        if ( $access_return == 0 || $access_return == 2 || $access_return == 65280 ) {
				exit(0);
			} else {
                                choose_client();
			}
		}##                if ( defined ($_ = $term->readline()) ) {

	}##                while( $access_return == 0 ){

}##sub choose_server($){

## Functions ##

choose_client();

$dbh->disconnect();
exit(0);
