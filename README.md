Puppet Azure Autosign
====
This repository contains an example Puppet autosign script that demonstrates how Azure resources can be queried by Puppet
at then time of instance provision and initial checking and signed without human intervention in event the virtual machine
instance is in the correct subscription and is tagged correctly.

This example code is provided for reference alongside an upcoming puppet.com blog post.

Setup
-------
1. Install and configure the Azure CLI on the instance, ensuring it has read access to the subscription and virtual
 machines contained within.
2. Create the /opt/autosign/autosign.rb file with the script contents in this repo and adjust for your environment.
3. Ensure that the permissions are  pe-puppet:pe-puppet and mode 750 for PE deployments.
4. Update the puppet.conf file to enable policy based autosigning and then restart the puppetserver service.

```
[master]
autosign = /opt/autosign/autosign.rb
```

Example outcomes
-------

* *Test 1*
  * The instance does not exist in our subscription
  * Do not sign certificate (exit 1)

```
----------------------------------------------------------------------
Commencing Azure validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net
 * The certificate / hostname passed to the autosign script does match the standard
 * Querying the Azure API
 * The Azure CLI returned with non-zero when querying pzzzzz9s99zp23s in sourced-dev (Instance not found)
Completed Azure Metadata validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net - NOT Signing CSR
----------------------------------------------------------------------
```

* *Test 2*
  * The Instance resides in our subscription
  * The instance is missing the mandatory tag "missing_tag"
  * Do not sign certificate (exit 1)

```
----------------------------------------------------------------------
Commencing Azure validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net
 * The certificate / hostname passed to the autosign script does match the standard
 * Querying the Azure API
 * The azure CLI command returned zero when querying pzzzzz9s99zp23s in sourced-dev (Instance found)
   * The service_tier MATCHES regex ^(prod|nonprod|lab)$ (Value: prod)
   * The business_unit MATCHES regex ^[a-z0-9]{4}$ (Value: zzzz)
   * The unique_instance_id MATCHES regex ^[a-z0-9]{3}$ (Value: 23s)
   * The tag missing_tag DOES NOT exist and is mandatory
Completed Azure Metadata validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net - NOT Signing CSR
----------------------------------------------------------------------
```

* *Test 3*
  * The instance resides in our subscription
  * The instance has all the required tags
  * The instance tag values don't match the defined regex
  * Do not sign certificate (exit 1)

```
----------------------------------------------------------------------
Commencing Azure validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net
 * The certificate / hostname passed to the autosign script does match the standard
 * Querying the Azure API
 * The azure CLI command returned zero when querying pzzzzz9s99zp23s in sourced-dev (Instance found)
  * The service_tier DOES NOT MATCH regex ^(prod|nonprod|lab)$ (Value: keiran)
  * Aborting further tag evaluation
Completed Azure Metadata validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net - NOT Signing CSR
----------------------------------------------------------------------
```

* *Test 4*
  * The instance meets all our requirements  !
  * Sign the CSR (exit 0)

```
----------------------------------------------------------------------
Commencing Azure validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net
 * The certificate / hostname passed to the autosign script does match the standard
 * Querying the Azure API
 * The azure CLI command returned zero when querying pzzzzz9s99zp23s in sourced-dev (Instance found)
  * The service_tier MATCHES regex ^(prod|nonprod|lab)$ (Value: prod)
  * The business_unit MATCHES regex ^[a-z0-9]{4}$ (Value: zzzz)
  * The unique_instance_id MATCHES regex ^[a-z0-9]{3}$ (Value: 23s)
Completed Azure Metadata validation for instance pzzzzz9s99zp23s.nxj5ujpspjpudkyjyxa00eo44e.cx.internal.cloudapp.net - Signing CSR
----------------------------------------------------------------------
```

Contact
-------
[@keiran_s](http://twitter.com/keiran_s) || [Email - Keiran](mailto:keiran@gmail.com)
