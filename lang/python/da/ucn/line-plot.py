# 导入数据分析三剑客
import pandas as pd
import matplotlib.pyplot as plt

# 读取Excel文件
df = pd.read_excel('line-plot.xlsx')

# 设置画布大小
plt.figure(figsize=(15, 10))

# 遍历每门课程绘制趋势图
subjects = ['云计算基础知识', '云数据库和中间件', 'openstack', '期中考试', '云原生']
for subject in subjects:
    plt.plot(df['姓名'], df[subject], label=subject, marker='o')

# 添加标题和坐标轴标签
plt.title('云原生成绩趋势图')
plt.xlabel('姓名')
plt.ylabel('分数')
plt.xticks(rotation=90)  # 旋转X轴标签以便于阅读
plt.legend()  # 显示图例
plt.grid(True)  # 显示网格
plt.tight_layout()  # 自动调整子图参数，使之填充整个图像区域

# 显示图表
plt.savefig('line-plot.png')