
using Printf

# Parameter eksperimen
L = 0.658
f1 = 328.501

# Massa asumsi
m = 0.0225

# Parameter turunan
mu = m / L
c = 2 * L * f1
T = mu * c^2

println("PARAMETER FISIKA SENAR")
@printf("Panjang bebas       : %.6f m\n", L)
@printf("Massa asumsi        : %.6f kg\n", m)
@printf("Massa linear        : %.8f kg/m\n", mu)
@printf("Fundamental         : %.6f Hz\n", f1)
@printf("Kecepatan rambat    : %.6f m/s\n", c)
@printf("Tegangan            : %.4f N\n", T)

# Menyimpan parameter
open("results/csv/physical_parameters.csv", "w") do io
    println(io, "parameter,value,unit,status")
    println(io, "L,$L,m,pengukuran")
    println(io, "m,$m,kg,asumsi")
    println(io, "mu,$mu,kg/m,turunan")
    println(io, "f1,$f1,Hz,FFT")
    println(io, "c,$c,m/s,turunan")
    println(io, "T,$T,N,turunan")
end