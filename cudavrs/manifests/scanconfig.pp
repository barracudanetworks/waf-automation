class cudavrs::vrsconfig {

	scan_create {"demoscantesting":
		ensure=>present,
		name => 'test_scan',
    		max_requests_per_second => '20',
    		scan_time_limit_hours => '9',
    		crawl_max_depth => '2',
    		browser_type => 'Firefox',
    		user_agent => 'Mozilla/5.0 (Windows NT 6.3; rv=>36.0) Gecko/20100101 Firefox/36.0',
    		evasion_techniques => 'False',
    		auth_type => 2,  # form
    		auth_html_form_username_parameter => 'username_param',
    		auth_html_username => 'username',
    		auth_html_form_password_parameter => 'password_param',
    		auth_html_password => 'password',
    		auth_html_form_test_url => 'http=>//demo.selahcloud.in/welcome/',
    		auth_html_form_test_value => 'test_value',
    		auth_login_form_url => 'http=>//demo.selahcloud.in/login/',
    		excluded_address_list => '["host1", "host2"]',  # excluded_address_list
    		excluded_url_list => '["*/patt1/*", "*patt2*"]',  # excluded_url_list
    		excluded_file_ext_list => '["ext1", "ext2"]',  # excluded_file_ext_list
    		webapp_id => 'webapp_id',
    		waf_bypass => 'False',
    		recurrence => 'manual'
	}

}
