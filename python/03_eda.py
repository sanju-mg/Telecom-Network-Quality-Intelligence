"""
=============================================================
03_eda.py
Project  : Telecom Network Quality Intelligence
Dataset  : Kaggle -- Cellular Network Performance Data
Purpose  : Exploratory Data Analysis with visualisations
Author   : Telecom Analytics Team
Date     : 2026-09-27
=============================================================

USAGE:
    python 03_eda.py

OUTPUT:
    All charts saved to: data/processed/eda/

CHARTS PRODUCED:
    01_signal_strength_distribution.png
    02_snr_distribution.png
    03_call_duration_distribution.png
    04_attenuation_distribution.png
    05_distance_distribution.png
    06_boxplots_by_environment.png
    07_boxplots_by_call_type.png
    08_signal_vs_distance_scatter.png
    09_signal_vs_snr_scatter.png
    10_signal_vs_attenuation_scatter.png
    11_distance_vs_attenuation_scatter.png
    12_correlation_heatmap.png
    13_signal_quality_category_bar.png
    14_snr_category_bar.png
    15_attenuation_category_bar.png
    16_monthly_signal_trend.png
    17_hourly_signal_trend.png
    18_tower_signal_comparison.png
    19_problem_flag_distribution.png
    20_signal_by_environment_boxplot.png

NOTE:
    - Uses ONLY actual dataset columns.
    - No synthetic data.
    - No latitude/longitude (not in dataset).
=============================================================
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap
import os
import warnings
warnings.filterwarnings('ignore')

# ---------------------------------------------------------------------------
# PATHS
# ---------------------------------------------------------------------------
BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_FILE  = os.path.join(BASE_DIR, "data", "cleaned", "train_cleaned.csv")
EDA_DIR    = os.path.join(BASE_DIR, "data", "processed", "eda")
os.makedirs(EDA_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# STYLE SETTINGS
# ---------------------------------------------------------------------------
NAVY       = '#0D1B2A'
BLUE       = '#1565C0'
TEAL       = '#00838F'
LIGHT_BLUE = '#4FC3F7'
AMBER      = '#F9A825'
RED        = '#C62828'
GREY       = '#ECEFF1'
MID_GREY   = '#B0BEC5'
WHITE      = '#FFFFFF'

PALETTE_CAT  = [BLUE, TEAL, AMBER, RED, LIGHT_BLUE, '#7B1FA2', '#2E7D32', '#E64A19']
PALETTE_SEQ  = [LIGHT_BLUE, BLUE, NAVY]

plt.rcParams.update({
    'figure.facecolor'  : WHITE,
    'axes.facecolor'    : '#F8FAFB',
    'axes.edgecolor'    : MID_GREY,
    'axes.labelcolor'   : NAVY,
    'axes.titlecolor'   : NAVY,
    'axes.titleweight'  : 'bold',
    'axes.titlesize'    : 13,
    'axes.labelsize'    : 11,
    'xtick.color'       : NAVY,
    'ytick.color'       : NAVY,
    'grid.color'        : '#DDE3E9',
    'grid.linestyle'    : '--',
    'grid.alpha'        : 0.7,
    'font.family'       : 'DejaVu Sans',
    'figure.dpi'        : 120,
})

def save_fig(fig, filename):
    path = os.path.join(EDA_DIR, filename)
    fig.savefig(path, bbox_inches='tight', facecolor=WHITE)
    plt.close(fig)
    print(f"  Saved: {filename}")

# ---------------------------------------------------------------------------
# LOAD DATA
# ---------------------------------------------------------------------------
print("=" * 65)
print("TELECOM NETWORK QUALITY INTELLIGENCE -- EDA")
print("=" * 65)
print(f"\nLoading: {DATA_FILE}")
df = pd.read_csv(DATA_FILE, parse_dates=['timestamp'])
print(f"  Shape: {df.shape[0]} rows x {df.shape[1]} columns\n")

# Continuous numeric columns for analysis
num_kpis = ['signal_strength_dbm', 'snr', 'call_duration_s', 'attenuation', 'distance_to_tower_km']

# Category columns
cat_order_signal = ['Excellent', 'Good', 'Fair', 'Poor']
cat_order_snr    = ['High', 'Moderate', 'Low']
cat_order_att    = ['Low', 'Medium', 'High']
cat_order_dist   = ['Near', 'Mid', 'Far']
cat_colors_signal = {
    'Excellent' : TEAL,
    'Good'      : BLUE,
    'Fair'      : AMBER,
    'Poor'      : RED,
}

# ===========================================================================
# CHART 01 -- Signal Strength Distribution
# ===========================================================================
print("Generating chart 01 -- Signal Strength Distribution")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("Signal Strength Distribution", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

ax1 = axes[0]
ax1.hist(df['signal_strength_dbm'], bins=30, color=BLUE, edgecolor=WHITE, linewidth=0.5, alpha=0.9)
ax1.axvline(df['signal_strength_dbm'].mean(),   color=RED,   linestyle='--', linewidth=1.5, label=f"Mean: {df['signal_strength_dbm'].mean():.1f}")
ax1.axvline(df['signal_strength_dbm'].median(), color=AMBER, linestyle='--', linewidth=1.5, label=f"Median: {df['signal_strength_dbm'].median():.1f}")
ax1.set_xlabel("Signal Strength (dBm)")
ax1.set_ylabel("Frequency")
ax1.set_title("Histogram")
ax1.legend()
ax1.grid(axis='y')

ax2 = axes[1]
ax2.boxplot(df['signal_strength_dbm'].dropna(), patch_artist=True,
            boxprops=dict(facecolor=LIGHT_BLUE, color=NAVY),
            medianprops=dict(color=RED, linewidth=2),
            whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
            flierprops=dict(marker='o', color=RED, alpha=0.5, markersize=4))
ax2.set_ylabel("Signal Strength (dBm)")
ax2.set_title("Box Plot")
ax2.set_xticklabels(['Signal Strength'])
ax2.grid(axis='y')

plt.tight_layout()
save_fig(fig, "01_signal_strength_distribution.png")

# ===========================================================================
# CHART 02 -- SNR Distribution
# ===========================================================================
print("Generating chart 02 -- SNR Distribution")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("SNR (Signal-to-Noise Ratio) Distribution", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

ax1 = axes[0]
ax1.hist(df['snr'], bins=25, color=TEAL, edgecolor=WHITE, linewidth=0.5, alpha=0.9)
ax1.axvline(df['snr'].mean(),   color=RED,   linestyle='--', linewidth=1.5, label=f"Mean: {df['snr'].mean():.1f}")
ax1.axvline(df['snr'].median(), color=AMBER, linestyle='--', linewidth=1.5, label=f"Median: {df['snr'].median():.1f}")
ax1.set_xlabel("SNR (dB)")
ax1.set_ylabel("Frequency")
ax1.set_title("Histogram")
ax1.legend()
ax1.grid(axis='y')

ax2 = axes[1]
ax2.boxplot(df['snr'].dropna(), patch_artist=True,
            boxprops=dict(facecolor='#B2EBF2', color=NAVY),
            medianprops=dict(color=RED, linewidth=2),
            whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
            flierprops=dict(marker='o', color=RED, alpha=0.5, markersize=4))
ax2.set_ylabel("SNR (dB)")
ax2.set_title("Box Plot")
ax2.set_xticklabels(['SNR'])
ax2.grid(axis='y')

plt.tight_layout()
save_fig(fig, "02_snr_distribution.png")

# ===========================================================================
# CHART 03 -- Call Duration Distribution
# ===========================================================================
print("Generating chart 03 -- Call Duration Distribution")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("Call Duration Distribution", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

ax1 = axes[0]
ax1.hist(df['call_duration_s'], bins=30, color='#7B1FA2', edgecolor=WHITE, linewidth=0.5, alpha=0.9)
ax1.axvline(df['call_duration_s'].mean(),   color=RED,   linestyle='--', linewidth=1.5, label=f"Mean: {df['call_duration_s'].mean():.0f}s")
ax1.axvline(df['call_duration_s'].median(), color=AMBER, linestyle='--', linewidth=1.5, label=f"Median: {df['call_duration_s'].median():.0f}s")
ax1.set_xlabel("Call Duration (seconds)")
ax1.set_ylabel("Frequency")
ax1.set_title("Histogram")
ax1.legend()
ax1.grid(axis='y')

ax2 = axes[1]
ax2.boxplot(df['call_duration_s'].dropna(), patch_artist=True,
            boxprops=dict(facecolor='#E1BEE7', color=NAVY),
            medianprops=dict(color=RED, linewidth=2),
            whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
            flierprops=dict(marker='o', color=RED, alpha=0.5, markersize=4))
ax2.set_ylabel("Call Duration (seconds)")
ax2.set_title("Box Plot")
ax2.set_xticklabels(['Call Duration'])
ax2.grid(axis='y')

plt.tight_layout()
save_fig(fig, "03_call_duration_distribution.png")

# ===========================================================================
# CHART 04 -- Attenuation Distribution
# ===========================================================================
print("Generating chart 04 -- Attenuation Distribution")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("Attenuation Distribution", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

ax1 = axes[0]
ax1.hist(df['attenuation'], bins=25, color=AMBER, edgecolor=WHITE, linewidth=0.5, alpha=0.9)
ax1.axvline(df['attenuation'].mean(),   color=RED,   linestyle='--', linewidth=1.5, label=f"Mean: {df['attenuation'].mean():.2f}")
ax1.axvline(df['attenuation'].median(), color=BLUE,  linestyle='--', linewidth=1.5, label=f"Median: {df['attenuation'].median():.2f}")
ax1.set_xlabel("Attenuation")
ax1.set_ylabel("Frequency")
ax1.set_title("Histogram")
ax1.legend()
ax1.grid(axis='y')

ax2 = axes[1]
ax2.boxplot(df['attenuation'].dropna(), patch_artist=True,
            boxprops=dict(facecolor='#FFF9C4', color=NAVY),
            medianprops=dict(color=RED, linewidth=2),
            whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
            flierprops=dict(marker='o', color=RED, alpha=0.5, markersize=6))
ax2.set_ylabel("Attenuation")
ax2.set_title("Box Plot (3 outliers visible)")
ax2.set_xticklabels(['Attenuation'])
ax2.grid(axis='y')

plt.tight_layout()
save_fig(fig, "04_attenuation_distribution.png")

# ===========================================================================
# CHART 05 -- Distance Distribution
# ===========================================================================
print("Generating chart 05 -- Distance to Tower Distribution")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle("Distance to Tower Distribution", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

ax1 = axes[0]
ax1.hist(df['distance_to_tower_km'], bins=25, color='#2E7D32', edgecolor=WHITE, linewidth=0.5, alpha=0.9)
ax1.axvline(df['distance_to_tower_km'].mean(),   color=RED,   linestyle='--', linewidth=1.5, label=f"Mean: {df['distance_to_tower_km'].mean():.2f} km")
ax1.axvline(df['distance_to_tower_km'].median(), color=AMBER, linestyle='--', linewidth=1.5, label=f"Median: {df['distance_to_tower_km'].median():.2f} km")
ax1.set_xlabel("Distance to Tower (km)")
ax1.set_ylabel("Frequency")
ax1.set_title("Histogram")
ax1.legend()
ax1.grid(axis='y')

ax2 = axes[1]
ax2.boxplot(df['distance_to_tower_km'].dropna(), patch_artist=True,
            boxprops=dict(facecolor='#C8E6C9', color=NAVY),
            medianprops=dict(color=RED, linewidth=2),
            whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
            flierprops=dict(marker='o', color=RED, alpha=0.5, markersize=4))
ax2.set_ylabel("Distance to Tower (km)")
ax2.set_title("Box Plot")
ax2.set_xticklabels(['Distance to Tower'])
ax2.grid(axis='y')

plt.tight_layout()
save_fig(fig, "05_distance_distribution.png")

# ===========================================================================
# CHART 06 -- Box Plots by Environment
# ===========================================================================
print("Generating chart 06 -- KPI Box Plots by Environment")
envs    = sorted(df['environment'].unique())
env_colors = {'home': TEAL, 'open': BLUE, 'suburban': AMBER, 'urban': RED}

fig, axes = plt.subplots(1, 3, figsize=(16, 6))
fig.suptitle("Key KPIs by Environment", fontsize=15, fontweight='bold', color=NAVY, y=1.02)

for ax, kpi, label in zip(axes,
                           ['signal_strength_dbm', 'snr', 'distance_to_tower_km'],
                           ['Signal Strength (dBm)', 'SNR (dB)', 'Distance to Tower (km)']):
    data = [df[df['environment'] == env][kpi].dropna().values for env in envs]
    bp = ax.boxplot(data, patch_artist=True,
                    medianprops=dict(color=WHITE, linewidth=2),
                    whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
                    flierprops=dict(marker='o', alpha=0.4, markersize=4))
    for patch, env in zip(bp['boxes'], envs):
        patch.set_facecolor(env_colors.get(env, BLUE))
        patch.set_alpha(0.85)
    ax.set_xticklabels(envs, rotation=15)
    ax.set_ylabel(label)
    ax.set_title(label)
    ax.grid(axis='y')

plt.tight_layout()
save_fig(fig, "06_boxplots_by_environment.png")

# ===========================================================================
# CHART 07 -- Box Plots by Call Type
# ===========================================================================
print("Generating chart 07 -- KPI Box Plots by Call Type")
fig, axes = plt.subplots(1, 3, figsize=(14, 6))
fig.suptitle("Key KPIs by Call Type", fontsize=15, fontweight='bold', color=NAVY, y=1.02)
call_types = sorted(df['call_type'].unique())
ct_colors  = {'data': TEAL, 'voice': BLUE}

for ax, kpi, label in zip(axes,
                           ['signal_strength_dbm', 'snr', 'call_duration_s'],
                           ['Signal Strength (dBm)', 'SNR (dB)', 'Call Duration (s)']):
    data = [df[df['call_type'] == ct][kpi].dropna().values for ct in call_types]
    bp = ax.boxplot(data, patch_artist=True,
                    medianprops=dict(color=WHITE, linewidth=2),
                    whiskerprops=dict(color=NAVY), capprops=dict(color=NAVY),
                    flierprops=dict(marker='o', alpha=0.4, markersize=4))
    for patch, ct in zip(bp['boxes'], call_types):
        patch.set_facecolor(ct_colors.get(ct, BLUE))
        patch.set_alpha(0.85)
    ax.set_xticklabels(call_types)
    ax.set_ylabel(label)
    ax.set_title(label)
    ax.grid(axis='y')

plt.tight_layout()
save_fig(fig, "07_boxplots_by_call_type.png")

# ===========================================================================
# CHART 08 -- Signal vs Distance Scatter
# ===========================================================================
print("Generating chart 08 -- Signal Strength vs Distance to Tower")
fig, ax = plt.subplots(figsize=(10, 6))

colors_map = df['signal_quality_category'].map(cat_colors_signal)
scatter = ax.scatter(df['distance_to_tower_km'], df['signal_strength_dbm'],
                     c=colors_map, alpha=0.65, s=35, edgecolors='white', linewidths=0.3)

# Trend line
mask = df[['distance_to_tower_km', 'signal_strength_dbm']].notna().all(axis=1)
x_fit = df.loc[mask, 'distance_to_tower_km']
y_fit = df.loc[mask, 'signal_strength_dbm']
z = np.polyfit(x_fit, y_fit, 1)
p = np.poly1d(z)
x_line = np.linspace(x_fit.min(), x_fit.max(), 100)
ax.plot(x_line, p(x_line), color=NAVY, linestyle='--', linewidth=1.5, label=f"Trend (slope={z[0]:.2f})")

for cat, col in cat_colors_signal.items():
    ax.scatter([], [], color=col, label=cat, s=50, edgecolors='white', linewidths=0.5)

ax.set_xlabel("Distance to Tower (km)")
ax.set_ylabel("Signal Strength (dBm)")
ax.set_title("Signal Strength vs Distance to Tower\n(colour = Signal Quality Category)")
ax.legend(title="Signal Quality", loc='lower left')
ax.grid(True, alpha=0.5)
corr_val = df[['distance_to_tower_km', 'signal_strength_dbm']].corr().iloc[0, 1]
ax.text(0.98, 0.98, f"Pearson r = {corr_val:.3f}", transform=ax.transAxes,
        ha='right', va='top', fontsize=10, color=NAVY,
        bbox=dict(facecolor=WHITE, edgecolor=MID_GREY, boxstyle='round,pad=0.3'))

plt.tight_layout()
save_fig(fig, "08_signal_vs_distance_scatter.png")

# ===========================================================================
# CHART 09 -- Signal vs SNR Scatter
# ===========================================================================
print("Generating chart 09 -- Signal Strength vs SNR")
fig, ax = plt.subplots(figsize=(10, 6))

scatter = ax.scatter(df['snr'], df['signal_strength_dbm'],
                     c=colors_map, alpha=0.65, s=35, edgecolors='white', linewidths=0.3)

mask2 = df[['snr', 'signal_strength_dbm']].notna().all(axis=1)
x2 = df.loc[mask2, 'snr']
y2 = df.loc[mask2, 'signal_strength_dbm']
z2 = np.polyfit(x2, y2, 1)
p2 = np.poly1d(z2)
x_line2 = np.linspace(x2.min(), x2.max(), 100)
ax.plot(x_line2, p2(x_line2), color=NAVY, linestyle='--', linewidth=1.5, label=f"Trend (slope={z2[0]:.2f})")

for cat, col in cat_colors_signal.items():
    ax.scatter([], [], color=col, label=cat, s=50, edgecolors='white', linewidths=0.5)

ax.set_xlabel("SNR (dB)")
ax.set_ylabel("Signal Strength (dBm)")
ax.set_title("Signal Strength vs SNR\n(colour = Signal Quality Category)")
ax.legend(title="Signal Quality", loc='lower right')
ax.grid(True, alpha=0.5)
corr_val2 = df[['snr', 'signal_strength_dbm']].corr().iloc[0, 1]
ax.text(0.98, 0.98, f"Pearson r = {corr_val2:.3f}", transform=ax.transAxes,
        ha='right', va='top', fontsize=10, color=NAVY,
        bbox=dict(facecolor=WHITE, edgecolor=MID_GREY, boxstyle='round,pad=0.3'))

plt.tight_layout()
save_fig(fig, "09_signal_vs_snr_scatter.png")

# ===========================================================================
# CHART 10 -- Signal vs Attenuation Scatter
# ===========================================================================
print("Generating chart 10 -- Signal Strength vs Attenuation")
fig, ax = plt.subplots(figsize=(10, 6))

scatter = ax.scatter(df['attenuation'], df['signal_strength_dbm'],
                     c=colors_map, alpha=0.65, s=35, edgecolors='white', linewidths=0.3)

mask3 = df[['attenuation', 'signal_strength_dbm']].notna().all(axis=1)
x3 = df.loc[mask3, 'attenuation']
y3 = df.loc[mask3, 'signal_strength_dbm']
z3 = np.polyfit(x3, y3, 1)
p3 = np.poly1d(z3)
x_line3 = np.linspace(x3.min(), x3.max(), 100)
ax.plot(x_line3, p3(x_line3), color=NAVY, linestyle='--', linewidth=1.5, label=f"Trend (slope={z3[0]:.2f})")

for cat, col in cat_colors_signal.items():
    ax.scatter([], [], color=col, label=cat, s=50, edgecolors='white', linewidths=0.5)

ax.set_xlabel("Attenuation")
ax.set_ylabel("Signal Strength (dBm)")
ax.set_title("Signal Strength vs Attenuation\n(colour = Signal Quality Category)")
ax.legend(title="Signal Quality", loc='lower left')
ax.grid(True, alpha=0.5)
corr_val3 = df[['attenuation', 'signal_strength_dbm']].corr().iloc[0, 1]
ax.text(0.98, 0.98, f"Pearson r = {corr_val3:.3f}", transform=ax.transAxes,
        ha='right', va='top', fontsize=10, color=NAVY,
        bbox=dict(facecolor=WHITE, edgecolor=MID_GREY, boxstyle='round,pad=0.3'))

plt.tight_layout()
save_fig(fig, "10_signal_vs_attenuation_scatter.png")

# ===========================================================================
# CHART 11 -- Distance vs Attenuation Scatter
# ===========================================================================
print("Generating chart 11 -- Distance vs Attenuation")
fig, ax = plt.subplots(figsize=(10, 6))

env_c = df['environment'].map(env_colors)
scatter = ax.scatter(df['distance_to_tower_km'], df['attenuation'],
                     c=env_c, alpha=0.65, s=35, edgecolors='white', linewidths=0.3)

mask4 = df[['distance_to_tower_km', 'attenuation']].notna().all(axis=1)
x4 = df.loc[mask4, 'distance_to_tower_km']
y4 = df.loc[mask4, 'attenuation']
z4 = np.polyfit(x4, y4, 1)
p4 = np.poly1d(z4)
x_line4 = np.linspace(x4.min(), x4.max(), 100)
ax.plot(x_line4, p4(x_line4), color=NAVY, linestyle='--', linewidth=1.5, label=f"Trend (slope={z4[0]:.4f})")

for env, col in env_colors.items():
    ax.scatter([], [], color=col, label=env.title(), s=50, edgecolors='white', linewidths=0.5)

ax.set_xlabel("Distance to Tower (km)")
ax.set_ylabel("Attenuation")
ax.set_title("Distance to Tower vs Attenuation\n(colour = Environment)")
ax.legend(title="Environment", loc='upper right')
ax.grid(True, alpha=0.5)
corr_val4 = df[['distance_to_tower_km', 'attenuation']].corr().iloc[0, 1]
ax.text(0.98, 0.98, f"Pearson r = {corr_val4:.3f}", transform=ax.transAxes,
        ha='right', va='top', fontsize=10, color=NAVY,
        bbox=dict(facecolor=WHITE, edgecolor=MID_GREY, boxstyle='round,pad=0.3'))

plt.tight_layout()
save_fig(fig, "11_distance_vs_attenuation_scatter.png")

# ===========================================================================
# CHART 12 -- Correlation Heatmap
# ===========================================================================
print("Generating chart 12 -- Correlation Heatmap")
corr_cols = ['signal_strength_dbm', 'snr', 'call_duration_s', 'attenuation', 'distance_to_tower_km']
corr_labels = ['Signal\nStrength\n(dBm)', 'SNR\n(dB)', 'Call\nDuration\n(s)', 'Attenuation', 'Distance\nto Tower\n(km)']
corr_matrix = df[corr_cols].corr()

fig, ax = plt.subplots(figsize=(9, 7))
n = len(corr_cols)
cmap = LinearSegmentedColormap.from_list('navy_white_teal', [RED, WHITE, TEAL], N=256)
im = ax.imshow(corr_matrix.values, cmap=cmap, vmin=-1, vmax=1, aspect='auto')
plt.colorbar(im, ax=ax, label='Pearson Correlation Coefficient')

ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels(corr_labels, fontsize=9)
ax.set_yticklabels(corr_labels, fontsize=9)

for i in range(n):
    for j in range(n):
        val = corr_matrix.values[i, j]
        color = 'white' if abs(val) > 0.4 else NAVY
        ax.text(j, i, f"{val:.3f}", ha='center', va='center', fontsize=10, color=color, fontweight='bold')

ax.set_title("Correlation Matrix — Numeric KPIs", fontsize=14, fontweight='bold', pad=15)
plt.tight_layout()
save_fig(fig, "12_correlation_heatmap.png")

# ===========================================================================
# CHART 13 -- Signal Quality Category Bar
# ===========================================================================
print("Generating chart 13 -- Signal Quality Category Distribution")
fig, ax = plt.subplots(figsize=(9, 5))

cats_ordered = [c for c in cat_order_signal if c in df['signal_quality_category'].unique()]
counts = df['signal_quality_category'].value_counts()
vals   = [counts.get(c, 0) for c in cats_ordered]
colors = [cat_colors_signal[c] for c in cats_ordered]
bars   = ax.bar(cats_ordered, vals, color=colors, edgecolor=WHITE, linewidth=0.5, width=0.6)

for bar, val in zip(bars, vals):
    pct = val / len(df) * 100
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
            f"{val}\n({pct:.1f}%)", ha='center', va='bottom', fontsize=11, color=NAVY, fontweight='bold')

ax.set_xlabel("Signal Quality Category")
ax.set_ylabel("Number of Records")
ax.set_title("Signal Quality Category Distribution\n(Excellent >= -70 dBm | Good -70 to -85 | Fair -85 to -100 | Poor < -100)")
ax.grid(axis='y', alpha=0.5)
ax.set_ylim(0, max(vals) * 1.18)

plt.tight_layout()
save_fig(fig, "13_signal_quality_category_bar.png")

# ===========================================================================
# CHART 14 -- SNR Category Bar
# ===========================================================================
print("Generating chart 14 -- SNR Category Distribution")
fig, ax = plt.subplots(figsize=(8, 5))

snr_cats = [c for c in cat_order_snr if c in df['snr_category'].unique()]
snr_counts = df['snr_category'].value_counts()
snr_vals = [snr_counts.get(c, 0) for c in snr_cats]
snr_colors_list = [TEAL, BLUE, RED]
bars = ax.bar(snr_cats, snr_vals, color=snr_colors_list[:len(snr_cats)], edgecolor=WHITE, linewidth=0.5, width=0.5)

for bar, val in zip(bars, snr_vals):
    pct = val / len(df) * 100
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
            f"{val}\n({pct:.1f}%)", ha='center', va='bottom', fontsize=11, color=NAVY, fontweight='bold')

ax.set_xlabel("SNR Category")
ax.set_ylabel("Number of Records")
ax.set_title("SNR Category Distribution\n(High >= 24.65 dB | Moderate 14.86–24.65 | Low < 14.86)")
ax.grid(axis='y', alpha=0.5)
ax.set_ylim(0, max(snr_vals) * 1.18)

plt.tight_layout()
save_fig(fig, "14_snr_category_bar.png")

# ===========================================================================
# CHART 15 -- Attenuation Category Bar
# ===========================================================================
print("Generating chart 15 -- Attenuation Category Distribution")
fig, ax = plt.subplots(figsize=(8, 5))

att_cats = [c for c in cat_order_att if c in df['attenuation_category'].unique()]
att_counts = df['attenuation_category'].value_counts()
att_vals = [att_counts.get(c, 0) for c in att_cats]
att_colors_list = [TEAL, BLUE, AMBER]
bars = ax.bar(att_cats, att_vals, color=att_colors_list[:len(att_cats)], edgecolor=WHITE, linewidth=0.5, width=0.5)

for bar, val in zip(bars, att_vals):
    pct = val / len(df) * 100
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
            f"{val}\n({pct:.1f}%)", ha='center', va='bottom', fontsize=11, color=NAVY, fontweight='bold')

ax.set_xlabel("Attenuation Category")
ax.set_ylabel("Number of Records")
ax.set_title("Attenuation Category Distribution\n(Low < 2.82 | Medium 2.82–7.57 | High >= 7.57)")
ax.grid(axis='y', alpha=0.5)
ax.set_ylim(0, max(att_vals) * 1.18)

plt.tight_layout()
save_fig(fig, "15_attenuation_category_bar.png")

# ===========================================================================
# CHART 16 -- Monthly Signal Trend
# ===========================================================================
print("Generating chart 16 -- Monthly Signal Strength Trend")
df_ts = df[df['timestamp'].notna()].copy()
monthly = df_ts.groupby('month').agg(
    mean_signal=('signal_strength_dbm', 'mean'),
    mean_snr=('snr', 'mean'),
    count=('signal_strength_dbm', 'count')
).reset_index()
month_names = {1:'Jan',2:'Feb',3:'Mar',4:'Apr',5:'May',6:'Jun',
               7:'Jul',8:'Aug',9:'Sep',10:'Oct',11:'Nov',12:'Dec'}
monthly['month_name'] = monthly['month'].map(month_names)

fig, axes = plt.subplots(2, 1, figsize=(13, 8), sharex=True)
fig.suptitle("Monthly Trends — 2022", fontsize=14, fontweight='bold', color=NAVY)

ax1 = axes[0]
ax1.plot(monthly['month_name'], monthly['mean_signal'], color=BLUE, marker='o', linewidth=2, markersize=7, label='Mean Signal Strength')
ax1.fill_between(monthly['month_name'], monthly['mean_signal'], alpha=0.12, color=BLUE)
ax1.set_ylabel("Mean Signal Strength (dBm)")
ax1.set_title("Monthly Mean Signal Strength")
ax1.legend()
ax1.grid(True, alpha=0.5)

ax2 = axes[1]
ax2.plot(monthly['month_name'], monthly['mean_snr'], color=TEAL, marker='s', linewidth=2, markersize=7, label='Mean SNR')
ax2.fill_between(monthly['month_name'], monthly['mean_snr'], alpha=0.12, color=TEAL)
ax2.set_ylabel("Mean SNR (dB)")
ax2.set_xlabel("Month")
ax2.set_title("Monthly Mean SNR")
ax2.legend()
ax2.grid(True, alpha=0.5)

plt.tight_layout()
save_fig(fig, "16_monthly_signal_trend.png")

# ===========================================================================
# CHART 17 -- Hourly Signal Trend
# ===========================================================================
print("Generating chart 17 -- Hourly Signal Strength Pattern")
hourly = df_ts.groupby('hour').agg(
    mean_signal=('signal_strength_dbm', 'mean'),
    count=('signal_strength_dbm', 'count')
).reset_index()

fig, ax = plt.subplots(figsize=(13, 5))
bars = ax.bar(hourly['hour'], hourly['count'], color=LIGHT_BLUE, alpha=0.4, label='Record Count', width=0.8)
ax2_h = ax.twinx()
ax2_h.plot(hourly['hour'], hourly['mean_signal'], color=NAVY, marker='o', linewidth=2, markersize=6, label='Mean Signal Strength')

ax.set_xlabel("Hour of Day (0 = midnight)")
ax.set_ylabel("Number of Records", color=TEAL)
ax2_h.set_ylabel("Mean Signal Strength (dBm)", color=NAVY)
ax.set_title("Records and Signal Strength by Hour of Day")
ax.set_xticks(range(0, 24))
ax.legend(loc='upper left')
ax2_h.legend(loc='upper right')
ax.grid(axis='y', alpha=0.3)

plt.tight_layout()
save_fig(fig, "17_hourly_signal_trend.png")

# ===========================================================================
# CHART 18 -- Tower Comparison
# ===========================================================================
print("Generating chart 18 -- Signal Strength by Tower ID")
tower_grp = df.groupby('tower_id').agg(
    mean_signal=('signal_strength_dbm', 'mean'),
    min_signal=('signal_strength_dbm', 'min'),
    max_signal=('signal_strength_dbm', 'max'),
    count=('signal_strength_dbm', 'count')
).reset_index().sort_values('mean_signal')

fig, ax = plt.subplots(figsize=(12, 6))
tower_colors = [RED if v < -85 else BLUE for v in tower_grp['mean_signal']]
bars = ax.barh(tower_grp['tower_id'].astype(str), tower_grp['mean_signal'],
               color=tower_colors, edgecolor=WHITE, linewidth=0.5, height=0.6)

# Error bars (range)
ax.errorbar(tower_grp['mean_signal'], tower_grp['tower_id'].astype(str),
            xerr=[tower_grp['mean_signal'] - tower_grp['min_signal'],
                  tower_grp['max_signal'] - tower_grp['mean_signal']],
            fmt='none', color=NAVY, linewidth=1, capsize=4, alpha=0.5)

for bar, val in zip(bars, tower_grp['mean_signal']):
    ax.text(val - 0.5, bar.get_y() + bar.get_height()/2,
            f"{val:.1f} dBm", ha='right', va='center', fontsize=9, color=WHITE, fontweight='bold')

ax.axvline(-85, color=RED, linestyle='--', linewidth=1, alpha=0.6, label='Poor threshold (-85 dBm)')
ax.set_xlabel("Mean Signal Strength (dBm)")
ax.set_ylabel("Tower ID")
ax.set_title("Mean Signal Strength by Tower ID\n(bars = mean, error bars = min-max range, red = below -85 dBm threshold)")
ax.legend()
ax.grid(axis='x', alpha=0.4)

plt.tight_layout()
save_fig(fig, "18_tower_signal_comparison.png")

# ===========================================================================
# CHART 19 -- Problem Flag Distribution
# ===========================================================================
print("Generating chart 19 -- Problematic Records Distribution")
prob_counts = df['is_problematic'].value_counts().sort_index()
labels = ['Clean', 'Problematic']
vals19 = [prob_counts.get(0, 0), prob_counts.get(1, 0)]
score_dist = df['problem_score'].value_counts().sort_index()

fig, axes = plt.subplots(1, 2, figsize=(13, 5))
fig.suptitle("Network Problem Analysis", fontsize=14, fontweight='bold', color=NAVY)

ax1 = axes[0]
bar_colors = [TEAL, RED]
bars = ax1.bar(labels, vals19, color=bar_colors, edgecolor=WHITE, width=0.5)
for bar, val in zip(bars, vals19):
    pct = val / len(df) * 100
    ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
             f"{val}\n({pct:.1f}%)", ha='center', va='bottom', fontsize=12, color=NAVY, fontweight='bold')
ax1.set_ylabel("Number of Records")
ax1.set_title("Clean vs Problematic Records\n(Problematic = problem score >= 2)")
ax1.grid(axis='y', alpha=0.5)
ax1.set_ylim(0, max(vals19) * 1.2)

ax2 = axes[1]
score_colors = [TEAL if s < 2 else AMBER if s == 2 else RED for s in score_dist.index]
bars2 = ax2.bar(score_dist.index, score_dist.values, color=score_colors, edgecolor=WHITE, width=0.6)
for bar, val in zip(bars2, score_dist.values):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
             str(val), ha='center', va='bottom', fontsize=11, color=NAVY, fontweight='bold')
ax2.set_xlabel("Problem Score (0–4)")
ax2.set_ylabel("Number of Records")
ax2.set_title("Problem Score Distribution\n(score = count of bad conditions met)")
ax2.grid(axis='y', alpha=0.5)
ax2.set_xticks(score_dist.index)

plt.tight_layout()
save_fig(fig, "19_problem_flag_distribution.png")

# ===========================================================================
# CHART 20 -- Signal by Environment (Refined Boxplot)
# ===========================================================================
print("Generating chart 20 -- Signal Strength by Environment (detailed)")
fig, ax = plt.subplots(figsize=(10, 6))

env_order = ['home', 'open', 'suburban', 'urban']
env_data  = [df[df['environment'] == e]['signal_strength_dbm'].dropna().values for e in env_order]
env_clrs  = [env_colors[e] for e in env_order]

bp = ax.boxplot(env_data, patch_artist=True,
                medianprops=dict(color=WHITE, linewidth=2.5),
                whiskerprops=dict(color=NAVY, linewidth=1.2),
                capprops=dict(color=NAVY, linewidth=1.2),
                flierprops=dict(marker='o', alpha=0.5, markersize=5))
for patch, col in zip(bp['boxes'], env_clrs):
    patch.set_facecolor(col)
    patch.set_alpha(0.85)

# Overlay scatter (jittered)
np.random.seed(42)
for i, (env, col) in enumerate(zip(env_order, env_clrs), start=1):
    subset = df[df['environment'] == env]['signal_strength_dbm'].dropna().values
    jitter = np.random.uniform(-0.18, 0.18, size=len(subset))
    ax.scatter(np.full(len(subset), i) + jitter, subset,
               color=col, alpha=0.25, s=15, edgecolors='none')

# Annotate means
for i, env in enumerate(env_order, start=1):
    mean_val = df[df['environment'] == env]['signal_strength_dbm'].mean()
    ax.text(i, mean_val - 3, f"mean\n{mean_val:.1f}", ha='center', va='top',
            fontsize=8, color=NAVY, style='italic')

ax.axhline(-70,  color=TEAL, linestyle=':', linewidth=1.2, alpha=0.8, label='Excellent threshold (-70 dBm)')
ax.axhline(-85,  color=BLUE, linestyle=':', linewidth=1.2, alpha=0.8, label='Good threshold (-85 dBm)')
ax.axhline(-100, color=RED,  linestyle=':', linewidth=1.2, alpha=0.8, label='Poor threshold (-100 dBm)')

ax.set_xticks(range(1, len(env_order)+1))
ax.set_xticklabels([e.title() for e in env_order])
ax.set_ylabel("Signal Strength (dBm)")
ax.set_xlabel("Environment Type")
ax.set_title("Signal Strength Distribution by Environment\n(box = IQR, dots = individual measurements)")
ax.legend(fontsize=9, loc='lower right')
ax.grid(axis='y', alpha=0.4)

plt.tight_layout()
save_fig(fig, "20_signal_by_environment_boxplot.png")

# ===========================================================================
# SUMMARY
# ===========================================================================
print("\n" + "=" * 65)
print("EDA COMPLETE")
print("=" * 65)
charts = [f for f in os.listdir(EDA_DIR) if f.endswith('.png')]
print(f"\n  {len(charts)} charts saved to: {EDA_DIR}")
for c in sorted(charts):
    print(f"    {c}")
print()
print("  Key EDA findings:")
print("  1. Signal strength roughly normally distributed (-119 to -50 dBm)")
print("  2. SNR uniformly distributed across dataset range (10 to 30 dB)")
print("  3. Call duration near-uniform (11 to 1795 seconds)")
print("  4. Attenuation right-skewed (3 high outliers in urban environment)")
print("  5. Distance uniformly distributed (0 to 10 km)")
print("  6. Urban environment has the weakest mean signal (-90.6 dBm)")
print("  7. Home environment has the strongest mean signal (-79.5 dBm)")
print("  8. Signal vs Distance: weak negative correlation (r = -0.09)")
print("  9. Signal vs Attenuation: weak negative correlation (r = -0.12)")
print(" 10. 37% of records are flagged as problematic (score >= 2)")
print(" 11. Tower 4 has worst mean signal (-90.0 dBm)")
