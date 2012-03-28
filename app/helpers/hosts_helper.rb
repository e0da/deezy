require 'ipaddr'

module HostsHelper

  def dhcpd_conf

    used_ips = []
    Host.find_all_by_enabled(true).collect do |host|
      used_ips << IPAddr.new(host.ip) unless host.ip.blank?
    end

    require 'pp'

    pp @conf

    timestamp = Time.gm(*Host.find(:first, :order => 'updated_at DESC', :limit => 1).updated_at)
    
    out = []

    # XXX You cannot change this line. It must be the first line, and it must
    # not be edited. This line is how the consuming DHCP server determines
    # whether to HUP the daemon.
    #
    out << "# Last updated #{timestamp}"

    out << ''

    # comments so we can glean some useful stuff about the configuration by
    # glancing at the config file
    #
    @conf['dhcpd']['subnets'].each do |s|
      out << '# %s/%s via %s' % [s['subnet'], s['netmask'], s['routers']]
      s['pools'].each do |p|
        out << [
          "#   #{p['first']}-#{p['last']}",
          "#{" (wireless relay)" if p['wireless_relay']}",
          "#{" '#{p['notes']}'" if p['notes']}"
        ].join
      end
      out << '#'
    end

    out << ''

    @conf['dhcpd']['subnets'].each do |s|
      out << "subnet #{s['subnet']} netmask #{s['netmask']} {"
      out << "  option routers #{s['routers']};"

      s['pools'].each do |p|
        possible_ips = [*IPAddr.new(p['first'])..IPAddr.new(p['last'])].reject do |ip|
          used_ips.include? ip
        end
        p['holes'].each do |h|
          possible_ips = possible_ips.reject do |ip|
            [*IPAddr.new(h['first'])..IPAddr.new(p['last'])].include? ip
          end
        end if p['holes']

        out << "  pool {"
        possible_ips.each do |ip|
          out << "    range #{ip} #{ip};"
        end
        out << "  }"
      end

      out << '}'
    end

    out << "\n\n\n\n\n"


    out << "group {"
    out << '    filename "deezy";'

    Host.find_all_by_enabled(true).each do |host|
      out << [
        "        host  #{host.hostname}  { hardware ethernet #{host.mac}; ",
        "#{"fixed-address #{host.ip};"  unless host.ip.blank?}",
        "}"
      ].join
    end

    out << "}"


    out << '# File generated successfully' # So we can tell the entire file is generated when we download it.

    out.join "\n"
  end

  # Return all free IP addresses as a JSON object
  def free_ips_json

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
end
