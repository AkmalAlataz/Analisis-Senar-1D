
using Statistics
using Printf

# ==================================================
# FUNGSI UJI KONVERGENSI ENERGI
# ==================================================

function energy_grid_convergence(;
    L, c, mu, T,
    Nx_values=[50, 100, 200],
    r=0.8,
    h=0.001,
    t_end=0.2
)

    summaries = NamedTuple[]
    curves = NamedTuple[]

    for Nx in Nx_values

        println("\nGrid Nx = ", Nx)

        # ==========================================
        # 1. SIMULASI TANPA REDAMAN
        # ==========================================

        res = simulate_damped_wave(
            L=L,
            c=c,
            gamma=0.0,
            h=h,
            Nx=Nx,
            r=r,
            t_end=t_end
        )

        # ==========================================
        # 2. MENGHITUNG ENERGI
        # ==========================================

        en = calculate_energy(res, mu, T)

        # Memastikan waktu target tercakup
        @assert t_end <= en.time[end] +
            100*eps(en.time[end])

        # Mengambil data hingga waktu target
        ids = findall(
            t -> t <= t_end,
            en.time
        )

        time_data = en.time[ids]
        ratio_data = en.normalized[ids]

        # ==========================================
        # 3. INTERPOLASI PADA WAKTU TARGET
        # ==========================================

        j = searchsortedlast(en.time, t_end)

        if j == length(en.time)

            ratio_end = en.normalized[end]

        elseif isapprox(
            en.time[j], t_end;
            atol=100*eps(t_end),
            rtol=0
        )

            ratio_end = en.normalized[j]

        else

            alpha = (
                t_end - en.time[j]
            ) / (
                en.time[j+1] - en.time[j]
            )

            ratio_end = (
                (1-alpha)*en.normalized[j] +
                alpha*en.normalized[j+1]
            )

        end

        # Menggabungkan data energi
        values = vcat(ratio_data, ratio_end)

        # Penyimpangan energi terhadap nilai awal
        deviation = abs.(values .- 1.0)

        max_deviation = maximum(deviation)

        rms_deviation = sqrt(
            mean(deviation.^2)
        )

        # ==========================================
        # 4. MENYIMPAN RINGKASAN GRID
        # ==========================================

        push!(
            summaries,
            (
                Nx=Nx,
                dx=res.dx,
                dt=res.dt,
                max_dev=max_deviation,
                rms_dev=rms_deviation,
                final_ratio=ratio_end,
                min_ratio=minimum(values),
                max_ratio=maximum(values)
            )
        )

        # Menambahkan titik interpolasi ke kurva
        curve_time = vcat(time_data, t_end)
        curve_energy = vcat(ratio_data, ratio_end)

        push!(
            curves,
            (
                Nx=Nx,
                time=curve_time,
                energy=curve_energy
            )
        )

        # ==========================================
        # 5. MENAMPILKAN HASIL
        # ==========================================

        @printf("dx              : %.6e m\n", res.dx)
        @printf("dt              : %.6e s\n", res.dt)
        @printf("Jumlah langkah  : %d\n", res.Nt)
        @printf("Max deviation   : %.8e\n", max_deviation)
        @printf("RMS deviation   : %.8e\n", rms_deviation)
        @printf("E(0.2)/E(0)     : %.8f\n", ratio_end)
        @printf("Minimum E/E0    : %.8f\n", minimum(values))
        @printf("Maksimum E/E0   : %.8f\n", maximum(values))

    end

    return summaries, curves

end