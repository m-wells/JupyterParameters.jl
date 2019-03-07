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
using Conda

####################################################################################################

function find_parameters_cell(jsondict::DataStructures.OrderedDict)
    """
    search the jjnb for the cell taged with "parameters"
    """
    param_cell = Vector{Int}(undef,0)
    
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

function paramitify_jjnb( infile        :: String
                        , passed_params :: Dict
                        )               :: DataStructures.OrderedDict
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
        elseif (line[1] == ';')
            default_params[string(';',i)] = line
        else
            varname_val = strip.(split(line, "="))
            @assert( length(varname_val) == 2
                   , string( "Expected something of the form \" var = val \" got "
                           , varname_val
                           )
                   )
            varname, varval = varname_val
            default_params[varname] = varval
        end
    end

    #s = ArgParseSettings()
    #for defpar in default_params
    #    if defpar[1] != '#'
    #        add_arg_table( s
    #                     , string( "--"
    #                             , defpar[1]
    #                             )
    #                     )
    #    end
    #end
    #passed_params = parse_args(args, s)

    for (i,defpar) in enumerate(default_params)

        k = defpar[1]
        defv = defpar[2]
        if !((k[1] == '#') || (k[1] == ';'))

            if k in keys(passed_params)
                v = passed_params[k]

                # check if we need to put quotes around the value
                if defv[1] == '"'
                    v = string('"',v,'"')
                end

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

function main(args::Vector{String})
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
    nargs = div(length(args), 2)

    s = ArgParseSettings()
    for i in 1:2:length(args)
        @show args[i]
        add_arg_table(s, args[i])
    end
    passed_params = parse_args(args, s)
    #-----------------------------------------------------------------------------------------------

    #-----------------------------------------------------------------------------------------------
    CONDASDIR=Conda.SCRIPTDIR
    jnbcommand = `$CONDASDIR/jupyter nbconvert --to notebook --execute --allow-errors`
    if "timeout" in keys(passed_params)
        timeout = passed_params["timeout"]
        delete!(passed_params, "timeout")
        jnbcommand = `$jnbcommand --ExecutePreprocessor.timeout=$timeout`
    end
    if "kernel_name" in keys(passed_params)
        kernel_name = passed_params["kernel_name"]
        delete!(passed_params, "kernel_name")
        jnbcommand = `$jnbcommand --ExecutePreprocessor.kernel_name=$kernel_name`
    end
    #-----------------------------------------------------------------------------------------------

    #-----------------------------------------------------------------------------------------------
    open(outfile, "w") do outf
        printstyled( string( "Starting paramitification of "
                           , infile
                           , "...\n")
                   , color = :orange
                   )
        jsondict = paramitify_jjnb(infile, passed_params)
        printstyled( "Successful replacement of parameters!\n"
                   , color = :green
                   )
        JSON.print( outf
                  , jsondict
                  , 1
                  )
        printstyled( string( "Wrote "
                           , outfile
                           , '\n'
                           )
                   , color = :green
                   )
    end

    printstyled( string( "Running "
                       , outfile
                       , '\n'
                       )
               , color = :orange
               )

    jnbcommand = `$jnbcommand $outfile --output $outfile`
    run(jnbcommand)
end

main(ARGS)
