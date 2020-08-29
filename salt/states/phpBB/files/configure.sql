UPDATE {{ prefix }}config SET config_value = 'key' WHERE config_name = 'auth_oauth_greenweb_key';
UPDATE {{ prefix }}config SET config_value = '{{ oauth_secret }}' WHERE config_name = 'auth_oauth_greenweb_secret';
