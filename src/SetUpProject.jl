
module SetUpProject
import Pkg, LibGit2
const PATH_SEPARATOR = joinpath("_", "_")[2]

# Misc functions for kw-macros
convert_to_kw(ex::Expr) = Expr(:kw,ex.args...)
convert_to_kw(ex) = error("invalid keyword argument syntax \"$ex\"")

# Pure Julia implementation
include("project_setup.jl")
include("naming.jl")
include("saving_tools.jl")

using UnPack
export @pack!, @unpack

# Functionality that saves/loads
using FileIO
export save, load
export wsave, wload

_wsave(filename, data...; kwargs...) = FileIO.save(filename, data...; kwargs...)

"""
    wsave(filename, data...; kwargs...)

Save `data` at `filename` by first creating the appropriate paths.
Default fallback is `FileIO.save`. Extend this for your types
by extending `SetUpProject._wsave(filename, data::YourType...; kwargs...)`.
"""
function wsave(filename, data...; kwargs...)
    mkpath(dirname(filename))
    return _wsave(filename, data...; kwargs...)
end

"Currently equivalent with `FileIO.load`."
wload(data...; kwargs...) = FileIO.load(data...; kwargs...)

include("saving_files.jl")
include("dict_list.jl")

# Functionality that requires Dataframes and other heavy dependencies:
using Requires
function __init__()
    @require DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0" begin
        include("result_collection.jl")
    end
end

# Update messages
const display_update = true
const update_version = "1.0.0"
const update_name = "update_v$update_version"
if display_update
if !isfile(joinpath(@__DIR__, update_name))
printstyled(stdout,
"""
\nVersion message: SetUpProject v$update_version

This code is a customized version of DrWatson Pkg v2.0.0

\n
"""; color = :light_magenta)
touch(joinpath(@__DIR__, update_name))
end
end

end
