# DoublyLinkedList
Pandora provides a doubly linked list implementation with `DoublyLinkedList{T}`. This 
data type supports fast insertion at both ends as well as fast iteration. The type parameter `T` is the type of elements in the list. 

## Usage
```
using Pandora

ll = Pandora.DoublyLinkedList{Int64}()

push!(ll, 10) # Adds 10 to the back of the list
length(ll) # Returns 1, the number of items in the list
pushfirst!(ll, 5) # Adds 5 to the front of the list
first(ll) # Returns 5, the first element in the list
last(ll) # Returns 10, the last element in the list
pop!(ll) # Returns 10, the last element of the list, and removes it
popfirst!(ll) # Returns 5, the first element of the list, and removes it

push!(ll, 1, 2, 3) # Adds multiple items to the end of the list
pushfirst!(ll, 4, 5, 6) # Adds multiple items to the beginning of the list

# Print every item in the list (in this case 4, 5, 6, 1, 2, 3)
for item in ll
    println(item)
end
```

# LRUSet
Pandora provides an implementation of a set using LRU semantics in `LRUSet{T}`. When the size of the set grows larger than the set's capcity items are vacated. Insertion, membership queries, and iteration in order of most recently used are all fast. The type parameter `T` is the type of the elements in the set. 

## Usage
```
using Pandora

lru = Pandora.LRUSet{Int64}(3) # Creates an LRUSet with capacity 3

Pandora.pushpop!(lru, 1) # Inserts 1
Pandora.pushpop!(lru, 2) # Inserts 2
Pandora.pushpop!(lru, 3) # Inserts 3
Pandora.pushpop!(lru, 1) # Moves 1 to being recently used

popped_items::Vector{Int64} = Pandora.pushpop!(lru, 4) # Inserts 4, vacates 2

popped_items == [2] # true
2 in lru # false
4 in lru # true

# Print every item in order of most recently used. In this case (4, 1, 3)
for item in lru
    println(item)
end

length(lru) # Returns 3, the number of elements in the set
```

## Advanced Usage
By default the size of an item in the set is 1. However you can customize that behavior by adding a method to `Pandora.item_size(x)` for your type of element. The method should take in the item and return a `Float64` object corresponding to its size.

```
using Pandora

Pandora.item_size(x::Int64) = convert(Float64, x)

lru = Pandora.LRUSet{Int64}(3) # Creates an LRUSet with capacity 3

Pandora.pushpop!(lru, 1)
popped_items = Pandora.pushpop!(lru, 4)

popped_items == [1, 4] # true
```
Note that multiple items can be evicted at once because of the custom `item_size` method. Also note that they are evicted in order of least recently used. Finally note that the inserted item may be evicted in the same call to `pushpop!` if its size is larger than the `LRUSet`'s capacity. 