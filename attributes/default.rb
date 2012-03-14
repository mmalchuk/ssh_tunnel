default[:ssh_tunnel][:list] = [
  {
    :name => "default_tunnel",
    :enabled => false,
    :config => {
      :loc_addr => "127.0.0.1",
      :loc_port => "",
      :gw_addr => "",
      :gw_port => "22",
      :gw_user => "root",
      :gw_cert => "/etc/ssh_tunnel",
      :rem_addr => "",
      :rem_port => "",
      :private_key => ""
    },
	:action => 'start'
  },
  {
    :name => "test_tunnel",
    :enabled => true,
    :config => {
      :loc_addr => "127.0.0.1",
      :loc_port => "2222",
      :gw_addr => "217.23.92.253",
      :gw_port => "22",
      :gw_user => "root",
      :gw_cert => "/etc/ssh_tunnel",
      :rem_addr => "217.23.92.197",
      :rem_port => "110",
      :private_key => "-----BEGIN RSA PRIVATE KEY-----
some pem-encoded data
-----END RSA PRIVATE KEY-----"
    },
	:action => 'restart'
  }
]
