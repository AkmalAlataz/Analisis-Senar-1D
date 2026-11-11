
using Plots, Printf, Statistics

# ==========================================
# 1. FUNGSI INTEGRASI TRAPESIUM
# ==========================================

function trapezoid_uniform(f,dx)

    return dx*(
        0.5*f[1] +
        sum(f[2:end-1]) +
        0.5*f[end]
    )

end


# ==========================================
# 2. FUNGSI PERHITUNGAN ENERGI
# ==========================================

function calculate_energy(res,mu,T)

    y = res.y
    Nx1,Nt1 = size(y)

    dx = res.dx
    dt = res.dt

    # Kecepatan setiap titik grid
    velocity = zeros(Float64,Nx1,Nt1)

    # Kecepatan awal diketahui: g(x)=0
    velocity[:,1] .= 0.0

    # Beda pusat untuk waktu interior
    for n in 2:Nt1-1

        velocity[:,n] .= (
            y[:,n+1]-y[:,n-1]
        )/(2dt)

    end

    # Beda mundur pada waktu akhir
    velocity[:,end] .= (
        y[:,end]-y[:,end-1]
    )/dt

    # Syarat batas kecepatan
    velocity[1,:] .= 0.0
    velocity[end,:] .= 0.0

    energy = zeros(Float64,Nt1)

    for n in 1:Nt1

        # Energi kinetik: aturan trapesium
        kinetic_integral = trapezoid_uniform(
            abs2.(velocity[:,n]),dx
        )

        # Turunan ruang dengan beda maju
        dy_dx = diff(y[:,n])/dx

        # Integral energi potensial
        potential_integral = dx*sum(abs2,dy_dx)

        energy[n] = 0.5*(
            mu*kinetic_integral +
            T*potential_integral
        )

    end

    return (
        time=res.waktu,
        energy=energy,
        normalized=energy./energy[1],
        velocity=velocity
    )

end


# ==========================================
# 3. SIMULASI DUA KONDISI REDAMAN
# ==========================================

gammas = [0.0,15.0]

damped_results = []

for gamma in gammas

    println("\nMenjalankan gamma = ",gamma)

    res = simulate_damped_wave(
        L=L,
        c=c,
        gamma=gamma,
        h=0.001,
        Nx=100,
        r=0.8,
        t_end=0.2
    )

    push!(damped_results,res)

    @printf("dx             : %.6e m\n",res.dx)
    @printf("dt             : %.6e s\n",res.dt)
    @printf("CFL            : %.4f\n",res.r)
    @printf("Jumlah langkah : %d\n",res.Nt)
    @printf("Waktu akhir    : %.6f s\n",res.waktu[end])
    println("Status         : ",res.reason)

end


# ==========================================
# 4. ANALISIS ENERGI
# ==========================================

energy_results = []

for res in damped_results

    energy = calculate_energy(res,mu,T)

    push!(energy_results,energy)

end


# ==========================================
# 5. EKSPOR DATA ENERGI
# ==========================================

csv_dir = "results/csv"
fig_dir = "results/figures"
anim_dir = "results/animation"

mkpath(csv_dir)
mkpath(fig_dir)
mkpath(anim_dir)

open(
    joinpath(csv_dir,"damped_energy.csv"),"w"
) do io

    println(io,"gamma,time_s,energy_J,normalized_energy")

    for (i,res) in enumerate(damped_results)

        en = energy_results[i]

        for n in eachindex(en.time)

            @printf(
                io,"%.1f,%.12e,%.12e,%.12e\n",
                res.gamma,
                en.time[n],
                en.energy[n],
                en.normalized[n]
            )

        end

    end

end


# ==========================================
# 6. GRAFIK ENERGI TERNORMALISASI
# ==========================================

p_energy = plot(
    xlabel="Waktu (s)",
    ylabel="Energi ternormalisasi E(t)/E(0)",
    title="Evolusi Energi Gelombang",
    legend=:topright
)

for (i,res) in enumerate(damped_results)

    en = energy_results[i]

    plot!(
        p_energy,
        en.time,
        en.normalized,
        label="gamma = $(res.gamma) s^-1",
        linewidth=1.8
    )

end

savefig(
    p_energy,
    joinpath(fig_dir,"damped_energy.png")
)

display(p_energy)


# ==========================================
# 7. SNAPSHOT PROFIL PADA t=0.1 s
# ==========================================

function snapshot_damped(res,target)

    t = res.waktu
    j = searchsortedlast(t,target)

    if target < t[1] || target > t[end]
        error("Waktu snapshot di luar simulasi")
    end

    if j == length(t)
        return copy(res.y[:,end])
    end

    alpha = (target-t[j])/(t[j+1]-t[j])

    return (
        (1-alpha).*res.y[:,j] +
        alpha.*res.y[:,j+1]
    )

end

target = 0.1

p_profile = plot(
    xlabel="Posisi (m)",
    ylabel="Simpangan (m)",
    title="Profil Gelombang pada t = 0.1 s",
    legend=:topright
)

for res in damped_results

    profile = snapshot_damped(res,target)

    plot!(
        p_profile,
        res.x,
        profile,
        label="gamma = $(res.gamma) s^-1",
        linewidth=1.6
    )

end

savefig(
    p_profile,
    joinpath(fig_dir,"damped_profile.png")
)

display(p_profile)


# ==========================================
# 8. ANIMASI PERBANDINGAN
# ==========================================

res0 = damped_results[1]
res15 = damped_results[2]

indices = unique(
    round.(Int,range(
        1,length(res0.waktu),
        length=min(100,length(res0.waktu))
    ))
)

film = Animation()

for n in indices

    p0 = plot(
        res0.x,
        res0.y[:,n],
        xlabel="Posisi (m)",
        ylabel="Simpangan (m)",
        title="gamma = 0",
        label=false,
        ylims=(-0.0012,0.0012)
    )

    p15 = plot(
        res15.x,
        res15.y[:,n],
        xlabel="Posisi (m)",
        ylabel="Simpangan (m)",
        title="gamma = 15 s^-1",
        label=false,
        ylims=(-0.0012,0.0012)
    )

    p_frame = plot(
        p0,p15,
        layout=(1,2),
        size=(1000,450),
        plot_title=@sprintf(
            "Evolusi Gelombang t = %.4f s",
            res0.waktu[n]
        )
    )

    frame(film,p_frame)

end

gif(
    film,
    joinpath(anim_dir,"damped_comparison.gif"),
    fps=20
)

println("\nANALISIS REDAMAN DAN ENERGI SELESAI")