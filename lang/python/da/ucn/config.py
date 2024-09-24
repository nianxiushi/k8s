# 查看系统有哪些字体
from matplotlib.font_manager import FontManager
fm = FontManager()
my_fonts = set (f.name for f in fm.ttflist)
my_fonts

# 用黑体显示中文，正常显示负号
plt.rcParams['font.sans-serif'] = ['WenQuanYi Micro Hei']  #
plt.rcParams['axes.unicode_minus'] = False     