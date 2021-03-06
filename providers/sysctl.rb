# /etc/sysctl.d directory contains settings similar to those found in
# /etc/sysctl.conf.
#
# In general, files in the 10-*.conf range come from the procps package and
# serve as system defaults.  Other packages install their files in the
# 30-*.conf range, to override system defaults.  End-users can use 60-*.conf
# and above, or use /etc/sysctl.conf directly, which overrides anything in this
# directory.

action :create do
  manage_sysctl_config
end

# IMPORTANT
# Deleting a file WILL NOT revert the configs until the system gets rebooted.
# If you want a real undo, you will need to explicitly set the default value (or reboot the system)
#
action :delete do
  manage_sysctl_config
end

#################################################################### IMPLEMENTATION #

def manage_sysctl_config
  service "procps" do
    provider Chef::Provider::Service::Init
  end

  file "/etc/sysctl.d/#{sysctl_name}" do
    content sysctl_contents
    owner "root"
    group "root"
    mode "0644"
    action new_resource.action
    notifies :start, resources(:service => "procps"), :delayed
  end
end

def sysctl_contents
  (
    [
      "# THIS FILE HAS BEEN GENERATED BY CHEF",
      "# ANY MANUAL MODIFICATIONS WILL BE OVERWRITTEN"
    ] +
    new_resource.directives
  ).join("\n") + "\n" # must be a newline, otherwise conf will be invalid!
end

def sysctl_name
  "#{new_resource.priority}-#{new_resource.name || "default"}.conf"
end
