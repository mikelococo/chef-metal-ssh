execute 'apt-get-update' do
  command 'apt-get update'
  ignore_failure true
  not_if { ::File.exists?('/var/lib/apt/periodic/update-success-stamp') }
end

package 'vim-nox'

chef_gem 'chef-metal-ssh' do
  source '/vagrant/pkg/chef-metal-ssh-0.0.3.gem'
  version '0.0.3'
end
