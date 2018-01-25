#!/usr/bin/ruby

require "net/http"
require "net/https"
require "uri"
require "json"
require "base64"

###Querying Azure for the the Instance ID and the Public and Private IP###
class Config_mode
def config_mode
config_mode = `azure config mode arm`
end
end
configmode = Config_mode.new
configmode.config_mode


###Querying Azure for the the Instance ID and the Public IP###
        azure = `cat /etc/puppetlabs/puppet/azure-instance-details`
        azure_json = JSON.parse(azure)
        rg_name = azure_json ["ResourceGroupName"]
        vm_name = azure_json ["VMName"]
        vm_nic_name = azure_json ["VMNIC"]
        vm_pw = azure_json ["VMPASS"]

        instance_id = "#{vm_pw.chomp}"

        public_ip = `azure vm show #{rg_name} #{vm_name} | grep "Public IP address" | awk -F ":" '{print $3}'`
        pub_ip = "#{public_ip.chomp}"
        login_token = `curl http://#{pub_ip}:8000/restapi/v1/login -X POST -H 'Content-Type: application/json' -d '{"username":"admin", "password":"#{vm_pw}"}'`
        response_json = JSON.parse (login_token)
        waf_login = response_json ["token"]
        waf_serial_number = `curl http://#{pub_ip}:8000/restapi/v1/system -u '#{waf_login}:'`

        uri = ["wafs", "create_webapp", "create_scan", "run_scan_now", "scan_status", "scan_results?webapp_id=", "mitigate_on_waf"]
        vrs = "https://vrs.barracudanetworks.com/api/v1"
        user = `cat /etc/puppetlabs/puppet/bcc_credentials`
        userjson = JSON.parse(user)
        basic_auth_user = userjson ["username"] 
        basic_auth_pass = userjson ["password"]

http = Net::HTTP.new('vrs.barracudanetworks.com', 443)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	#step1 : Authenticate and fetch services
 	parsed_uri = URI.parse("#{vrs}/#{uri[0]}")
	request = Net::HTTP::Get.new(parsed_uri.path)
	request.basic_auth "#{basic_auth_user}", "#{basic_auth_pass}"
	response = http.request(request)
	output = response.body
	services = JSON.parse (output)
	services_json = services ["id"]
	#puts "#{services_json}"

	#step2 : create the web app configuration to set up scans
	parsed_uri = URI.parse("#{vrs}/#{uri[1]}")
	request = Net::HTTP::Post.new(parsed_uri.path)
	request.basic_auth "#{basic_auth_user}", "#{basic_auth_pass}"
	request.set_form_data({'url' => 'http://demo.selahcloud.in:80/',
    'name' => 'selahcloudstaging',
    'waf_serial' => "'#{waf_serial_number}'",
    'waf_service' => 'service_http_auto',
    'waf_policy_name' => 'default',
    'verify_method' => 'email',
    'verification_email' => 'aravindan.acct@selahcloud.in',
    'notification_emails' => 'aravindan.acct@selahcloud.in'}, ';')
	response = http.request(request)
	output = response.body
	parsed_json = JSON.parse (output)
	id = parsed_json ["id"]
	id_chomped = "#{id}".chomp
	puts "#{id_chomped}"

	#steps = 3 setup scan
	parsed_uri = URI.parse("#{vrs}/#{uri[2]}")
	request = Net::HTTP::Post.new(parsed_uri.path)
	request.basic_auth "#{basic_auth_user}", "#{basic_auth_pass}"
	request.set_form_data({
    'name' => 'testscan',
    'max_requests_per_second' => '20',
    'scan_time_limit_hours' => '9',
    'crawl_max_depth' => '2',
    'browser_type' => 'Firefox',
    'user_agent' => 'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0',
    'evasion_techniques' => 'False',
    #'auth_type' => '2',
    #'auth_html_form_username_parameter' => 'username_param',
    #'auth_html_username' => 'username',
    #'auth_html_form_password_parameter' => 'password_param',
    #'auth_html_password' => 'password',
    #'auth_html_form_test_url' => 'http://staging.selahcloud.in:8888/welcome/',
    #'auth_html_form_test_value' => 'test_value',
    #'auth_login_form_url' => 'http://staging.selahcloud.in:8888/login/',
    'excluded_address_list' => ["host1", "host2"],
    'excluded_url_list' => ["*/patt1/*", "*patt2*"],
    'excluded_file_ext_list' => ["ext1", "ext2"],
    'webapp_id' => "#{id_chomped}",
    'waf_bypass' =>'False',
    'recurrence' => 'manual'}, ';')	
    response = http.request(request)
	output = response.body
	puts "#{output}"

#puts "You are all set to start a Barracuda Vulnerability Remediation Service Scan on your Web Application. This action will give you insights into the existing threats on your application and will offer you remediation steps to mitigate against those threats. Thank you."
