import boto3

ec2 = boto3.client('ec2')

# Retrieves all regions/endpoints that work with EC2
response = ec2.describe_regions()
print('Regions:', response['Regions'])
T=response['Regions']
print(type(T))
for p in T:
    print(p['Endpoint']+"    "+p['RegionName'] )

# Retrieves availability zones only for region of the ec2 object
#response = ec2.describe_availability_zones()
#print('Availability Zones:', response['AvailabilityZones'])
