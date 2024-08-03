import matplotlib.pyplot as plt
import numpy as np

# 设置中文字体
plt.rcParams['font.family'] = 'SimHei'
plt.rcParams['axes.unicode_minus'] = False  # 显示负号
# 设置黑色背景与鲜艳色彩
plt.rcParams['figure.facecolor'] = '#0d0d0d'  # 图表外部背景，黑色
plt.rcParams['axes.facecolor'] = '#1b1b1b'    # 坐标轴背景，深灰色
plt.rcParams['axes.labelcolor'] = '#e0e0e0'   # 坐标轴标签颜色，浅灰色
plt.rcParams['xtick.color'] = '#e0e0e0'       # x轴刻度颜色
plt.rcParams['ytick.color'] = '#e0e0e0'       # y轴刻度颜色
plt.rcParams['text.color'] = '#e0e0e0'        # 文本颜色
plt.rcParams['legend.facecolor'] = '#1a1a1a'  # 图例背景颜色，接近黑色
plt.rcParams['legend.edgecolor'] = '#e0e0e0'  # 图例边框颜色，浅灰色

# 数据
x = np.arange(1, 65)  # 横坐标从1到64

same_numa = [45.4, 90.7, 136, 180, 226, 270, 315, 362, 403, 450, 495, 538, 583, 627, 668, 703, 736, 764, 785, 797, 809, 810, 817, 821, 821, 824, 824, 828, 832, 831, 839, 875, 910, 928, 959, 994, 1020, 1040, 1060, 1070, 1080, 1080, 1110, 1110, 1120, 1120, 1130, 1140, 1150, 1160, 1170, 1180, 1180, 1180, 1190, 1210, 1230, 1240, 1220, 1230, 1180, 1230, 1250, 1240]
diff_numa = [25.4, 49.9, 74.6, 99.4, 123, 148, 172, 197, 222, 244, 268, 294, 317, 340, 361, 385, 407, 428, 449, 468, 490, 503, 521, 532, 547, 560, 569, 577, 583, 591, 597, 601, 608, 610, 615, 619, 623, 624, 629, 632, 631, 633, 633, 634, 635, 636, 636, 636, 637, 638, 640, 641, 643, 642, 647, 645, 645, 648, 650, 652, 652, 653, 654, 648]
regular = [45.1, 89.4, 134, 179, 224, 269, 314, 358, 402, 449, 495, 537, 582, 627, 671, 716, 761, 801, 851, 892, 938, 978, 1020, 996, 1110, 1160, 1190, 1230, 1280, 1310, 1350, 1380, 1390, 1410, 1460, 1480, 1480, 1500, 1540, 1540, 1560, 1580, 1570, 1600, 1590, 1610, 1610, 1620, 1630, 1630, 1640, 1640, 1650, 1650, 1660, 1670, 1660, 1670, 1660, 1680, 1680, 1690, 1720, 1760]

# 绘图
plt.figure(figsize=(12, 6))

# 绘制不同的线条
plt.plot(x, same_numa, label='同一numa节点iperf测试', color='#00bfff', linestyle='-')
plt.plot(x, diff_numa, label='不同numa节点iperf测试', color='#ff6347', linestyle='-')
plt.plot(x, regular, label='常规iperf测试', color='#32cd32', linestyle='-')

# 设置标题和标签
plt.title('不同测试带宽大小与并行数的关系')
plt.xlabel('并发线程数/个')
plt.ylabel('1分钟iperf3打流TCP带宽大小/Gbps')

# 设置x轴范围
plt.xlim(1, 64)

# 显示图例
plt.legend()

# 显示网格
plt.grid(True)

# 显示图形
plt.show()
