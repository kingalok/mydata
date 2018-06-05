class X():
          a=1000
          def __init__(self):
                    print("inside the constructor")
          def __init__(self,a):
                    print("inside the constructor with one parameter")

          def m1(self):
                    b=2000
                    global a
                    a=a+100
                    print("In m1 of X")
                    print(b)
          def m2(self):
                    print("In m2 of X")
                    
x1=X(10)
x1.m1()
#X.a
print(X.a)
#x1.m2()
#x1.m2()
