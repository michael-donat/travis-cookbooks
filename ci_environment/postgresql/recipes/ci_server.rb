#
# Following steps must absolutely be executed on cold systems!
#
service 'postgresql' do
  action :stop
end

#
# Tweak default init.d script to deal with following "CI specific" features:
# 1) RAMFS data storage to reduce I/O costs
# 2) Control that only one postgres instance is running at the same time
#    (all instances are configured to listen on the same TCP port)
#
template "/etc/init.d/postgresql" do
  source "initd_postgresql.erb"
  owner  'root'
  group  'root'
  mode   0755
end

#
# Create base directory on RAMFS
#
include_recipe "ramfs" if node['postgresql']['data_on_ramfs']

#
# Tune PostgreSQL settings
#
([node['postgresql']['default_version']] + node['postgresql']['alternate_versions']).each do |pg_version|

  # postgresql.conf template is specific to PostgreSQL version installed
  template "/etc/postgresql/#{pg_version}/main/postgresql.conf" do
    source "#{pg_version}/postgresql.conf.erb"
    owner  'postgres'
    group  'postgres'
    mode   0644        # apply same permissions as in 'pdpg' packages
  end

  # pg_hba.conf template is the same for all PostgreSQL versions (so far)
  template "/etc/postgresql/#{pg_version}/main/pg_hba.conf" do
    source "pg_hba.conf.erb"
    owner  'postgres'
    group  'postgres'
    mode   0640        # apply same permissions as in 'pdpg' packages
  end

end
