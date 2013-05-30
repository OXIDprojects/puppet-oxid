class oxid::php {
  include oxid::php::params
  $module_path = get_module_path('oxid')
  
  package { $oxid::php::params::packages: ensure => installed, require => Package["apache2"] } ->   
  
  file { ["/usr/local/zend/", "/usr/local/zend/lib/", "/usr/local/zend/lib/php/", "/usr/local/zend/lib/php/extensions/"]:
    owner   => "root",
    group   => "root",
    ensure => "directory"
  } ->
  
  file { "/usr/local/zend/lib/php/extensions/ZendGuardLoader.so":
    owner   => "root",
    group   => "root",
    source  => "${module_path}/files/zend/php-5.3.x/ZendGuardLoader.so",
    ensure => "directory"
  } ->

  file { "/etc/php5/apache2/conf.d/zend_guard.ini":
    owner   => "root",
    group   => "root",
    source  => "${module_path}/files/zend/zend_guard.ini"
  } ->
  
  file { $oxid::php::params::config:
    ensure  => present 
  }  
}