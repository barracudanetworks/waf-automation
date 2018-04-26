#!/usr/bin/ruby

require "net/http"
require "uri"
require "json"
require "base64"

###Querying Azure for the the Public and Private IP###
class Config_mode
def config_mode
config_mode = `azure config mode arm`
end
end
configmode = Config_mode.new
configmode.config_mode

class Waf_Info
		azure = `cat /etc/puppetlabs/puppet/azure-instance-details`
		azure_json = JSON.parse(azure)
		rg_name = azure_json ["ResourceGroupName"]
		vm_name = azure_json ["VMName"]
		vm_nic_name = azure_json ["VMNIC"]
		vm_pw = azure_json ["VMPASS"]

		
		@@ins_id = "#{vm_pw.chomp}"

		public_ip = `azure vm show #{rg_name} #{vm_name} | grep "Public IP address" | awk -F ":" '{print $3}'`
		@@pub_ip = "#{public_ip.chomp}"

		system_ip = `azure network nic show #{rg_name} #{vm_nic_name} | grep "Private IP address" | awk -F ":" '{print $3}' | cut -c 2-`
		@@sys_ip = "#{system_ip.chomp}"

		common = "#{public_ip.chomp}:8000/restapi/v1/"
		@@common_url = "#{common}"

		header = "-X POST -H Content-Type:application/json -d"
		@@http_header = "#{header}"

		common_service_path = "#{common}virtual_services"
		@@service_url = "#{common_service_path}"

	def self.ins_id
	@@ins_id
	end
	def ins_id
	@@ins_id
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
	def self.service_url
	@@service_url
	end
	def service_url
	@@service_url
	end
end

#accepting EULA
class EULA < Waf_Info
		
	def agreement
	instance_id_waf = Waf_Info.ins_id
	instance_publicip = Waf_Info.pub_ip
	instance_sysip = Waf_Info.sys_ip
	common_urlpath = Waf_Info.common_url
	header_http = Waf_Info.http_header
	serviceurl = Waf_Info.service_url
	puts "#{instance_id_waf}"
	puts "#{instance_publicip}"
	puts "#{instance_sysip}"
	puts "#{common_urlpath}"
	puts "#{header_http}"
	puts "#{serviceurl}"
	
	###Accepting EULA###
	i = 0
		limit = 60
		if i < limit

	
	#http://13.56.20.135:8000/ -X POST -H Content-Type:application/x-www-form-urlencoded -d "name_sign=self-provisioned&email_sign=self-provisioned&company_sign=self-provisioned&eula_hash_val=ed4480205f84cde3e6bdce0c987348d1d90de9db&action=save_signed_eula"
	
	eula_uri = URI.parse("http://#{instance_publicip}:8000/")
	eula_http = Net::HTTP.new(eula_uri.host, eula_uri.port)
	eula_request = Net::HTTP::Get.new(eula_uri.path)
	eula_response = eula_http.request(eula_request)
	eula_output = eula_response.code
		if eula_output == "200"
		accept_params = "name_sign=self-provisioned&email_sign=self-provisioned&company_sign=self-provisioned&eula_hash_val=ed4480205f84cde3e6bdce0c987348d1d90de9db&action=save_signed_eula"
		eula_post = Net::HTTP::Post.new(eula_uri.path)
		eula_post.body = "{#{accept_params}}"
		eula_post_request = eula_http.request(eula_post)
			else
			puts "re-attempting in 30 seconds ..."
			sleep (30)
			i +=30;
			end
		end
	end
end

eula = EULA.new
eula.agreement



#Logging in to the WAF :###
#http://10.11.31.231:8000/restapi/v1/login -X POST -H Content-Type:application/json -d '{"username": "admin", "password": "admin" }'
class Token < Waf_Info
		def logintoken
		
		
		i = 0
		limit = 60
		if i < limit
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
		else
			puts "re-attempting in 10 seconds ..."
			sleep (10)
			i +=10;

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

#Service Group Creation
class Service_group < Waf_Info::Token
	def create_svc_grp
		group_name = ["production", "staging"]
		group_name.each do |environment_setting|

		svc_grp_name = "#{environment_setting}"

		wafip = Waf_Info.pub_ip
		wafport = 8000
		logintoken = Token.token
		common_path = Waf_Info.common_url
		header_string = Waf_Info.http_header
		@@svc_grp = `curl http://#{common_path}vsites/default/service_groups -u '#{logintoken}:' #{header_string} '{"name":"#{svc_grp_name}"}'`
		end
	end
	def self.svc_grp
		@@svc_grp
	end
	def svc_grp
		@@svc_grp
	end
end
service_group = Service_group.new
service_group.create_svc_grp


#HTTP Service
	class WAF_CONFIG < Waf_Info::Token
		def config

#Services details
http_svc_name = "service_http_auto"

#website details
	http_fqdn = "demo.selahcloud.in"

#waf details
	wafip = Waf_Info.sys_ip
	wafport = 8000
	waftoken = Token.token
	svc_grp = "production"
	common_path = Waf_Info.common_url
	header_string = Waf_Info.http_header
	common_path_service = Waf_Info.service_url

#Service creation
	svc = `curl http://#{common_path_service} -u '#{waftoken}:' #{header_string} '{"name": "#{http_svc_name}", "ip_address":"#{wafip}", "port":"80", "type":"HTTP", "address_version":"ipv4", "vsite":"default", "group":"#{svc_grp}"}'`
