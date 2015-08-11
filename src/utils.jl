# read groups from file
function grpread(filename)
    groups = Vector{Int}[]
    f = open(filename, "r")
    for ll in eachline(f)
        push!(groups, [parse(Int, i) for i in split(chomp(ll))])
    end
    groups
end

# write groups to file
function grpwrite(filename, groups::Vector{Vector{Int}})
    f = open(filename, "w")
    for i=1:length(groups)
        for j=1:length(groups[i])-1
            print(f, groups[i][j],' ')
        end
        print(f, groups[i][end],'\n')
    end
    close(f)
end

# read membership from file
function mspread(filename)
    membership = Dict{Int, Vector{Int}}()
    f = open(filename, "r")
    for ll in eachline(f)
        entries = [parse(Int, i) for i in split(chomp(ll))]
        membership[entries[1]] = entries[2:end]
    end
    membership
end

# write membership to file
function mspwrite(filename, membership::Dict{Int, Vector{Int}})
    f = open(filename, "w")
    for k in sort(collect(keys(membership)))
        print(f, k, '\t')
        for j=1:length(membership[k])-1
            print(f, membership[k][j], ' ')
        end
        print(f, membership[k][end], '\n')
    end
    close(f)
end

# transform membership to groups
function msp2grp(membership::Dict{Int, Vector{Int}})
    groups = Dict{Int, Vector{Int}}()
    for (k,v) in membership
        for i in v
            if haskey(groups, i)
                push!(groups[i], k)
            else
                groups[i] = [k]
            end
        end
    end
    collect(values(groups))
end

# transform groups to membership
function grp2msp1(groups::Vector{Vector{Int}})
    membership = Dict{Int, Vector{Int}}()
    for i=1:length(groups)
        for j=1:length(groups[i])
            if haskey(membership, groups[i][j])
                push!(membership[groups[i][j]], i)
            else
                membership[groups[i][j]] = [i]
            end
        end
    end
    membership
end

# calculate the entropy of a probility distribution
function entropy(P::Vector{Float64})
    H = 0.0
    for i=1:length(P)
        # treat 0*log(0) as being equal to zero
        H += P[i] > 0.0 ? P[i]*log(P[i]) : 0.0
    end
    -H > 0 ? -H : 0.0
end

# select an index with probility proportion to it's frequency
function selectindex(a::Vector{Int})
    c = a[:]
    sumc = c[1]
    for i=2:length(c)
        sumc += c[i]
        c[i] += c[i-1]
    end
    r = rand()*sumc
    for i=1:length(c)
        if r<c[i]
            return i
        end
    end
end

# select a key from Dict with probility proportion to it's values (frequency)
function selectkey{K}(label_list::Dict{K,Int})
    k = collect(keys(label_list))
    c = collect(values(label_list))
    N = length(c)
    if N == 1
        return k[1]
    end
    sumc = c[1]
    for i=2:N
        sumc += c[i]
        c[i] += c[i-1]
    end
    r = rand()*sumc
    for i=1:N
        if r<c[i]
            return k[i]
        end
    end
end

# select the most frequency key from the Dict
function selectmaxkey{K}(label_list::Dict{K,Int})
    labels = collect(keys(label_list))
    counts = collect(values(label_list))
    maxcount = maximum(counts)
    dominant_labels = labels[counts.>=maxcount]
    selected_label = dominant_labels[rand(1:length(dominant_labels))]
end
