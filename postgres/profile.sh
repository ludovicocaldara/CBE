###########################
#
# Common Oracle Environment
#
###########################


CBE_BASE=${CBE_BASE:-~/CBE}
if [ -f ${CBE_BASE}/postgres/variables.conf ] ; then
	. ${CBE_BASE}/postgres/variables.conf
	. ${CBE_BASE}/postgres/aliases.conf
	. ${CBE_BASE}/postgres/functions.conf

	export PROMPT_COMMAND=F_pg_prompt

else
	echo "Cannot find the CBE_BASE with the correct files in $CBE_BASE"
	false
fi
