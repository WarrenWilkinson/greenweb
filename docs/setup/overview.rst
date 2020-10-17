Overview
========

Even though this project provides a infrastructure 'templates', you're
still going to get your hands dirty setting up your own greenweb.

Have you familiarized yourself with :doc:`launching the development
instance of greenweb</cantrips/runit>`?  We're going to do basically
that, but insert your security passwords in place of several
placeholder passwords. We're also going to:

* Run your production instance locally, just lke a development instance.
* Customize the users database (and talk about how to maintain it).
* Install your production instance onto production hardware.
* Customize DNS records so your site is accessible.
* Discuss back-ups.
* Discuss maintenance and development: how you can build onto your greenweb.

To elaborate that last bullet, the typical development cycle is:

1. Review and pull or create upstream greenweb changes.
2. Modify and maintain your sites salt environment (to be explained).
3. Build/update a local copy of your production instance to work out the kinks.
4. Build/update your production instance.

A strong unix background will be very helpful to you. Greenweb isn't a
'product', it's a set of executable build scripts that deploy a lot of
software products. The better your unix background, the easier
debugging will be for you.
