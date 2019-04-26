#=
    runtest
    Copyright © 2019 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the AGPL-3.0 license.
=#

using Test
using JSON
using DataStructures
using IJulia

using JupyterParam

origfile = (@__DIR__)*"/origfile.ipynb"
outfile  = (@__DIR__)*"/outfile.ipynb"

function get_source( jsondict :: OrderedDict
                   , cell     :: Integer
                   )
    return jsondict["cells"][cell]["source"]
end

function get_outputs( jsondict :: OrderedDict
                    , cell     :: Integer
                    )
    return jsondict["cells"][cell]["outputs"][1]["data"]["text/plain"][1]
end

function get_kernel()
    return JupyterParam.get_kernels()[1]
end

function change_kernel(jsondict :: OrderedDict) 
    jsondict["metadata"]["kernelspec"]["name"] = get_kernel()
    return jsondict
end

@testset "testing JupyterParam" begin

    origdict = change_kernel(JSON.parsefile(origfile, dicttype=OrderedDict))
    open(origfile, "w") do outf
        JSON.print(outf, origdict, 1)
    end

    deleteat!(ARGS,eachindex(ARGS))

    origcell1 = get_source(origdict,1)
    origcell2 = get_source(origdict,2)
    origcell3 = get_source(origdict,3)
    x = "y"
    y = "7"
    xy = "2"

    push!(ARGS, origfile, outfile)
    push!(ARGS,"--x",x)
    push!(ARGS,"--y",y)
    push!(ARGS,"--xy",xy)
    jjnbparam()
    
    outdict = JSON.parsefile(outfile, dicttype=OrderedDict)
    
    origcell = get_source(origdict,1)
    outcell  = get_source(outdict,1)

    @test outcell[1] == string("x = \"$x\"\n")
    @test outcell[2] == string("y = $y\n")
    @test outcell[3] == string("xy = $xy")

    outcell  = get_outputs(outdict,2)
    @test outcell == "9"

    outcell  = get_outputs(outdict,3)
    @test outcell == "\"y\""

    @test origcell1 == get_source(origdict,1)
    @test origcell2 == get_source(origdict,2)
    @test origcell3 == get_source(origdict,3)
end

@testset "jupyter nb extensions" begin
    x = "y"

    deleteat!(ARGS,eachindex(ARGS))
    push!(ARGS, origfile, outfile)
    push!(ARGS,"--x",x)
    push!(ARGS,"--kernel_name",get_kernel())
    push!(ARGS,"--timeout","-1")
    jjnbparam()

    outdict = JSON.parsefile(outfile, dicttype=OrderedDict)
    outcell  = get_source(outdict,1)
    @test outcell[1] == string("x = \"$x\"\n")
end

@testset "error testing" begin
    x = "y"

    deleteat!(ARGS,eachindex(ARGS))
    push!(ARGS, origfile, outfile)
    push!(ARGS,"--x",x)
    push!(ARGS,"--kernel_name","ajnkfnq234iqnwerht")
    @testthrows jjnbparam()
end
