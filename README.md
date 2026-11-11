# Simulasi dan Analisis Gelombang Senar Satu Dimensi

Proyek ini merupakan implementasi tugas Fisika Komputasi mengenai **persamaan diferensial parsial hiperbolik**, dengan studi kasus simulasi dan analisis gelombang pada senar gitar satu dimensi.

Program ditulis menggunakan Julia. Analisis meliputi pengolahan rekaman audio, estimasi frekuensi fundamental menggunakan Fast Fourier Transform (FFT), penyelesaian persamaan gelombang dengan metode beda hingga, pengujian kestabilan CFL, verifikasi solusi analitik, serta model peredaman dan analisis energi.

## Isi proyek

- Analisis rekaman audio tiga petikan senar.
- Estimasi frekuensi fundamental dan parameter model senar.
- Simulasi persamaan gelombang tanpa redaman.
- Eksperimen kestabilan CFL dan analisis dispersi numerik.
- Verifikasi terhadap solusi analitik dan pengujian konvergensi.
- Simulasi gelombang teredam untuk dua nilai koefisien redaman.
- Perhitungan energi, visualisasi, dan pengujian konvergensi estimasi energi.

## Persyaratan perangkat lunak

Lingkungan pengembangan yang digunakan:

- Julia 1.13.3
- Juliaup untuk pengelolaan instalasi Julia
- Visual Studio Code dengan extension **Julia** dari publisher `julialang` (opsional, tetapi direkomendasikan)

Paket Julia yang digunakan secara langsung:

| Paket | Kegunaan |
|---|---|
| `WAV` | Membaca rekaman audio WAV |
| `FFTW` | Menghitung Fast Fourier Transform |
| `Plots` | Membuat grafik dan animasi GIF |
| `Statistics` | Perhitungan statistik, termasuk rata-rata dan simpangan baku |
| `Printf` | Format keluaran numerik |

Versi paket yang tercatat pada lingkungan pengembangan awal:

- FFTW 1.10.0
- Plots 1.41.7
- WAV 1.2.0

Versi dependensi yang lengkap dikunci melalui `Manifest.toml`.

## Struktur direktori

```text
Tugas1 Analisis Gelombang Gitar/
│
├── README.md
├── run_all.jl
├── Project.toml
├── Manifest.toml
│
├── data/
│   ├── audio/
│   │   └── Senar_E_Akmal.wav
│   └── eksperimen/
│       └── foto_susunan_eksperimen.jpg
│
├── src/
│   ├── inspect_audio.jl
│   ├── detect_plucks.jl
│   ├── fft_analysis.jl
│   ├── parameter_analysis.jl
│   ├── physical_parameters.jl
│   ├── wave_solver.jl
│   ├── cfl_experiment.jl
│   ├── convergence_test.jl
│   ├── damped_solver.jl
│   ├── energy_analysis.jl
│   ├── energy_convergence.jl
│   └── run_energy_convergence.jl
│
├── results/
│   ├── csv/
│   ├── figures/
│   └── animation/
│
├── report/
│   └── laporan.pdf
│
└── video/
    └── penjelasan_tugas.mp4
```

Ganti `USERNAME/REPOSITORY` pada perintah clone dengan alamat repository milikmu. Nama file foto, laporan, dan video pada struktur di atas merupakan contoh nama yang disarankan. Sesuaikan dengan file yang benar-benar disertakan.

## Instalasi dan persiapan

### 1. Instal Julia

Instal Julia melalui Juliaup mengikuti petunjuk resmi:

<https://julialang.org/install/>

Periksa instalasi melalui terminal:

```bash
julia --version
juliaup status
```

### 2. Buka project

Clone repository, kemudian masuk ke folder project:

```bash
git clone https://github.com/USERNAME/REPOSITORY.git
cd "Tugas1 Analisis Gelombang Gitar"
```

Apabila project sudah dibuka di Visual Studio Code, pastikan folder yang dibuka adalah root project, yaitu folder yang berisi `Project.toml` dan `Manifest.toml`.

### 3. Instal dependensi project

