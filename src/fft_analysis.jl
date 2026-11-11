
using WAV, FFTW, Plots, Statistics, Printf

# ==================================================
# 1. MEMBACA REKAMAN
# ==================================================

file = joinpath(pwd(), "data", "audio",
                "Senar_E_Akmal.wav")

audio, fs, _, _ = wavread(file)

signal = ndims(audio) == 1 ?
         Float64.(audio) :
         Float64.(audio[:, 1])

Ntotal = length(signal)
duration = Ntotal / fs

# Rentang tiga petikan hasil deteksi
segments = [
    (name = "Petikan 1", t0 = 2.780, t1 = 3.780),
    (name = "Petikan 2", t0 = 7.960, t1 = 8.960),
    (name = "Petikan 3", t0 = 12.830, t1 = 13.830)
]

# Folder penyimpanan
folder_csv = joinpath(pwd(), "results", "csv")
folder_fig = joinpath(pwd(), "results", "figures")

mkpath(folder_csv)
mkpath(folder_fig)

# ==================================================
# 2. FUNGSI ANALISIS FFT
# ==================================================


function calculate_fft(signal, fs, t0, t1)

    # Menentukan panjang segmen secara konsisten
    i1 = floor(Int, t0 * fs) + 1
    N = round(Int, (t1 - t0) * fs)
    i2 = i1 + N - 1

    @assert 1 <= i1 <= i2 <= length(signal)

    s = Float64.(signal[i1:i2])

    # Menghilangkan komponen DC
    s .-= mean(s)

    # Hann window
    w = 0.5 .* (
        1 .- cos.(2pi .* (0:N-1) ./ (N-1))
    )

    # FFT
    X = rfft(s .* w)

    frequency = collect(0:length(X)-1) .* fs/N
    amplitude = abs.(X) ./ sum(w)

    # Spektrum satu sisi
    if iseven(N)
        amplitude[2:end-1] .*= 2
    else
        amplitude[2:end] .*= 2
    end

    relative = amplitude ./ maximum(amplitude)

    return (
        frequency = frequency,
        amplitude = amplitude,
        relative = relative,
        N = N,
        df = fs/N
    )
end

# Interpolasi parabola pada log amplitudo
function interpolate_peak(f, a, k)

    if k <= 1 || k >= length(a)
        return f[k]
    end

    b = log.(max.(a[k-1:k+1], eps(Float64)))

    den = b[1] - 2b[2] + b[3]

    delta = 0.0

    if abs(den) > eps(Float64)
        delta = clamp(
            0.5 * (b[1] - b[3]) / den,
            -0.5, 0.5
        )
    end

    df = f[2] - f[1]

    return f[k] + delta * df
end

# ==================================================
# 3. ANALISIS KETIGA PETIKAN
# ==================================================

results = []

for seg in segments

    result = calculate_fft(
        signal, fs, seg.t0, seg.t1
    )

    push!(results, result)

    println("\n", seg.name)

    @printf("Jumlah sampel : %d\n", result.N)
    @printf("Resolusi FFT  : %.3f Hz\n", result.df)

    # Mencari puncak lokal spektrum
    a = result.relative
    f = result.frequency

    peaks = [
        k for k in 2:length(a)-1
        if f[k] >= 20 &&
           f[k] <= 2000 &&
           a[k] > a[k-1] &&
           a[k] >= a[k+1]
    ]

    # Mengurutkan berdasarkan amplitudo
    order = sort(
        peaks,
        by = k -> a[k],
        rev = true
    )

    # Menampilkan 10 puncak tertinggi
    top = order[1:min(10, length(order))]

    println("10 puncak spektrum tertinggi:")

    for k in top
        fp = interpolate_peak(f, a, k)

        @printf("f = %8.3f Hz | Arel = %.4f\n",
                fp, a[k])
    end

    # Menyimpan spektrum ke CSV
    csv_file = joinpath(
        folder_csv,
        replace(seg.name, " " => "_") * ".csv"
    )

    open(csv_file, "w") do io

        println(io,
            "frequency_Hz,amplitude,relative_amplitude"
        )

        for k in eachindex(f)
            @printf(io, "%.6f,%.12e,%.8f\n",
                f[k], result.amplitude[k],
                result.relative[k])
        end
    end

    # Grafik spektrum
    p = plot(
        f,
        result.relative,
        xlims = (0, 2000),
        xlabel = "Frekuensi (Hz)",
        ylabel = "Amplitudo relatif",
        title = seg.name,
        label = "FFT Hann",
        linewidth = 1.2
    )

    savefig(
        p,
        joinpath(folder_fig,
            replace(seg.name, " " => "_") * "_FFT.png")
    )

end

# ==================================================
# 4. PERBANDINGAN SPEKTRUM KETIGA PETIKAN
# ==================================================

p_all = plot(
    xlabel = "Frekuensi (Hz)",
    ylabel = "Amplitudo relatif",
    title = "Perbandingan Spektrum Tiga Petikan",
    xlims = (0, 2000),
    legend = :topright
)

for (i, result) in enumerate(results)

    plot!(
        p_all,
        result.frequency,
        result.relative,
        label = segments[i].name,
        linewidth = 1.2
    )

end

savefig(
    p_all,
    joinpath(folder_fig, "perbandingan_FFT.png")
)

display(p_all)

println("\nAnalisis FFT selesai.")