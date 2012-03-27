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


  def dhcpd_conf

    require 'pp'
    pp @conf

    timestamp = Time.gm(*Host.find(:first, :order => 'updated_at DESC', :limit => 1).updated_at)
    
    out = []
    out << "# Last updated #{timestamp}"
    out << ''


    @conf['subnets'].each do |s|
      out << "# #{s['subnet']}:"
      out << "#   ranges:"
      s['ranges'].each do |r|
        out << "#     #{r['range']}#{' - wireless relay' if r['wireless_relay']}#{" - #{r['notes']}" if r['notes']}"
      end
      out << ''
    end

    out << ''

    out << "ddns-update-style none;"
    out << "default-lease-time #{@conf['lease_time']};"
    out << "max-lease-time #{@conf['lease_time']};"
    out << "authoritative;"

    out << ''

    out << %[option domain-name "#{@conf['domain_name']}";]
    out << %[option domain-name-servers #{@conf['domain_name_servers'].join(',')};]

    out << ''

    # Build the ranges for each scope
    scopes = [
      [186, FIRST_186, LAST_186],
      [206, FIRST_206, LAST_206],
      [207, FIRST_207, LAST_207]
    ]
    ranges = []

    # 207 is a special case since there's a hole. 
    guest207 = []
    # Remove IPs that are reserved for "GGSE Guest"
    (FIRST_GUEST..LAST_GUEST).each do |i|
      guest207 << '128.111.207.' + i.to_s
    end


    scopes.each do |scope|
      sub = scope[0]
      first = scope[1]
      last = scope[2]
      ranges[sub] = []
      used = []
      hosts = Host.find_all_by_scope(sub)
      hosts.each { |host| used << host.ip unless host.ip.blank? }
      range_open = false
      range_valid = false 
      start = nil
      stop = nil
      [*first..last].each do |i|
        ip = "128.111.#{sub}.#{i}"

        # Don't consider this address if it's in the GGSE Guest range
        next if guest207.include? ip

        last_ip = "128.111.#{sub}.#{last}"
        if !used.include?(ip) and !range_open
          start = ip 
          range_open = true
        end
        if !used.include?(ip) and range_open
          stop = ip
        end
        if (used.include?(ip) or (ip == last_ip and !used.include?(last_ip))) and range_open
          ranges[sub] << [start,stop]
          range_open = false
          start = stop = nil
        end
      end
    end

    out << "subnet 128.111.206.0 netmask 255.255.255.0 {"
    out << "    option routers 128.111.206.254;"
    out << "    pool {"

    ranges[206].each { |range| out << "        range #{range[0]} #{range[1]};" }

    out << "        deny unknown clients;"
    out << "    }"
    out << "}"

    out << "subnet 128.111.207.0 netmask 255.255.255.0 {"
    out << "    option routers 128.111.207.254;"
    out << "    pool {"

    ranges[207].each { |range| out << "        range #{range[0]} #{range[1]};" }

    out << "        deny unknown clients;"
    out << "    }"
    out << "}"

    out << "subnet 128.111.186.0 netmask 255.255.255.0 {"
    out << "    option routers 128.111.186.254;"
    out << "    class \"wireless\" {"
    out << "        match if (binary-to-ascii(10,8, \".\", packet(24,4)) = \"128.111.186.252\");"
    out << "    }"
    out << "    pool {"
    out << "        allow members of \"wireless\";"
    out << "        range 128.111.186.#{FIRST_WIFI} 128.111.186.#{LAST_WIFI};"
    out << "        default-lease-time 900;"
    out << "        max-lease-time 900;"
    out << "    }" 
    out << "    pool {"

    ranges[186].each { |range| out << "        range #{range[0]} #{range[1]};" }

    out << "        deny unknown clients;"
    out << "    }"
    out << "}"


    out << "group {"
    out << "    filename \"wired\";"

    Host.find_all_by_enabled(true).each do |host|
      out << "        host  #{host.hostname}  { hardware ethernet #{host.mac}; "
      out << "fixed-address #{host.ip}; " unless host.ip.blank? # Only print the fixed address if an IP is specified.
      out << "        }"
    end

    out << "}"


    out << '# File generated successfully' # So we can tell the entire file is generated when we download it.

    out.join "\n"
  end
end
