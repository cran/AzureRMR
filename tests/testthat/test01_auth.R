context("Authentication")

tenant <- Sys.getenv("AZ_TEST_TENANT_ID")
app <- Sys.getenv("AZ_TEST_APP_ID")
password <- Sys.getenv("AZ_TEST_PASSWORD")
subscription <- Sys.getenv("AZ_TEST_SUBSCRIPTION")

if(tenant == "" || app == "" || password == "" || subscription == "")
    skip("Authentication tests skipped: ARM credentials not set")


clean_token_directory(confirm=FALSE)
suppressWarnings(file.remove(file.path(AzureR_dir(), "arm_logins.json")))

scopes <- c("https://management.azure.com/.default", "openid", "offline_access")

test_that("ARM authentication works",
{
    az <- az_rm$new(tenant=tenant, app=app, password=password)
    expect_is(az, "az_rm")
    expect_true(is_azure_token(az$token))

    tok <- get_azure_token(scopes, tenant, app, password, version=2)
    az2 <- az_rm$new(token=tok)
    expect_is(az2, "az_rm")
})

test_that("Login interface works",
{
    lst <- list_azure_logins()
    expect_true(is.list(lst))

    az3 <- create_azure_login(tenant=tenant, app=app, password=password, graph_host=NULL)
    expect_is(az3, "az_rm")

    creds <- tempfile(fileext=".json")
    writeLines(jsonlite::toJSON(list(tenant=tenant, app=app, password=password)), creds)

    az4 <- create_azure_login(config_file=creds, graph_host=NULL)
    expect_identical(normalize_tenant(tenant), az4$tenant)
    expect_is(az4, "az_rm")

    az5 <- get_azure_login(tenant)
    expect_is(az5, "az_rm")

    tok <- get_azure_token(scopes, tenant, app, password, version=2)
    az6 <- create_azure_login(token=tok, graph_host=NULL)
    expect_is(az6, "az_rm")
})

test_that("Graph interop works",
{
    if(!requireNamespace("AzureGraph"))
        skip("Graph interop tests skipped: AzureGraph not installed")

    graph_logins <- file.path(AzureR_dir(), "graph_logins.json")
    suppressWarnings(file.remove(graph_logins))

    az <- create_azure_login(tenant=tenant, app=app, password=password)
    expect_true(file.exists(graph_logins))

    gr <- AzureGraph::get_graph_login(tenant)
    expect_is(gr, "ms_graph")
    expect_true(
        (!is.null(gr$token$resource) && grepl("graph\\.microsoft\\.com", gr$token$resource)) ||
        (!is.null(gr$token$scope) && any(grepl("graph\\.microsoft\\.com", gr$token$scope)))
    )
})

test_that("Top-level do_operation works",
{
    az <- get_azure_login(tenant)
    out <- az$do_operation("providers/Microsoft.Management/operations", api_version="2020-02-01")
    expect_is(out, "list")
})