Dari terminal pada root project, jalankan:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Perintah tersebut memasang dependensi berdasarkan `Project.toml` dan `Manifest.toml`.

## Menjalankan program

### Menjalankan seluruh analisis

Pastikan rekaman asli tersedia pada:

```text
data/audio/Senar_E_Akmal.wav
```

Kemudian, dari root project, jalankan:

```bash
julia --project=. run_all.jl
```

`run_all.jl` mengaktifkan environment project, mengatur direktori kerja ke root project, memeriksa keberadaan file audio, lalu menjalankan seluruh script secara berurutan.

Urutan eksekusi:

1. Inspeksi rekaman audio.
2. Deteksi tiga petikan.
3. Analisis FFT.
4. Statistik frekuensi fundamental.
5. Estimasi parameter fisika.
6. Definisi solver gelombang tanpa redaman.
7. Eksperimen CFL.
8. Verifikasi solusi analitik dan konvergensi.
9. Definisi solver gelombang teredam.
10. Simulasi redaman, energi, dan pembuatan GIF.
11. Definisi fungsi konvergensi energi.
12. Uji konvergensi energi dan ekspor hasil.

Script dapat pula dijalankan satu per satu dari Julia REPL. Jalankan dari root project dan ikuti urutan dependensi di atas. Beberapa script menggunakan fungsi atau parameter yang didefinisikan oleh script sebelumnya.

### Menjalankan melalui Visual Studio Code

1. Buka root project di Visual Studio Code.
2. Pastikan extension Julia telah terpasang.
3. Jalankan perintah **Julia: Start REPL**.
4. Pastikan environment project aktif. `run_all.jl` juga mengaktifkan project secara otomatis.
5. Jalankan:

```julia
include("run_all.jl")
```

Untuk pengujian ulang yang bersih, disarankan membuka sesi Julia REPL baru sebelum menjalankan keseluruhan program.

## Data eksperimen dan estimasi frekuensi

Rekaman yang dianalisis adalah `data/audio/Senar_E_Akmal.wav`.

Informasi rekaman:

| Besaran | Nilai |
|---|---:|
| Sampling rate, \(f_s\) | 44.100 Hz |
| Durasi rekaman | 20,410 s |
| Jumlah petikan | 3 |
| Durasi tiap segmen FFT | 1 s |
| Jumlah sampel tiap segmen, \(N\) | 44.100 |
| Resolusi frekuensi, \(\Delta f=f_s/N\) | 1 Hz |

Segmen yang digunakan untuk analisis:

| Petikan | Rentang waktu |
|---|---:|
| 1 | 2,780–3,780 s |
| 2 | 7,960–8,960 s |
| 3 | 12,830–13,830 s |

Pemrosesan spektrum mencakup penghilangan komponen DC, penerapan Hann window, FFT satu sisi, dan interpolasi parabola pada log-amplitudo untuk memperkirakan posisi puncak spektrum di antara bin FFT. Fundamental diidentifikasi dari pola harmonik, bukan hanya dari puncak amplitudo terbesar tanpa pemeriksaan.

Hasil frekuensi fundamental:

| Petikan | Fundamental (Hz) |
|---|---:|
| 1 | 328,512 |
| 2 | 328,516 |
| 3 | 328,475 |
| Rata-rata | 328,501 |

Simpangan baku antarpetikan adalah 0,022605 Hz dan standard error rata-rata adalah 0,013051 Hz. Interpolasi puncak menghasilkan estimasi sub-bin, tetapi tidak mengubah resolusi nominal FFT sebesar 1 Hz dan tidak dengan sendirinya menyatakan ketidakpastian total pengukuran.

## Parameter model

Parameter yang digunakan pada simulasi:

