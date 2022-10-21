module Kibisis

################### using statements #####################


################### LRU Types ########################
"""
The building block of the `DoublyLinkedList` and by extension the `LRUSet`
"""
mutable struct Node{T}
    prev::Union{Node{T}, Nothing}
    next::Union{Node{T}, Nothing}
    const val::T
end

"""
An implementation of a double linked list with some unsafe operations that are 
utilized for an efficient implementation of `LRUSet`
"""
mutable struct DoublyLinkedList{T}
    first::Union{Node{T}, Nothing}
    last::Union{Node{T}, Nothing}
    size::Int64

    DoublyLinkedList{T}() where T = new(nothing, nothing, 0)
end

"""
A least-recently-used cache that keeps its `size` less than or equal 
to its `capacity`. The size of an item is determined by defining 
methods for `item_size` that return `Float64`
"""
mutable struct LRUSet{T}
    linked_list::DoublyLinkedList{T}
    hash_map::Dict{T, Node{T}}
    size::Float64
    const capacity::Float64

    LRUSet{T}(capacity) where T = new(DoublyLinkedList{T}(), Dict{T, Node{T}}(), 0, capacity)
end

################## DoublyLinkedList implementation #################
Base.length(linked_list::DoublyLinkedList) = linked_list.size

set_next!(::Nothing, ::Union{Node, Nothing}) = nothing
set_next!(node::Node{T}, to::Union{Node{T}, Nothing}) where T = node.next = to; nothing 

set_prev!(::Nothing, ::Union{Node, Nothing}) = nothing
set_prev!(node::Node{T}, to::Union{Node{T}, Nothing}) where T = node.prev = to; nothing

set_last_and_conditionally_first!(linked_list::DoublyLinkedList{T}, to::Union{Node{T}, Nothing}) where T = begin
    if length(linked_list) == 0
        linked_list.first = to
    end
    linked_list.last = to
    nothing
end

set_first_and_conditionally_last!(linked_list::DoublyLinkedList{T}, to::Union{Node{T}, Nothing}) where T = begin
    if length(linked_list) == 0
        linked_list.last = to
    end
    linked_list.first = to
    nothing
end

Base.push!(linked_list::DoublyLinkedList{T}, item::T) where T = begin
    item_node = Node(linked_list.last, nothing, item)
    set_next!(linked_list.last, item_node)
    set_last_and_conditionally_first!(linked_list, item_node)
    linked_list.size += 1
    linked_list
end

Base.push!(linked_list::DoublyLinkedList{T}, items::Vararg{T}) where T = begin
    for i in items
        push!(linked_list, i)
    end
    linked_list
end

Base.pushfirst!(linked_list::DoublyLinkedList{T}, item::T) where T = begin
    item_node = Node(nothing, linked_list.first, item)
    set_prev!(linked_list.first, item_node)
    set_first_and_conditionally_last!(linked_list, item_node)
    linked_list.size += 1
    linked_list
end

Base.pushfirst!(linked_list::DoublyLinkedList{T}, items::Vararg{T}) where T = begin
    for i in length(items):-1:1
        pushfirst!(linked_list, items[i])
    end
    linked_list
end

"""
A hidden version of `pushfirst!` that returns the underlying node rather than the 
list and thereby breaking the abstraction. Useful for when you want to store the created node 
in another data structure for lookup. This is dangerous if you don't know what you are doing.
"""
_pushfirst!(linked_list::DoublyLinkedList{T}, item::T) where T = begin
    item_node = Node(nothing, linked_list.first, item)
    set_prev!(linked_list.first, item_node)
    set_first_and_conditionally_last!(linked_list, item_node)
    linked_list.size += 1
    item_node
end

"""
A hidden version of `pushfirst!` that uses a properly extricated node as
the insert value. The node must have already been properly extricated with 
a call to `unsafe_pop!`. This is dangerous if you don't know what you are doing. 
Returns `nothing`
"""
_pushfirst!(linked_list::DoublyLinkedList{T}, node::Node{T}) where T = begin
    node.prev = nothing
    node.next = linked_list.first
    set_prev!(linked_list.first, node)
    set_first_and_conditionally_last!(linked_list, node)
    linked_list.size += 1
    nothing
end

Base.pop!(linked_list::DoublyLinkedList) = begin
    length(linked_list) > 0 || error("cannot pop from an empty list")
    popped_node = linked_list.last
    linked_list.size -= 1
    set_next!(popped_node.prev, nothing)
    set_last_and_conditionally_first!(linked_list, popped_node.prev)
    popped_node.val
end

