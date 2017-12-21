class cudavrs::vrsconfig {

        webapp_create{"test":
                ensure => present,
                url => 'demo.selahcloud.in:4443',
                name => 'blrtest1',
                waf_serial => '777942',  # WAF QA
                waf_service => 'AutomationVS',
                waf_policy_name => 'default',
                verify_method => 'email',
                verification_email => 'aravindan.acct@selahcloud.in',
                notification_emails => 'aravindan.acct@selahcloud.in'
        }
}