| Parameter | Nilai | Ketidakpastian / keterangan |
|---|---:|---|
| Panjang bebas, \(L\) | 0,658 m | \(\sigma_L=0,001\) m |
| Massa, \(m\) | 0,0225 kg | Asumsi rentang 22–23 g; \(\sigma_m=0,0002887\) kg |
| Frekuensi fundamental, \(f_1\) | 328,501 Hz | Standard error 0,013051 Hz |
| Massa linear, \(\mu=m/L\) | 0,03419453 kg/m | \(\sigma_\mu\approx0,0004418\) kg/m |
| Kecepatan rambat, \(c=2Lf_1\) | 432,307316 m/s | \(\sigma_c\approx0,6572\) m/s |
| Tegangan, \(T=\mu c^2\) | 6390,6024 N | \(\sigma_T\approx82,57\) N |
| Simpangan awal simulasi, \(h\) | 0,001 m | Parameter simulasi, bukan hasil pengukuran |
| Posisi petikan model, \(x_p/L\) | 0,2 | Posisi pada profil awal simulasi |

Untuk massa yang diasumsikan seragam pada rentang 22–23 g, ketidakpastian standarnya dihitung sebagai \(\sigma_m=(23-22)/\sqrt{12}\) g. Karena \(\mu=m/L\), massa linear tidak independen terhadap panjang. Propagasi ketidakpastian tegangan dilakukan dari bentuk \(T=4mLf_1^2\), yaitu \((\sigma_T/T)^2=(\sigma_m/m)^2+(\sigma_L/L)^2+4(\sigma_f/f_1)^2\), dengan masukan independen \(m,L,f_1\).

**Catatan status data massa:** massa 22,5 g bukan hasil penimbangan langsung dalam eksperimen ini. Nilai tersebut dipilih sebagai nilai nominal dari rentang referensi 22–23 g dan diasumsikan berlaku untuk panjang 0,658 m. Karena itu, \(\mu\), \(c\), dan terutama \(T\) harus dibaca dengan keterbatasan asumsi tersebut. Nilai \(h=0,001\) m juga merupakan parameter simulasi dan tidak diklaim sebagai simpangan hasil pengukuran.

## Metode numerik dan eksperimen simulasi

### Persamaan gelombang tanpa redaman

Model dasar:

\[
 y_{tt}=c^2y_{xx},\qquad y(0,t)=y(L,t)=0.
\]

Skema beda hingga eksplisit menggunakan beda pusat orde dua dalam ruang dan waktu:

\[
 y_i^{n+1}=2y_i^n-y_i^{n-1}
 +r^2(y_{i+1}^n-2y_i^n+y_{i-1}^n),
 \qquad r=\frac{c\Delta t}{\Delta x}.
\]

Langkah pertama ditentukan dari ekspansi Taylor dengan kecepatan awal nol. Kondisi batas kedua ujung diterapkan pada setiap langkah waktu.

### Eksperimen CFL

Eksperimen dilakukan dengan \(N_x=100\) dan tiga nilai CFL:

- \(r=0,80\)
- \(r=1,00\)
- \(r=1,05\)

Durasi target adalah sekitar \(2L/c\). Profil dibandingkan pada waktu fisik \(L/(2c)\) dan \(L/c\), menggunakan interpolasi waktu apabila diperlukan. Amplitudo maksimum \(M_n=\max_i|y_i^n|\) disimpan terhadap waktu. Kasus tidak stabil dihentikan jika amplitudo melewati \(10^6h\) atau muncul nilai tidak hingga. Kasus yang berhenti sebelum waktu snapshot tidak memiliki profil pada waktu snapshot tersebut; kondisi ini dicatat, bukan diganti dengan data perkiraan.

### Verifikasi dan konvergensi solusi

Profil awal sinusoidal digunakan:

\[
 y(x,0)=h\sin\left(\frac{\pi x}{L}\right),
\]

Dengan solusi eksak:

\[
 y_{\mathrm{eksak}}(x,t)=h\sin\left(\frac{\pi x}{L}\right)
 \cos\left(\frac{\pi ct}{L}\right).
\]

Pengujian menggunakan \(r=0,8\) dan \(N_x=50,100,200\). Waktu evaluasi yang digunakan adalah \(t^*=0,8L/c\), sehingga dapat dicapai tepat pada grid waktu untuk ketiga grid tersebut. Galat dihitung dengan RMSE seluruh titik grid dan orde teramati dihitung dari perbandingan galat pada dua grid berturutan.

