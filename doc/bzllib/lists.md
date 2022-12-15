<!-- Generated with Stardoc, Do Not Edit! -->
# `lists` API


<a id="lists.compact"></a>

## lists.compact

<pre>
lists.compact(<a href="#lists.compact-items">items</a>)
</pre>

Returns the provide items with any `None` values removed.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.compact-items"></a>items |  A <code>list</code> of items to evaluate.   |  none |

**RETURNS**

A `list` of items with the `None` values removed.


<a id="lists.contains"></a>

## lists.contains

<pre>
lists.contains(<a href="#lists.contains-items">items</a>, <a href="#lists.contains-target_or_fn">target_or_fn</a>)
</pre>

Determines if the provide value is found in a list.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.contains-items"></a>items |  A <code>list</code> of items to evaluate.   |  none |
| <a id="lists.contains-target_or_fn"></a>target_or_fn |  The item that may be contained in the items list or a <code>function</code> that takes a single value and returns a <code>bool</code>.   |  none |

**RETURNS**

A `bool` indicating whether the target item was found in the list.


<a id="lists.find"></a>

## lists.find

<pre>
lists.find(<a href="#lists.find-items">items</a>, <a href="#lists.find-bool_fn">bool_fn</a>)
</pre>

Returns the list item that satisfies the provide boolean function.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lists.find-items"></a>items |  A <code>list</code> of items to evaluate.   |  none |
| <a id="lists.find-bool_fn"></a>bool_fn |  A <code>function</code> that takes a single parameter (list item) and returns a <code>bool</code> indicating whether the meets the criteria.   |  none |

**RETURNS**

A list item or `None`.


