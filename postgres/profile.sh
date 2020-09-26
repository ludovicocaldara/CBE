###########################
#
# Common Oracle Environment
#
###########################


CBE_HOME=${CBE_HOME:-~/CBE}
if [ -f ${CBE_HOME}/postgres/variables.conf ] ; then
	. ${CBE_HOME}/postgres/variables.conf
	. ${CBE_HOME}/postgres/aliases.conf
	. ${CBE_HOME}/postgres/functions.conf

	export PROMPT_COMMAND=F_pg_prompt

else
	echo "Cannot find the CBE_HOME with the correct files in $CBE_HOME"
	false
fi