Base.popfirst!(linked_list::DoublyLinkedList) = begin
    length(linked_list) > 0 || error("cannot pop from an empty list")
    popped_node = linked_list.first
    linked_list.size -= 1
    set_prev!(popped_node.next, nothing)
    set_first_and_conditionally_last!(linked_list, popped_node.next)
    popped_node.val
end

Base.first(linked_list::DoublyLinkedList) = begin
    linked_list.first isa Node ? linked_list.first.val : nothing 
end

Base.last(linked_list::DoublyLinkedList) = begin
    linked_list.last isa Node ? linked_list.last.val : nothing
end

"""
Pops the `node` out of the `linked_list`. The `node` must be in `linked_list`. 
This is not checked and is potentially dangerous. Returns `nothing`.
""" 
unsafe_pop!(linked_list::DoublyLinkedList{T}, node::Node{T}) where T = begin
    length(linked_list) > 0 || error("node cannot possibly belong to list")
    linked_list.size -= 1
    if linked_list.first === node 
        set_prev!(node.next, nothing)
        set_first_and_conditionally_last!(linked_list, node.next)  
    elseif linked_list.last === node
        set_next!(node.prev, nothing)
        set_last_and_conditionally_first!(linked_list, node.prev)
    else
        length(linked_list) > 2 || error("node cannot possibly belong to list")
        set_prev!(node.next, node.prev)
        set_next!(node.prev, node.next)
    end
    nothing
end

"""
Takes `node` that must be in `linked_list` and moves the `node` to the front 
of the `linked_list`. This is done without creating a new `Node`. The membership 
condition is not checked and is therefore dangerous if you don't know what you are doing. 
Returns `nothing`
"""
unsafe_move_to_front!(linked_list::DoublyLinkedList{T}, node::Node{T}) where T = begin
    unsafe_pop!(linked_list, node)
    _pushfirst!(linked_list, node)
    nothing
end

Base.iterate(iter::DoublyLinkedList) = begin
    length(iter) != 0 ? (iter.first.val, iter.first) : nothing
end

Base.iterate(iter::DoublyLinkedList{T}, state::Node{T}) where T = begin
    state !== iter.last ? (state.next.val, state.next) : nothing
end

Base.convert(::Type{Vector{T}}, linked_list::DoublyLinkedList{T}) where T = begin
    v = Vector{T}(undef, length(linked_list))
    i = 1
    for item in linked_list
        v[i] = item
        i += 1
    end
    v
end


########################## LRU implementation ########################
Base.length(lru::LRUSet) = length(lru.linked_list)

Base.in(item::T, lru::LRUSet{T}) where T = item in keys(lru.hash_map)
Base.in(::U, ::LRUSet{T}) where {T, U} = error("$U is not the element type. $T is")

"""
Maps an item that is put in an `LRUSet` to a `Float64`
that represents the size it adds to the cache. Define this 
method for your own types if you need something different than `1.0`
"""
item_size(::Any) = 1.0

"""
Function executes on item when it enters LRUSet and was not there before. 
Executes before size of cache is updated.
"""
on_new_push(::Any) = nothing

"""
Function executes on item when it is used in an LRUSet when it already existed
"""
on_old_push(::Any) = nothing

"""
Function executes on item when it is removed from the LRUSet (before any other removals).
Executes before size of cache is updated
"""
on_pop(::Any) = nothing

"""
Pushes `item` into the `LRUSet` (potentially pushing `size` over `capacity` temporarily), 
and then removes items until capacity constraint is met (possibly removing the `item` just 
pushed in). Returns a `Vector` of the vacated items. First item in the `Vector` is the first
item vacated (i.e earlier in the `Vector` means less recently used). If the `item` already exists
then it is moved to the front of the `LRUSet`. 
"""
pushpop!(lru::LRUSet{T}, item::T) where T = begin
    # Check if item already exists
    if item in keys(lru.hash_map)
        unsafe_move_to_front!(lru.linked_list, lru.hash_map[item])
        on_old_push(item)
        return Vector{T}()
    end
    
    # Push item into linked list and hash map
    item_node = _pushfirst!(lru.linked_list, item)
    push!(lru.hash_map, item => item_node)
    on_new_push(item)
    lru.size += item_size(item)
    

    # Remove items from the cache to meet capacity
    removed_items = Vector{T}()
    while lru.size > lru.capacity 
        popped_item = pop!(lru.linked_list)
        pop!(lru.hash_map, popped_item)
        push!(removed_items, popped_item)
        on_pop(popped_item)
        lru.size -= item_size(popped_item)
    end
    
    removed_items
end

Base.iterate(iter::LRUSet) = begin
    iterate(iter.linked_list)
end

Base.iterate(iter::LRUSet{T}, state::Node{T}) where T = begin
    iterate(iter.linked_list, state)
end


end

