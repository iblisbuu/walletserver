#
# Cookbook Name:: coins
# Recipe:: setup_bitcoin
#
# Copyright 2014, Alexey Zilber
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#  include_attribute "coins::bitcoin"

log "Install #{node[:coins][:bitcoin][:executable]} into #{node[:walletserver][:root]}"


  directory "#{node[:walletserver][:root]}/build/bitcoin" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    recursive true
  end

  template "#{node[:walletserver][:root]}/build/bitcoin/makefile.bitcoin.unix" do
    source "makefile.bitcoin.unix.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0644
  end

log "Configuring #{node[:coins][:bitcoin][:executable]} with rpc_allow_net=#{node[:coins][:bitcoin][:rpc_allow_net]}, port #{node[:coins][:bitcoin][:rpc_port]}"

  template "#{node[:walletserver][:root]}/configs/#{node[:coins][:bitcoin][:executable]}.conf" do
    source "coin.conf.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:bitcoin][:executable],
       :rpcuser => node[:coins][:bitcoin][:rpc_user],
       :rpcpass => node[:coins][:bitcoin][:rpc_pass],
       :rpcnet => node[:coins][:bitcoin][:rpc_allow_net],
       :rpcport => node[:coins][:bitcoin][:rpc_port]
    })
    mode 0600
  end


  template "#{node[:walletserver][:root]}/control/start-#{node[:coins][:bitcoin][:executable]}.sh" do
    source "control-start-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:bitcoin][:executable],
       :rpcuser => node[:coins][:bitcoin][:rpc_user],
       :rpcpass => node[:coins][:bitcoin][:rpc_pass],
       :rpcport => node[:coins][:bitcoin][:rpc_port]
    })
    mode 0700
  end

  template "#{node[:walletserver][:root]}/control/stop-#{node[:coins][:bitcoin][:executable]}.sh" do
    source "control-stop-default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:bitcoin][:executable],
       :rpcuser => node[:coins][:bitcoin][:rpc_user],
       :rpcpass => node[:coins][:bitcoin][:rpc_pass],
       :rpcport => node[:coins][:bitcoin][:rpc_port]
    })
    mode 0700
  end

  directory "#{node[:walletserver][:root]}/data/#{node[:coins][:bitcoin][:executable]}" do
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    mode 0700
    recursive true
  end


  template "/etc/monit.d/bitcoin.conf" do
    source "monit_default.erb"
    owner node[:walletserver][:daemon][:user]
    group node[:walletserver][:daemon][:group]
    variables({
       :procname => node[:coins][:bitcoin][:executable],
       :coinuser => node[:walletserver][:daemon][:user],
       :coingroup => node[:walletserver][:daemon][:group],
       :rpchost => "127.0.0.1",
       :rpcport => node[:coins][:bitcoin][:rpc_port]
    })
    mode 0600
  end

  remote_file "#{Chef::Config[:file_cache_path]}/bitcoin.tar.gz" do
         source node[:coins][:bitcoin][:source]
         mode "0644"
         backup false
         action :create_if_missing
         notifies :run, 'bash[setup_bitcoin]', :immediately
         notifies :reload, 'service[monit]', :immediately
  end

  bash "setup_bitcoin" do
    user "#{node[:walletserver][:daemon][:user]}"
    code <<-EOH
      export LDFLAGS="#{node[:walletserver][:ldflags]}"

      export CPPFLAGS="#{node[:walletserver][:cppflags]}"

      tar -xzvp --strip-components 1 -f #{Chef::Config[:file_cache_path]}/bitcoin.tar.gz -C #{node[:walletserver][:root]}/build/bitcoin/
      (cd #{node[:walletserver][:root]}/build/bitcoin/src/src  && make -f #{node[:walletserver][:root]}/build/bitcoin/makefile.bitcoin.unix )

      strip #{node[:walletserver][:root]}/build/bitcoin/src/src/#{node[:coins][:bitcoin][:executable]}

      mv -f #{node[:walletserver][:root]}/build/bitcoin/src/src/#{node[:coins][:bitcoin][:executable]} #{node[:walletserver][:root]}/daemons/

    EOH
    action :nothing
  end