### Model gelombang teredam

Model perluasan:

\[
 y_{tt}+\gamma y_t=c^2y_{xx}.
\]

Perbandingan dilakukan untuk \(\gamma=0\) dan \(\gamma=15\,\mathrm{s}^{-1}\), menggunakan \(r=0,8\), parameter lain sama, dan durasi sekitar 0,2 s. Koefisien \(\gamma\) diperlakukan sebagai peredaman efektif.

### Analisis energi

Energi kontinu dihitung dari:

\[
 E(t)=\frac12\int_0^L\left[\mu y_t^2+T y_x^2\right]dx.
\]

Turunan waktu pada titik interior dihitung dengan beda pusat; pada waktu awal digunakan kecepatan awal yang diketahui, sedangkan pada waktu akhir digunakan beda satu sisi mundur. Turunan ruang menggunakan beda maju pada interval ruang, dan integral energi kinetik menggunakan aturan trapesium. Energi dibandingkan melalui rasio \(E_n/E_0\). Untuk kasus tanpa redaman, penyimpangan estimasi energi diperiksa pada \(N_x=50,100,200\).

## Hasil keluaran

Seluruh keluaran program disimpan pada direktori `results/`.

### CSV

- `Petikan_1.csv`, `Petikan_2.csv`, `Petikan_3.csv`: spektrum tiap petikan.
- `fundamental.csv`: frekuensi fundamental tiap petikan.
- `physical_parameters.csv`: parameter model.
- `cfl_summary.csv`: ringkasan eksperimen CFL.
- `cfl_amplitude.csv`: amplitudo maksimum terhadap waktu.
- `convergence_summary.csv`: RMSE dan orde konvergensi.
- `convergence_profiles.csv`: profil numerik dan analitik.
- `damped_energy.csv`: energi teredam dan tanpa redaman.
- `energy_convergence.csv`: penyimpangan energi untuk beberapa grid.

### Grafik

Grafik FFT, waveform rekaman, profil gelombang, eksperimen CFL, verifikasi solusi, evolusi energi, dan konvergensi disimpan dalam format PNG pada `results/figures/`.

### Animasi

`results/animation/damped_comparison.gif` memperlihatkan perbandingan evolusi gelombang untuk \(\gamma=0\) dan \(\gamma=15\,\mathrm{s}^{-1}\).

## Keterbatasan model

Model senar ideal mengasumsikan senar homogen, simpangan kecil, tegangan konstan, dan kedua ujung terikat. Model dasar tidak secara eksplisit memasukkan kekakuan senar, kehilangan energi, maupun kopling dengan badan gitar. Model teredam menambahkan koefisien \(\gamma\) sebagai peredaman efektif dan tidak mengidentikkannya hanya dengan gesekan udara.

Mikrofon merekam tekanan bunyi, bukan perpindahan transversal senar secara langsung. Karena kecepatan rambat dihitung menggunakan \(c=2Lf_1\), kecocokan frekuensi simulasi dengan fundamental hasil FFT merupakan pemeriksaan konsistensi, bukan validasi eksperimen independen. Validasi independen memerlukan pengukuran gerak senar dengan metode lain, misalnya metode optik.

## Penggunaan AI dan pemeriksaan hasil

AI digunakan sebagai alat bantu dalam penyusunan struktur program, penjelasan metode numerik, debugging, dan interpretasi awal hasil. Program dijalankan dan hasilnya diperiksa melalui inspeksi data audio, pola harmonik FFT, pemeriksaan kondisi batas, pengujian CFL, perbandingan dengan solusi analitik, perhitungan RMSE, serta analisis konvergensi energi. Pengguna/penulis bertanggung jawab atas pemeriksaan akhir, interpretasi, dan seluruh hasil yang diserahkan.

## Referensi tugas

Eko Sulistya, *Tugas ke-1 Setelah UTS Fisika Komputasi: Persamaan Diferensial Parsial Hiperbolik — Simulasi dan Analisis Gelombang Senar Satu Dimensi*, Departemen Fisika, FMIPA, Universitas Gadjah Mada, 2026.
