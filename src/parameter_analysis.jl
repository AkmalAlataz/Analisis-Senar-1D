using Statistics
using Printf

# Fundamental hasil interpolasi FFT
f1 = [328.512, 328.516, 328.475]

# Statistik antarpetikan
f1_mean = mean(f1)
f1_std = std(f1)
f1_se = f1_std / sqrt(length(f1))

println("ESTIMASI FUNDAMENTAL")
@printf("Rata-rata       : %.6f Hz\n", f1_mean)
@printf("Simpangan baku  : %.6f Hz\n", f1_std)
@printf("Standard error  : %.6f Hz\n", f1_se)
@printf("Rentang         : %.6f Hz\n",
        maximum(f1) - minimum(f1))

# Simpan data
open("results/csv/fundamental.csv", "w") do io
    println(io, "petikan,fundamental_Hz")

    for (i, f) in enumerate(f1)
        @printf(io, "%d,%.6f\n", i, f)
    end
end