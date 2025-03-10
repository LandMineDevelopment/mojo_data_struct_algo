from collections import Optional
from memory import UnsafePointer



trait FormattableCollectionElement(Writable, WritableCollectionElement, EqualityComparable):
    ...

@value
struct LinkedList[T: FormattableCollectionElement]:
    var tail: UnsafePointer[LinkedList[T]]
    var head: Optional[T]

    fn __init__(out self):
        self.tail = UnsafePointer[LinkedList[T]]()
        self.head = Optional[T](None)
        # print('init empty')
        
    
    fn __init__(out self, head: T):
        self.tail = UnsafePointer[LinkedList[T]]()
        self.head = head
        # print('init:', head)

    fn __init__(out self, owned *values: T):
        self.head = Optional[T](values[0])
        self.tail = UnsafePointer[LinkedList[T]].alloc(1)
        # print('init:', values[0])

        var curr = UnsafePointer.address_of(self.tail[])
        for i in range(1,len(values)-1):
            curr.init_pointee_move(LinkedList[T](values[i]))
            curr[].tail = UnsafePointer[LinkedList[T]].alloc(1)
            curr = UnsafePointer.address_of(curr[].tail[])

        curr.init_pointee_move(LinkedList[T](values[len(values)-1]))

                
    fn __init__(out self, head: Optional[T]):
        self.tail = UnsafePointer[LinkedList[T]]()
        self.head = head
        # print('init opt:', head.value())
    
    fn __init__(out self, head: T, owned tail: LinkedList[T]):
        self.tail = UnsafePointer[LinkedList[T]].alloc(1)
        self.tail.init_pointee_move(tail^)
        self.head = Optional(head)
        # print('init head:', head,', tail:')

    fn __del__(owned self):
        if self.tail:
            self.tail.destroy_pointee()
            self.tail.free()
        # if self.head: print('del',self.head.value()) else: print('del: none')
    
    fn __len__(self) -> Int:
        if not self.tail:
            return 1
        else:
            return 1 + len(self.tail[])

    fn __getitem__(ref self, idx: Int) -> ref[self.head] Optional[T]:
        debug_assert(0 == idx or (0 <= idx and self.tail), 'index out of bounds')
        if idx == 0:
            return self.head
        else:
            return self.tail[][idx-1]
                
    fn __str__(self) -> String:
        return String.write(self)
    
    fn write_to[W: Writer](self, mut writer: W):
        writer.write('[')
        if self[0]:
            writer.write(self[0].value())
        else:
            writer.write('None')
        for i in range(1,len(self)):
            if self[i]:
                writer.write(', ', self[i].value())
            else:
                writer.write(', ', 'None')
        writer.write(']')

    fn reverse(mut self): 
        var tmp: LinkedList[T]
        if self.tail:
            tmp = self.pop_head() 
        else:
            tmp = LinkedList[T]()

        while self.tail:
            var val = self.pop_head()
            print('head:', val)
            tmp.prepend(val^) 
        tmp.prepend(LinkedList[T](self.head))
        
        self = tmp^

    fn append(mut self, owned val: LinkedList[T]):
        if not self.tail:
            self.tail = UnsafePointer[LinkedList[T]].alloc(1)
            self.tail.init_pointee_move(val^)
        else:
            self.tail[].append(val^)

    fn append(mut self, owned val: T):
        if not self.tail:
            self.tail = UnsafePointer[LinkedList[T]].alloc(1)
            self.tail.init_pointee_move(LinkedList[T](val))
        elif not self.tail[].head:
            self.tail.init_pointee_move(LinkedList[T](val))
        else:
            self.tail[].append(val)
    
    fn prepend(mut self, owned val: LinkedList[T]):
        val.append(self)
        self = val^
    
    fn prepend(mut self, owned val: T):
        self = LinkedList[T](val, self)

    fn insert(mut self, idx: Int, val: T):
        debug_assert(0 == idx or (0 <= idx and self.tail), 'index out of bounds')
        if idx == 0:
            var tmp = self
            self = LinkedList[T](val)
            self.append(tmp)
        else:
            self.tail[].insert(idx-1, val) 

    fn pop_head(mut self) -> LinkedList[T]:
        if not self.tail:
            return self
        
        var tmp = LinkedList[T](self.head)
        
        if self.tail:
            self.head = self.tail[].head
            self.tail = self.tail[].tail
        else:
            self.head = Optional[T](None)
        
        return tmp^ 

    fn pop_end(mut self) -> LinkedList[T]:
        if not self.tail:
            self.head = Optional[T](None)
            return LinkedList[T]()
        elif not self.tail[].tail:
            var tmp = self.tail[]
            self.tail = UnsafePointer[LinkedList[T]]()
            return tmp
        else:
            return self.tail[].pop_end()
    

    fn remove(mut self, idx: Int):
        debug_assert(0 <= idx and self.tail, 'index out of bounds')
        if idx == 0:
            self.head = self.tail[].head
            self.tail = self.tail[].tail
        else:
            self.tail[0].remove(idx-1)

    fn delete_first_instance(mut self, val: T):
        if not self.tail:
            return
        if self.head and self.head.value() == val:
            if self.tail[].head:
                self.head = self.tail[].head
                self.tail = self.tail[].tail
            else:
                self = LinkedList[T]()
            return

        self.tail[].delete_all_instance(val)
    
    fn delete_all_instance(mut self, val: T):
        if not self.tail:
            return
        if self.head and self.head.value() == val:
            if self.tail[].head:
                self.head = self.tail[].head
                self.tail = self.tail[].tail
            else:
                self = LinkedList[T]()
                return

        self.tail[0].delete_all_instance(val)
         
    fn has(self, val: T) -> Bool:
        if self.head and self.head.value() == val:
            return True
        if not self.tail:
            return False
        else:
            return self.tail[].has(val)
    
    fn count(self, val: T) -> Int:
        var count = 0  
        if self.head and self.head.value() == val:
            count += 1 
        if not self.tail:
            return count
        else:
            return count + self.tail[].count(val)

