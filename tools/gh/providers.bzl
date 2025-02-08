"""Definitions for the GitHub CLI providers."""

GhInfo = provider(
    fields = {
        "gh": "The `gh` utility as an exeutable `File`.",
    },
    doc = "Information about the GitHub CLI.",
)
