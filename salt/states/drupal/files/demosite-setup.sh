#!/bin/bash

set -x
set -e

DRUSH='sudo -u www-data /opt/drupal/vendor/bin/drush'

echo "Installing Drupal..."

$DRUSH --yes site:install standard \
  install_configure_form.enable_update_status_emails=NULL \
  --db-url=pgsql://{{ dbuser }}:{{ dbpassword }}@{{ dbhost }}:{{ dbport }}/{{ database }} \
  --account-name="{{ account_name }}" \
  --account-mail="{{ account_mail }}" \
  --account-pass="{{ account_pass }}" \
  --site-mail="{{ site_mail }}" \
  --site-name="{{ site_name }}"

echo "Setting up Drupal..."

$DRUSH pm:enable smtp openid_connect syslog

# Setup site
# $DRUSH config:set system.site name '{{ site_name }}'
# $DRUSH config:set system.site mail '{{ site_mail }}'

# Setup Syslog
$DRUSH config:set syslog.settings identity '{{ log_name }}'
$DRUSH config:set syslog.settings facility 128
$DRUSH config:set syslog.settings format '!base_url|!timestamp|!type|!ip|!request_uri|!referer|!uid|!link|!message'
$DRUSH config:set system.logging error_level some

# Setup SMTP
$DRUSH config:set smtp.settings smtp_on true
$DRUSH config:set smtp.settings smtp_host '{{ smtp_host }}'
$DRUSH config:set smtp.settings smtp_hostbackup ''
$DRUSH config:set smtp.settings smtp_port {{ smtp_port }}
$DRUSH config:set smtp.settings smtp_protocol standard
$DRUSH config:set smtp.settings smtp_timeout 30
$DRUSH config:set smtp.settings smtp_username ''
$DRUSH config:set smtp.settings smtp_password ''
$DRUSH config:set smtp.settings smtp_from '{{ site_mail }}'
$DRUSH config:set smtp.settings smtp_fromname '{{ site_name }}'
$DRUSH config:set smtp.settings smtp_client_hostname ''
$DRUSH config:set smtp.settings smtp_client_helo ''
$DRUSH config:set smtp.settings smtp_allowhtml '1'
$DRUSH config:set smtp.settings smtp_test_address ''
$DRUSH config:set smtp.settings smtp_debugging false
$DRUSH config:set smtp.settings smtp_keepalive true
$DRUSH config:set system.mail interface.default SMTPMailSystem

# Setup Oauth:
$DRUSH config:set openid_connect.settings.generic enabled true
$DRUSH config:set openid_connect.settings.generic settings.redirect_url ''
$DRUSH config:set openid_connect.settings.generic settings.client_id '{{ oauth_client_id }}'
$DRUSH config:set openid_connect.settings.generic settings.client_secret '{{ oauth_secret }}'
$DRUSH config:set openid_connect.settings.generic settings.authorization_endpoint '{{ oauth_auth_endpoint }}'
$DRUSH config:set openid_connect.settings.generic settings.token_endpoint '{{ oauth_token_endpoint }}'
$DRUSH config:set openid_connect.settings.generic settings.userinfo_endpoint '{{ oauth_userinfo_endpoint }}'
$DRUSH config:set openid_connect.settings always_save_userinfo true
$DRUSH config:set openid_connect.settings connect_existing_users true
$DRUSH config:set openid_connect.settings override_registration_settings false
$DRUSH config:set openid_connect.settings user_login_display above
$DRUSH config:set openid_connect.settings userinfo_mappings.timezone: zoneinfo
$DRUSH config:set openid_connect.settings userinfo_mappings.user_picture picture
