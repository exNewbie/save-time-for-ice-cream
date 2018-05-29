import boto3
import os
import pathlib
import shutil


TEMP_DIR = '/tmp/s3_on_local/'
S3_BUCKET = 'my_bucket'
S3_PREFIX = 'sub-folder1/sub-folder2'


def download_files(s3_client):
    response = s3_client.list_objects_v2(
        Bucket=S3_BUCKET,
        EncodingType='url',
        MaxKeys=10000,
        Prefix=S3_PREFIX
    )

    for obj in response['Contents']:
        downloaded_file = TEMP_DIR + obj['Key']
        print('Downloading file: ' + downloaded_file)
        parent_folder = "/".join(obj['Key'].split("/")[0:-1])
        parent_folder = os.path.join(TEMP_DIR, parent_folder)

        key_path = os.path.join(parent_folder, obj['Key'].split("/")[-1])
        if not os.path.exists(parent_folder):
            os.makedirs(name=parent_folder)
        if not os.path.exists(key_path):
            with open(downloaded_file, 'wb') as data:
                s3_client.download_fileobj('trungldd', obj['Key'], data)
    return

def upload_files(s3_client, delete=False):
    for (dirpath, dirnames, filenames) in os.walk(TEMP_DIR):
        if filenames:
            for filename in filenames:
                full_path = dirpath + '/' + filename
                s3_key = full_path.replace(TEMP_DIR, '')
                print('Uploading file:' + full_path)
                with open(full_path, 'rb') as data:
                    s3_client.upload_fileobj(data, S3_BUCKET, s3_key)

    if delete:
        try:
            print('Deleting folder: ' + TEMP_DIR)
            shutil.rmtree(TEMP_DIR)
        except OSError as e:
            print ("Error: %s - %s." % (e.filename, e.strerror))
    return

s3_client = boto3.client('s3')
#download_files(s3_client)
#upload_files(s3_client, True)
