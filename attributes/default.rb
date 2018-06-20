#
# Specify which mode we want the WAF engine operating in.
#  On: Prevention mode (will terminate the HTTP transaction)
#  DetectionOnly: Passively monitor, log but do NOT impact the HTTP transaction (default)
#
default['waf_testbed']['engine_mode'] = 'DetectionOnly'
default['waf_testbed']['ftw']['use_git'] = true
default['waf_testbed']['ftw']['branch'] = 'master'
default['waf_testbed']['ftw']['pip_version'] = '1.0.1'
