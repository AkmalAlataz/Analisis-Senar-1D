
function simulate_damped_wave(;
    L, c, gamma, h=0.001,
    Nx=100, r=0.8,
    t_end=0.2, faktor_batas=1e6
)

    @assert L > 0 && c > 0 && Nx >= 3
    @assert gamma >= 0 && r > 0
    @assert t_end > 0 && h != 0

    dx = L/Nx
    dt = r*dx/c

    q = t_end/dt
    Nt = max(2, ceil(Int, q-100*eps(q)))

    x = collect(range(0.0,L,length=Nx+1))
    waktu = collect(0:Nt).*dt

    y = zeros(Float64,Nx+1,Nt+1)

    # Kondisi awal segitiga
    y[:,1] .= initial_profile(x,L,h)

    y[1,1] = 0.0
    y[end,1] = 0.0

    # Langkah pertama Taylor, dengan g(x)=0
    for i in 2:Nx

        y[i,2] = y[i,1] +
            0.5*r^2*(
                y[i+1,1] -
                2*y[i,1] +
                y[i-1,1]
            )

    end

    # Kondisi batas
    y[1,2] = 0.0
    y[end,2] = 0.0

    # Koefisien redaman
    qgamma = gamma*dt/2

    threshold = faktor_batas*abs(h)

    stopped = false
    stop_time = NaN
    reason = "Selesai sampai waktu akhir"
    last_col = 2

    # Iterasi waktu
    for n in 2:Nt

        for i in 2:Nx

            lap = (
                y[i+1,n] -
                2*y[i,n] +
                y[i-1,n]
            )

            y[i,n+1] = (
                2*y[i,n] -
                (1-qgamma)*y[i,n-1] +
                r^2*lap
            )/(1+qgamma)

        end

        y[1,n+1] = 0.0
        y[end,n+1] = 0.0

        profile = view(y,:,n+1)

        if !all(isfinite,profile)

            stopped = true
            reason = "Muncul NaN atau Inf"
            stop_time = waktu[n+1]
            last_col = n
            break

        elseif maximum(abs,profile) > threshold

            stopped = true
            reason = "Amplitudo melewati ambang"
            stop_time = waktu[n+1]
            last_col = n+1
            break

        end

        last_col = n+1

    end

    y_final = y[:,1:last_col]
    t_final = waktu[1:last_col]

    return (
        x=x,
        waktu=t_final,
        y=y_final,
        L=L,
        c=c,
        gamma=gamma,
        dx=dx,
        dt=dt,
        r=c*dt/dx,
        Nx=Nx,
        Nt=last_col-1,
        stopped=stopped,
        reason=reason,
        stop_time=stop_time
    )

end