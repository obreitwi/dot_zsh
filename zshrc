
# get md5sum of hostname
mdh() {
	if [[ $# == 0 ]]; then
		input=$HOST
	else
		input=$1
	fi
	echo $(set -- $(echo "$input" | md5sum -); echo $1)
}
ENCHOST=$(mdh)

# host specific configs that have to be loaded before anything else
[ -f ~/.zsh/hosts/pre_$ENCHOST ] && source ~/.zsh/hosts/pre_$ENCHOST

if [ -d ~/.oh-my-zsh ]; then
	source /home/obreitwi/.zsh/oh-my-zshrc
else
	source $HOME/.zsh/main
	source $HOME/.zsh/variables
	source $HOME/.zsh/prompt
	source $HOME/.zsh/lscolors
	source $HOME/.zsh/functions
	source $HOME/.zsh/aliases
	source $HOME/.zsh/bindkeys
	if [ -e $HOME/.zsh/private ]; then
		source $HOME/.zsh/private
	fi

	[[ -s /etc/profile.d/autojump.zsh ]] && source /etc/profile.d/autojump.zsh
	# if there is a local version, source it as well
	[[ -s ~/.autojump/etc/profile.d/autojump.zsh ]] && source ~/.autojump/etc/profile.d/autojump.zsh

	# support for 256 colors
	# export TERM='rxvt-256color'
	# (only load when we are in no tmux session)
	if [[ -z $TMUX ]]; then
		# if [[ -e /usr/share/terminfo/x/xterm-256color  ||  -e /lib/terminfo/x/xterm-256color ]]; then
			# export TERM='xterm-256color'
		# else
			# export TERM='xterm-color'
		# fi
		# if [[ -n $DISPLAY ]]; then
			# export TERM='rxvt-unicode-256color'
			# export LANG='en_US.UTF8'
		infocmp rxvt-unicode-256color &>/dev/null
		if [[ $? -eq 0 ]]; then
			export TERM='rxvt-unicode-256color'
		else
			export TERM='linux'
			# export LANG='en_US.iso88591'
			# export LANG='en_US.UTF8'
		fi
	else
		export TERM='screen-256color'

		# Try setting this here for nice vim in tmux
		# does not help
		# export LANG=en_US.UTF-8
		# export LC_CTYPE=
		# export LC_NUMERIC=
		# export LC_TIME=
		# export LC_COLLATE=
		# export LC_MONETARY="en_US.UTF-8"
		# export LC_MESSAGES=
		# export LC_PAPER="en_US.UTF-8"
		# export LC_NAME="en_US.UTF-8"
		# export LC_ADDRESS="en_US.UTF-8"
		# export LC_TELEPHONE="en_US.UTF-8"
		# export LC_MEASUREMENT="en_US.UTF-8"
		# export LC_IDENTIFICATION="en_US.UTF-8"
		# export LC_ALL=
	fi

	# check for host specific configs
	[ -f ~/.zsh/hosts/$ENCHOST ] && source ~/.zsh/hosts/$ENCHOST


	# source $HOME/.zsh/completion/*.zsh_completion

	# finally load gmrl zshrc - now only used for neat little functions
	#  source $HOME/.zsh/zshrc_grml
fi

