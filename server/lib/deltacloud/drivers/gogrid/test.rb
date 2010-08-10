require 'gogrid_client'
require 'ap'

user='fbb1de3897597ccf'
password='ngieth10'

client=GoGridClient.new('https://api.gogrid.com/api', user, password)

ap client.request('grid/ip/list', {
  'ip.type' => '1',
  'ip.state' => '1',
  'datacenter' => '1'
})
