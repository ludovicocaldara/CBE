###########################
#
# Common Oracle Environment
#
###########################


CBE_BASE=${CBE_BASE:-~/CBE}
if [ -f ${CBE_BASE}/variables.conf ] ; then
	. ${CBE_BASE}/variables.conf
	. ${CBE_BASE}/aliases.conf
	. ${CBE_BASE}/functions.conf

	export PROMPT_COMMAND=common_prompt

else
	echo "Cannot find the CBE_BASE with the correct files in $CBE_BASE"
	false
fi
