#!/bin/bash
#
# Change the environment variables below to match your environment
# The AWS cli and SnowballEdge cli should be configured so that the profile name is in the ENV variable SBE_PROFILE
# The PNIC_ID can be found using "snowballEdge describe-device"
# The IMAGE_ID can be found using "aws ec2 describe-images --endpoint http://<SBE_IP>:8008 --profile <SBE_PROFILE>"


export MSG_SVR_IP=192.168.26.83
export VV_SVR_IP=192.168.26.84
export COMPLIANCE_SVR_IP=192.168.26.85
export NETMASK=255.255.255.0
export PNIC_ID=s.ni-81de3334a74d29280
export SBE_PROFILE=sbe89
export SBE_IP=192.168.26.89
export KEY_NAME=markngykp
export IMAGE_ID=s.ami-8144e2b13711e662b

# create VNIs for all instances
echo Creating VNIs...
snowballEdge create-virtual-network-interface --physical-network-interface-id $PNIC_ID --ip-address-assignment STATIC --static-ip-address-configuration IpAddress=$MSG_SVR_IP,NetMask=$NETMASK --profile $SBE_PROFILE
snowballEdge create-virtual-network-interface --physical-network-interface-id $PNIC_ID --ip-address-assignment STATIC --static-ip-address-configuration IpAddress=$VV_SVR_IP,NetMask=$NETMASK --profile $SBE_PROFILE
snowballEdge create-virtual-network-interface --physical-network-interface-id $PNIC_ID --ip-address-assignment STATIC --static-ip-address-configuration IpAddress=$COMPLIANCE_SVR_IP,NetMask=$NETMASK --profile $SBE_PROFILE

# launch MSG Server instance
echo launching Messaging server....
export MSG_SVR_INSTANCE_ID=`aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type sbe-c.large --key-name $KEY_NAME --user-data file://MSG_SVR_userdata.txt --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE --region snow | grep InstanceId | awk -F '"' '{print $4}'`
sleep 40
aws ec2 associate-address --instance-id $MSG_SVR_INSTANCE_ID --public-ip $MSG_SVR_IP --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow
echo creating volume.....
export MSG_SVR_VOLUME=`aws ec2 create-volume --availability-zone snow --volume-type "sbp1" --size 500 --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow | grep VolumeId | awk -F '"' '{print $4}'`
sleep 20
echo attaching volume....
aws ec2 attach-volume --instance-id $MSG_SVR_INSTANCE_ID --volume-id $MSG_SVR_VOLUME --device /dev/sdh --region snow --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE

# launch Voice Video Server instance
echo launching Voice Video server....
export VV_SVR_INSTANCE_ID=`aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type sbe-c.large --key-name $KEY_NAME --user-data file://VV_SVR_userdata.txt --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE --region snow | grep InstanceId | awk -F '"' '{print $4}'`
sleep 40
aws ec2 associate-address --instance-id $VV_SVR_INSTANCE_ID --public-ip $VV_SVR_IP --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow
echo creating volume.....
export VV_SVR_VOLUME=`aws ec2 create-volume --availability-zone snow --volume-type "sbp1" --size 500 --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow | grep VolumeId | awk -F '"' '{print $4}'`
sleep 20
echo attaching volume....
aws ec2 attach-volume --instance-id $VV_SVR_INSTANCE_ID --volume-id $VV_SVR_VOLUME --device /dev/sdh --region snow --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE

# launch Compliance Server instance
echo launching Compliance server....
export COMPLIANCE_SVR_INSTANCE_ID=`aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type sbe-c.large --key-name $KEY_NAME --user-data file://COMPLIANCE_SVR_userdata.txt --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE --region snow | grep InstanceId | awk -F '"' '{print $4}'`
sleep 40
aws ec2 associate-address --instance-id $COMPLIANCE_SVR_INSTANCE_ID --public-ip $COMPLIANCE_SVR_IP --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow
echo creating volume.....
export COMPLIANCE_SVR_VOLUME=`aws ec2 create-volume --availability-zone snow --volume-type "sbp1" --size 500 --profile $SBE_PROFILE --endpoint http://$SBE_IP:8008 --region snow | grep VolumeId | awk -F '"' '{print $4}'`
sleep 20
echo attaching volume....
aws ec2 attach-volume --instance-id $COMPLIANCE_SVR_INSTANCE_ID --volume-id $COMPLIANCE_SVR_VOLUME --device /dev/sdh --region snow --endpoint http://$SBE_IP:8008 --profile $SBE_PROFILE
echo launch complete.
echo please wait 3 minutes for yum updates and online install
