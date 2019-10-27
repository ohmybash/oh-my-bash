# OH-MY-BASH plugin

## Install
Follow the ususal download and install procedure.
Make sure you have `jq` installed.

```bash
grep -qi 'ID_LIKE=ubuntu' /etc/os-release \
    && sudo apt install jq \
    || sudo yum install jq

cd $HOME/.oh-my-bash/plugins/ \
&& git clone https://github.com/gpid007/gpid007.git \
&& sed -i '/plugin/a gpid007' $HOME/.bashrc
```

## Use
```
getec2 \
    [-g [REXP|*]] \
    [-p [PROFILE|all]] 
    [-c [COLUMN|all|1,3..6,9]] 
    [-h [HELP|?]]
    [-H [HEADER]]
```
