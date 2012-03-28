require 'ipaddr'

module HostsHelper

  FIRST_206    =  6
  LAST_206     =  200
  FIRST_207    =  5
  LAST_207     =  200
  FIRST_186    =  1
  LAST_186     =  90
  FIRST_WIFI   =  91
  LAST_WIFI    =  199
  FIRST_GUEST  =  96
  LAST_GUEST   =  116
  LEASE_LENGTH = 3*60*60 # 3 hours


  def dhcpd_conf
    # XXX You cannot change the first and last lines. They're consumed by the
    # receiving DHCP server and it expects a specific format. XXX
    #
    [
      "# Last updated #{Host.last_updated}",
      comments,
      globals,
      subnets,
      hosts,
      '# File generated successfully'
    ].join "\n"
  end

  # Return all free IP addresses as a JSON object
  def free_ips_json

    # Gather all used IP address from database
    used = []
    used[206] = []
    used[207] = []
    used[186] = []

    Host.find_all_by_scope('206').each { |e| used[206] << e.ip }
    used[206].uniq!

    Host.find_all_by_scope('207').each { |e| used[207] << e.ip }
    used[207].uniq!

    Host.find_all_by_scope('186').each { |e| used[186] << e.ip }
    used[186].uniq!

    # Calculate all possible IP addresses
    possible = []
    possible[206] = []
    possible[207] = []
    possible[186] = []

    (FIRST_206..LAST_206).each do |i|
      possible[206] << '128.111.206.'+i.to_s
    end

    (FIRST_207..LAST_207).each do |i|
      possible[207] << '128.111.207.'+i.to_s
    end

    (FIRST_186..LAST_186).each do |i|
      possible[186] << '128.111.186.'+i.to_s
    end

    # Remove IPs that are reserved for "GGSE Guest"
    (FIRST_GUEST..LAST_GUEST).each do |i|
      possible[207].delete '128.111.207.' + i.to_s
    end

    # Calculate available IP addresses for each scope
    scope = {}
    scope['206'] = possible[206] - used[206]
    scope['207'] = possible[207] - used[207]
    scope['186'] = possible[186] - used[186]

    # Construct JSON object
    out = '{ "free_ips": { '
    out << ' "scopes": [ '
    scope.each_pair do |k,s|
      out << ' { "id": "'+k+'", '
      out << ' "ips": [ '
      s.each do |ip|
        out << '{ "ip": "'+ip+'" },'
      end
      out.chop! # Removes extraneous comma
      out << '] }, ' 
    end
    out.chop! # Removes extraneous comma 
    out << ' ] } }' 
  end

  private

  #
  # Return an array of IP address pairs which represent DHCPD ranges. The
  # ranges are calculated by running through the list of ips and detecting
  # non-contiguous addresses.
  #
  def ranges(ips)
    ranges, start, prev = [], ips.first, ips.first
    ips.each_with_index do |ip, i|
      prev = ips[i-1] if i > 0
      if ip == ips.last
        ranges << [start, ip]
      elsif ip.to_i - prev.to_i > 1
        ranges << [start, prev]
        start = ip
      end
    end
    ranges
  end

  #
  # Comments so we can glean some useful stuff about the configuration by
  # glancing at the config file
  #
  def comments
    out = []
    out << '#'
    @conf['dhcpd']['subnets'].each do |s|
      out << '# %s/%s via %s' % [s['subnet'], s['netmask'], s['routers']]
      s['pools'].each do |p|
        exceptions = []
        p['exceptions'].each do |e|
          exceptions << ", [except: %s-%s (%s)]" % [e['first'], e['last'], e['notes']]
        end if p['exceptions']
        out << [
          "#   #{p['first']}-#{p['last']}",
          "#{" (#{p['notes']})" if p['notes']}",
            exceptions.join
        ].join
      end
      out << '#'
    end
    out << ''
  end


  def globals
    out = []
    out << raw_options(@conf['dhcpd']['raw_options'])
    out << dhcpd_options(@conf['dhcpd']['options'])
    out << ''
  end

  def dhcpd_options(options, indent=0)
    out = []
    options.each do |key, value|
      value = value.join(',') if value.class == Array
      out << "#{' '*indent}option #{key} #{value.chomp};"
    end if options
    out << ''
  end

  def raw_options(options, indent=0)
    out = []
    options.each do |option|
      out << "#{' '*indent}#{option};"
    end if options
    out << ''
  end


  def classes(subnet)
    out = []
    subnet['classes'].each do |clas|
      out << %[  class "#{clas['class']}" {]
      out << raw_options(clas['raw_options'], 4)
      out << "  }"
      out << ''
    end if subnet['classes']
    out << ''
  end

  def pools(subnet)
    out = []
    subnet['pools'].each do |pool|

      pool_ips = [*IPAddr.new(pool['first'])..IPAddr.new(pool['last'])]
      used_ips = Host.used_ips
      possible_ips = pool_ips.reject do |ip|
        used_ips.include? ip
      end

      pool['exceptions'].each do |h|
        possible_ips.reject! do |ip|
          [*IPAddr.new(h['first'])..IPAddr.new(pool['last'])].include? ip
        end
      end if pool['exceptions']

      out << "  pool {"

      out << raw_options(pool['raw_options'], 4)

      ranges(possible_ips).each do |range|
        out << "    range #{range.first} #{range.last};"
      end
      out << "  }"
      out << ''
    end
    out << ''
  end


  def subnets
    out = []
    @conf['dhcpd']['subnets'].each do |subnet|
      out << "subnet #{subnet['subnet']} netmask #{subnet['netmask']} {"
      out << dhcpd_options(subnet['options'], 2)
      out << raw_options(subnet['raw_options'], 2)
      out << classes(subnet)
      out << pools(subnet)
      out << '}'
      out << ''
    end
    out << ''
  end

  def hosts
    out = []
    out << "group {"
    out << '  filename "deezy";'
    Host.find_all_by_enabled(true).each do |host|
      out << [
        "  host  #{host.hostname}  { hardware ethernet #{host.mac}; ",
        "#{"fixed-address #{host.ip};"  unless host.ip.blank?}",
        "}"
      ].join
    end
    out << "}"
    out << ''
  end
end
