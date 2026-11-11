
using WAV, Statistics, Printf

# Membaca rekaman
file = joinpath(pwd(), "data", "audio",
                "Senar_E_Akmal.wav")

audio, fs, _, _ = wavread(file)

# Mengambil kanal pertama jika stereo
signal = ndims(audio) == 1 ?
         Float64.(audio) :
         Float64.(audio[:, 1])

N = length(signal)
duration = N / fs

@printf("Sampling rate : %.0f Hz\n", fs)
@printf("Durasi        : %.3f s\n", duration)

# Rentang pencarian setiap petikan
ranges = [(0.0, 5.0),
          (5.0, 10.0),
          (10.0, 15.0)]

# Panjang jendela RMS = 10 ms
window_size = max(1, round(Int, 0.01 * fs))

println("\nHASIL DETEKSI PETIKAN")

for (j, (t0, t1)) in enumerate(ranges)

    t1_actual = min(t1, duration)

    if t0 >= duration
        @warn "Rentang petikan $j berada di luar rekaman"
        continue
    end

    # Indeks sampel
    i1 = floor(Int, t0 * fs) + 1
    i2 = min(floor(Int, t1_actual * fs), N)

    # Menghitung RMS per 10 ms
    starts = collect(i1:window_size:i2)
    rms_values = Float64[]

    for a in starts
        b = min(a + window_size - 1, i2)
        s = view(signal, a:b)
        push!(rms_values, sqrt(sum(abs2, s) / length(s)))
    end

    # Lokasi energi terbesar
    k = argmax(rms_values)
    t_peak = (starts[k] - 1) / fs

    # Kandidat segmen FFT setelah impuls
    t_start = t_peak + 0.05
    t_end = min(t_start + 1.0, t1_actual)

    println("\nPetikan $j:")
    @printf("  Puncak RMS       : %.4f s\n", t_peak)
    @printf("  Kandidat FFT     : %.4f - %.4f s\n",
            t_start, t_end)
    @printf("  Durasi segmen    : %.4f s\n",
            t_end - t_start)
    @printf("  Resolusi FFT     : %.4f Hz\n",
            1 / (t_end - t_start))

    if t_end - t_start < 0.5
        println("  PERHATIAN: Segmen terlalu pendek, perlu diperiksa.")
    end
end