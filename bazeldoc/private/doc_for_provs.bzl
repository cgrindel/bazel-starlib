load(":stardoc_for_prov.bzl", "stardoc_for_provs")
load(":diff_test_for_provs.bzl", "diff_test_for_provs")
load(":update_doc.bzl", "update_doc")

def doc_for_provs(doc_provs):
    """Defines targets for generating documentation, testing that the generated doc matches the workspace directory, and copying the generated doc to the workspace directory.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.

    Returns:
        None.
    """
    stardoc_for_provs(doc_provs = doc_provs)
    diff_test_for_provs(doc_provs = doc_provs)
    update_doc(doc_provs = doc_provs)
