using Healpix
using Healpix: udgrade
import Healpix: saveToFITS 
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
    mapdir = "/tigress/zequnl/planck/maps/"
    cols = [process_map(i, nside_out, mapdir, fname) for i in 1:10]
    hp.fitsfunc.write_map("data/plancklowres/nside$(nside_out)_$(fname)", cols, nest=true, overwrite=true)
end

## write masks
for s in ("1", "2"), f in ("100", "143", "217"), type in ("temperature", "polarization")
    fname = "COM_Mask_Likelihood-$(type)-$(f)-hm$(s)_2048_R3.00.fits"
    mapdir = "/tigress/zequnl/planck/masks/"

    cols = udgrade(readMapFromFITS(joinpath(mapdir,fname), 1, Float64), nside_out).pixels
    hp.fitsfunc.write_map("data/plancklowres/nside$(nside_out)_$(fname)", cols, nest=false, overwrite=true)
end


##
function test_read_map(fname, col=1)
    m = readMapFromFITS(fname, col, Float64)
end


println("testing...")
for s in ("1", "2"), f in ("100", "143", "217")
    fname = "HFI_SkyMap_$(f)_2048_R3.01_halfmission-$(s).fits"
    test_read_map("data/plancklowres/nside$(nside_out)_$(fname)", 1)
    test_read_map("data/plancklowres/nside$(nside_out)_$(fname)", 2)
    test_read_map("data/plancklowres/nside$(nside_out)_$(fname)", 3)
end
for s in ("1", "2"), f in ("100", "143", "217"), type in ("temperature", "polarization")
    fname = "COM_Mask_Likelihood-$(type)-$(f)-hm$(s)_2048_R3.00.fits"
    test_read_map("data/plancklowres/nside$(nside_out)_$(fname)")
end


##
cd("data")
run(`tar -zcvf plancklowres.tar.gz plancklowres`)
filename = "plancklowres.tar.gz"
##
using Tar, Inflate, SHA
println("sha256: ", bytes2hex(open(sha256, filename)))
println("git-tree-sha1: ", Tar.tree_hash(IOBuffer(inflate_gzip(filename))))


##
# plot(mI, clim=(-1e-3,1e-3))

# ##
# m1 = readMapFromFITS("data/plancklowres/nside256_HFI_SkyMap_100_2048_R3.01_halfmission-1.fits", 1, Float64)
# m2 = readMapFromFITS("data/plancklowres/nside256_HFI_SkyMap_100_2048_R3.01_halfmission-2.fits", 1, Float64)
# plot(m1 - m2, clim=(-2e-5,2e-5))

