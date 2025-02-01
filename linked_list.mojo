from collections import Optional
from memory import UnsafePointer


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
    

    # fn sort(mut self):
    #     if not self.tail:
    #         return
    #     if self.head and self.tail[].head and self.head.value() > self.tail[].head.value():

    

    
def main():
    var d4 = LinkedList[Int](4)
    var d3 = LinkedList[Int](3)
    var d2 = LinkedList[Int](2)
    var d1 = LinkedList[Int](1)
    var d0 = LinkedList[Int](0)
    # var dNone = LinkedList[Int]()
    d0.concat(d1^)
    # print(d0)
    d0.concat(d2^)
    # print(d0)
    d0.concat(d3)
    d0.concat(d4)
    print(d0)
    d0.append(6)
    print('append:',d0)
    d0.prepend(-1)
    print('prepend:',d0)
    d0.insert(5,17)
    print('insert:',d0)
    d0.delete_idx(4)
    print('del_idx[4]:', d0)
    d0.delete_first_instance(17)
    d0.delete_first_instance(55)
    print('del_17&55:',d0)
    d0.append(2)
    print('app_2:', d0)
    print('has 2:', d0.has(2))
    print('count # of 2s:', d0.count(2))
    d0.delete_all_instance(2)
    print('del_all_2s:', d0)