@value
struct LinkedListArray[T:FormattableCollectionElement]:
    alias val = 0
    alias next = 1
    alias null = -1
    var start: Int
    var length: Int
    var next_free: List[Int]
    var list: List[(T, Int)]
    
    fn __init__(out self):
        self.list = List[(T, Int)]()
        self.start = 0
        self.length = 0
        self.next_free = List[Int]()
    
    fn __init__(out self, owned *values: T):
        self.list = List[(T, Int)](capacity = len(values))
        self.start = 0
        self.length = len(values)
        self.next_free = List[Int]()

        for v in range(len(values)-1):
            self.list.append((values[v],v+1))
        self.list.append((values[len(values)-1],-1))
            

    fn __getitem__(ref self, idx: Int) -> ref[self.list] T:
        debug_assert(0 <= idx < self.length, 'index out of bounds')
        var node = self.start
        for _ in range(idx):
            node = self.list[node][self.next]
        return self.list[node][self.val]

    fn __str__(self) -> String:
        return String.write(self)
    
    fn write_to[W: Writer](self, mut writer: W):
        writer.write('[')
        var node = self.start
        for _ in range(self.length-1):
            writer.write(self.list[node][self.val], ',')
            node = self.list[node][self.next] 
        writer.write(self.list[node][self.val])
        writer.write(']')

    fn has(self, val: T) -> Bool:
        var next = self.start
        for _ in range(self.length):
            if self.list[next][self.val] == val:
                return True
            next = self.list[next][self.next]
        return False

    fn reverse(mut self):
        var next_node = self.list[self.start][self.next]
        var prior = self.start
        self.list[self.start][self.next] = -1
        var tmp_n = next_node 
        var tmp_p = prior
        for _ in range(self.length - 1):
            tmp_p = prior 
            tmp_n = next_node
            prior = next_node
            next_node = self.list[tmp_n][self.next]
            self.list[tmp_n][self.next] = tmp_p 
        self.start = tmp_n 

    fn prepend(mut self, val: T):
        if len(self.list) == 0:
            self.list.append((val, self.null))
        elif len(self.next_free) == 0:
            self.list.append((val,self.start))
            self.start = len(self.list) - 1
        else:
            var idx = self.next_free.pop()
            self.list[idx] = (val, self.start)
            self.start = idx
        self.length += 1
   
    fn prepend(mut self, owned other: Self):
        other.reverse() 
        for _ in range(other.length):
            self.prepend(other.pop_head())
    
    fn append(mut self, val: T):
        var idx: Int
        if len(self.next_free) == 0:
            self.list.append((val,self.null))
            idx = len(self.list) - 1
        else:
            idx = self.next_free.pop()
            self.list[idx] = (val, self.null)

        var node = self.start
        for _ in range(self.length -1):
            node = self.list[node][self.next]
        self.list[node][self.next] = idx
        
        self.length += 1
    
    fn append(mut self, owned other: Self):
        self.reverse()
        other.reverse()
        self.prepend(other)
        self.reverse() 

    fn insert(mut self, val: T, owned idx: Int):
        if idx >= self.length:
            idx = self.length
        elif idx < 0:
            idx = 0
        self.length += 1

        if len(self.list) == 0:
            self.list.append((val, self.null))
            return 
        
        var node = self.start
        for _ in range(idx):
            node = self.list[node][self.next]

        if len(self.next_free) == 0:
            self.list.append(self.list[node])
            self.list[node] = (val,len(self.list)-1)
        else:
            var free = self.next_free.pop()
            var node_tup = self.list[node]
            self.list[free] = node_tup
            self.list[node] = (val, free)

    fn pop_head(mut self) -> T:
        debug_assert(self.length > 0)
        self.next_free.append(self.start)
        var popped = self.start
        self.start = self.list[self.start][self.next]
        self.length += -1
        return self.list[popped][self.val]

    fn pop_end(mut self) -> T:
        debug_assert(self.length > 0)
        var node = self.start
        for _ in range(self.length -2):
            node = self.list[node][self.next]
        var idx = self.list[node][self.next]
        self.list[node][self.next] = self.null
        self.length += -1
        self.next_free.append(idx)
        return self.list[idx][self.val]

    fn remove(mut self, idx: Int) -> T:
        debug_assert(self.length > 0)
        if idx <= 0:
            return self.pop_head()
        if idx >= self.length:
            return self.pop_end()

        var node = self.start
        for _ in range(idx - 1):
            node = self.list[node][self.next]
        var popped = self.list[node][self.next]
        self.list[node][self.next] = self.list[popped][self.next]
        self.next_free.append(popped)
        self.length += -1
        return self.list[popped][self.val]
    
    fn delete_first_instance(mut self, val: T):
        var node = self.start
        var last = self.start
        if self.list[self.start][self.val] == val:
            self.next_free.append(self.start)
            self.start = self.list[self.start][self.next]
            self.length += -1
            return
        for _ in range(self.length - 1):
            last = node
            node = self.list[node][self.next]
            if self.list[node][self.val] == val:
                self.next_free.append(node)
                self.list[last][self.next] = self.list[node][self.next]
                self.length += - 1
                return
    
    fn delete_all(mut self, val: T):
        var node = self.start
        var last = self.start
        if self.list[self.start][self.val] == val:
            self.next_free.append(self.start)
            self.start = self.list[self.start][self.next]
            self.length += -1
        last = node
        for _ in range(self.length - 1):
            node = self.list[node][self.next]
            if self.list[node][self.val] == val:
                self.next_free.append(node)
                self.list[last][self.next] = self.list[node][self.next]
                self.length += - 1
            else:
                last = node



