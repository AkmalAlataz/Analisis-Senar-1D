
using WAV, Plots, Statistics, Printf

# Membaca rekaman audio
file = joinpath(pwd(), "data", "audio",
                "Senar_E_Akmal.wav")

audio, fs, _, _ = wavread(file)

# Mengambil kanal pertama jika stereo
signal = ndims(audio) == 1 ?
         vec(audio) : vec(audio[:, 1])

# Informasi dasar audio
N = length(signal)
duration = N / fs

@printf("Sampling rate : %.0f Hz\n", fs)
@printf("Jumlah sampel : %d\n", N)
@printf("Durasi        : %.3f s\n", duration)
@printf("Amplitudo min : %.6f\n", minimum(signal))
@printf("Amplitudo max : %.6f\n", maximum(signal))

# Membuat sumbu waktu
t = (0:N-1) ./ fs

# Downsampling untuk visualisasi
step_plot = max(1, div(N, 50000))
idx = 1:step_plot:N

# Membuat grafik waveform
p = plot(
    t[idx], signal[idx],
    xlabel = "Waktu (s)",
    ylabel = "Amplitudo digital",
    title = "Rekaman Senar E - Tiga Petikan",
    label = "Waveform",
    linewidth = 0.6
)

# Menyimpan grafik
savefig(p, joinpath(pwd(), "results",
                    "figures", "waveform_rekaman.png"))

display(p)