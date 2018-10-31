# Project

It's used to build tools for [PouchContainer](https://github.com/alibaba/pouch).
Build package to release is one of examples.

## Build package

One important role of this repo is to build deb/rpc package to release PouchContainer.

### How to build deb package

First of all, we should build image.

```
cd ${this-repo}
docker build -f Dockerfile.amd64.ubuntu . -t build-deb-pkg
```

After that, we run the container to build the package.

```
docker run -it \ # needs input for password
  -v gpg_keys_dir:/build/keys \ # gpg_keys_dir contains gpg keys.
  -v bundle_dir:/build/bundles \ # bundle_dir contains release files.
  build-deb-pkg ${pouch-commit-id-or-branch-or-tag} ${pkg-version-name}
```

`/build/keys` is volume to contains the gpd keys which builder needs.
The layout of folder is like:

```
keys:
  |- default_key
  |_ public
  |_ private
```

`/build/bundles` will contains the release files created by builder.
After build, we can retrieve the files from the folder.

In PouchContainer, the ${pkg-version-name} of deb must be like the format:

```
x.y.z~rc{digit}
```

Therefore, we can make sure that the policy works right for selecting new version.

## Common scripts

`scripts` folder will hold any common scripts.
