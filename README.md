# waf_testbed

## Purpose

Cookbook to create a WAF rule testing environment. This cookbook will provision apache2,
modsecurity and version 3 of the OWASP core ruleset. In addition, this cookbook will
provision services for both HTTP/HTTPS. This cookbook installs the Framework for Testing WAFs
(FTW) package in additional to the OWASP core ruleset regression tests (projects linked below).

[FTW] (https://github.com/fastly/ftw)

[OWASP regression tests] (https://github.com/SpiderLabs/OWASP-CRS-regressions)

## Dependencies

To use the Vagrantfile, you will need the Berksfile plugin installed:

	% vagrant plugin install vagrant-berkshelf

Change the following attribute to control the mode (block/log):

```
default['waf_testbed']['engine_mode'] = 'On'
```


To view the audit trails associated with mod security:

```
/var/log/apache2/modsec_audit.log
```

To view the logs associated with mod security:

```
/var/log/apache2-default/error_log
```
