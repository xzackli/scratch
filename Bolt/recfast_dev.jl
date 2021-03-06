using DelimitedFiles
using PyPlot
cd("test")

recfastdata = readdlm("data/test_recfast_1.dat", ',', Float64, '\n', header=true)[1]
zā, Xe = recfastdata[:,1], recfastdata[:,2]

# clf()
# plot(z, Xe, "-", label=raw"$X_e$")
# legend()
# gcf()

##
using Bolt
š” = CosmoParams(Ī£m_Ī½ = 0.0, N_Ī½ = 3.0)
bg = Background(š”)
š£ = Bolt.RECFAST(bg=bg, Yp=š”.Y_p, OmegaB=š”.Ī©_b)
# š£ = Bolt.Peebles()
ih = IonizationHistory(š£, š”, bg);


##
Nz = 1000
xe_bespoke, Tmat = Bolt.recfast_xe(š£; Nz=Nz, zinitial=10000., zfinal=0.);

# zā = 10000.0-10.0:-10.0:0.0
dz = (0. - 10000.)/float(Nz)
zā = (10000. + dz):(dz):0.0

clf()
plot(zā, Tmat, "-", label=raw"$T_{\mathrm{mat}}$")
plot(zā, š£.Tnow .* (1 .+ zā), "--", label=raw"$T_{\mathrm{rad}}$")

yscale("log")
xscale("log")
legend()
ylim(1, 2e4)
xlim(10, 10000)
xlabel("redshift")
ylabel("temperature [K]")
gcf()

##
clf()
plot(zā, Tmat ./ (š£.Tnow .* (1 .+ zā)), "-")
xscale("log")
legend()
xlim(10, 10000)
xlabel("redshift")
ylabel(raw"$T_{\mathrm{mat}} \, / \, T_{\mathrm{rad}}$")
gcf()

##

clf()
# plot(zā, Xe ./ xe_bespoke , "-", label=raw"RECFAST / recfast.jl")
plot(zā, Xe ./ ih.Xā.(z2x.(zā)) , "-", label=raw"RECFAST / recfast.jl")
ylim(1 - 0.01, 1 + 0.01)

# plot(z, Xe , "-")
# plot(z, xe_bespoke, "--")
xlabel(raw"redshift")
legend()
gcf()


##

clf()
x_grid = bg.x_grid
fig, ax = subplots(1,2,figsize=(10,5))
ax[1].plot(x_grid, ih.Ļ.(x_grid), "-", label=raw"$\tau$")
ax[1].plot(x_grid, abs.(ih.Ļā².(x_grid)), "--", label=raw"$|\tau^\prime|$")
ax[2].plot(x_grid, ih.gĢ.(x_grid), "-", label=raw"$\tilde{g}$")
ax[2].plot(x_grid, ih.gĢā².(x_grid) ./ 10, "--", label=raw"$\tilde{g}\prime/10$")
ax[2].plot(x_grid, ih.gĢā²ā².(x_grid) ./ 300, "--", label=raw"$\tilde{g}\prime/300$")
ax[1].set_yscale("log")
ax[1].legend()
ax[1].set_xlabel(raw"$x$")
ax[2].set_xlim(-8.0, -6.0)
ax[2].set_ylim(-3.5, 5.5)
ax[2].legend()
ax[2].set_xlabel(raw"$x$")
tight_layout()
gcf()


##
using UnitfulAstro, NaturallyUnitful
xā = let z = 100.0
    Hz = š£.HO * sqrt((1+z)^4/(1+š£.z_eq)*š£.OmegaT + š£.OmegaT*(1+z)^3 + š£.OmegaK*(1+z)^2 + š£.OmegaL)
    (š£.HO^2 /2/Hz)*(4*(1+z)^3/(1+š£.z_eq)*š£.OmegaT + 3*š£.OmegaT*(1+z)^2 + 2*š£.OmegaK*(1+z))
end

##
xā = let z = 100.0
    H0_natural_unit_conversion = ustrip(u"s", unnatural(u"s", 1u"eV^-1"))

    a = 1 / (1+z)  # scale factor
    x_a = a2x(a)
	Hz = š£.bg.ā(x_a) / a / š£.H0_natural_unit_conversion
	dHdz = (-š£.bg.āā²(x_a) + š£.bg.ā(x_a)) / š£.H0_natural_unit_conversion
end

##
let z = 0.0
    a = 1.0
    x_a = a2x(a)
    H0_natural_unit_conversion = ustrip(u"s", unnatural(u"s", 1u"eV^-1"))
	Hz = š£.bg.Hā / š£.H0_natural_unit_conversion
end

##

š£.HO


##



##
