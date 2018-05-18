#!/usr/bin/perl
use strict;
use JSON;
use Data::Dumper;
use Getopt::Long;

########################################################################################################################
## Variables

my %PARAMTERERS;
my $new_recordset_value;
my $tmp_file = "/tmp/change_batch.json";

########################################################################################################################
## Functions

sub trim($){
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}## sub trim

sub print_help() {
    print "Usage:\n";
    print "\t$0 [-hz|--hosted-zone] [-n|--dns-name] [-t|--dns-type] [-?|--help]\n";
    print "\t  -hz, --hosted-zone    Route53 Hosted Zone ID\n";
    print "\t  -n,  --dns-name       DNS record name (e.g. sub-domain.example.com)\n";
    print "\t  -t,  --dns-type       DNS record type (e.g. A|CNAME)\n";
    exit 0;
}

sub process() {
    GetOptions(
     'hosted-zone|hz=s' => \$PARAMTERERS{'HOSTED_ZONE'},
     'dns-type|t=s' => \$PARAMTERERS{'RECORD_SET_TYPE'},
     'dns-name|n=s' => \$PARAMTERERS{'RECORD_SET_VALUE'},
     'help' => sub{ print_help() }
    );
}

########################################################################################################################
## Main handler

process();

if( $PARAMTERERS{'RECORD_SET_TYPE'} eq 'CNAME') {
  $new_recordset_value = trim(`curl -s http://169.254.169.254/latest/meta-data/public-hostname`);

} elsif( $PARAMTERERS{'RECORD_SET_TYPE'} eq 'A') {
  $new_recordset_value = trim(`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`);
}

my %json_body = ( 'Comment' => 'Update Route53 record',
				'Changes' => [
					{
						'Action' => 'UPSERT',
						'ResourceRecordSet' => {
							'Type' => "$PARAMTERERS{'RECORD_SET_TYPE'}",
							'TTL' => 10,
							'Name' => "$PARAMTERERS{'RECORD_SET_VALUE'}.",
							'ResourceRecords' => [
								{
									'Value' => $new_recordset_value
								}
							]
						}
					}
				]
				);

my $change_batch = to_json( \%json_body );

open my $file, '>', "$tmp_file" or die $!;
print $file $change_batch;

print `aws route53 change-resource-record-sets --hosted-zone-id "/hostedzone/$PARAMTERERS{'HOSTED_ZONE'}" --change-batch file://$tmp_file`;
`rm $tmp_file`;
