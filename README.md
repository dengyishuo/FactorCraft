# FactorCraft

**FactorCraft**: A Standardized Full\-process Factor Engineering Toolkit for A\-share Quantitative Research

**FactorCraft**：一款面向A股量化投资的轻量、标准化、全流程因子工程R工具包

---

## ✨ Project Introduction

**FactorCraft** is a standardized factor development framework designed for A\-share quantitative research\. It solves common pain points in quantitative research, including messy raw data, inconsistent function logic, cumbersome multi\-period calculation, poor code reusability and irregular output formats\.

All functions in this package follow **unified parameter specifications, unified output formats and chainable calling styles**\. It supports one\-click multi\-period factor batch calculation and standardized preprocessing, out\-of\-the\-box, fully adapted to A\-share quantitative research and backtesting scenarios\.

## ✨ 项目简介

**FactorCraft** 是专为A股量化研究打造的标准化因子开发框架，解决量化研究中数据杂乱、函数逻辑不统一、多周期计算繁琐、代码复用性差、输出格式不规范等核心痛点。

本包所有函数遵循**统一参数规范、统一输出格式、链式调用风格**，支持一键批量多周期因子计算、标准化预处理，开箱即用，完全适配A股量化研究、策略回测、因子挖掘场景。

---

## 🎯 Core Design Philosophy

- **Unified Architecture**: All `add\_\*` series functions share identical parameters, logic and return formats, learn once and use universally\.

- **Multi\-period Batch Calculation**: Natively support single period or vector multi\-period batch calculation with automatic column naming, no manual loop required\.

- **Dual Output Mode**: Support appending factors to raw data or exporting independent factor matrix separately\.

- **Dual Format Compatibility**: Freely switch output between `tibble` and `data\.frame` to adapt all upstream and downstream code\.

- **Time Series Safety**: Force grouping by stock code and sorting by date to completely avoid cross\-stock and time sequence disorder errors\.

- **Native Algorithm**: Calculation based on native `TTR` algorithms, fully consistent with standard quantitative indicators in the industry\.

## 🎯 核心设计思路

- **统一架构**：所有 `add\_\*` 系列函数参数、逻辑、返回格式完全统一，一次学习，全系列通用。

- **多周期批量计算**：原生支持单周期/向量多周期批量运算，自动命名生成因子列，无需手动编写循环。

- **双输出模式**：支持追加因子至原数据、单独导出独立因子矩阵两种模式。

- **双格式兼容**：输出可自由切换 `tibble` / `data\.frame`，适配所有上下游代码场景。

- **时序安全**：强制按股票代码分组、日期排序，彻底杜绝跨股错乱、时序错位等量化致命bug。

- **原生算法复刻**：底层基于TTR官方原生算法计算，结果对标行业标准量化指标，精准可靠。

---

## 📦 Implemented Modules

### 1\. Data Acquisition Module

- `get\_data\(\)`: Batch download A\-share daily market data and return standard long\-format panel data\.

### 2\. Factor Generation Module

- `add\_return\(\)`: Multi\-period return factors \(continuous log return / discrete simple return\)\.

- `add\_mom\(\)`: Multi\-period momentum factors \(trend strength indicators\)\.

### 3\. Utility Compatibility Module

- `utils\-pipe\.R`: Uniform pipe operator, resolve naming conflicts between dplyr and xts, ensure global environment stability\.

## 📦 已实现功能模块

### 1\. 基础数据模块

- `get\_data\(\)`：A股日线行情批量下载，输出量化标准长格式面板数据。

### 2\. 因子生成模块

- `add\_return\(\)`：多周期收益率因子（支持对数收益、简单收益）。

- `add\_mom\(\)`：多周期动量因子，衡量标的价格趋势强弱。

### 3\. 工具兼容模块

- `utils\-pipe\.R`：统一管道符，解决dplyr与xts函数命名冲突，保证全局运行环境稳定。

---

## ⚙️ Unified Parameter Specification

All `add\_\*` factor functions share the same universal parameters:

- `data`: Standard long\-format market data from `get\_data`\.

- `close\_col`: Benchmark price column for calculation, default as `close`\.

- `new\_col`: Prefix of output factor column; auto generate `prefix\_period` if empty\.

- `n`: Lookback period, support single value or vector \(e\.g\.,`1`, `c\(1,5,10\)`\)\.

- `type`: Return type, `continuous`\(log return\) / `discrete`\(simple return\)\.

- `na\.pad`: Whether to pad leading NA values, default `TRUE`\.

- `append`: `TRUE` append factors to raw data; `FALSE` return only core factor fields\.

- `output`: Output format, support `tibble` / `data\.frame`\.

## ⚙️ 全包统一参数规范

所有 `add\_\*` 因子函数通用一套参数体系，完全统一、零学习成本：

- `data`：标准长格式行情数据，由 `get\_data`函数生成。

- `close\_col`：计算基准价格列，默认收盘价 `close`。

- `new\_col`：因子列名前缀，为空则自动生成「前缀\_周期」格式列名。

- `n`：计算周期，支持单数值、多周期向量批量计算。

- `type`：收益类型，可选 continuous 对数收益 / discrete 简单收益。

- `na\.pad`：是否前置填充空值NA，默认开启。

