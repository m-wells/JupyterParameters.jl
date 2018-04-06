#=
    jjnbparam.jl
    Copyright © 2018 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.

    -----------------------------------------------------------------

    jjnb <= Julia Jupyter NoteBook
    
    Performs the "magic" of passing the command line args into the jjnb
    
    Does NOT execute the newly created jjnb.
    This is handled by nbconvert (see the jjnb script)
=#

import DataStructures
import JSON
using ArgParse

function find_parameters_cell(jsondict::DataStructures.OrderedDict)
    """
    search the jjnb for the cell taged with "parameters"
    """
    param_cell = Array{Int,1}(0)
    
    for (i,cell) in enumerate(jsondict["cells"])
        if haskey(cell["metadata"], "tags")
            if "parameters" in cell["metadata"]["tags"]
                push!(param_cell, i)
            end
        end
    end

    if length(param_cell) == 0
        error("Found NO cells containing the tag \"parameters\"")
    end
    if length(param_cell) > 1
        error("Found multiple cells containing the tag \"parameters\"")
    end

    return param_cell
end

function paramitify_jjnb( infile :: String
                        , args   :: AbstractArray{String,1}
                        )        :: DataStructures.OrderedDict
    """
    replace the default values with the passed values and return the jsondict
    """
    jsondict = JSON.parsefile(infile, dicttype=DataStructures.OrderedDict)
    pcellnum = find_parameters_cell(jsondict)

    pcell = view(jsondict["cells"][pcellnum][1]["source"],:)

    default_params = DataStructures.OrderedDict()
    for (i,line) in enumerate(pcell)
        if (line[1] == '#') | all(isspace,line)
            default_params[string('#',i)] = line
        else
            varname, varval = strip.(split(line, "="))
            default_params[varname] = varval
        end
    end

    s = ArgParseSettings()
    for defpar in default_params
        if defpar[1][1] != '#'
            add_arg_table( s
                         , string( "--"
                                 , defpar[1]
                                 )
                         )
        end
    end
    passed_params = parse_args(args, s)


    for (i,defpar) in enumerate(default_params)

        k = defpar[1]
        if k[1] != '#'

            v = passed_params[k]
            if v != nothing

                line = string( k
                             , " = "
                             , v
                             )

                if pcell[i][end] == '\n'
                    line = string(line, '\n')
                end

                pcell[i] = line
            end
        end
    end

    return jsondict
end

function main(args)
    """
    the top level of this program
    """
    if length(args) < 4
        msg = "Requires at least: infile outfile --var value\n"
        msg = string( msg
                    , "if you want to overwrite infile then pass:\n\t"
                    , "infile infile --var value\n"
                    )
        error(msg)
    end

    infile  = args[1]
    outfile = args[2]

    args = args[3:end]
    
    open(outfile, "w") do outf
        jsondict = paramitify_jjnb(infile, args)
        JSON.print(outf, jsondict, 1)
    end

end

main(ARGS)
