import logging
import os

import boto3
from botocore.exceptions import ClientError
from flask import request, send_file
from psycopg2.pool import ThreadedConnectionPool

from app import app

BUCKET_NAME = os.environ.get('BUCKET_NAME')
RDS_ENDPOINT = os.environ.get('RDS_ENDPOINT')
RDS_READ_REPLICA_ENDPOINT = os.environ.get('RDS_READ_REPLICA_ENDPOINT')
RDS_PORT = os.environ.get('RDS_PORT')
RDS_USER = os.environ.get('RDS_USER')
RDS_PASSWORD = os.environ.get('RDS_PASSWORD')
RDS_DB = os.environ.get('RDS_DB')


RDS_TABLE_NAME = 'name_to_s3_key'

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)

write_pool = ThreadedConnectionPool(1, 10,
                                    host=RDS_ENDPOINT,
                                    database=RDS_DB,
                                    user=RDS_USER,
                                    password=RDS_PASSWORD,
                                    port=RDS_PORT)
read_pool = ThreadedConnectionPool(1, 10,
                                   host=RDS_READ_REPLICA_ENDPOINT,
                                   database=RDS_DB,
                                   user=RDS_USER,
                                   password=RDS_PASSWORD,
                                   port=RDS_PORT)
s3_client = boto3.client('s3')
s3 = boto3.resource('s3')


@app.route('/<name>', methods=['GET', 'PUT', 'DELETE'])
def interact(name):
    create_table()
    if request.method == 'PUT':
        file = request.get_data()
        response = upload_file(name, file)
        return response
    if request.method == 'DELETE':
        response = delete_file(name)
        return response
    elif request.method == 'GET':
        key = get_s3_key_from_rds(name)
        if not key:
            return {'key exists': False, 'getKey': 'Fail'}, 404
        file = download_file(key)
        body = file['Body']
        return send_file(body, mimetype='image/png')
    raise Exception("Something has gone wrong!")


@app.route('/', methods=['DELETE'])
def delete():
    conn = write_pool.getconn()
    with conn.cursor() as cursor:
        command = f"DROP TABLE IF EXISTS {RDS_TABLE_NAME}"
        cursor.execute(command)
        conn.commit()
    bucket = s3.Bucket(BUCKET_NAME)
    bucket.objects.all().delete()
    logger.info(f'Have deleted all objects in {BUCKET_NAME} and have dropped table {RDS_TABLE_NAME}')
    return {'Everything deleted': True}


@app.route('/health/check', methods=['GET'])
def health_check():
    return {'Feeling healthy': True}, 200


def create_table():
    conn = write_pool.getconn()
    with conn.cursor() as cursor:
        command = f"""
        CREATE TABLE IF NOT EXISTS {RDS_TABLE_NAME} (
            name TEXT PRIMARY KEY NOT NULL,
            key TEXT NOT NULL
        );
        """
        cursor.execute(command)
        conn.commit()


def upload_file(name: str, file):
    conn = write_pool.getconn()
    conn.set_session(autocommit=False)
    with conn.cursor() as cursor:
        key = f'user-photos/{name}_s3_key'
        command = f"INSERT INTO {RDS_TABLE_NAME} (name, key) VALUES (%s, %s)"
        search_query = f'SELECT 1 FROM {RDS_TABLE_NAME} WHERE name = %s'
        cursor.execute(search_query, (name,))
        key_there = cursor.fetchone()
        if key_there:
            return {'post': 'fail'}, 400
        try:
            cursor.execute(command, (name, key))
            response = s3_client.put_object(Body=file,
                                            Bucket=BUCKET_NAME,
                                            Key=key,
                                            ServerSideEncryption='AES256')
            conn.commit()
        except ClientError as e:
            conn.rollback()
            logger.error(e)
            return {'post': 'fail'}, 400
    return response


def delete_file(name: str):
    conn = write_pool.getconn()
    conn.set_session(autocommit=False)
    with conn.cursor() as cursor:
        query_command = f"SELECT key FROM {RDS_TABLE_NAME} WHERE name = %s"
        cursor.execute(query_command, (name,))
        values = cursor.fetchone()
        if values is None or len(values) == 0:
            return {'not present': True}, 200
        key = values[0]
        try:
            delete_command = f"DELETE FROM {RDS_TABLE_NAME} WHERE name = %s"
            cursor.execute(delete_command, (name,))
            s3_client.delete_object(Bucket=BUCKET_NAME,
                                    Key=key)
            conn.commit()
        except ClientError as e:
            conn.rollback()
            logger.error(e)
            return {'delete': 'fail'}, 400
    return {'deleted': name}, 200


def get_s3_key_from_rds(name):
    conn = read_pool.getconn()
    with conn.cursor() as cursor:
        command = f"SELECT key FROM {RDS_TABLE_NAME} WHERE name = %s"
        cursor.execute(command, (name,))
        values = cursor.fetchone()
        if values is None or len(values) == 0:
            return False
        key = values[0]
    return key


def download_file(key):
    return s3_client.get_object(Bucket=BUCKET_NAME, Key=key)
