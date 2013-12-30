class oxid::php::zendguardloader (
  $php_dir       = "/etc/php5/apache2/conf.d",
  $extension_dir = "/usr/local/zend/lib/php/extensions",
  $version       = "5.3",
  $repository    = $oxid::params::zend_repository,
  $zend_optimizer_optimization_level = 15,
  $zend_loader_license_path          = "",
  $zend_loader_disable_licensing     = 0,
  $ini_source    = undef) inherits oxid::apache::params {
  if defined(Class['apache::mod::php']) {
    Class['apache::mod::php'] -> Oxid::Php::Zendguardloader <| |>
  }
  $downloads = {
    "5.3-i386"   => "5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz",
    "5.3-x86_64" => "5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz"
  }

  $supported_versions = ['5.3']
  $found = grep($supported_versions, $version)

  if count($found) == 0 {
    $supported_versions_str = join($supported_versions, ',')
    fail("Version ${version} is not supported, only following versions: ${supported_versions_str}")
  }

  $source = $downloads["${version}-${hardwaremodel}"]
  $download_basename = inline_template("<%= File.basename(@source) %>")
  $download_basename_without_extension = inline_template("<%= File.basename(@download_basename, '.tar.gz') %>")
  /* $archive_file = "${oxid::params::tmp_dir}/${download_basename}" */
  $version_dir = "php-${version}.x"
  $zend_loader_extension_file = "${extension_dir}/loader/${version_dir}/ZendGuardLoader.so"

  $repo_config = $oxid::params::repository_configs["${repository}"]
  $repo_dir = $repo_config['directory']

  $archive_file = inline_template("<%= File.join(@repo_dir, File.basename(@source)) %>")

  oxid::repository::get { $name:
    repository => $repository,
    source     => $source
  } ->
  exec { "mkdir -p '${extension_dir}/loader'":
    path   => $oxid::params::path,
    unless => "test -d $(dirname '${zend_loader_extension_file}')"
  } ->
  exec { "tar --directory ${extension_dir}/loader --strip-components=1 -zxvf ${archive_file} ${download_basename_without_extension}/${version_dir}/ZendGuardLoader.so"
  :
    path    => $oxid::params::path,
    unless  => "test -f '${zend_loader_extension_file}'",
    require => Class[oxid::package::packer]
  } ->
  file { "${oxid::php::params::confdir}/zend_guard.ini":
    owner   => "root",
    group   => "root",
    content => $ini_source ? {
      undef   => template("oxid/php/zend-guard-loader.erb"),
      default => undef
    },
    source  => $ini_source ? {
      undef   => undef,
      default => $ini_source
    },
    notify  => Service[$oxid::apache::params::service_name]
  }
}