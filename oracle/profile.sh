###########################
#
# Common Oracle Environment
#
###########################


CBE_HOME=${CBE_HOME:-~/CBE}
if [ -f ${CBE_HOME}/oracle/variables.conf ] ; then
	. ${CBE_HOME}/oracle/variables.conf
	. ${CBE_HOME}/oracle/aliases.conf
	. ${CBE_HOME}/oracle/functions.conf

	export PROMPT_COMMAND=F_ora_prompt

else
	echo "Cannot find the CBE_HOME with the correct files in $CBE_HOME"
	false
fi
