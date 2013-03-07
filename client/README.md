# deltacloud-client

The Deltacloud project includes a Ruby client.  Other language-bindings
are possible and will be supported soon.  The client aims to insulate
users from having to deal with HTTP and REST directly.

Each resource type has an associated model to ease usage.  Where
resource reference other resources, natural navigation across the
object model is possible.

This is a Ruby client library for the [Deltacloud API](http://deltacloud.apache.org).

## Usage

```ruby
require 'deltacloud/client'

API_URL = "http://localhost:3001/api" # Deltacloud API endpoint

# Simple use-cases
client = Deltacloud::Client(API_URL, 'mockuser', 'mockpassword')

pp client.instances           # List all instances
pp client.instance('i-12345') # Get one instance

inst = client.create_instance 'ami-1234', :hwp_id => 'm1.small' # Create instance

inst.reboot!  # Reboot instance

# Advanced usage

# Deltacloud API supports changing driver per-request:

client.use(:ec2, 'API_KEY', 'API_SECRET').instances # List EC2 instances
client.use(:openstack, 'admin@tenant', 'password', KEYSTONE_URL).instances # List Openstack instances

```
# Want help?

## Adding new Deltacloud collection to client

```
$ rake generate[YOUR_COLLECTION] # eg. 'storage_snapshot'
# Hit Enter 2x
```

- Edit `lib/deltacloud/client/methods/YOUR_COLLECTION.rb` and add all
  methods for manipulating your collection. The list/show methods
  should already be generated for you, but double-check them.

- Edit `lib/deltacloud/client/model/YOUR_COLLECTION.rb` and add model
  methods. Model methods should really be just a syntax sugar and exercise
  the *Deltacloud::Client::Methods* methods.
  The purpose of *model* class life is to deserialize XML body received
  from Deltacloud API to a Ruby class.

## Debugging a nasty bug?

- You can easily debug deltacloud-client using powerful **pry**.

  - `gem install deltacloud-core`
  - optional: `rbenv rehash` ;-)
  - `deltacloudd -i mock -p 3002`
  - `rake console`

Console require **pry** gem installed. If you are not using this awesome
gem, you can fix it by `gem install pry`.

# License

Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/
