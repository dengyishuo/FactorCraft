# ==============================================
# FactorCraft 完整测试：add_vol_std 波动率因子
# 自带数据获取 + 全场景测试
# ==============================================

# 加载包
library(FactorCraft)
library(dplyr)

# ------------------------------
# 1. 获取原始数据（必须步骤）
# ------------------------------
# 你的股票列表 + 时间范围
stock_list <- c("000001.SZ", "000002.SZ", "600000.SH")
dat <- get_data(stock_list, start = "2024-01-01", end = "2025-01-01")

# ------------------------------
# 2. 默认参数：周期 5/10/20 波动率
# ------------------------------
dat_with_vol <- add_vol_std(dat)

# 查看结果
colnames(dat_with_vol)
head(dat_with_vol)


# ------------------------------
# 3. 自定义周期波动率
# ------------------------------
dat_with_custom_vol <- add_vol_std(dat, n = c(10, ))


# ------------------------------
# 4. 简单收益率（discrete）波动率
# ------------------------------
dat_with_vol_discrete <- add_vol_std(dat, type = "discrete")


# ------------------------------
# 5. 只导出波动率因子（带 date+code+name）
# ------------------------------
vol_only <- add_vol_std(dat, append = FALSE)
head(vol_only)


# ------------------------------
# 6. 输出 data.frame 格式
# ------------------------------
vol_df <- add_vol_std(dat, append = FALSE, output = "data.frame")
str(vol_df)



# 1. 默认 5/10/20 日均线
dat_with_sma <- add_sma(dat)

# 2. 自定义长周期均线
dat_with_sma_long <- add_sma(dat, n = c(20, 60, 120))

# 3. 仅导出均线因子（带名称）
sma_only <- add_sma(dat, append = FALSE)
head(sma_only)

# 4. 输出 data.frame
sma_df <- add_sma(dat, append = FALSE, output = "data.frame")


# ------------------------------
# 1. 默认：波动率调整动量
# ------------------------------
dat_ram_vol <- add_risk_adj_mom(dat, n = c(10))

# ------------------------------
# 2. VaR 调整 (95% 置信度)
# ------------------------------
dat_ram_var <- add_risk_adj_mom(dat, risk_type = "VaR", p = 0.95)

# ------------------------------
# 3. CVaR 调整
# ------------------------------
dat_ram_cvar <- add_risk_adj_mom(dat, risk_type = "CVaR")

# ------------------------------
# 4. 仅导出因子
# ------------------------------
ram_only <- add_risk_adj_mom(dat, append = FALSE)
head(ram_only)
