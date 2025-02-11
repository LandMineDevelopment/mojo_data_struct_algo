from collections import Optional
from memory import UnsafePointer
from collections import Deque
from bit import is_power_of_two


trait FormattableCollectionElement(
    Writable, StringableCollectionElement, EqualityComparable, Comparable
    ):
    ...


@value
struct BinaryTree[T: FormattableCollectionElement]:
    var root: Optional[T]
    var left: UnsafePointer[BinaryTree[T]]
    var right: UnsafePointer[BinaryTree[T]]
    var name: String

    fn __init__(out self):
        self.root = Optional[T](None)
        self.left = UnsafePointer[BinaryTree[T]]()
        self.right = UnsafePointer[BinaryTree[T]]()
        self.name = 'None'

    fn __init__(out self, root: T, name: String):
        self.root = Optional[T](root)
        self.left = UnsafePointer[BinaryTree[T]].alloc(1)
        self.left.init_pointee_move(BinaryTree[T]())
        self.right = UnsafePointer[BinaryTree[T]].alloc(1)
        self.right.init_pointee_move(BinaryTree[T]())
        self.name = name
    
    fn __init__(
        inout self, root: T, name: String, *, owned left: BinaryTree[T], owned right: BinaryTree[T]
        ):
        self.root = Optional[T](None)
        self.left = UnsafePointer[BinaryTree[T]].alloc(1)
        self.left.init_pointee_move(left)
        self.right = UnsafePointer[BinaryTree[T]].alloc(1)
        self.right.init_pointee_move(right)
        self.name = name

    fn __bool__(self) -> Bool:
        return bool(self.root) 
    
    fn __str__(self) -> String:
        return String.write(self)
    
    
    fn write_to[W:Writer](self, mut writer: W):
        # if self:
        #     writer.write(self.root.value(),'\n')
        # else:
        #     writer.write('None')
        # if self.has_left():
        #     self.left[].write_to(writer)
        # if self.has_right():
        #     self.right[].write_to(writer)
        var ret_array = self.get_print_array()
        for i in ret_array:
            for j in i[]:
                if j[]:
                    writer.write(j[].value(),',')
                else:
                    writer.write('none',',')
            writer.write('\n')
    
    fn get_print_array(self) -> List[List[Optional[T]]]:
        if not self.root:
            return List[List[Optional[T]]](Optional[T](None))
        var left = List[List[Optional[T]]]()
        var right = List[List[Optional[T]]]()
        if self.has_left():
            left = self.left[].get_print_array()
        if self.has_right():
            right = self.right[].get_print_array()
        var min_ = min(len(left), len(right))
        var max_ = max(len(left), len(right))
        var remainder = List[List[Optional[T]]]()
        if min_ != max_:
            if len(left) == max_:
                remainder = left[min_:-1]
        var ret_array = List[List[Optional[T]]](List(Optional(self.root.value()))) 
        for i in range(min_):
            ret_array.append(left[i] + right[i])
        if len(remainder) > 0:
            ret_array += remainder
        return ret_array 
    
    fn has_left(self) -> Bool:
        return self.left and self.left[0].root

    fn has_right(self) -> Bool:
        return self.right and self.right[0].root

    fn is_child_less(self) -> Bool:
        return not self.has_left() and not self.has_right()
    
    fn max_dept(self) -> Int:
        if not self.root:
            return 0
        if self.is_child_less():
            return 1
        var left = 0
        var right = 0
        if self.has_left():
            left = self.left[0].max_dept() + 1
        if self.has_right():
            right = self.right[0].max_dept() + 1
        return max(left, right)
    
    fn size(self) -> Int:
        if not self:
            return 0
        if self.is_child_less():
            return 1
        var count = 1
        if self.has_left():
            count += self.left[0].size()         
        if self.has_right():
            count += self.right[0].size()         
        return count

    # fn get_vals_at_dept(self, dept: Int) -> List[T]:
    #     if self.root and dept == 0:
    #         return List[T](self.root.value())
    #     if dept > 0:
        

   
    fn insert(inout self, val: T):
        if not self.root:
            self.root = Optional[T](val)
        elif self.root and val < self.root.value():
            self.left[].insert(val)
        else:
            self.right[].insert(val)

    fn delete(inout self, val: T):
        
        # print('ho')
        if not self.root:
            return
        elif self.root and val > self.root.value():
            self.right[].delete(val)
        elif self.root and val < self.root.value():
            self.left[].delete(val)
        else:
            # print('hi')
            self.root = self._delete_replace(first = True)

    fn _delete_replace(inout self, first: Bool) -> Optional[T]:
        # print('hi')
        if self.is_child_less():
            ret = self.root
            self = BinaryTree[T]()
            return ret
        elif not self.has_right():
            ret = self.root
            self = self.left[]
            return ret 
        elif first and self.has_left():
            return self._delete_replace(first = False)
        else:
            return self._delete_replace(first = False)   

