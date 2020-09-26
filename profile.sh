###########################
#
# Common Oracle Environment
#
###########################


CBE_HOME=${CBE_HOME:-~/CBE}
if [ -f ${CBE_HOME}/variables.conf ] ; then
	. ${CBE_HOME}/variables.conf
	. ${CBE_HOME}/aliases.conf
	. ${CBE_HOME}/functions.conf

	export PROMPT_COMMAND=F_common_prompt

else
	echo "Cannot find the CBE_HOME with the correct files in $CBE_HOME"
	false
fi
