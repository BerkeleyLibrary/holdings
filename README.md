# BerkeleyLibrary::Location

[![Build Status](https://github.com/BerkeleyLibrary/location/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/BerkeleyLibrary/location/actions/workflows/build.yml)
[![Gem Version](https://img.shields.io/gem/v/berkeley_library-location.svg)](https://github.com/BerkeleyLibrary/location/releases)

Miscellaneous location-related utilities for the UC Berkeley Library.

Updated to Worldcat API Version 2:
https://developer.api.oclc.org/wcv2#/Member%20General%20Holdings/find-bib-holdings


NOTE: For new and updated tests we've implemented the use of VCR to handle API mocks. Therefore in order to run tests, you'll need to have your API Key and Secret set as environment variables:
LIT_WORLDCAT_API_KEY
LIT_WORLDCAT_API_SECRET

Once the cassettes are created you can force a re-recording of cassettes by adding the following ENV:
RE_RECORD_VCR="true"
