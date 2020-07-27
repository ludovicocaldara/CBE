###########################
#
# Common Oracle Environment
#
###########################


CBE_BASE=${CBE_BASE:-~/CBE}
if [ -f ${CBE_BASE}/oracle/variables.conf ] ; then
	. ${CBE_BASE}/oracle/variables.conf
	. ${CBE_BASE}/oracle/aliases.conf
	. ${CBE_BASE}/oracle/functions.conf

	export PROMPT_COMMAND=F_ora_prompt

else
	echo "Cannot find the CBE_BASE with the correct files in $CBE_BASE"
	false
fi
