# gcloud

This plugin provides completion support for the
[Google Cloud SDK CLI](https://cloud.google.com/sdk/gcloud/).
Based on [gcloud plugin for oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/gcloud).

To use it, add `gcloud` to the plugins array in your bashrc file.

```bash
plugins=(... gcloud)
```

It relies on you having installed the SDK using one of the supported options
listed [here](https://cloud.google.com/sdk/install).

## Plugin Options

* Set `OMB_PLUGIN_GCLOUD_HOME` in your `bashrc` file before you load oh-my-bash if you have
your GCloud SDK installed in a non-standard location. The plugin will use this
as the base for your SDK if it finds it set already.

* If you do not have a `python2` in your `PATH` you'll also need to set the
`CLOUDSDK_PYTHON` environment variable at the end of your `.bashrc`. This is
used by the SDK to call a compatible interpreter when you run one of the
SDK commands.
