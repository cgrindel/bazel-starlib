load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

def diff_test_for_prov(doc_prov):
    """Defines a `diff_test` for a document provider.

    Args:
        doc_prov: A `struct` as returned from `providers.create()`.

    Returns:
        None.
    """
    diff_test(
        name = "test_" + doc_prov.name,
        file1 = doc_prov.out_basename,
        file2 = doc_prov.doc_basename,
    )

def diff_test_for_provs(doc_provs):
    """Defines a `diff_test` for each of the provided document providers.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.

    Returns:
        None.
    """
    [
        diff_test_for_prov(
            doc_prov = doc_prov,
        )
        for doc_prov in doc_provs
    ]
