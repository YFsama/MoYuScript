import re

def process_as_path(as_path):
    # 展开方括号内的 ASN
    as_path = re.sub(r'\[([0-9\s]+)\]', r'\1', as_path)
    
    # 提取 ASN 序列
    as_numbers = re.findall(r'\d+', as_path)
    
    # 去除前导 localpref
    as_numbers = [asn for asn in as_numbers if asn != "999"]
    
    # AS-Path 必须以 9886 开头
    if as_numbers and as_numbers[0] != "9886":
        as_numbers.insert(0, "9886")

    # 合并连续重复的 ASN
    compressed_as_path = []
    last_asn = None
    for asn in as_numbers:
        if asn != last_asn:
            compressed_as_path.append(asn)
        last_asn = asn
    
    # 生成最终格式
    formatted_as_path = "^(" + "_)+(".join(compressed_as_path) + "_)+$"
    return formatted_as_path

def process_bgp_output(lines):
    results = []
    for line in lines:
        parts = line.split()
        if len(parts) < 2:
            continue

        # 提取 IP/CIDR
        ip_cidr = parts[1]

        # 提取 AS-Path 部分
        as_path = " ".join(parts[4:])  # 省略前面的无关字段

        # 处理 AS-Path
        formatted_as_path = process_as_path(as_path)

        # 生成最终输出
        result = f"{ip_cidr} AS-Path: {formatted_as_path}"
        results.append(result)
    
    return results

# 示例输入数据
bgp_output = """
* 11.45.1.4/24          Self                         999        114514 I
* 19.19.8.10/24         Self                 0       999        114514 1919810 I
"""

# 处理 BGP 数据
lines = bgp_output.strip().split("\n")
processed_results = process_bgp_output(lines)

# 输出结果
for res in processed_results:
    print(res)
