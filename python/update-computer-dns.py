#!/usr/bin/python

from netifaces import interfaces, ifaddresses, AF_INET
from optparse import OptionParser
import boto3
import logging
import socket
import sys

def get_ip(interface):
  for ifaceName in interfaces():
    if ifaceName == options.INTERFACE:
      for i in ifaddresses(ifaceName).setdefault(AF_INET, [{'addr':'No IP addr'}] ):
        return i['addr']
  return

def hostname_2_ip(hostname):
  try:
    return socket.gethostbyname(hostname)
  finally:
    return False

LOG_FILE = '/var/log/update-computer-dns.log'
SCRIPT = 'update-computer-dns.py'

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
parser.add_option("--interface", dest="INTERFACE", help="Network interface", action="store", type="str")
parser.add_option("--hostname", dest="HOSTNAME", help="Hostname", action="store", type="str")
parser.add_option("--hosted-zone", dest="HOSTED_ZONE", help="ID of hosted zone", action="store")
(options, args) = parser.parse_args()

if not options.INTERFACE:
  parser.error('Interface not given')
  exit(1)

if not options.HOSTNAME:
  parser.error('Hostname not given')
  exit(1)

if not options.HOSTED_ZONE:
  parser.error('Hosted zone not given')
  exit(1)

logger.info( "--interface %s --hostname %s --hosted-zone %s starting..." % ( options.INTERFACE, options.HOSTNAME, options.HOSTED_ZONE ) )

new_recordset_value = get_ip(options.INTERFACE)
old_recordset_value = hostname_2_ip(options.HOSTNAME)

if new_recordset_value != old_recordset_value:
  logger.info( "Set value = %s" % ( new_recordset_value ) )

  response = client.change_resource_record_sets(
    HostedZoneId=options.HOSTED_ZONE,
    ChangeBatch={
        'Comment': 'Update Route53 record',
        'Changes': [
            {
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': options.HOSTNAME,
                    'Type': 'A',
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

else:
  logger.info( 'Same IP address' )

