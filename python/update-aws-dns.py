#!/usr/bin/python3

from optparse import OptionParser
from boto.utils import get_instance_metadata
import boto3
import json
import datetime
import logging

LOG_FILE = '/var/log/update-aws-dns.log'
SCRIPT = 'update-aws-dns.py'

#Logging
logger = logging.getLogger(SCRIPT)
logger.setLevel(logging.INFO)

hdlr = logging.FileHandler(LOG_FILE)
hdlr.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(name)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)

#Initial RDS API
client = boto3.client('route53')

#Arguments
parser = OptionParser()
parser.add_option("-z", "--hosted-zone", dest="HOSTED_ZONE", help="ID of hosted zone", action="store")
parser.add_option("-n", "--dns-name", dest="RECORD_SET_VALUE", help="DNS record name (e.g. sub-domain.example.com)", action="store")
parser.add_option("-t", "--dns-type", dest="RECORD_SET_TYPE", help="DNS record type (e.g. A|CNAME)", action="store")
parser.add_option("-i", "--ip-type", dest="IP_TYPE", help="IP type (e.g. public or local)", action="store")
(options, args) = parser.parse_args()

logger.info( "--hosted-zone %s --dns-name %s --dns-type %s --ip-type %s starting..." % ( options.HOSTED_ZONE, options.RECORD_SET_VALUE, options.RECORD_SET_TYPE, options.IP_TYPE ) )

## Retrieve meta data
if options.RECORD_SET_TYPE == 'CNAME':
  metadata_data = 'meta-data/' + options.IP_TYPE + '-hostname/'
  metadata = get_instance_metadata(version='latest', url='http://169.254.169.254', data=metadata_data, timeout=None, num_retries=1)

elif options.RECORD_SET_TYPE == 'A':
  metadata_data = 'meta-data/' + options.IP_TYPE + '-ipv4/'
  metadata = get_instance_metadata(version='latest', url='http://169.254.169.254', data=metadata_data, timeout=None, num_retries=1)

new_recordset_value = list(metadata.values())[0]
logger.info( "Set value = %s" % ( new_recordset_value ) )

response = client.change_resource_record_sets(
    HostedZoneId=options.HOSTED_ZONE,
    ChangeBatch={
        'Comment': 'Update Route53 record',
        'Changes': [
            {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': options.RECORD_SET_VALUE,
                    'Type': options.RECORD_SET_TYPE,
                    'TTL': 60,
                    'ResourceRecords': [
                        {
                            'Value': new_recordset_value
                        },
                    ],
                }
            }
        ]
    }
)

logger.info( "Result: %s" % ( response ) )
