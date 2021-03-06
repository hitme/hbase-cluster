# Starts HBase related services
class hbase::start($user, $isMaster) {

  if $isMaster {

    # # Can be moved to its own virtual machine
    # exec { 'start hbase master':
    #   command => "/home/${user}/hbase/bin/start-hbase.sh",
    #   user    => $user,
    #   path    => '/bin:/usr/bin:/sbin'
    # }

    cron { 'start hbase':
      user  => $user,
      special => 'reboot',
      command => "cd /home/${user}/hbase && bin/stop-hbase.sh && bin/start-hbase.sh"
    }
  }

}