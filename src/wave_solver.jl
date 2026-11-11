using Printf

function initial_profile(x, L, h; position=0.2)

    xp = position * L

    return [
        xi <= xp ?
        h * xi / xp :
        h * (L - xi) / (L - xp)
        for xi in x
    ]
end


function simulate_wave(;
    L, c, h=0.001, Nx=100,
    r=0.8, t_end=nothing,
    faktor_batas=1e6,
    initial=:triangle
)

    @assert L > 0 && c > 0
    @assert Nx >= 3 && r > 0
    @assert h != 0 && faktor_batas > 1

    if r > 1
        @warn "CFL > 1: simulasi berpotensi tidak stabil."
    end

    dx = L / Nx
    dt = r * dx / c

    tf = isnothing(t_end) ? 2*L/c : t_end

    q = tf/dt
    tol = 100*eps(q)

    Nt = max(2, ceil(Int, q-tol))

    x = collect(range(0.0, L; length=Nx+1))
    time_values = collect(0:Nt) .* dt

    y = zeros(Float64, Nx+1, Nt+1)

    # Kondisi awal
    if initial == :triangle

        y[:,1] .= initial_profile(x,L,h)

    elseif initial == :sine

        y[:,1] .= h .* sin.(pi .* x ./ L)

    else

        error("Initial profile tidak dikenal")

    end

    y[1,1] = 0.0
    y[end,1] = 0.0

    # Langkah pertama Taylor
    for i in 2:Nx

        y[i,2] = y[i,1] +
            0.5*r^2*(
                y[i+1,1] -
                2*y[i,1] +
                y[i-1,1]
            )

    end

    y[1,2] = 0.0
    y[end,2] = 0.0

    # Deteksi ketidakstabilan
    threshold = faktor_batas * abs(h)

    stopped = false
    stop_time = NaN
    reason = "Selesai sampai waktu akhir"

    last_col = 2

    for n in 2:Nt

        for i in 2:Nx

            y[i,n+1] =
                2*y[i,n] - y[i,n-1] +
                r^2*(
                    y[i+1,n] -
                    2*y[i,n] +
                    y[i-1,n]
                )

        end

        # Kondisi batas
        y[1,n+1] = 0.0
        y[end,n+1] = 0.0

        profile = view(y, :, n+1)

        if !all(isfinite, profile)

            stopped = true
            reason = "Muncul NaN atau Inf"
            stop_time = time_values[n+1]
            last_col = n
            break

        elseif maximum(abs, profile) > threshold

            stopped = true
            reason = "Amplitudo melewati ambang"
            stop_time = time_values[n+1]
            last_col = n+1
            break

        end

        last_col = n+1

    end

    y_final = y[:,1:last_col]
    t_final = time_values[1:last_col]

    max_amp = maximum(abs, y_final)

    return (
        x=x,
        t=t_final,
        y=y_final,
        L=L,
        c=c,
        Nx=Nx,
        dx=dx,
        dt=dt,
        r=r,
        r_actual=c*dt/dx,
        Nt_planned=Nt,
        nsteps_completed=last_col-1,
        stopped=stopped,
        reason=reason,
        stop_time=stop_time,
        threshold=threshold,
        max_amplitude=max_amp
    )

end