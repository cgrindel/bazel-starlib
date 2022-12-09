"""API for resolving and managing Bazel labels"""

load(":workspace_name_resolvers.bzl", "workspace_name_resolvers")

_ROOT_SEPARATOR = "//"
_ROOT_SEPARATOR_LEN = len(_ROOT_SEPARATOR)
_NAME_SEPARATOR = ":"
_NAME_SEPARATOR_LEN = len(_NAME_SEPARATOR)
_PKG_SEPARATOR = "/"
_PKG_SEPARATOR_LEN = len(_PKG_SEPARATOR)

def make_bazel_labels(workspace_name_resolvers = workspace_name_resolvers):
    """Creates a `bazel_labels` module using the specified name resolver.

    Args:
        workspace_name_resolvers: A `workspace_name_resolvers` module.

    Returns:
        A `struct` that can be used as a `bazel_labels` module.
    """

    def _new(name, repository_name = None, package = None):
        if repository_name == None:
            repository_name = workspace_name_resolvers.repository_name()

        # Support `--noincompatible_unambiguous_label_stringification`
        if not repository_name.startswith("@"):
            repository_name = "@{}".format(repository_name)

        if package == None:
            package = workspace_name_resolvers.package_name()

        return struct(
            repository_name = repository_name,
            package = package,
            name = name,
        )

    def _parse(value):
        """Parse a string as a Bazel label returning its parts.

        Args:
            value: A `string` value to parse.

        Returns:
            A `struct` as returned from `bazel_labels.create`.
        """
        root_sep_pos = value.find(_ROOT_SEPARATOR)

        # The package starts after the root separator
        if root_sep_pos > -1:
            pkg_start_pos = root_sep_pos + _ROOT_SEPARATOR_LEN
        else:
            pkg_start_pos = -1

        # Extract the repo name
        if root_sep_pos > 0:
            repo_name = value[:root_sep_pos]
        else:
            repo_name = None

        colon_pos = value.find(_NAME_SEPARATOR)

        # Extract the name
        if colon_pos > -1:
            # Found a colon, the name follows it
            name_start_pos = colon_pos + _NAME_SEPARATOR_LEN
            pkg_end_pos = colon_pos
        elif pkg_start_pos > -1:
            # No colon and have a package, so the name is the last part of the
            # package
            pkg_end_pos = len(value)
            last_sep_pos = value.rfind(_PKG_SEPARATOR, pkg_start_pos)
            if last_sep_pos > -1:
                name_start_pos = last_sep_pos + _PKG_SEPARATOR_LEN
            else:
                name_start_pos = pkg_start_pos
        else:
            # No colon and no package, the value is the name
            name_start_pos = 0
            pkg_end_pos = -1
        name = value[name_start_pos:]

        if pkg_start_pos > -1:
            package = value[pkg_start_pos:pkg_end_pos]
        else:
            package = None

        return _new(
            repository_name = repo_name,
            package = package,
            name = name,
        )

    def _normalize(value):
        """Converts a value into a Bazel label string.

        Args:
            value: A `Label`, `struct` from `bazel_labels.new`, or a `string`.

        Returns:
            A fully-formed Bazel label string.
        """
        value_type = type(value)
        if value_type == "Label":
            parts = _new(
                repository_name = value.workspace_name,
                package = value.package,
                name = value.name,
            )
        elif value_type == "struct":
            parts = value
        elif value_type == "string":
            parts = _parse(value)
        else:
            fail("Unrecognized type for bazel_labels.normalize.", value)

        pkg_parts = parts.package.split("/")
        if pkg_parts[-1] == parts.name:
            return "{repo_name}//{package}".format(
                repo_name = parts.repository_name,
                package = parts.package,
            )

        return "{repo_name}//{package}:{name}".format(
            repo_name = parts.repository_name,
            package = parts.package,
            name = parts.name,
        )

    return struct(
        new = _new,
        parse = _parse,
        normalize = _normalize,
    )

bazel_labels = make_bazel_labels(workspace_name_resolvers = workspace_name_resolvers)