def main():
    from time import monotonic
    
    # var b = LinkedListArray[Int](7,4,7,7,7,5,6,7)
    # print('b:', b)
    # var a = LinkedListArray[Int](0,1,2,3)
    # print('a:',a)
    # a.append(b^)
    # print('a.app(b):', a)
    # a.reverse()
    # print('a.rev():', a)
    # a.delete_first_instance(7)
    # print('a.dfi(7):', a)
    # a.delete_all(7)
    # print('a.da(7):', a)
    # print('start')
  

    var c = LinkedList[Int](2,3,4,5)
    print(c)
    # var a = LinkedList[Int](0)
    # a.append(1)
    # a.append(2)
    # a.append(3)
    # a.prepend(-1)
    # print(a)
    # var b = LinkedList[Int](4)
    # b.append(5)
    # b.append(6)
    # b.append(7)
    # print(b)
    # b.reverse()
    # # print(b.pop_head())
    # print(b)
    # b.prepend(a^)
    # print(b)
    # print(b.pop_end())
    # print(b)
    # # _ = b^



    # # a = LinkedListArray[Int]()
    # a = LinkedList[Int]()
    # var start = monotonic()
    # print('start')
    # for i in range(100_000):
    #     a.prepend(i)
    # for _ in range(100_000):
    #     _ = a.pop_head()
    # print('time:', (monotonic()- start)/1_000_000_000)