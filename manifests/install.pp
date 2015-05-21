# == Define: python::install
#
# Installs core python packages
#
# === Examples
#
# include python::install
#
# === Authors
#
# Sergey Stankevich
# Ashley Penney
# Fotis Gimian
#

class python::install {

  $python = $::python::version ? {
    'system' => 'python',
    'pypy'   => 'pypy',
    default  => "python${python::version}",
  }

  $pythondev = $::osfamily ? {
    'RedHat' => "${python}-devel",
    'Debian' => "${python}-dev"
  }

  # pip version: use only for installation via os package manager!
  if $::python::version =~ /^3/ {
    $pip = 'python3-pip'
  } else {
    $pip = 'python-pip'
  }

  $dev_ensure = $python::dev ? {
    true    => present,
    default => absent,
  }

  $pip_ensure = $python::pip ? {
    true    => present,
    default => absent,
  }

  $venv_ensure = $python::virtualenv ? {
    true    => present,
    default => absent,
  }

  # Install latest from pip if pip is the provider
  package { $pip: ensure         => $pip_ensure }->
  package { 'pip': ensure        => present, provider => pip }->
  package { 'virtualenv': ensure => present, provider => pip }

  file { '/bin/pip-python':
    target  => '/bin/pip',
    ensure  => link,
    require => Package[$pip]
  }

  package { $pythondev: ensure => $dev_ensure }
  package { $python: ensure => present }

  if $python::manage_gunicorn {
    $gunicorn_ensure = $python::gunicorn ? {
      true    => present,
      default => absent,
    }
    package { 'gunicorn': ensure => $gunicorn_ensure }
  }

}
