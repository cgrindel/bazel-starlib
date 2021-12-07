def workspace_snippet(name, pkg, url):
    hash_name = name + "_sha256"
    hash_sha256(
        name = hash_name,
        src = pkg,
    )

    expand_make_vars(
        name = "bazel_starlib_workspace_snippet",
        template = "@cgrindel_bazel_starlib//rules/private:workspace_snippet.tmpl",
        substitutions = {
            "{WORKSPACE_NAME}": workspac,
            "{SHA256}": sha256,
            "{URL}": url,
        },
        out = name + ".snippet",
    )
