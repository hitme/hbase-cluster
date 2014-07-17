# Installs Oracle's Java 1.7 for a specified user the rogue way
class java ($user, $shareFolder) {

  $protocol = 'http'
  $domain = 'download.oracle.com/'
  $path = "/otn-pub/java/jdk/7u65-b17/"
  $archive = "jdk-7u65-linux-x64.tar.gz"
  $header = '--header "Cookie: oraclelicense=accept-securebackup-cookie"'
  $javaHome = '$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")'

  Exec {
    path  => '/bin:/usr/bin:/sbin',
    user  => 'root'
  }

  if $::java_version !~ /1\.7.*/ {

    exec { 'download java-7u65-b17':
      command   => "wget ${header} ${protocol}://${domain}${path}${archive}",
      cwd       => $shareFolder,
      logoutput => true,
      timeout   => 1800, # 30 minutes `should be more than enough`,
      onlyif    => "test ! -f ${$shareFolder}/${archive}"
    }

    # Ensure a specific folder structure
    file { '/usr/lib/jvm':
      ensure  => 'directory',
      owner   => 'root'
    }

    exec { 'extract java-7u65-b17':
      command => "tar -xvf ${archive} -C /usr/lib/jvm",
      cwd     => $shareFolder,
      require => [
        File['/usr/lib/jvm'],
        Exec['download java-7u65-b17']
      ]
    }

    exec { 'rename java-7u65-b17':
      command => 'mv /usr/lib/jvm/jdk1.7.0_65 /usr/lib/jvm/java-7-oracle',
      require => Exec['extract java-7u65-b17']
    }

    exec { 'install java':
      command => 'update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-7-oracle/bin/java 100',
      require => Exec['rename java-7u65-b17']
    }

    exec { 'install javac':
      command => 'update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-7-oracle/bin/javac 100',
      require => Exec['rename java-7u65-b17']
    }

    exec { "add JAVA_HOME to ${user} profile":
      command => "echo 'export JAVA_HOME=${javaHome}' >> /home/${user}/.bashrc",
      require => Exec[
        'install java',
        'install javac'
      ]
    }
  }

}