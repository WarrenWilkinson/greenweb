<?php
/**
 *
 * This file is NOT part of the phpBB Forum Software package.
 *
 * @copyright (c) greenweb
 * @license GNU General Public License, version 2 (GPL-2.0)
 *
 * It's adapted from PHPoAuthLib examples. Anyone can use this for anything.
 * Warren Wilkinson warrenwilkinson@gmail.com <2020-Aug>
 */

namespace OAuth\OAuth2\Service;

use OAuth\Common\Consumer\CredentialsInterface;
use OAuth\Common\Http\Client\ClientInterface;
use OAuth\Common\Http\Exception\TokenResponseException;
use OAuth\Common\Http\Uri\Uri;
use OAuth\Common\Http\Uri\UriInterface;
use OAuth\Common\Storage\TokenStorageInterface;
use OAuth\OAuth2\Token\StdOAuth2Token;

//class Greenweb extends AbstractService
class Greenweb extends Google
{
}