alias null = -1

alias node_val = 0
alias left = 1
alias right = 2
alias parent = 3

struct BinaryTreeArray[T: FormattableCollectionElement](Writable):
    var tree: List[(T,Int,Int,Int)]

    fn __init__(out self):
        self.tree = List[(T,Int,Int,Int)]()

    fn __str__(self) -> String:
        return String.write(self)

    fn write_to[W: Writer](self, mut writer: W):
        var que = Deque[(Int,Int)]((0,0))
        alias idx = 0
        alias lvl = 1
        var current_lvl = 0
        var counter = 0

        try:
            while len(que) > 0:
                var q = que.pop()
                if q[lvl] > current_lvl:
                    for _ in range((current_lvl)**2 - counter):
                        writer.write('empt,')
                    writer.write('\n')
                    current_lvl += 1
                    counter = 0
                
                if q[idx] == null: 
                   writer.write('null,')
                else:
                    writer.write(self.tree[q[idx]][node_val],',')
                    que.appendleft((self.tree[q[idx]][left], q[lvl]+1))
                    que.appendleft((self.tree[q[idx]][right], q[lvl]+1))
            
                counter += 1

        except:
            print('sucks to suck')
            
    fn is_empty(self) -> Bool:
        if len(self.tree) == 0:
            return True
        return False

    fn insert(mut self, val: T):
        if self.is_empty():
            self.tree.append((val, null, null, null))
            return
        
        var idx = 0
        for _ in range(len(self.tree)):
            if self.tree[idx][node_val] >= val:
                if self.tree[idx][left] == null:
                    self.tree.append((val, null, null, idx))
                    self.tree[idx][left] = len(self.tree) - 1
                    return
                idx = self.tree[idx][left]                
            else:
                if self.tree[idx][right] == null:
                    self.tree.append((val, null, null, idx))
                    self.tree[idx][right] = len(self.tree) - 1
                    return
                idx = self.tree[idx][right]        
    
    fn insert(mut self, vals: List[T]):
        for val in vals:
            self.insert(val[])

    fn delete(mut self, val: T, first_only: Bool = True):
        if self.is_empty():
            return
        
        var idx = 0
        for _ in range(len(self.tree)):
            if self.tree[idx][node_val] > val:
                if self.tree[idx][left] == null:
                    break
                idx = self.tree[idx][left]                
            elif self.tree[idx][node_val] < val:
                if self.tree[idx][right] == null:
                    break
                idx = self.tree[idx][right]
            else:
                self.tree[idx] = self.tree.pop()
                var parent_idx = self.tree[idx][parent]
                if self.tree[parent_idx][left] == len(self.tree):
                    self.tree[parent_idx][left] = idx               
                else:
                    self.tree[parent_idx][right] = idx
                
                if first_only: return
                
                idx = self.tree[idx][left]
                
                if idx == null: return


from utils import Variant
trait Updateable:
    fn update(self): ...    

@value
struct A(Updateable):
    fn update(self):
        print('A')

@value
struct B(Updateable):
    fn update(self):
        print('B')

fn update_it[U: Updateable](item: U):
    item.update()

fn update_all(lst: List[Variant[A,B]]):
    for e in lst:
        if e[].isa[A]():
            update_it(e[][A])


def main():
    # var a = BinaryTreeArray[Int]()
    # # a.insert(List(5,3,2,7,6))
    # a.insert(List(5,3,2,1,0,8,7,6))

    # print(a)
    # for x in a.tree:
    #     print('val:', x[][node_val],',','left:',x[][left],', right:', x[][right])

    a = A()
    b = B()
    l = List[Variant[A,B]](a,b)
    update_all(l)

    