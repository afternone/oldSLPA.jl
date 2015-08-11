# Identify overlapping communities in social networks using Speaker-listener label propogation algorithm
# g is the graph (network)
# iteration is the number of iterations
# threshold is the threshold for post processing
function slpa{V}(g::AbstractGraph{V}; iteration::Int=20, threshold::Real=0.1, listen_rule::Symbol=:max_vote)
    if listen_rule == :max_vote
        node_memory = perform_slpa(g, iteration)
    end
    if listen_rule == :nsd
        node_memory = perform_nsdslpa(g, iteration)
    end
    post_processing!(node_memory, threshold)
    node_memory
end

# Performs SLPA algorithm
# Use multinomial sampling for speaker rule
# Use maximum vote for listener rule
function perform_slpa{V}(g::AbstractGraph{V}, T::Int)
    node_memory = Dict{Int,Int}[]
    for i=1:num_vertices(g)
        push!(node_memory, {i=>1})
    end
    for t=1:T
        order = shuffle(collect(vertices(g))) # shuffle nodes order
        for u in order
            u_idx = vertex_index(u, g)
            label_list = Dict{Int,Int}()
            for v in out_neighbors(u, g)
                label = selectkey(node_memory[vertex_index(v, g)])
                if !haskey(label_list, label)
                    label_list[label] = 1
                else
                    label_list[label] += 1
                end
            end

            # listener chose a received label to add to memory
            labels = collect(keys(label_list))
            counts = collect(values(label_list))
            maxcount = maximum(counts)
            dominant_labels = labels[counts.>=maxcount]
            selected_label = dominant_labels[rand(1:length(dominant_labels))]
            # add the selected label to the memory
            if haskey(node_memory[u_idx], selected_label)
                node_memory[u_idx][selected_label] += 1
            else
                node_memory[u_idx][selected_label] = 1
            end
        end
    end
    node_memory
end

# Performs SLPA algorithm
# Use multinomial sampling for speaker rule
# Use neighbor strength driven for listener rule
function perform_nsdslpa{V}(g::AbstractGraph{V}, T::Int)
    node_memory = Dict{Int,Int}[]
    for i=1:num_vertices(g)
        push!(node_memory, {i=>1})
    end
    for t=1:T
        order = shuffle(collect(vertices(g))) # shuffle nodes order
        for u in order
            u_idx = vertex_index(u, g)
            label_list = Dict{Int,Int}()
            for v in out_neighbors(u, g)
                label = selectkey(node_memory[vertex_index(v, g)])
                if !haskey(label_list, label)
                    label_list[label] = 1 + length(intersect(out_neighbors(u, g), out_neighbors(v, g)))
                else
                    label_list[label] += 1 + length(intersect(out_neighbors(u, g), out_neighbors(v, g)))
                end
            end

            # listener chose a received label to add to memory
            labels = collect(keys(label_list))
            counts = collect(values(label_list))
            maxcount = maximum(counts)
            dominant_labels = labels[counts.>=maxcount]
            selected_label = dominant_labels[rand(1:length(dominant_labels))]
            # add the selected label to the memory
            if haskey(node_memory[u_idx], selected_label)
                node_memory[u_idx][selected_label] += 1
            else
                node_memory[u_idx][selected_label] = 1
            end
        end
    end
    node_memory
end

# performs post processing to remove the labels that are below the threshhold
# r∈[0,1], if the probability is less than r, remove it during post processing
function post_processing!(node_memory::Vector{Dict{Int,Int}}, r::Real)
    for memory in node_memory
        tempmemory = copy(memory)
        sum_count = sum(values(memory))
        threshold = sum_count*r
        for (k,v) in memory
            if v < threshold
                delete!(memory, k)
            end
        end

        # if r is too large to lead to some node_memory empty, we will select label with the max_count
        if isempty(memory)
            selected_label = selectmaxkey(tempmemory)
            memory[selected_label] = tempmemory[selected_label]
        end
    end
end

# get all groups
function get_groups(node_memory::Vector{Dict{Int,Int}})
    groups = Dict{Int,Vector{Int}}()
    for i=1:length(node_memory)
        for k in keys(node_memory[i])
            if haskey(groups, k)
                push!(groups[k], i)
            else
                groups[k] = [i]
            end
        end
    end
    collect(values(groups))
end
