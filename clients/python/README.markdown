# Deltacloud Python Bindings

A simple python client for [![Deltacloud API](http://deltacloud.org)] REST interface


## FEATURES:

- Basic operations with images, instances, hardware-profiles and realms
- Manage instances using start, stop, destroy and reboot operations
- Create new instance from image

## EXAMPLES:

### Launching an instance

    client = Deltacloud('http://localhost:3001/api', 'mockuser', 'mockpassword')
    instance = client.create_instance('img1', { 'hwp_id' => 'm1-small' })

### Listing images/hardware profiles/realms/instances

    client = Deltacloud('http://localhost:3001/api', 'mockuser', 'mockpassword')
    print client.images()
    print client.instances()

### Stopping instance

    client = Deltacloud('http://localhost:3001/api', 'mockuser', 'mockpassword')
    instance = client.instances()[0]
    instance.stop()

