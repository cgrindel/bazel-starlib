# Manage Javascript Dependencies


## Upgrade Dependencies to Latest

If you just want the latest upgrades, do the following:

```sh
# Change to this directory
cd markdown/private

# Upgrade all deps to their latest
bazel run @yarn//:yarn -- upgrade
```

If you want to change the declared minimum version in `package.json`, update `package.json` and then
do the following:

```sh
# Change to this directory
cd markdown/private

# Upgrade all deps to their latest
bazel run @yarn//:yarn -- install
```