- `append`：TRUE 追加因子到原数据；FALSE 仅导出核心因子字段。

- `output`：输出格式，自由切换 tibble / data\.frame。

---

## 🚀 Installation \&amp; Quick Start

### 1\. Installation

Currently, FactorCraft only supports **GitHub online installation** \(not released on CRAN\)\.

```r
# Install devtools if not installed
if (!requireNamespace("devtools", quietly = TRUE))
  install.packages("devtools")

# Install latest FactorCraft from GitHub
devtools::install_github("dengyishuo/FactorCraft")

```

### 2\. Load Package \&amp; Get Data

```r
# Load library
library(FactorCraft)

# Obtain A-share market data
dat <- get_data(stock_list, start = "2020-01-01", end = "2025-01-01")

```

### 3\. Multi\-period Return Calculation

```r
# Default: 1/5/10-day log return, append to raw data
dat_with_ret <- add_return(dat)

# Custom periods + simple return
dat_with_ret2 <- add_return(dat, n = c(1,20), type = "discrete")

# Export pure factor data (date/code/name + factors)
ret_only <- add_return(dat, append = FALSE)

```

### 4\. Multi\-period Momentum Calculation

```r
# Default: 2/5/10-day momentum factors
dat_with_mom <- add_mom(dat)

# Custom long-period momentum
dat_with_mom2 <- add_mom(dat, n = c(5,20,60))

# Export pure momentum factors
mom_only <- add_mom(dat, append = FALSE)

```

## 🚀 安装教程 \&amp; 快速上手

### 1\. 包安装方式

当前包**仅支持 GitHub 在线安装**，暂未上架 CRAN 官方仓库。

```r
# 安装devtools工具（未安装则执行）
if (!requireNamespace("devtools", quietly = TRUE))
  install.packages("devtools")

# 从GitHub安装最新版 FactorCraft
devtools::install_github("dengyishuo/FactorCraft")

```

### 2\. 加载包 \&amp; 获取行情数据

```r
# 加载工具包
library(FactorCraft)

# 下载A股区间行情数据
dat <- get_data(stock_list, start = "2020-01-01", end = "2025-01-01")

```

### 3\. 多周期收益率因子计算

```r
# 默认计算1/5/10日对数收益率，追加至原数据
dat_with_ret <- add_return(dat)

# 自定义1/20日简单收益率
dat_with_ret2 <- add_return(dat, n = c(1,20), type = "discrete")

# 仅导出收益率因子（含日期、代码、名称、因子列）
ret_only <- add_return(dat, append = FALSE)

```

### 4\. 多周期动量因子计算

```r
# 默认2/5/10日动量因子
dat_with_mom <- add_mom(dat)

# 自定义5/20/60日长周期动量
dat_with_mom2 <- add_mom(dat, n = c(5,20,60))

# 单独导出动量因子矩阵
mom_only <- add_mom(dat, append = FALSE)

```

---

## 📌 Core Advantages

- **Zero Configuration**: Default parameters perfectly match mainstream A\-share quantitative research scenarios\.

- **Efficient Batch Calculation**: One line of code generates multiple factors of different periods\.

- **Absolute Data Safety**: Strict grouping and sorting avoid factor mismatch and cross\-stock errors\.

- **Standardized Output**: Independent factor output reserves `date/code/name` for easy splicing and backtesting\.

- **High Scalability**: Unified function template, support subsequent volatility, skewness, neutralization, orthogonalization and factor synthesis modules\.

## 📌 核心特性亮点

- **零配置开箱即用**：默认参数适配A股主流量化研究场景，无需复杂调参。

- **高效批量计算**：一行代码批量生成多周期因子，大幅提升研究效率。

- **数据安全可靠**：强制分组时序排序，彻底杜绝因子错位、串股等致命问题。

- **输出规范统一**：单独导出因子自带日期、代码、股票名称，方便因子库拼接与回测。

- **高可扩展性**：统一函数开发模板，后续波动率、偏度、中性化、正交化、多因子合成模块可无缝接入。

---

## 📁 Project Structure

```Plain Text
FactorCraft/
├── R/                    # Core function source code
├── dev/                  # Development auxiliary files (ignored in package compilation)
├── man/                  # Auto-generated documentation
├── DESCRIPTION           # Package configuration
├── NAMESPACE             # Function export configuration
└── README.md             # Project introduction

```

## 📁 项目目录结构

```Plain Text
FactorCraft/
├── R/                    # 核心函数源码文件夹
├── dev/                  # 开发辅助文档（R包编译自动忽略）
├── man/                  # 自动生成的帮助文档
├── DESCRIPTION           # 包基础配置信息
├── NAMESPACE             # 函数导出与依赖配置
└── README.md             # 项目介绍文档

```

---

## 🔮 Future Development Plan

Subsequent updates will continuously add: volatility factors, skewness factors, volume\-based factors, outlier processing, standardization, industry neutralization, orthogonalization and multi\-factor synthesis modules\.

## 🔮 后续开发计划

后续将持续迭代更新：波动率因子、偏度因子、成交量类因子、去极值处理、标准化、行业中性化、正交化、多因子合成等全套量化工具模块。

---

**FactorCraft — Make A\-share Factor Research More Standard, Efficient and Elegant**

**FactorCraft — 让A股量化因子研究更标准、更高效、更优雅**
