import paramiko
import os
import datetime

# 定义要连接的Juniper MX304服务器信息
servers = [
    {'hostname': '192.168.1.1', 'username': 'admin', 'password': 'password', 'name': 'Server1'},
    {'hostname': '192.168.1.2', 'username': 'admin', 'password': 'password', 'name': 'Server2'},
    # 添加更多服务器信息
]

# 获取当前日期时间，作为备份文件的标识
timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')

# 遍历每个服务器
for server in servers:
    hostname = server['hostname']
    username = server['username']
    password = server['password']
    server_name = server['name']

    # 定义每个服务器的备份目录
    server_backup_dir = os.path.join('./backup_configs/', server_name)
    
    # 创建服务器的备份目录（如果不存在）
    if not os.path.exists(server_backup_dir):
        os.makedirs(server_backup_dir)

    try:
        # 创建SSH客户端
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname, username=username, password=password,timeout=15)

        # 备份 display set 格式的配置文件
        stdin, stdout, stderr = ssh.exec_command('show configuration | display set')
        config_set_data = stdout.read().decode('utf-8')
        backup_filename_set = f'{server_name}_backup_set_{timestamp}.conf'
        backup_filepath_set = os.path.join(server_backup_dir, backup_filename_set)

        # 将 display set 配置文件内容写入备份文件
        with open(backup_filepath_set, 'w') as f:
            f.write(config_set_data)

        print(f'备份成功: {backup_filename_set}')

        # 备份普通格式的配置文件
        stdin, stdout, stderr = ssh.exec_command('show configuration')
        config_data = stdout.read().decode('utf-8')
        backup_filename_normal = f'{server_name}_backup_{timestamp}.conf'
        backup_filepath_normal = os.path.join(server_backup_dir, backup_filename_normal)

        # 将普通配置文件内容写入备份文件
        with open(backup_filepath_normal, 'w') as f:
            f.write(config_data)

        print(f'备份成功: {backup_filename_normal}')

        # 关闭SSH连接
        ssh.close()

    except Exception as e:
        print(f'无法连接到 {hostname}: {str(e)}')

print('所有备份完成！')
