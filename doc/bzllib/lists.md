<!-- Generated with Stardoc, Do Not Edit! -->
# `lists` API


<a id="lists.compact"></a>

## lists.compact

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.compact(<a href="#lists.compact-items">items</a>)
</pre>

Returns a new `list` with any `None` values removed.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.compact-items"></a>items |  A `list` of items to evaluate.   |  none |

**RETURNS**

A new `list` of items with the `None` values removed.


<a id="lists.contains"></a>

## lists.contains

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.contains(<a href="#lists.contains-items">items</a>, <a href="#lists.contains-target_or_fn">target_or_fn</a>)
</pre>

Determines if a value exists in the provided `list`.

If a boolean function is provided as the second argument, the function is
evaluated against the items in the list starting from the first item. If
the result of the boolean function call is `True`, processing stops and
this function returns `True`. If no items satisfy the boolean function,
this function returns `False`.

If the second argument is not a `function` (i.e., the target), each item in
the list is evaluated for equality (==) with the target. If the equality
evaluation returns `True` for an item in the list, processing stops and
this function returns `True`. If no items are found to be equal to the
target, this function returns `False`.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.contains-items"></a>items |  A `list` of items to evaluate.   |  none |
| <a id="lists.contains-target_or_fn"></a>target_or_fn |  An item to be evaluated for equality or a boolean `function`. A boolean `function` is defined as one that takes a single argument and returns a `bool` value.   |  none |

**RETURNS**

A `bool` indicating whether an item was found in the list.


<a id="lists.filter"></a>

## lists.filter

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.filter(<a href="#lists.filter-items">items</a>, <a href="#lists.filter-bool_fn">bool_fn</a>)
</pre>

Returns a new `list` containing the items from the original that     satisfy the specified boolean `function`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.filter-items"></a>items |  A `list` of items to evaluate.   |  none |
| <a id="lists.filter-bool_fn"></a>bool_fn |  A `function` that takes a single parameter returns a `bool` value.   |  none |

**RETURNS**

A new `list` containing the items that satisfy the provided boolean
  `function`.


<a id="lists.find"></a>

## lists.find

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.find(<a href="#lists.find-items">items</a>, <a href="#lists.find-bool_fn">bool_fn</a>)
</pre>

Returns the list item that satisfies the provided boolean `function`.

The boolean `function` is evaluated against the items in the list starting
from the first item. If the result of the boolean function call is `True`,
processing stops and this function returns item. If no items satisfy the
boolean function, this function returns `None`.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.find-items"></a>items |  A `list` of items to evaluate.   |  none |
| <a id="lists.find-bool_fn"></a>bool_fn |  A `function` that takes a single parameter and returns a `bool` value.   |  none |

**RETURNS**

A list item or `None`.


<a id="lists.flatten"></a>

## lists.flatten

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.flatten(<a href="#lists.flatten-items">items</a>, <a href="#lists.flatten-max_iterations">max_iterations</a>)
</pre>

Flattens a `list` containing an arbitrary number of child `list` values     to a new `list` with the items from the original `list` values.

Every effort is made to preserve the order of the flattened list items
relative to their order in the child `list` values. For instance, an input
of `["foo", ["alpha", ["omega"]], ["chicken", "cow"]]` to this function
returns `["foo", "alpha", "omega", "chicken", "cow"]`.

If provided a `list` value, each item in the `list` is evaluated for
inclusion in the result.  If the item is not a `list`, the item is added to
the result. If the item is a `list`, the items in the child `list` are
added to the result and the result is marked for another round of
processing. Once the result has been processed without detecting any child
`list` values, the result is returned.

If provided a value that is not a `list`, the value is wrapped in a list
and returned.

Because Starlark does not support recursion or boundless looping, the
processing of the input is restricted to a fixed number of processing
iterations. The default for the maximum number of iterations should be
sufficient for processing most multi-level `list` values. However, if you
need to change this value, you can specify the `max_iterations` value to
suit your needs.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.flatten-items"></a>items |  A `list` or a single item.   |  none |
| <a id="lists.flatten-max_iterations"></a>max_iterations |  Optional. The maximum number of processing iterations.   |  `10000` |

**RETURNS**

A `list` with all of the items flattened (i.e., no items in the result
  are an item of type `list`).


<a id="lists.map"></a>

## lists.map

<pre>
load("@cgrindel_bazel_starlib//bzllib:defs.bzl", "lists")

lists.map(<a href="#lists.map-items">items</a>, <a href="#lists.map-map_fn">map_fn</a>)
</pre>

Returns a new `list` where each item is the result of calling the map     `function` on each item in the original `list`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.map-items"></a>items |  A `list` of items to evaluate.   |  none |
| <a id="lists.map-map_fn"></a>map_fn |  A `function` that takes a single parameter returns a value that will be added to the new list at the correspnding location.   |  none |

**RETURNS**

A `list` with the transformed values.


