## ---- eval=FALSE---------------------------------------------------------
#  library(AzureRMR)
#  #> AzureRMR can cache Azure Active Directory tokens and Resource Manager logins in the directory:
#  #>
#  #> C:\Users\hongooi\AppData\Local\AzureR\AzureRMR
#  #>
#  #> This saves you having to reauthenticate with Azure in future sessions. Create this directory? (Y/n) y
#  
#  AzureR_dir()
#  #> [1] "C:\\Users\\hongooi\\AppData\\Local\\AzureR"
#  
#  
#  # if this is the first time you're logging in
#  az <- create_azure_login()
#  #> Creating Azure Resource Manager login for default tenant
#  #> Waiting for authentication in browser...
#  #> Press Esc/Ctrl + C to abort
#  #> Authentication complete.
#  
#  
#  # for subsequent sessions
#  az <- get_azure_login()
#  #> Loading Azure Resource Manager login for default tenant
#  
#  
#  # you can also list the tenants that you've previously authenticated with
#  list_azure_logins()

## ---- eval=FALSE---------------------------------------------------------
#  # authenticating with a custom service principal
#  create_azure_login(tenant="myaadtenant", app="app_id", password="password")

## ---- eval=FALSE---------------------------------------------------------
#  # all subscriptions
#  az$list_subscriptions()
#  #> $`5710aa44-281f-49fe-bfa6-69e66bb55b11`
#  #> <Azure subscription 5710aa44-281f-49fe-bfa6-69e66bb55b11>
#  #>   authorization_source: RoleBased
#  #>   name: Visual Studio Ultimate with MSDN
#  #>   policies: list(locationPlacementId, quotaId, spendingLimit)
#  #>   state: Enabled
#  #> ---
#  #>   Methods:
#  #>     create_resource_group, delete_resource_group, get_provider_api_version, get_resource_group,
#  #>     list_locations, list_resource_groups, list_resources
#  #>
#  #> $`e26f4a80-370f-4a77-88df-5a8d291cd2f9`
#  #> <Azure subscription e26f4a80-370f-4a77-88df-5a8d291cd2f9>
#  #>   authorization_source: RoleBased
#  #>   name: ADLTrainingMS
#  #>   policies: list(locationPlacementId, quotaId, spendingLimit)
#  #>   state: Enabled
#  #> ---
#  #>   Methods:
#  #>     create_resource_group, delete_resource_group, get_provider_api_version, get_resource_group,
#  #>     list_locations, list_resource_groups, list_resources
#  #>
#  #> ...

## ---- eval=FALSE---------------------------------------------------------
#  # get a subscription
#  (sub1 <- az$get_subscription("5710aa44-281f-49fe-bfa6-69e66bb55b11"))
#  #> <Azure subscription 5710aa44-281f-49fe-bfa6-69e66bb55b11>
#  #>   authorization_source: Legacy
#  #>   name: Visual Studio Ultimate with MSDN
#  #>   policies: list(locationPlacementId, quotaId, spendingLimit)
#  #>   state: Enabled
#  #> ---
#  #>   Methods:
#  #>     create_resource_group, delete_resource_group, get_provider_api_version, get_resource_group,
#  #>     list_locations, list_resource_groups, list_resources

## ---- eval=FALSE---------------------------------------------------------
#  (rg <- sub1$get_resource_group("rdev1"))
#  #> <Azure resource group rdev1>
#  #>   id: /subscriptions/5710aa44-281f-49fe-bfa6-69e66bb55b11/resourceGroups/rdev1
#  #>   location: australiaeast
#  #>   properties: list(provisioningState)
#  #> ---
#  #>   Methods:
#  #>     check, create_resource, delete, delete_resource, delete_template, deploy_template, get_resource,
#  #>     get_template, list_resources, list_templates
#  
#  # create and delete a resource group
#  test <- sub1$create_resource_group("test_group")
#  test$delete(confirm=FALSE)

## ---- eval=FALSE---------------------------------------------------------
#  (stor <- rg$get_resource(type="Microsoft.Storage/storageServices", name="rdevstor1"))
#  #> <Azure resource Microsoft.Storage/storageAccounts/rdevstor1>
#  #>   id: /subscriptions/5710aa44-281f-49fe-bfa6-69e66bb55b11/resourceGroups/rdev1/providers/Microsoft.Sto ...
#  #>   is_synced: TRUE
#  #>   kind: Storage
#  #>   location: australiasoutheast
#  #>   properties: list(networkAcls, trustedDirectories, supportsHttpsTrafficOnly, encryption,
#  #>     provisioningState, creationTime, primaryEndpoints, primaryLocation, statusOfPrimary)
#  #>   sku: list(name, tier)
#  #>   tags: list()
#  #> ---
#  #>   Methods:
#  #>     check, delete, do_operation, set_api_version, sync_fields, update

## ---- eval=FALSE---------------------------------------------------------
#  # use method chaining to get a resource without creating a bunch of intermediaries
#  # same result as above
#  stor <- az$
#      get_subscription("5710aa44-281f-49fe-bfa6-69e66bb55b11")$
#      get_resource_group("rdev1")$
#      get_resource(type="Microsoft.Storage/storageServices", name="rdevstor1")

## ---- eval=FALSE---------------------------------------------------------
#  stor$do_operation("listKeys", http_verb="POST")
#  #>  $`keys`
#  #>  $`keys`[[1]]
#  #>  $`keys`[[1]]$`keyName`
#  #>  [1] "key1"
#  #>
#  #>  $`keys`[[1]]$value
#  #>  [1] "k0gGFi8LirKcDNe73fzwDzhZ2+4oRKzvz+6+Pfn2ZCKO/JLnpyBSpVO7btLxBXQj+j8MZatDTGZ2NXUItye/vA=="
#  #>
#  #>  $`keys`[[1]]$permissions
#  #>  [1] "FULL"
#  #> ...

## ---- eval=FALSE---------------------------------------------------------
#  vm <- rg$get_resource(type="Microsoft.Compute/virtualMachines",
#      name="myVirtualMachine")
#  
#  vm$do_operation("start", http_verb="POST") # may take a while
#  vm$do_operation("runCommand",
#      body=list(
#          commandId="RunShellScript", # RunPowerShellScript for Windows
#          script=as.list("ifconfig > /tmp/ifconfig.out")
#      ),
#      encode="json",
#      http_verb="POST")
#  vm$do_operation("powerOff", http_verb="POST")

## ---- eval=FALSE---------------------------------------------------------
#  # file and blob storage endpoint
#  stor$properties$primaryEndpoints$file
#  stor$properties$primaryEndpoints$blob
#  
#  # OS profile for a VM: includes login details
#  vm$properties$osProfile

## ---- eval=FALSE---------------------------------------------------------
#  vm_tpl <- rg$deploy_template("myNewVirtualMachine",
#      template="vm_template.json",
#      parameters=list(
#          os="Linux",
#          size="Standard_DS2_v2",
#          username="ruser",
#          publickey=readLines("~/id_rsa.pub")
#      ))

## ---- eval=FALSE---------------------------------------------------------
#  vm_tpl$delete(free_resources=TRUE)

