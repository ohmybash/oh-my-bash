# progress2

Spice up your scripts with a full width animated progress bar which also adjusts to window size changes.

## Usage

```shell
source $OSH/plugins/progress/progress2.plugin.sh

init_progress
progress 1
...
progress 10
...
progress 90
...
progress 100
```

## Advanced

The characters used to draw the progress bar can be changed to suit your tastes. Simply set your own values (see script for complete list) after calling init_progress but before calling progress for the first time.


