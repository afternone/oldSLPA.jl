module SLPA

using Graphs

export
    slpa,
    perform_slpa,
    post_processing!,
    get_groups,
    overlapnmi,
    msp2grp,
    grpread,
    grpwrite,
    mspread,
    mspwrite

include("slpafunc.jl")
include("utils.jl")
include("overlapnmi.jl")

end # module
