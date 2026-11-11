using Plots, Printf

# Parameter eksperimen
r_values = [0.80, 1.00, 1.05]

# Menjalankan ketiga simulasi
cfl_results = []

for r in r_values

    println("\nMenjalankan CFL = ", r)

    res = simulate_wave(
        L=L,
        c=c,
        h=0.001,
        Nx=100,
        r=r,
        t_end=2*L/c,
        faktor_batas=1e6
    )

    push!(cfl_results, res)

    @printf("dx              = %.6e m\n", res.dx)
    @printf("dt              = %.6e s\n", res.dt)
    @printf("CFL aktual      = %.6f\n", res.r_actual)
    @printf("Jumlah langkah  = %d\n", res.nsteps_completed)
    @printf("Amplitudo maks  = %.6e m\n", res.max_amplitude)
    println("Status          = ", res.reason)

    if res.stopped
        @printf("Waktu berhenti  = %.6e s\n", res.stop_time)
    end

end

# Folder penyimpanan
csv_dir = "results/csv"
fig_dir = "results/figures"

mkpath(csv_dir)
mkpath(fig_dir)

# ==========================================
# 1. TABEL RINGKASAN CFL
# ==========================================

open(joinpath(csv_dir, "cfl_summary.csv"), "w") do io

    println(io,
        "r,dx_m,dt_s,Nx,Nt_planned,nsteps,stopped,reason,stop_time_s,max_amplitude_m"
    )

    for res in cfl_results

        @printf(io,
            "%.4f,%.9e,%.9e,%d,%d,%d,%s,%s,%.9e,%.9e\n",
            res.r, res.dx, res.dt,
            res.Nx, res.Nt_planned,
            res.nsteps_completed,
            string(res.stopped),
            res.reason,
            res.stop_time,
            res.max_amplitude
        )

    end

end

# ==========================================
# 2. DATA AMPLITUDO MAKSIMUM
# ==========================================

open(joinpath(csv_dir, "cfl_amplitude.csv"), "w") do io

    println(io, "r,time_s,max_amplitude_m")

    for res in cfl_results

        for n in eachindex(res.t)

            amplitude = maximum(abs, view(res.y, :, n))

            @printf(io, "%.2f,%.12e,%.12e\n",
                res.r, res.t[n], amplitude)

        end

    end

end

# ==========================================
# 3. GRAFIK AMPLITUDO MAKSIMUM
# ==========================================

p_amp = plot(
    xlabel="Waktu (s)",
    ylabel="Maksimum |y| (m)",
    title="Pertumbuhan Amplitudo Maksimum",
    yscale=:log10,
    legend=:topleft
)

for res in cfl_results

    amplitude = [
        maximum(abs, view(res.y, :, n))
        for n in eachindex(res.t)
    ]

    plot!(
        p_amp,
        res.t,
        max.(amplitude, eps(Float64)),
        label="r = $(res.r)",
        linewidth=1.5
    )

end

savefig(
    p_amp,
    joinpath(fig_dir, "cfl_max_amplitude.png")
)

display(p_amp)

# ==========================================
# 4. INTERPOLASI PROFIL PADA WAKTU TERTENTU
# ==========================================

function snapshot_at(res, target_time)

    if target_time < first(res.t) ||
       target_time > last(res.t)

        return nothing

    end

    j = searchsortedlast(res.t, target_time)

    if j == length(res.t)
        return copy(res.y[:,end])
    end

    alpha = (
        target_time-res.t[j]
    ) / (
        res.t[j+1]-res.t[j]
    )

    return (
        (1-alpha).*res.y[:,j] +
        alpha.*res.y[:,j+1]
    )

end

# Dua waktu fisik untuk perbandingan
target_times = [L/(2*c), L/c]

for (j, target_time) in enumerate(target_times)

    p_snapshot = plot(
        xlabel="Posisi (m)",
        ylabel="Simpangan (m)",
        title="Profil Gelombang t = $(target_time) s",
        legend=:topright
    )

    for res in cfl_results

        profile = snapshot_at(res, target_time)

        if isnothing(profile)

            println(
                "CFL $(res.r): snapshot tidak tersedia ",
                "karena simulasi berhenti lebih awal."
            )

            continue

        end

        plot!(
            p_snapshot,
            res.x,
            profile,
            label="r = $(res.r)",
            linewidth=1.5
        )

    end

    filename = j == 1 ?
        "cfl_profile_L_2c.png" :
        "cfl_profile_L_c.png"

    savefig(p_snapshot, joinpath(fig_dir, filename))

    display(p_snapshot)

end

println("\nEKSPERIMEN CFL SELESAI")