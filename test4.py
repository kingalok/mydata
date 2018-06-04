class A:
    def __init__(self):
        print('one')

    def f(self):
        print(float())
        print(hex(-255))

class B(A):
    def __init__(self):
        print('two')

    def f(self):
        print(float())
        print(hex(-42))

x = B()
x.f()
