from troposphere import Ref, Template
import troposphere.ec2 as ec2
t = Template()
instance = ec2.Instance("myinstance")
instance.ImageId = "ami-951945d0"
instance.InstanceType = "t1.micro"
t.add_resource(instance)
#<troposphere.ec2.Instance object at 0x101bf3390>
print(t.to_json())
