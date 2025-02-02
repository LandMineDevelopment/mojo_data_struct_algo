from collections import Optional
from memory import UnsafePointer
from collections import Deque


trait FormattableCollectionElement(Writable, StringableCollectionElement, EqualityComparable):
    ...

@value
struct LinkedList[T: FormattableCollectionElement]:
    var tail: UnsafePointer[LinkedList[T]]
    var head: Optional[T]

    fn __init__(out self):
        self.tail = UnsafePointer[LinkedList[T]]()
        self.head = Optional[T](None)
        print('init empty')
        
    
    fn __init__(out self, head: T):
        self.tail = UnsafePointer[LinkedList[T]].alloc(1)
        self.tail.init_pointee_move(LinkedList[T]())
        self.head = head
        print('init:', head)


    fn __del__(owned self):
        if self.tail:
            self.tail.destroy_pointee()
        self.tail.free()
        if self.head: print('del',self.head.value()) else: print('del: none')
    
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
    
    fn concat(mut self, owned val: LinkedList[T]):
        if not self.tail:
            return
        if not self.tail[][0]:
            self.tail.init_pointee_move(val^)
        else:
            self.tail[].concat(val^)

    fn append(inout self, owned val: T):
        if not self.tail:
            self.tail = UnsafePointer[LinkedList[T]].alloc(1)
            self.tail.init_pointee_move(LinkedList[T](val))
        elif not self.tail[].head:
            self.tail.init_pointee_move(LinkedList[T](val))
        else:
            self.tail[].append(val)
    
    fn prepend(inout self, owned val: T):
        var tmp = self
        self = LinkedList[T](val)
        self.concat(tmp)

    fn insert(inout self, idx: Int, val: T):
        debug_assert(0 == idx or (0 <= idx and self.tail), 'index out of bounds')
        if idx == 0:
            var tmp = self
            self = LinkedList[T](val)
            self.concat(tmp)
        else:
            self.tail[].insert(idx-1, val)  

    fn delete_idx(inout self, idx: Int):
        debug_assert(0 <= idx and self.tail, 'index out of bounds')
        if idx == 0:
            self.head = self.tail[].head
            self.tail = self.tail[].tail
        else:
            self.tail[0].delete_idx(idx-1)

    fn delete_first_instance(inout self, val: T):
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
    
    fn delete_all_instance(inout self, val: T):
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
    var list: List[(Int, Int)]
    # var avalable: Deque[Int] 

    fn __init__(out self):
        self.list = List[(Int, Int)]()
        available = Deque[Int]()
        # self.avalable = 0

def main():
    pass
    # VariadicList[Int](2,3,4)