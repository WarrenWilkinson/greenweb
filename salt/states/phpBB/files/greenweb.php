<?php
/**
 *
 * This file is NOT part of the phpBB Forum Software package.
 *
 * @copyright (c) greenweb
 * @license GNU General Public License, version 2 (GPL-2.0)
 *
 * It's adapted from google.php. Anyone can use this for anything.
 * Warren Wilkinson warrenwilkinson@gmail.com <2020-Aug>
 *
 */

namespace phpbb\auth\provider\oauth\service;

require 'GreenwebOauth.php';

/**
 * Greenweb OAuth service
 */
class greenweb extends base
{
	/** @var \phpbb\config\config */
	protected $config;

	/** @var \phpbb\request\request_interface */
	protected $request;

	/**
	 * Constructor.
	 *
	 * @param \phpbb\config\config				$config		Config object
	 * @param \phpbb\request\request_interface	$request	Request object
	 */
	public function __construct(\phpbb\config\config $config, \phpbb\request\request_interface $request)
	{
		$this->config	= $config;
		$this->request	= $request;
	}

	/**
	 * {@inheritdoc}
	 */
	public function get_auth_scope()
	{
		return [
			'email',
			'openid',
		];
	}

	/**
	 * {@inheritdoc}
	 */
	public function get_service_credentials()
	{
		return [
			'key'		=> $this->config['auth_oauth_greenweb_key'],
			'secret'	=> $this->config['auth_oauth_greenweb_secret'],
		];
	}

    /**
     * Override the php oauth service class. We need a custom one
     * because the underlying library is coupled to each service provider
     * rather than just providing a generic interface.
     */
    public function get_external_service_class()
    {
        return "OAuth\OAuth2\Service\Greenweb";
    }

	/**
	 * {@inheritdoc}
	 */
	public function perform_auth_login()
	{
		if (!($this->service_provider instanceof \OAuth\OAuth2\Service\Greenweb))
		{
			throw new exception('AUTH_PROVIDER_OAUTH_ERROR_INVALID_SERVICE_TYPE');
		}

		try
		{
			// This was a callback request, get the token
			$this->service_provider->requestAccessToken($this->request->variable('code', ''));
		}
		catch (\OAuth\Common\Http\Exception\TokenResponseException $e)
		{
			throw new exception('AUTH_PROVIDER_OAUTH_ERROR_REQUEST');
		}

		try
		{
			// Send a request with it
			$result = (array) json_decode($this->service_provider->request('https://www.greenwebapis.com/oauth2/v1/userinfo'), true);
		}
		catch (\OAuth\Common\Exception\Exception $e)
		{
			throw new exception('AUTH_PROVIDER_OAUTH_ERROR_REQUEST');
		}

		// Return the unique identifier
		return $result['id'];
	}

	/**
	 * {@inheritdoc}
	 */
	public function perform_token_auth()
	{
		if (!($this->service_provider instanceof \OAuth\OAuth2\Service\Greenweb))
		{
			throw new exception('AUTH_PROVIDER_OAUTH_ERROR_INVALID_SERVICE_TYPE');
		}

		try
		{
			// Send a request with it
			$result = (array) json_decode($this->service_provider->request('https://www.greenwebapis.com/oauth2/v1/userinfo'), true);
		}
		catch (\OAuth\Common\Exception\Exception $e)
		{
			throw new exception('AUTH_PROVIDER_OAUTH_ERROR_REQUEST');
		}

		// Return the unique identifier
		return $result['id'];
	}
}
