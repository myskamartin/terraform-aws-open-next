data "local_file" "dynamodb_cache" {
  filename = "${var.build_dir}/dynamodb-provider/dynamodb-cache.json"
}

resource "random_string" "prefix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  project_id      = "${var.project_name}-${var.project_environment}"
  project_id_full = "${random_string.prefix.id}www-${replace(var.project_domain, ".", "-")}"

  unhashed_assets = {
    for file in fileset("${var.build_dir}/assets/", "**") : file => { path = file, content_type = reverse(split(".", file))[0] }
    if !startswith(file, "_next/")
  }
  hashed_assets = {
    for file in fileset("${var.build_dir}/assets/", "**") : file => { path = file, content_type = reverse(split(".", file))[0] }
    if startswith(file, "_next/")
  }
  cache_files = {
    for file in fileset("${var.build_dir}/cache", "**") : file => { path = file, content_type = reverse(split(".", file))[0] }
  }

  content_types = {
    css   = "text/css"
    woff2 = "font/woff2"
    js    = "text/javascript"
    svg   = "image/svg+xml"
    ico   = "image/x-icon"
    html  = "text/html"
    htm   = "text/html"
    json  = "application/json"
    png   = "image/png"
    jpg   = "image/jpeg"
    jpeg  = "image/jpeg"
  }

  artifacts_dir = "${path.root}/../.open-next/.build/"
  input_data    = jsondecode(data.local_file.dynamodb_cache.content)
  transformed_data = [
    for item in local.input_data : {
      "tag"           = { "S" = item.tag["S"] },
      "path"          = { "S" = item.path["S"] },
      "revalidatedAt" = { "N" = item.revalidatedAt["N"] },
    }
  ]
}
