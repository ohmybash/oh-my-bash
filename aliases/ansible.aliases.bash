#! bash oh-my-bash.module

# kept for backwards compatbility, these used to be functions in the previous oh-my-bash ansible plugin
alias aver='ansible --version; ansible-community --version'
#alias arinit='ansible-role-init'   # this alias can now be found in the ansible-dev aliases

# ansible-core: https://docs.ansible.com/projects/ansible-core/devel/
alias a='ansible '
alias aconf='ansible-config '
alias acon='ansible-console '
alias adoc='ansible-doc '
alias agal='ansible-galaxy '
alias ainv='ansible-inventory '
alias aplay='ansible-playbook '
alias aplaybook='aplay' # this long version of the playbook alias is kept for backwards compatibility
alias apull='ansible-pull '
alias atest='ansible-test '
alias aval='ansible-vault '
