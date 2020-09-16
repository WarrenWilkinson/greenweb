-- Enable OAuth
INSERT INTO {{ prefix }}config (config_name, config_value, is_dynamic)
VALUES ('auth_method', 'oauth', 0)
ON CONFLICT (config_name) DO UPDATE SET config_value = 'oauth';

INSERT INTO {{ prefix }}config (config_name, config_value, is_dynamic)
VALUES ('auth_oauth_greenweb_key', 'phpbb', 0)
ON CONFLICT (config_name) DO UPDATE SET config_value = 'phpbb';

INSERT INTO {{ prefix }}config (config_name, config_value, is_dynamic)
VALUES ('auth_oauth_greenweb_secret', '{{ oauth_secret }}', 0)
ON CONFLICT (config_name) DO UPDATE SET config_value = '{{ oauth_secret }}';
