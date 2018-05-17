import base64
import binascii

def base64_encode_md5_str(md5_str):
    md5_str = binascii.unhexlify(md5_str)
    return base64.encodestring(md5_str)

def lambda_handler(event, context):
    # TODO implement
    print(base64_encode_md5_str('bea8252ff4e80f41719ea13cdf007273'))
    return 