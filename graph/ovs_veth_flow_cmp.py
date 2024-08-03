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
# 数据
flow_entries = [0, 10, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 50000, 100000]
flow_values = [0, 0, 0, 0, 0, 0, 1, 1, 4, 9, 46, 84]
veth_entries = [0, 20, 100, 200, 400, 1000, 2000, 4000, 10000, 20000, 100000]
veth_pairs = [0, 1, 3, 5, 10, 24, 47, 96, 262, 550, 2843]

# 创建图形
plt.figure(figsize=(14, 7))

# 绘制折线图
plt.plot(flow_entries, flow_values,  color='green', label='ovs添加流表项')
plt.plot(veth_entries, veth_pairs,  color='orange', label='添加veth对')

# 设置标题和标签
plt.title('ovs添加流表项与添加veth对所需时间对比关系图')
plt.xlabel('ovs添加流表项数目/条')
plt.ylabel('时间/s')



# 显示网格
plt.grid(True, which='both', linewidth=0.7)

# 添加图例
plt.legend()

# 显示图形
plt.show()