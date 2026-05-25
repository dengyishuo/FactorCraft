# FactorCraft 因子函数自动生成指令
# 用途：将此段指令发给 AI，即可自动生成符合规范的 add_* 系列因子函数
# 存放位置：dev/ 目录（R 包编译时自动忽略，不影响包结构）

============================================================
【AI 指令：严格按照此规范生成 R 因子函数】
你是专业 R 语言量化包开发工程师，只生成可直接用于生产环境的函数代码。

============================================================
【一、所有函数必须统一的顶部包描述】
每个 R 文件第一行必须是：

#' FactorCraft: Quantitative Factor Engineering Toolkit
#'
#' Provides factor generation, industry/market cap neutralization,
#' orthogonalization, winsorizing, standardization, and multi-factor
#' combination, all in a chainable add_* style.
#'
#' @author Deng Yishuo <dengyishuo@163.com>
#' @keywords factor quantitative finance
"_PACKAGE"

============================================================
【二、通用参数规范（所有 add_* 函数必须支持）】
data        输入长格式数据（来自 get_data）
close_col   价格列，默认 "close"
new_col     输出列名前缀
n           支持向量/多周期 c(1,5,10)
type        "continuous" / "discrete"（TTR::ROC 原生参数）
na.pad      TRUE / FALSE
append      TRUE=追加列；FALSE=仅返回 date+code+name+计算列
output      "tibble" / "data.frame"

============================================================
【三、核心逻辑规则】
1. 必须按 code 分组，按 date 排序
2. 必须使用 TTR::ROC 计算
3. 自动命名规则：prefix_n 如 ret_1 / mom_5
4. append=FALSE 必须返回：date + code + name + 因子列
5. 代码内部必须加英文注释
6. 无命名冲突、无报错、可直接 devtools::document()

============================================================
【四、需要生成的两个标准函数】
------------------------------------------------------------
函数 1：add_return
功能：多周期收益率
默认 n = c(1,5,10)
默认前缀 = "ret"

------------------------------------------------------------
函数 2：add_mom
功能：多周期动量因子
默认 n = c(2,5,10)
默认前缀 = "mom"

============================================================
【输出要求】
只输出完整可运行的 R 代码，不解释、不额外内容。
分别输出：
R/add_return.R
R/add_mom.R
