# 导入数据分析三剑客
import pandas as pd
import matplotlib.pyplot as plt

# 加载Excel文件
file_path = 'data.xlsx'  # 请替换为实际的文件路径
df = pd.read_excel(file_path)

# 计算每门课程的平均成绩
average_scores = df[['云计算基础知识', '云数据库和中间件', 'openstack', '云原生']].mean()

# 创建柱状图
plt.figure(figsize=(15, 10))
average_scores.plot(kind='bar')  # 使用Pandas的plot方法创建柱状图
plt.title('各模块考试平均成绩对比')
plt.xlabel('模块内容')
plt.ylabel('平均分数')
plt.xticks(rotation=0)  # 水平显示科目名称

# 添加数据标签
for index, value in enumerate(average_scores):
    plt.text(index, value + 2, str(round(value, 2)), ha='center', va='bottom')

plt.grid(axis='y', linestyle='--', alpha=0.7)  # 只在Y轴添加网格线
plt.tight_layout()  # 自动调整子图参数，使之填充整个图像区域

# 导出图表
plt.savefig('bar-plot.png')