#!/usr/bin/ruby

require "net/http"
require "uri"
require "json"
require "base64"


		###Querying AWS for the the Instance ID and the Public and Private IP###
		instance_id = `aws ec2 describe-instances --filter Name=tag:Name,Values=awswafinstancebyPUPPET7 --query 'Reservations[*].Instances[*].[InstanceId]' --output text`
		ins_id = "#{instance_id.chomp}"

		eip_alloc_json = `aws ec2 describe-addresses --filters "Name=domain,Values=vpc"`
    eip_alloc_json_parsed = JSON.parse(eip_alloc_json)
		eip_alloc_json_parsed ['Addresses'].each do |info|
			eip_alloc_id = info ['AllocationId']
			attach_ip = `aws ec2 associate-address --instance-id "#{instance_id.chomp}" --allocation-id "#{eip_alloc_id.chomp}"`
			att_ip = "#{attach_ip.chomp}"
		end

		public_ip = `aws ec2 describe-instances --filter Name=tag:Name,Values=awswafinstancebyPUPPET7 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text`
		pub_ip = "#{public_ip.chomp}"

		system_ip = `aws ec2 describe-instances --filter Name=tag:Name,Values=awswafinstancebyPUPPET7 --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text`
		sys_ip = "#{system_ip.chomp}"

		svr_system_ip = `aws ec2 describe-instances --filter Name=tag:Name,Values=lampinstancebyPUPPET7 --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text`
		svr_sys_ip = "#{svr_system_ip.chomp}"

		# Creating the facts
    puts "waf_public_ip=#{pub_ip}"
    puts "waf_private_ip=#{sys_ip}"
    puts "waf_instance_id=#{ins_id}"
