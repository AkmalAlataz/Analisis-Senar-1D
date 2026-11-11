
# ==========================================
# 1. MENJALANKAN UJI KONVERGENSI ENERGI
# ==========================================

energy_summaries, energy_curves = energy_grid_convergence(
    L=L,
    c=c,
    mu=mu,
    T=T,
    Nx_values=[50,100,200],
    r=0.8,
    t_end=0.2
)

# ==========================================
# 2. EKSPOR CSV
# ==========================================

mkpath("results/csv")
mkpath("results/figures")

open("results/csv/energy_convergence.csv","w") do io

    println(
        io,
        "Nx,dx_m,dt_s,max_deviation,rms_deviation,final_energy_ratio"
    )

    for s in energy_summaries

        @printf(
            io,
            "%d,%.9e,%.9e,%.9e,%.9e,%.9e\n",
            s.Nx,s.dx,s.dt,
            s.max_dev,s.rms_dev,s.final_ratio
        )

    end

end

# ==========================================
# 3. GRAFIK ENERGI UNTUK SETIAP GRID
# ==========================================

p_energy_grid = plot(
    xlabel="Waktu (s)",
    ylabel="E(t)/E(0)",
    title="Konservasi Energi untuk Berbagai Grid",
    legend=:topright
)

for curve in energy_curves

    plot!(
        p_energy_grid,
        curve.time,
        curve.energy,
        label="Nx = $(curve.Nx)",
        linewidth=1.5
    )

end

hline!(
    p_energy_grid,
    [1.0],
    linestyle=:dash,
    label="Energi kontinu konstan"
)

savefig(
    p_energy_grid,
    "results/figures/energy_grid_comparison.png"
)

display(p_energy_grid)

# ==========================================
# 4. GRAFIK PENYIMPANGAN ENERGI
# ==========================================

dx_values = [s.dx for s in energy_summaries]

deviations = [s.max_dev for s in energy_summaries]

p_deviation = plot(
    dx_values,
    deviations,
    xscale=:log10,
    yscale=:log10,
    marker=:circle,
    linewidth=2,
    xlabel="Ukuran grid dx (m)",
    ylabel="Maksimum penyimpangan energi",
    title="Konvergensi Estimasi Energi",
    label="Max deviation"
)

savefig(
    p_deviation,
    "results/figures/energy_convergence.png"
)

display(p_deviation)

println("\nUJI KONVERGENSI ENERGI SELESAI")