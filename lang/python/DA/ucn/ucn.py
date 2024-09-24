import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# 创建一个示例数据集
df = pd.read_excel('data.xlsx')

plt.figure(figsize=(20, 6))  # 设置图形大小

# 假设DataFrame中有两列：'Name' 和 'Score'
plt.bar(df['name'], df['score'])  # 绘制条形图显示每个学生的分数
plt.xlabel('学员姓名')  # X轴标签
plt.ylabel('学员分数')  # Y轴标签
plt.title('云原生考试成绩')  # 图形标题
plt.xticks(rotation=90)  # 旋转X轴上的标签以便于阅读
plt.tight_layout()  # 自动调整子图参数，使之填充整个图像区域
plt.savefig('ucn.png')  # 显示图形