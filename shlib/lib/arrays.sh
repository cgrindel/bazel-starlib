#!/usr/bin/env bash

# This is used to determine if the library has been loaded
cgrindel_bazel_shlib_lib_arrays_loaded() { return; }

# Sorts the arguments and outputs a unique and sorted list with each item on its own line.
#
# Args:
#   *: The items to sort.
#
# Outputs:
#   stdout: A line per unique item.
#   stderr: None.
sort_items() {
  local IFS=$'\n'
  sort -u <<<"$*"
}

# Prints the arguments with each argument on its own line.
#
# Args:
#   *: The items to print.
#
# Outputs:
#   stdout: A line per item.
#   stderr: None.
print_by_line() {
  for item in "${@:-}" ; do
    echo "${item}"
  done
}

# Joins the arguments by the provided separator.
#
# Args:
#   separator: The separator that should be printed between each item.
#   *: The items to join.
#
# Outputs:
#   stdout: A string where the items are separated by the separator.
#   stderr: None.
join_by() {
  local delimiter="${1}"
  shift 1
  printf -v joined '%s'"${delimiter}" "${@}"
  echo "${joined%"${delimiter}"}"
}

# GH076: Figure out how to handle returning items with spaces.
# base64_encode_items() {
#   [[ ${#} == 0 ]] && return
#   items=()
#   while (("$#")); do
#     items+=( $( echo "${1}" | base64) )
#     shift 1
#   done 
#   echo "${items[@]}"
# }
#
# base64_decode_items() {
#   [[ ${#} == 0 ]] && return
#   items=()
#   while (("$#")); do
#     items+=( $( echo "${1}" | base64 --decode) )
#     shift 1
#   done 
#   echo "${items[@]}"
# }

# Add double quotes around each of the arguments.
#
# Args:
#   *: The items to be double quoted.
#
# Outputs:
#   stdout: The double quoted items separated by spaces.
#   stderr: None.
double_quote_items() {
  while (("$#")); do
    echo "\"${1}\""
    shift 1
  done 
}

# Searches for the expected value in the follow-on arguments. If your list is sorted and has
# more than ~40 items, consider using 'contains_item_sorted'.
#
# Args:
#   expected: The first argument is the expected value.
#   *: The follow on arguments are the list values being checked. They can be in any order.
#
# Outputs:
#   stdout: None.
#   stderr: None.
#   Returns 0 if the expected value is found. Otherwise returns -1.
contains_item() {
  # NOTE: The variables are purposefully short. Bash performance is greatly
  # influenced by the number of variables and the length of their names. 
  # x: expected value

  # Remember the expected value
  local x="${1}"
  shift
  
  # Do a quick regex to see if the value is in the rest of the args
  # If not, then don't bother looping
  [[ ! "${*}" =~ ${x} ]] && return 1

  # Loop through items for a precise match
  for it in "${@}" ; do
    [[ "${it}" == "${x}" ]] && return 0
  done

  # We did not find the item
  return 1
}

# Searches for the expected value in the follow-on arguments. This function assumes that the list 
# items are sorted and unique. Only use this function over 'contains_item' if you expect to have 40 
# or more items in your list. Check out //tools:contains_item_perf_comparison to run some comparisons
# between this function and contains_item.
#
# Args:
#   expected: The first argument is the expected value.
#   *: The follow on arguments are the list values being checked. They can be in any order.
#
# Outputs:
#   stdout: None.
#   stderr: None.
#   Returns 0 if the expected value is found. Otherwise returns -1.
contains_item_sorted() {
  # NOTE: The variables are purposefully short. Bash performance is greatly
  # influenced by the number of variables and the length of their names. 
  # Removed count var - Fastest (0.191s vs 0.214s contains_item)
  # x: expected value
  # s: start index
  # e: end index
  # m: midpoint index
  # mv: midpoint value

  # Remember the expected value
  local x="${1}"
  shift

  # Don't preceed if we have no list items.
  [[ ${#} -eq 0 ]] && return 1

  # Init the start and end indexes
  local s=1
  local e=${#}

  while true; do
    # Find midpoint
    local m=$(( s + (e - s + 1)/2 ))

    # If the midpoint value (!m) is the expected, found it
    local mv="${!m}"
    [[ "${x}" == "${mv}" ]] && return 

    # If the start index and end index are the same, finished searching
    [[ $s -eq $e ]] && return 1

    # Update the start/end index based upon whether the expected is greater
    # than or less than the midpoint value.
    if [[ "${x}" < "${mv}" ]]; then
      local e=$(( m - 1 ))
    else
      [[ $m -eq $e ]] && return 1
      local s=$(( m + 1 ))
    fi
  done
}
