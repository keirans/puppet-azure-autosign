
#!/usr/bin/ruby
# Example Puppet Autosign script for Azure
# Keiran Sweet, Sourced Group
#
# Note:
# For example purposes all output goes to STDERR so it appears in the puppetserver.log
#
 
require 'json'
azuresubscriptionname = 'sourced-dev'
 
#
# The tags that must be present on an instance alongside the regex to validate
# their values when set.
#
tagregex = {
    'service_tier'        => '^(prod|nonprod|lab)$',
    'business_unit'       => '^[a-z0-9]{4}$' ,
    'unique_instance_id'  => '^[a-z0-9]{3}$',
}
 
STDERR.puts ""
STDERR.puts "----------------------------------------------------------------------"
STDERR.puts "Commencing Azure validation for instance #{ARGV[0]}"
 
# Validate the certificate/hostname being passed to us first. (We match everything for this example)
unless ARGV[0].match('^.*$')
  STDERR.puts " * The certificate / hostname passed to the autosign script DOES NOT match the standard - Exiting"
  exit(1)
else
  STDERR.puts " * The certificate / hostname passed to the autosign script does match the standard"
  servernamearray = ARGV[0].split('.')
  servername = servernamearray[0]
end
 
STDERR.puts " * Querying the Azure API"
jsonraw = %x(/bin/azure vm list -s #{azuresubscriptionname} #{servername} --json 2>>/dev/null)
 
if $? == 0
  puts " * The azure CLI command returned zero when querying #{servername} in #{azuresubscriptionname} (Instance found)"
 
else
  puts " * The Azure CLI returned with non-zero when querying #{servername} in #{azuresubscriptionname} (Instance not found) "
  STDERR.puts "Completed Azure Metadata validation for instance #{ARGV[0]} - NOT Signing CSR"
  STDERR.puts "----------------------------------------------------------------------"
  STDERR.puts ""
  exit(1)
end
 
json = JSON.parse(jsonraw)
 
# We now validate each of the tags to make sure that they match the regex defined for each
# tag in the tagregex hash.
 
tagregex.keys.each { | tagname |
  if json[0]['tags'].key?(tagname)
    if json[0]['tags'][tagname].match(tagregex[tagname])
      STDERR.puts "  * The #{tagname} MATCHES regex #{tagregex[tagname]} (Value: #{json[0]['tags'][tagname]})"
    else
      STDERR.puts "  * The #{tagname} DOES NOT MATCH regex #{tagregex[tagname]} (Value: #{json[0]['tags'][tagname]}) "
      STDERR.puts "  * Aborting further tag evaluation"
      STDERR.puts "Completed Azure Metadata validation for instance #{ARGV[0]} - NOT Signing CSR"
      STDERR.puts "----------------------------------------------------------------------"
      STDERR.puts ""
      exit(1)
    end
  else
    STDERR.puts "  * The tag #{tagname} DOES NOT exist and is mandatory"
    STDERR.puts "Completed Azure Metadata validation for instance #{ARGV[0]} - NOT Signing CSR"
    STDERR.puts "----------------------------------------------------------------------"
    STDERR.puts ""
    exit(1)
  end
}
STDERR.puts "Completed Azure Metadata validation for instance #{ARGV[0]} - Signing CSR"
STDERR.puts "----------------------------------------------------------------------"
STDERR.puts "" 
