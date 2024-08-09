import os
import boto3
from botocore.client import Config
from botocore.exceptions import NoCredentialsError

# Cloudflare R2 配置
r2_access_key_id = 'your_access_key_id'
r2_secret_access_key = 'your_secret_access_key'
r2_bucket_name = 'your_bucket_name'
r2_endpoint_url = 'https://your_r2_endpoint_url'

# 初始化R2的S3客户端，使用指定的签名版本
s3_client = boto3.client('s3',
                         endpoint_url=r2_endpoint_url,
                         aws_access_key_id=r2_access_key_id,
                         aws_secret_access_key=r2_secret_access_key,
                         config=Config(signature_version='s3v4'))

# 定义本地备份目录
backup_root_dir = '/backup'

def file_exists_in_r2(bucket_name, object_name):
    """检查R2中是否存在指定的文件"""
    try:
        s3_client.head_object(Bucket=bucket_name, Key=object_name)
        return True
    except Exception:
        return False

def upload_to_r2(file_path, bucket_name, object_name=None):
    """上传文件到Cloudflare R2，如果文件不存在"""
    if object_name is None:
        object_name = os.path.basename(file_path)
    
    if file_exists_in_r2(bucket_name, object_name):
        print(f'文件已存在: {object_name}, 跳过上传')
    else:
        try:
            s3_client.upload_file(file_path, bucket_name, object_name)
            print(f'上传成功: {file_path} 到 R2 -> {object_name}')
        except FileNotFoundError:
            print(f'文件未找到: {file_path}')
        except NoCredentialsError:
            print('无法访问凭证，上传失败')
        except Exception as e:
            print(f'上传到R2时发生错误: {str(e)}')

def list_r2_files(bucket_name, prefix=''):
    """列出R2存储桶中的所有文件，并按最后修改时间排序"""
    try:
        response = s3_client.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
        files = response.get('Contents', [])
        files.sort(key=lambda x: x['LastModified'], reverse=True)
        return files
    except Exception as e:
        print(f'列出R2文件时发生错误: {str(e)}')
        return []

def delete_r2_file(bucket_name, key):
    """从R2删除指定的文件"""
    try:
        s3_client.delete_object(Bucket=bucket_name, Key=key)
        print(f'删除文件: {key}')
    except Exception as e:
        print(f'删除R2文件时发生错误: {str(e)}')

def manage_r2_files(bucket_name, prefix='', max_files=50):
    """确保R2上只保留最新的 max_files 份备份文件"""
    files = list_r2_files(bucket_name, prefix)
    if len(files) > max_files:
        for file in files[max_files:]:
            delete_r2_file(bucket_name, file['Key'])

def sync_backups_to_r2(backup_root_dir, max_files=50):
    """同步本地备份到 R2，并管理保留的文件数量"""
    for root, _, files in os.walk(backup_root_dir):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            relative_path = os.path.relpath(file_path, backup_root_dir)

            # 上传文件到Cloudflare R2
            upload_to_r2(file_path, r2_bucket_name, object_name=relative_path)

            # 同步后管理R2上的文件数量，保留最新的max_files个文件
            manage_r2_files(r2_bucket_name, prefix=os.path.dirname(relative_path), max_files=max_files)

# 执行同步操作
sync_backups_to_r2(backup_root_dir, max_files=50)

print('同步完成！')
