import pandas as pd

# 读取 Excel 文件
file_path = 'data.xlsx'  # 替换为你的 Excel 文件路径
df = pd.read_excel(file_path, engine='openpyxl')

# 找出所有标记为“缺勤”或“请假”的单元格
absence_records = []

# 遍历 DataFrame 的每一行和每一列
for index, row in df.iterrows():
    name = row[0]  # 假设第一列为姓名
    for date, status in row[1:].items():  # 跳过姓名列，从第二列开始
        if status in ['缺勤', '请假']:  # 检查是否是“缺勤”或“请假”
            absence_records.append([name, date, status])  # 记录姓名、日期和状态

# 将结果转换为 DataFrame
absence_df = pd.DataFrame(absence_records, columns=['姓名', '日期', '状态'])



# 如果需要，可以保存到新的 Excel 文件中
output_file_path = 'absence_and_leave_records.xlsx'
absence_df.to_excel(output_file_path, index=False, engine='openpyxl')
