# DoublyLinkedList
Kibisis provides a doubly linked list implementation with `DoublyLinkedList{T}`. This 
data type supports fast insertion and deletion at both ends as well as fast iteration. The type parameter `T` is the type of elements in the list. 

Check out `Deque` in [DataStructures.jl](https://juliacollections.github.io/DataStructures.jl/stable/deque/) as it is likely better for your use case. This interface is primarily defined only for the implementation of `LRUSet` seen below. 

## Usage
```
using Kibisis

ll = Kibisis.DoublyLinkedList{Int64}()

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
Kibisis provides an implementation of a set using LRU semantics in `LRUSet{T}`. When the size of the set grows larger than the set's capcity items are vacated. Insertion, membership queries, and iteration in order of most recently used are all fast. The type parameter `T` is the type of the elements in the set. 

## Usage
```
using Kibisis

lru = Kibisis.LRUSet{Int64}(3) # Creates an LRUSet with capacity 3

Kibisis.pushpop!(lru, 1) # Inserts 1
Kibisis.pushpop!(lru, 2) # Inserts 2
Kibisis.pushpop!(lru, 3) # Inserts 3
Kibisis.pushpop!(lru, 1) # Moves 1 to being recently used

popped_items::Vector{Int64} = Kibisis.pushpop!(lru, 4) # Inserts 4, vacates 2

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
By default the size of an item in the set is 1. However you can customize that behavior by adding a method to `Kibisis.item_size(x)` for your type of element. The method should take in the item and return a `Float64` object corresponding to its size. This value should not change over the lifetime of the object in the `LRUSet`. 

```
using Kibisis

Kibisis.item_size(x::Int64) = convert(Float64, x)

lru = Kibisis.LRUSet{Int64}(3) # Creates an LRUSet with capacity 3

Kibisis.pushpop!(lru, 1)
popped_items = Kibisis.pushpop!(lru, 4)

popped_items == [1, 4] # true
```
Note that multiple items can be evicted at once because of the custom `item_size` method. Also note that they are evicted in order of least recently used. Finally note that the inserted item may be evicted in the same call to `pushpop!` if its size is larger than the `LRUSet`'s capacity. 

One can also add methods to `on_new_push(x)`, `on_old_push(x)`, and `on_pop(x)` that do some kind of mutating operation (perhaps the creation and deletion of files on disk). These methods are executed on the items going into or leaving the `LRUSet`. `on_new_push` is executed when an item is used that is not currently in the `LRUSet`, and `on_old_push` is executed when the item already exists. By default all three of these do nothing. 

It is worth noting that `on_new_push` is executed before computation of `item_size` and `on_pop` is executed after. This makes it easy to use `LRUSet` to implement a file system cache in which the set only contains the names of files. One would define `item_size` to return the size of those files, `on_new_push` to create the file, and `on_pop` to delete the file. (consider what would happen if you ran `item_size` before creating the file or after deleting the file)

Finally each of `on_new_push`, `on_old_push`, and `on_pop` can take in a variable amount of additional arguments to aid in their mutating operations. These arguments are then passed in as additonal arguments to `pushpop!` and will be propogated to these other methods. Note that if you use additional arguments for even one of the above, you will need to specify them in the signature of any others that you define even if the arguments are not used. In the example of creating a file system cache one would pass the file name as well as the file contents to `pushpop!`. Those file contents would be used in `on_new_push` (to write the file), but would not be used in `on_pop`. `on_old_push` would not need to be defined for this use case. 

It is worth noting that the additional arguments passed to `pushpop!` are not saved and so when an item is popped, `on_pop` is called with the current additional arguments. **Not** the arguments that were passed when that item was first placed into the `LRUSet`. 

