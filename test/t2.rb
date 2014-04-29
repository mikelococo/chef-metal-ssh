#!/usr/bin/env ruby
require 'json'

new_machine = {
  "cpu_type" => "",
  "memory" => "256",
  "subnet" => "255.255.255.0",
  "machine_types" => [
    # "app_servers",
    # "web_server"
  ],
  "ip_address" => "192.168.33.21"
}

def validate_machine_options(node)
  allowed_new_machine_keys = %w{
    ssh_cluster_path
    machine_types
    mac_address
    ip_address
    subnet
    hostname
    domain
    fqdn
    memory
    cpu_count
    cpu_type
    arch
  }

  # Validate Machine Options
  new_machine.each { |k,v| raise 'Invalid Machine Option' unless allowed_new_machine_keys.include?(k) }

  if new_machine['cpu_type'] && ! new_machine['cpu_type'].empty?
    raise "Bad Cpu Type" unless ( new_machine['cpu_type'] == 'intel' || new_machine['cpu_type'] == 'amd' )
  end

  if new_machine['arch']
    raise "No Such Arch. Either i386 or x86_64" unless ( new_machine['arch'] == 'i386' || new_machine['arch'] == 'x86_64' )
  end

end

def registered_machine_is_available?(v)
  case v
  when "false"
    false
  when "true"
    true
  end
end

def match_and_registered
  Dir.glob('/tmp/rgm/*.json').sort.each do |registered_machine_file|

    # Not Available By Default.
    available_registered_machine = false

    # Fail By Default.
    will_work      = false
    not_gonna_work = false

    puts registered_machine_file
    registered_machine_json = JSON.parse(File.read(registered_machine_file))

    registered_machine_json.each_pair do |k,v|
      if k == "available"
        available_registered_machine = true if registered_machine_is_available?(v)
        break unless available_registered_machine
      else
        if available_registered_machine
          if new_machine.has_key?(k)
            case v
            when String
              # see if registered_machine value equals value in new_machine
              if v == new_machine[k]
                # puts 'value'
                # puts v
                # puts 'new_machine[k]'
                # puts new_machine[k]
                will_work = true
              else
                # puts 'nah'
                # puts 'v'
                # puts v
                # puts 'new_machine[k]'
                # puts new_machine[k]
                # next if new_machine[k].nil? || new_machine[k].empty?
                not_gonna_work = true unless new_machine[k].nil? || new_machine[k].empty?
                # raise 'nah'
              end
            when Array
              Array(new_machine[k]).each do |sv|
                if v.include?(sv)
                  puts 'V INCLUDES'
                  will_work = true
                else
                  puts 'V NO INCLUDES'
                  not_gonna_work = true
                  break
                end
              end
            when Hash
            end
          end
        end
      end
    end

    # If we decided it will work and nobody said otherwise, we have a match.
    if will_work == true && not_gonna_work == false

      # Strip out any erroneous empty hash keys so we don't overwrite non-empty
      # registered values with empty passed values
      stripped_machine_json = JSON.parse(new_machine.to_json).delete_if { |k, v| v.empty? unless k == 'machine_types' }

      # Chef::Log.debug("======================================>")
      # Chef::Log.debug("machine_registration_match - stripped_machine_json: #{stripped_machine_json.inspect}")
      # Chef::Log.debug("======================================>")

      new_registraton = Hash.new
      new_registraton = registered_machine_json.merge!(stripped_machine_json)

      # We're off the market
      set_available_to_false = { "available" => "false" }
      new_registraton = new_registraton.merge!(JSON.parse(set_available_to_false.to_json))
      puts
      puts new_registraton.inspect
      break
    end

  end
end


# registered_machine = {
#   "available" =>  "false",
#   # "available" =>  "true",
#   "ip_address" =>  "192.168.33.22",
#   "mac_address" =>  "",
#   "hostname" =>  "",
#   "subnet" =>  "",
#   "domain" =>  "",
#   "fqdn" =>  "",
#   "allowed_machine_types" => [
#     "app_server",
#     "web_server"
#   ],
#   "assign_machine_types" => [

#   ],
#   "memory" =>  "",
#   "cpu_count" =>  "",
#   "cpu_type" =>  "",
#   "arch" =>  ""
# }
