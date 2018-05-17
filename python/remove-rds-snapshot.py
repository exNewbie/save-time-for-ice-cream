#!/usr/bin/python

#from datetime import datetime
from optparse import OptionParser
import boto3
import json
import datetime
import logging

#Constants
LOG_FILE = '/var/log/rds-snapshot.log'
SCRIPT = 'remove-snapshot'
EXPIRED_PERIOD = -425
bk_datetime = datetime.datetime.now() + datetime.timedelta( EXPIRED_PERIOD )

#Logging
logger = logging.getLogger(SCRIPT)
logger.setLevel(logging.INFO)

hdlr = logging.FileHandler(LOG_FILE)
hdlr.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(name)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)

#Initial RDS API
client = boto3.client('rds', region_name='ap-southeast-2')

#Arguments
parser = OptionParser()
parser.add_option("-s", dest="SOURCE_DB", help="Source DB Identifier", action="store")
parser.add_option("-k", "--key", dest="KEY_WORD", help="Key word of backups", action="store")
(options, args) = parser.parse_args()

all_snapshots_rsp = client.describe_db_snapshots(
    DBInstanceIdentifier=options.SOURCE_DB,
    SnapshotType='manual',
    MaxRecords=20
)

logger.info( "-s %s -k %s starting..." % ( options.SOURCE_DB, options.KEY_WORD ) )

filtered_snapshots = []
#loop over response and append SnapshotCreateTime and DBSnapshotIdentifier to a list
for all_snapshots_key, all_snapshots_value in all_snapshots_rsp.items():
	if all_snapshots_key == 'DBSnapshots':
		for snapshot in all_snapshots_value:
			if options.KEY_WORD in snapshot['DBSnapshotIdentifier']:
				filtered_snapshots.append( {snapshot['SnapshotCreateTime'] , snapshot['DBSnapshotIdentifier']} )

#Sort the list and get the 1st item only which is the eldest backup
filtered_snapshots.sort()
logger.info( "The eldest snapshot: %s" % filtered_snapshots[0])
for eldest_snapshot in filtered_snapshots[0]:
	if type(eldest_snapshot) is datetime.datetime:
		eldest_snapshot_date = eldest_snapshot.date()
	else:
		eldest_snapshot_name = eldest_snapshot

if eldest_snapshot_date < bk_datetime.date():
	print "eldest_snapshot_date < bk_datetime.date eldest_snapshot_name=", eldest_snapshot_name
	logger.info("Remove snapshot=%s" % eldest_snapshot_name)
	remove_snapshot_rsp = client.delete_db_snapshot( DBSnapshotIdentifier=eldest_snapshot_name )
        logger.info(remove_snapshot_rsp)
else:
	logger.info("No snapshots to delete")

logger.info("Work finished")
