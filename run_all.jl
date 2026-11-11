# ============================================================
# RUN_ALL.JL
# Entry point untuk menjalankan seluruh analisis tugas.
# Jalankan dari root project dengan Julia 1.13.x.
# ============================================================

import Pkg

# Root project diambil dari lokasi file run_all.jl,
# sehingga script tetap bekerja meskipun dipanggil dari folder lain.
project_root = @__DIR__
cd(project_root)

println("="^64)
println("SIMULASI DAN ANALISIS GELOMBANG SENAR SATU DIMENSI")
println("="^64)
println("Project : ", project_root)
println("Julia   : ", VERSION)

# Aktifkan environment project dan pastikan seluruh dependensi tersedia.
Pkg.activate(project_root)
Pkg.instantiate()

# Periksa file audio wajib sebelum menjalankan rangkaian analisis.
audio_file = joinpath(project_root, "data", "audio", "Senar_E_Akmal.wav")
if !isfile(audio_file)
    error("File audio tidak ditemukan: $(audio_file)")
end

# Siapkan direktori keluaran.
for folder in (
    joinpath(project_root, "results", "csv"),
    joinpath(project_root, "results", "figures"),
    joinpath(project_root, "results", "animation"),
)
    mkpath(folder)
end

println("\nEnvironment aktif dan file audio ditemukan.")
println("Memulai seluruh tahapan analisis...\n")

# ------------------------------------------------------------
# BAGIAN 1: INSPEKSI AUDIO, DETEKSI PETIKAN, DAN FFT
# ------------------------------------------------------------
println("[1/12] Inspeksi rekaman audio")
include(joinpath(project_root, "src", "inspect_audio.jl"))

println("\n[2/12] Deteksi tiga petikan")
include(joinpath(project_root, "src", "detect_plucks.jl"))

println("\n[3/12] Analisis FFT tiga petikan")
include(joinpath(project_root, "src", "fft_analysis.jl"))

println("\n[4/12] Statistik frekuensi fundamental")
include(joinpath(project_root, "src", "parameter_analysis.jl"))

println("\n[5/12] Estimasi parameter fisika")
include(joinpath(project_root, "src", "physical_parameters.jl"))

# ------------------------------------------------------------
# BAGIAN 2: SOLVER, CFL, DAN VERIFIKASI KONVERGENSI
# ------------------------------------------------------------
println("\n[6/12] Definisi solver gelombang tanpa redaman")
include(joinpath(project_root, "src", "wave_solver.jl"))

println("\n[7/12] Eksperimen CFL dan snapshot profil")
include(joinpath(project_root, "src", "cfl_experiment.jl"))

println("\n[8/12] Verifikasi solusi analitik dan konvergensi")
include(joinpath(project_root, "src", "convergence_test.jl"))

# ------------------------------------------------------------
# BAGIAN 3: REDAMAN DAN ENERGI
# ------------------------------------------------------------
println("\n[9/12] Definisi solver gelombang teredam")
include(joinpath(project_root, "src", "damped_solver.jl"))

println("\n[10/12] Simulasi redaman, energi, dan animasi")
include(joinpath(project_root, "src", "energy_analysis.jl"))

println("\n[11/12] Definisi fungsi konvergensi energi")
include(joinpath(project_root, "src", "energy_convergence.jl"))

println("\n[12/12] Uji konvergensi energi dan ekspor hasil")
include(joinpath(project_root, "src", "run_energy_convergence.jl"))

# ------------------------------------------------------------
# RINGKASAN AKHIR
# ------------------------------------------------------------
println("\n" * "="^64)
println("SELURUH TAHAPAN SELESAI")
println("="^64)
println("Periksa hasil pada direktori:")
println("  results/csv/")
println("  results/figures/")
println("  results/animation/")
println("\nPastikan foto eksperimen dan video penjelasan juga")
println("disertakan secara terpisah sebelum pengumpulan.")
