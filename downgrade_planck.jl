using Healpix
using Healpix: udgrade
import Healpix: saveToFITS 
using CFITSIO
using PyCall
hp = pyimport("healpy")

nside_out = 256

mkpath("data/plancklowres")

##  remove some weird pixels from the pixel cov 
function process_map(i, nside_out, mapdir, fname)
    m = readMapFromFITS(joinpath(mapdir,fname), i, Float64)
    if i ∈ (8, 10)
        bad = (m .> 1e-6) .| (m .< 0.0)
        m[bad] .= Healpix.UNSEEN
        println("bad", sum(bad))
    end
    udgrade(m, nside_out).pixels
end

## write maps
for s in ("1", "2"), f in ("100", "143", "217")
    fname = "HFI_SkyMap_$(f)_2048_R3.01_halfmission-$(s).fits"
    mapdir = "/tigress/zequnl/planck18/maps/"
    cols = [process_map(i, nside_out, mapdir, fname) for i in 1:10]
    hp.fitsfunc.write_map("data/plancklowres/nside$(nside_out)_$(fname)", cols, nest=true, overwrite=true)
end

## write masks
for s in ("1", "2"), f in ("100", "143", "217"), type in ("temperature", "polarization")
    fname = "COM_Mask_Likelihood-$(type)-$(f)-hm$(s)_2048_R3.00.fits"
    mapdir = "/tigress/zequnl/planck18/masks/"

    cols = udgrade(readMapFromFITS(joinpath(mapdir,fname), 1, Float64), nside_out).pixels
    hp.fitsfunc.write_map("data/plancklowres/nside$(nside_out)_$(fname)", cols, nest=true, overwrite=true)
end


##
# plot(mI, clim=(-1e-3,1e-3))

# ##
# m1 = readMapFromFITS("data/plancklowres/nside256_HFI_SkyMap_100_2048_R3.01_halfmission-1.fits", 1, Float64)
# m2 = readMapFromFITS("data/plancklowres/nside256_HFI_SkyMap_100_2048_R3.01_halfmission-2.fits", 1, Float64)
# plot(m1 - m2, clim=(-2e-5,2e-5))

