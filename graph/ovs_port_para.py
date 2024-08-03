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
ports = [0, 10, 50, 100, 200, 500, 1000, 2000, 5000]
iperf_same_num = [869.8, 870.8, 871.6, 867.4, 869.2, 870.2, 871.6, 860, 867.8]
iperf_diff_num = [596.4, 595.4, 597.8, 598, 598.6, 596.4, 599, 598.2, 590]
iperf_regular = [1366, 1378, 1364, 1360, 1360, 1368, 1356, 1292, 1180]

# 绘制图形
plt.figure(figsize=(10, 6))
plt.plot(ports, iperf_same_num,  label='同一NUMA测试')
plt.plot(ports, iperf_diff_num, label='不同NUMA测试')
plt.plot(ports, iperf_regular, label='常规iperf测试')

# 设置标题和标签
plt.title('多线程下带宽大小与ovs添加port数目的关系图')
plt.xlabel('ovs添加port数/个')
plt.ylabel('1分钟iperf3打流TCP带宽大小/Gbps')
# 设置纵坐标范围
plt.ylim(0, 1500)
# 设置横坐标范围
plt.xlim(0, max(ports))
# 设置x轴刻度间隔为500
plt.xticks(np.arange(0, max(ports) + 500, 500))
plt.legend()
plt.grid(True)

# 显示图形
plt.show()
