import matplotlib.pyplot as plt
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
# 网桥级联数量
bridging_counts = [1, 2, 4, 10, 20, 50]

# 64多线程iperf打流测试得到的带宽（单位：Gbps）
bandwidths = [1760, 1780, 1820, 1830, 1760, 1790]

# 创建图表
plt.figure(figsize=(10, 6))
plt.plot(bridging_counts, bandwidths, marker='o', linestyle='-', color='orange')

# 添加标题和标签
plt.title('带宽 vs 网桥级联数量')
plt.xlabel('网桥级联数量 (个)')
plt.ylabel('带宽 (Gbps)')
# 设置纵坐标范围
plt.ylim(0, 2000)
# 设置横坐标范围
plt.xlim(1, max(bridging_counts))
# 添加网格
plt.grid(True)

# 显示图表
plt.show()
