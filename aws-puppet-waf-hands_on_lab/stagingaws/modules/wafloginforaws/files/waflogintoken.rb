#!/usr/bin/ruby

require "net/http"
require "uri"
require "json"
require "base64"

time = `clear; date`
puts "Current time is #{time}\n\n"
###Querying AWS for the the Instance ID and the Public and Private IP###
class Waf_Info
		instance_id = `aws ec2 describe-instances --filter Name=tag:tag_name,Values=awswafinstancebyPUPPET5 --query 'Reservations[*].Instances[*].[InstanceId]' --output text`
		@@ins_id = "#{instance_id.chomp}"
		
		attach_ip = `aws ec2 associate-address --instance-id "#{instance_id.chomp}" --public-ip 52.37.124.1`
		@@att_ip = "#{attach_ip}"
		
		public_ip = `aws ec2 describe-instances --filter Name=tag:tag_name,Values=awswafinstancebyPUPPET5 --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text`
		@@pub_ip = "#{public_ip.chomp}"

		system_ip = `aws ec2 describe-instances --filter Name=tag:tag_name,Values=awswafinstancebyPUPPET5 --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text`
		@@sys_ip = "#{system_ip.chomp}"

		common = "#{public_ip.chomp}:8000/restapi/v1/"
		@@common_url = "#{common}"

		header = "-X POST -H Content-Type:application/json -d"
		@@http_header = "#{header}"


	def self.ins_id
	@@ins_id
	end
	def ins_id
	@@ins_id
	end
	def self.att_ip
        @@att_ip
        end
        def att_ip
        @@att_ip
        end
	def self.pub_ip
	@@pub_ip
	end
	def pub_ip
	@@pub_ip
	end
	def self.sys_ip
	@@sys_ip
	end
	def sys_ip
	@@sys_ip
	end
	def self.common_url
	@@common_url
	end
	def common_url
	@@common_url
	end
	def self.http_header
	@@http_header
	end
	def http_header
	@@http_header
	end
end


#Logging in to the WAF :###
class Token < Waf_Info
		def logintoken
		
		
		time_increment = 0
		time_limit = 300
		if time_increment < time_limit
        instance_publicip = Waf_Info.pub_ip
        login_check = URI.parse("http://#{instance_publicip}:8000/cgi-bin/index.cgi")
		login_check_http = Net::HTTP.new(login_check.host, 8000)
		login_request = Net::HTTP::Get.new(login_check.path)
		response_check = login_check_http.request(login_request)
		output_check = response_check.code
		puts "#{output_check}" 
		if output_check == "200"
			urlpath = Waf_Info.common_url
			uri = URI.parse("http://#{urlpath}login")
			password = Waf_Info.ins_id
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
			request.body = {"username" => "admin", "password" => "#{password}"}.to_json
			response = http.request(request)
			output = response.body
			parsed_json = JSON.parse(output)
			token_value = parsed_json ["token"]
			@@token = token_value.chomp
			#puts "#{token_value.chomp}"
			create_token_file = `touch /etc/puppetlabs/puppet/waftoken.json; chmod 0644 /etc/puppetlabs/puppet/waftoken.json; echo #{token_value.chomp} >> /etc/puppetlabs/puppet/waftoken.json`
			
		else
			puts "re-attempting in 10 seconds ..."
			sleep (10)
			time_increment +=10;

			end
		end
	
		
		
	end
	def self.token
	@@token
	end
	def token
	@@token
	end
end
token_for_login = Token.new
token_for_login.logintoken

