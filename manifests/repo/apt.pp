# requires
#   puppetlabs-apt
#   puppetlabs-stdlib
#
# @api private
class rabbitmq::repo::apt(
  String $location               = 'https://packagecloud.io/rabbitmq/rabbitmq-server',
  String $repos                  = 'main',
  Boolean $include_src           = false,
  String $key                    = '8C695B0219AFDEB04A058ED8F4E789204D206F89',
  String $key_source             = $rabbitmq::package_gpg_key,
  Optional[String] $key_content  = $rabbitmq::key_content,
  Optional[String] $architecture = undef,
  ) {

  $pin = $rabbitmq::package_apt_pin

  # ordering / ensure to get the last version of repository
  Class['rabbitmq::repo::apt']
  -> Class['apt::update']

  $osname = downcase($facts['os']['name'])
  apt::source { 'rabbitmq':
    ensure       => present,
    location     => "${location}/${osname}",
    repos        => $repos,
    include      => { 'src' => $include_src },
    key          => {
      'id'      => $key,
      'source'  => $key_source,
      'content' => $key_content,
    },
    architecture => $architecture,
  }

  if $pin {
    apt::pin { 'rabbitmq':
      packages => '*',
      priority => $pin,
      origin   => 'packagecloud.io',
    }
  }

  apt::source { 'erlangsolutions':
    location    => 'https://packages.erlang-solutions.com/debian',
    release     =>  "${lsbdistcodename}",
    repos       => 'contrib',
    key         => {
      id => '434975BD900CCBE4F7EE1B1ED208507CA14F4FCA',
      source => 'https://packages.erlang-solutions.com/debian/erlang_solutions.asc'
    },
    before   => [ Class['Apt::Update'] ],
  }

  apt::key { 'rabbitmq':
    id => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
    source  => 'https://www.rabbitmq.com/rabbitmq-release-signing-key.asc',
    require => Apt::Source['erlangsolutions'],
  }

  apt::pin { 'erlangsolutions':
    originator => 'Erlang Solutions Ltd.',
    packages => '*',
    priority => '999'
  }

}