#Rule group for the http service
	rule_group = `curl http://#{common_path_service}/#{http_svc_name}/content_rules -u '#{waftoken}:' #{header_string} '{"name":"rule_1","host_match":"#{http_fqdn}","url_match":"/index.html","extended_match":"*", "extended_match_sequence":5}'`
#server for the rule group
	rule_grp_svr = `curl http://#{common_path_service}/#{http_svc_name}/content_rules/rule_1/rg_servers -u '#{waftoken}:' #{header_string} '{"name":"rg_server_1","ip_address":"10.11.3.213","port":"80"}'`
#HTTPS Service
#services details
	https_svc_name = "service_https_auto"

#website details
	https_fqdn = "demo.selahcloud.in"

#Creating a certificate on the WAF
	cert = `curl http://#{common_path}certificates -u '#{waftoken}:' #{header_string} '{"name":"cert4","common_name":"barracuda.tme.com","country_code":"US","state":"California","city":"Campbell","organization_name":"BarracudaNetworks","organization_unit":"Engineering","key_size":"1024","allow_private_key_export":"yes"}'`
#Creating a HTTPS service :
	svc_https = `curl http://#{common_path_service} -u '#{waftoken}:' #{header_string} '{"certificate":"cert4", "address_version":"ipv4", "name":"#{https_svc_name}", "type":"https", "ip_address":"#{wafip}", "port":"4443", "vsite":"default", "group":"#{svc_grp}"}'`
#Creating a rule group for the service :
	https_rule_group = `curl http://#{common_path_service}/#{https_svc_name}/content_rules -u '#{waftoken}:' #{header_string} '{"name":"rule_2","host_match":"#{http_fqdn}","url_match":"/index.html","extended_match":"*", "extended_match_sequence":5}'`
#Creating a server for the rule group :
	https_rule_grp_svr = `curl http://#{common_path_service}/#{https_svc_name}/content_rules/rule_2/rg_servers -u '#{waftoken}:' #{header_string} '{"name":"rg_server_1","ip_address":"10.11.3.213","port":"80"}'`

#STAGING
	http_svc_name = "service_http_auto_staging"
	svc_grp = "staging"
	puts "Creating the configuration for the staging service group"
	puts "======================================================= \n"

#HTTP Service creation
        svc = `curl http://#{common_path_service} -u '#{waftoken}:' #{header_string} '{"name": "#{http_svc_name}", "ip_address":"#{wafip}", "port":"8888", "type":"HTTP", "address_version":"ipv4", "vsite":"default", "group":"#{svc_grp}"}'`
puts "The Service #{http_svc_name} has been created"

#Rule group for the http service
       	rule_group = `curl http://#{common_path_service}/#{http_svc_name}/content_rules -u '#{waftoken}:' #{header_string} '{"name":"rule_1","host_match":"#{http_fqdn}","url_match":"/*","extended_match":"*", "extended_match_sequence":5}'`
       	puts "The rule group under #{http_svc_name} has been created"

#server for the rule group
       	rule_grp_svr = `curl http://#{common_path_service}/#{http_svc_name}/content_rules/rule_1/rg_servers -u '#{waftoken}:' #{header_string} '{"name":"rg_server_1","ip_address":"#{server_ip}","port":"80"}'`
puts "The server ip address for the rule group rule_1 under the service #{http_svc_name} is configured"

#HTTPS Service
#services details
       	https_svc_name = "service_https_auto_staging"

#Creating a HTTPS service :
       	svc_https = `curl http://#{common_path_service} -u '#{waftoken}:' #{header_string} '{"certificate":"cert4", "address_version":"ipv4", "name":"#{https_svc_name}", "type":"https", "ip_address":"#{wafip}", "port":"9443", "vsite":"default", "group":"#{svc_grp}"}'`
	puts "The Service #{https_svc_name} has been created"

#Creating a rule group for the service :
	https_rule_group = `curl http://#{common_path_service}/#{https_svc_name}/content_rules -u '#{waftoken}:' #{header_string} '{"name":"rule_2","host_match":"#{http_fqdn}","url_match":"/*","extended_match":"*", "extended_match_sequence":5}'`
	puts "The rule group under #{https_svc_name} has been created"

#Creating a server for the rule group :
	https_rule_grp_svr = `curl http://#{common_path_service}/#{https_svc_name}/content_rules/rule_2/rg_servers -u '#{waftoken}:' #{header_string} '{"name":"rg_server_1","ip_address":"#{server_ip}","port":"80"}'`	
	puts "The server ip address for the rule group rule_2 under the service #{https_svc_name} is configured"

#Connecting the unit to BCC
	bcc = `cat /etc/puppetlabs/puppet/bcc_credentials`
	bcc_json = JSON.parse (bcc)
	bcc_user = bcc_json ["username"]
	bcc_password = bcc_json ["password"]
	bcc_link = `curl http://#{common_path}cloud_control -u '#{waftoken}:' -X PUT -H Content-Type:application/json -d '{"connect_mode":"cloud","state":"connected","username":"#{bcc_user}","password":"#{bcc_password}","barracuda_control_server":"svc.bcc.barracudanetworks.com"}'`
#puts "#{bcc_link}"
	puts "=================================================================== \n\n"
	puts "This unit is now linked to the Barracuda Cloud Control Service as well as the Barracuda Vulnerability Remediation Service"

	end
end

config_waf = WAF_CONFIG.new
config_waf.config

