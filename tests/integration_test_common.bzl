INTEGRATION_TEST_TAGS = [
    "exclusive",
    "manual",
]

GH_ENV_INHERIT = [
    # The HOME, GH_TOKEN, and GITHUB_TOKEN environment variables help the gh utility find
    # its auth info.
    "GITHUB_TOKEN",
    "GH_TOKEN",
    "HOME",
]
