using Pandora
using Test

@testset "linked list" begin
    ll = Pandora.DoublyLinkedList{Int64}()
    
    @test length(ll) == 0
    @test ll.size == 0

    push!(ll, 42)

    @test length(ll) == 1
    @test ll.size == 1
    @test first(ll) == 42
    @test last(ll) == 42
    @test convert(Vector{Int64}, ll) == [42]

    push!(ll, 10)

    @test length(ll) == 2
    @test ll.size == 2
    @test first(ll) == 42
    @test last(ll) == 10
    @test convert(Vector{Int64}, ll) == [42, 10]
    
    @test_throws MethodError push!(ll, 10.0)

    push!(ll, 1, 2)

    @test length(ll) == 4
    @test ll.size == 4
    @test first(ll) == 42
    @test last(ll) == 2
    @test convert(Vector{Int64}, ll) == [42, 10, 1, 2]

    popped = pop!(ll)

    @test typeof(popped) == Int64
    @test length(ll) == 3
    @test ll.size == 3
    @test first(ll) == 42
    @test last(ll) == 1
    @test convert(Vector{Int64}, ll) == [42, 10, 1]
    @test popped == 2

    pushfirst!(ll, 3)

    @test length(ll) == 4
    @test ll.size == 4
    @test first(ll) == 3
    @test last(ll) == 1
    @test convert(Vector{Int64}, ll) == [3, 42, 10, 1]

    pushfirst!(ll, 100, 101, 102)

    @test length(ll) == 7
    @test ll.size == 7
    @test first(ll) == 100
    @test last(ll) == 1
    @test convert(Vector{Int64}, ll) == [100, 101, 102, 3, 42, 10, 1]

    @test_throws MethodError pushfirst!(ll, 10.0)

    popped = popfirst!(ll)

    @test typeof(popped) == Int64
    @test length(ll) == 6
    @test ll.size == 6
    @test first(ll) == 101
    @test last(ll) == 1
    @test convert(Vector{Int64}, ll) == [101, 102, 3, 42, 10, 1]
    @test popped == 100
    
    @test pop!(ll) == 1
    @test popfirst!(ll) == 101
    @test pop!(ll) == 10
    @test pop!(ll) == 42
    @test popfirst!(ll) == 102
    @test popfirst!(ll) == 3

    @test_throws ErrorException pop!(ll)
    @test_throws ErrorException popfirst!(ll)
    @test first(ll) === nothing
    @test last(ll) === nothing
    @test length(ll) == 0
    @test ll.size == 0
    @test convert(Vector{Int64}, ll) == []
end;


@testset "lru set" begin
    lru = Pandora.LRUSet{Int64}(10.0)

    Pandora.item_size(x::Int64) = convert(Float64, x)

    @test length(lru) == 0
    @test lru.size == 0.0
    @test lru.capacity == 10.0

    @test_throws ErrorException 10.0 in lru
    @test (10 in lru) == false

    popped_values = Pandora.pushpop!(lru, 10)

    @test typeof(popped_values) === Vector{Int64}
    @test popped_values == []
    @test length(lru) == 1
    @test lru.size == 10.0
    @test lru.capacity == 10.0
    @test (10 in lru) == true

    popped_values = Pandora.pushpop!(lru, 10)

    @test popped_values == []
    @test length(lru) == 1
    @test lru.size == 10.0
    @test (10 in lru) == true

    popped_values = Pandora.pushpop!(lru, 11)

    @test popped_values == [10, 11]
    @test length(lru) == 0
    @test lru.size == 0.0
    @test (11 in lru) == false
    @test (10 in lru) == false

    Pandora.pushpop!(lru, 2)
    Pandora.pushpop!(lru, 5)
    Pandora.pushpop!(lru, 3)
    Pandora.pushpop!(lru, 2)
    popped_values = Pandora.pushpop!(lru, 8)

    @test popped_values == [5, 3]
    @test length(lru) == 2
    @test lru.size == 10.0
    @test (5 in lru) == false
    @test (3 in lru) == false
    @test (2 in lru) == true
    @test (8 in lru) == true

    popped_values = Pandora.pushpop!(lru, 3)

    @test popped_values == [2, 8]
    @test length(lru) == 1
    @test lru.size == 3
    @test (3 in lru) == true
    @test (8 in lru) == false
    @test (2 in lru) == false

    Pandora.pushpop!(lru, 2)
    Pandora.pushpop!(lru, 3)
    Pandora.pushpop!(lru, 1)

    v = Vector{Int64}()
    for item in lru
        push!(v, item)
    end

    @test v == [1, 3, 2]
end;


