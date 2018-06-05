class A(object):
    def __init__(self):
        print('A: before init')
        super().__init__()
        print('A: after init')

class B(A):
    def __init__(self):
        print('B: before init')
        super().__init__()
        print('B: after init')
        
class C:
    def __init__(self):
        print('C: before init')
        super().__init__()
        print('C: after init')
        
class D(B, C):
    def __init__(self):
        print('D: before init')
        super().__init__()
        print('D: after init')
object1 = D()

