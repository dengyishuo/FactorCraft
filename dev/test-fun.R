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

# ================================
# FactorCraft 正确测试代码（无报错）
# ================================
library(FactorCraft)
library(dplyr)

# 正确股票列表（code + name）
stock_df <- data.frame(
  code = c("000001.SZ", "000002.SZ", "600000.SH"),
  name = c("PingAn Bank", "Vanke A", "SPD Bank")
)

# --------------------
# 下载数据（正确参数）
# --------------------
dat <- get_data(
  stock_df = stock_list, # 你包里面是 data，不是 stock_list
  start = "2024-01-01",
  end = "2024-06-01"
)

# 计算收益率
dat <- add_return(dat, n = c(1, 5, 10))

# 测试去极值
dat <- add_winsorize(dat, cols = c("ret_1", "ret_5", "ret_10"))

# 测试标准化
dat <- add_standardize(dat, cols = c("win_ret_1", "win_ret_5", "win_ret_10"))

# 查看最终结果
head(dat[, c("date", "code", "name", "ret_10", "win_ret_10", "std_win_ret_10")])


# ==========================================
# FactorCraft 行业中性化 完整测试
# ==========================================
library(FactorCraft)
library(dplyr)

# 1. 股票列表（必须 code + name）
stock_list <- data.frame(
  code   = c("000001.SZ", "000002.SZ", "600000.SH", "600036.SH"),
  name   = c("PingAn Bank", "Vanke A", "SPD Bank", "China Merchants Bank")
)

# 2. 下载数据
dat <- get_data(
  stock_df = stock_list,
  start    = "2024-01-01",
  end      = "2024-06-01"
)

# 3. 手工加行业（测试用）
dat <- dat %>%
  dplyr::mutate(
    industry = dplyr::case_when(
      code %in% c("000001.SZ", "600000.SH", "600036.SH") ~ "Bank",
      code == "000002.SZ" ~ "RealEstate",
      TRUE ~ "Other"
    )
  )

# 4. 计算因子
dat <- add_return(dat, n = 10)

# 5. 预处理
dat <- add_winsorize(dat, cols = "ret_10")
dat <- add_standardize(dat, cols = "win_ret_10")

# --------------------------
# 6. ✅ 行业中性化（核心！）
# --------------------------
dat <- add_industry_neutralize(
  data = dat,
  factor_col = "std_win_ret_10",
  industry_col = "industry"
)

# 查看最终结果
head(dat[, c(
  "date", "code", "name", "industry",
  "std_win_ret_10",
  "ind_neu_std_win_ret_10"
)])



# ======================================================
# FactorCraft 市值中性化 完整测试
# ======================================================
library(FactorCraft)
library(dplyr)

# 1. 股票列表
stock_list <- data.frame(
  code = c("000001.SZ", "000002.SZ", "600000.SH", "600036.SH"),
  name = c("PingAn Bank", "Vanke A", "SPD Bank", "China Merchants Bank")
)

# 2. 下载数据
dat <- get_data(
  stock_df = stock_list,
  start    = "2024-01-01",
  end      = "2024-06-01"
)

# 3. 添加测试用行业 & 市值
dat <- dat %>%
  mutate(
    industry = case_when(
      code %in% c("000001.SZ", "600000.SH", "600036.SH") ~ "Bank",
      code == "000002.SZ" ~ "RealEstate"
    ),
    size = runif(n(), min = 1e10, max = 1e12) # 测试市值
  )

# 4. 计算因子
dat <- add_return(dat, n = 10)

# 5. 预处理
dat <- add_winsorize(dat, cols = "ret_10")
dat <- add_standardize(dat, cols = "win_ret_10")

# 6. 行业中性化
dat <- add_industry_neutralize(
  data = dat,
  factor_col = "std_win_ret_10",
  industry_col = "industry"
)

# ======================================================
# FactorCraft 市值中性化 【完整 · 干净 · 可直接运行】测试
# ======================================================
library(FactorCraft)
library(dplyr)

# 1. 股票列表（必须 code + name）
stock_list <- data.frame(
  code = c("000001.SZ", "000002.SZ", "600000.SH", "600036.SH"),
  name = c("PingAn Bank", "Vanke A", "SPD Bank", "China Merchants Bank")
)

# 2. 下载真实 A 股数据（正确参数：stock_df）
dat <- get_data(
  stock_df = stock_list,
  start    = "2024-01-01",
  end      = "2024-06-01"
)

# 3. ✅ 自动模拟市值列 size（测试专用，真实回测替换为真实市值）
set.seed(123)
dat <- dat %>%
  group_by(code) %>%
  mutate(
    size = runif(n(), min = 5e9, max = 2e12) # 50亿 ~ 2万亿
  ) %>%
  ungroup()

# 4. 计算收益率
dat <- add_return(dat, n = 10)

# 5. 去极值 + 标准化
dat <- add_winsorize(dat, cols = "ret_10")
dat <- add_standardize(dat, cols = "win_ret_10")

# --------------------------
# 6. ✅ 市值中性化（核心函数）
# --------------------------
dat <- add_size_neutralize(
  data       = dat,
  factor_col = "std_win_ret_10",
  size_col   = "size"
)

# --------------------------
# 查看最终结果
# --------------------------
result <- dat %>%
  select(
    date, code, name, close, size,
    ret_10,
    win_ret_10,
    std_win_ret_10,
    size_neu_std_win_ret_10
  )

head(result, 10)



# ======================================================
# FactorCraft 终极一键预处理测试
# ======================================================
library(FactorCraft)
library(dplyr)

# 1. 股票列表
stock_list <- data.frame(
  code = c("000001.SZ", "000002.SZ", "600000.SH", "600036.SH"),
  name = c("PingAn Bank", "Vanke A", "SPD Bank", "China Merchants Bank")
)

# 2. 下载数据
dat <- get_data(
  stock_df = stock_list,
  start    = "2024-01-01",
  end      = "2024-06-01"
)

# 3. 模拟行业 + 市值
set.seed(123)
dat <- dat %>%
  group_by(code) %>%
  mutate(
    industry = case_when(
      code %in% c("000001.SZ", "600000.SH", "600036.SH") ~ "Bank",
      code == "000002.SZ" ~ "RealEstate"
    ),
    size = runif(n(), 5e9, 2e12)
  ) %>%
  ungroup()

# 4. 计算因子
dat <- add_return(dat, n = 10)

# ======================================================
# 🚀 超级函数：一行 = 4 步预处理
# ======================================================
dat <- add_factor_preprocess(
  data = dat,
  factor_col = "ret_10", # 要处理的因子
  industry_col = "industry", # 行业列
  size_col = "size" # 市值列
)

# 查看最终结果
result <- dat %>%
  select(date, code, name, ret_10, full_neu_ret_10)

head(result, 10)
