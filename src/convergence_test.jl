
using Statistics, Printf, Plots

# ==========================================
# 1. PARAMETER KONVERGENSI
# ==========================================

Nx_values = [50, 100, 200]
r_conv = 0.8
h_conv = 0.001

t_star = 0.8 * L/c

convergence_results = []

println("VERIFIKASI DAN KONVERGENSI")
@printf("Waktu evaluasi = %.9e s\n", t_star)

# ==========================================
# 2. SIMULASI UNTUK SETIAP GRID
# ==========================================

for Nx_conv in Nx_values

    println("\nGrid Nx = ", Nx_conv)

    res = simulate_wave(
        L=L,
        c=c,
        h=h_conv,
        Nx=Nx_conv,
        r=r_conv,
        t_end=t_star,
        initial=:sine
    )

    # Jumlah langkah harus tepat
    @assert res.nsteps_completed == Nx_conv

    # Solusi numerik
    y_num = res.y[:,end]

    # Solusi analitik
    y_exact = h_conv .* sin.(pi .* res.x ./ L) .*
              cos(pi*c*t_star/L)

    # Galat absolut
    error = y_num .- y_exact

    # RMSE seluruh titik grid
    rmse = sqrt(mean(abs2, error))

    push!(
        convergence_results,
        (
            Nx=Nx_conv,
            dx=res.dx,
            dt=res.dt,
            nsteps=res.nsteps_completed,
            time=res.t[end],
            rmse=rmse,
            x=res.x,
            numerical=copy(y_num),
            exact=y_exact
        )
    )

    @printf("dx       = %.9e m\n", res.dx)
    @printf("dt       = %.9e s\n", res.dt)
    @printf("Langkah  = %d\n", res.nsteps_completed)
    @printf("Waktu    = %.9e s\n", res.t[end])
    @printf("RMSE     = %.9e m\n", rmse)

end

# ==========================================
# 3. ORDE KONVERGENSI
# ==========================================

orders = fill(NaN, length(Nx_values))

for i in 1:length(Nx_values)-1

    E1 = convergence_results[i].rmse
    E2 = convergence_results[i+1].rmse

    orders[i] = log(E1/E2)/log(2)

end

# ==========================================
# 4. MENYIMPAN TABEL HASIL
# ==========================================

csv_dir = "results/csv"
fig_dir = "results/figures"

mkpath(csv_dir)
mkpath(fig_dir)

open(
    joinpath(csv_dir,"convergence_summary.csv"),"w"
) do io

    println(
        io,
        "Nx,dx_m,dt_s,nsteps,time_s,RMSE_m,order"
    )

    for i in eachindex(convergence_results)

        res = convergence_results[i]

        order_text = isfinite(orders[i]) ?
            @sprintf("%.8f",orders[i]) : ""

        @printf(
            io,
            "%d,%.9e,%.9e,%d,%.9e,%.9e,%s\n",
            res.Nx,res.dx,res.dt,
            res.nsteps,res.time,
            res.rmse,order_text
        )

    end

end

# ==========================================
# 5. MENYIMPAN PROFIL NUMERIK DAN EKSAK
# ==========================================

open(
    joinpath(csv_dir,"convergence_profiles.csv"),"w"
) do io

    println(
        io,
        "Nx,x_m,y_numerical_m,y_exact_m,error_m"
    )

    for res in convergence_results

        for i in eachindex(res.x)

            @printf(
                io,
                "%d,%.9e,%.9e,%.9e,%.9e\n",
                res.Nx,
                res.x[i],
                res.numerical[i],
                res.exact[i],
                res.numerical[i]-res.exact[i]
            )

        end

    end

end

# ==========================================
# 6. GRAFIK KONVERGENSI
# ==========================================

dx_values = [res.dx for res in convergence_results]
rmse_values = [res.rmse for res in convergence_results]

p_conv = plot(
    dx_values,
    rmse_values,
    xscale=:log10,
    yscale=:log10,
    marker=:circle,
    linewidth=2,
    label="RMSE",
    xlabel="Ukuran grid dx (m)",
    ylabel="RMSE (m)",
    title="Uji Konvergensi Numerik"
)

savefig(
    p_conv,
    joinpath(fig_dir,"convergence_error.png")
)

display(p_conv)

# ==========================================
# 7. PERBANDINGAN SOLUSI PADA GRID TERHALUS
# ==========================================

fine = last(convergence_results)

p_profile = plot(
    fine.x,
    fine.exact,
    label="Solusi eksak",
    linewidth=2,
    xlabel="Posisi (m)",
    ylabel="Simpangan (m)",
    title="Verifikasi Solusi (Nx = 200)"
)

plot!(
    p_profile,
    fine.x,
    fine.numerical,
    label="Solusi numerik",
    linestyle=:dash,
    linewidth=1.5
)

savefig(
    p_profile,
    joinpath(fig_dir,"convergence_profile.png")
)

display(p_profile)

# ==========================================
# 8. RINGKASAN ORDE
# ==========================================

println("\nRINGKASAN KONVERGENSI")

for i in 1:length(orders)

    if isfinite(orders[i])

        @printf(
            "Nx %d -> %d : p = %.6f\n",
            Nx_values[i],
            Nx_values[i+1],
            orders[i]
        )

    end

end

println("\nUJI KONVERGENSI SELESAI")