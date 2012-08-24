Deltacloud API tests guide
==========================

Running tests
-----------------------

Each test can be run manually using:

$ bundle exec ruby tests/drivers/ec2/realms_test.rb

In addition to manual run, you can use one of there Rake tasks:

$ rake test                 # Run all tests

This Rake task will run all the tests below:

Frontend tests:

$ rake test:base            # Run tests for base
$ rake test:cimi:models     # Run tests for models
$ rake test:ec2             # Run tests for ec2

Driver tests:

$ rake test:drivers:ec2     # Run tests for ec2
$ rake test:drivers:mock    # Run tests for mock
$ rake test:drivers:rhevm   # Run tests for rhevm

Driver and core helpers
-----------------------

* drivers/

This directory provides all **driver** tests. Each driver tests are placed into
separate directory with the driver name.  Everything that does touch the driver
API goes here as well. It's a good practice to divide the tests into logical
collections, in this case to driver methods.

Driver tests use the Deltacloud::new method to create new instance of driver.
This method is usually called in 'before' block. Method does take two
parameters: driver name and credentials.  You can then call the driver methods
directly on the instance of Deltacloud::new.

Some driver tests may use VCR gem to record and then mock the real communication
with the backend server. In that case, the fixtures produced by this recording
are stored in the 'tests/drivers/DRIVER/fixtures' directory.

For more informations about recording, look into 'tests/drivers/ec2/common.rb'
file.

The 'base' directory contain tests for Deltacloud::Driver class and the Library
class.

* helpers/

Deltacloud core class helpers (String, Integer, etc...).


Frontend tests
--------------------------------------

In addition to default 'deltacloud' frontend Deltacloud may also operate using
different frontend. In this case, instead of exposing the DC API specification
to the client, Deltacloud will provide its drivers API through different
frontend (like CIMI or Amazon EC2).

Some tests might use the Mock driver to call the 'control' blocks in Rabbit
collections.  These tests are **not** driver tests, they just use the mock
driver to make sure the Rabbit operation 'control blocks' works as expected and
they provide expected output.

* deltacloud/

This directory provides tests for Deltacloud API frontend. It contains tests
for collections that this frontend provides and also tests helpers that this
frontend use.

* ec2/

This directory provides tests for the EC2 frontend. Tests make sure that mapping
between EC2 actions and Deltacloud driver API works correctly. All tests
relevant to EC2 frontend tests should go here. **NOTE** this directory does not
provide Amazon EC2 driver tests.

* cimi/

This directory provides tests for the CIMI frotend. They make sure that
JSON/XML serialization of the CIMI models works correctly. Also there are tests
to make sure the output provided by CIMI collections is correct.


Updating VCR data
------------------

In some cases you will need to re-record the VCR fixtures for particular test.
This happen when a new request is made to the backend cloud in method that
already has tests. To do so, you will need your own credentials. Then in the
'before' section of test you will need to use Time.be method to freeze time
to the current time and use your credentials instead of 'default' ones.

NOTE: This may change at some point to be more user-friendly.


Test scenarios
=================

Bug/feature in the Deltacloud driver
---------------------------------

* Scenario: You fixed a bug in EC2 driver, where images() method does not work
            properly.

* Steps:    1. Open 'tests/drivers/ec2/images_tests.rb'
            2. Since the current tests did not capture this bug, go to the end
               of this file and add yoru code there:

               it 'should provide correct output' do
                # assertions go here
               end

* Scenario: You added new collection 'oranges()' into RHEV-M driver.

* Steps:    1. Write all driver methods tests here: 'tests/drivers/rhevm/oranges_tests.rb'
            2. Create 'tests/deltacloud/collections/oranges_collection_tests.rb'
            3. Write all collection operations tests here ^^


Bug/feature in the Deltacloud frontnend
------------------------------------

* Scenario: The '/api/images/123/create' operation does not provide correct
            status code. You corrected it.

* Steps:    1. Open 'tests/deltacloud/collections/images_collection_test.rb'
            2. Locate this line:
               it 'allow to create and destroy the new image' do
            3. Provide the correct value into 'status.must_equal' method
