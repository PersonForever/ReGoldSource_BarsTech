#-----------------------------------------------------------------------------
# SIMPLEINSTALL.CMAKE
#
# SanyaSho (2025)
#-----------------------------------------------------------------------------

include_guard( GLOBAL )

set( EXECUTABLE_SUBNAME "" )
if( ${IS_POSIX} )
	set( EXECUTABLE_SUBNAME "_linux" )
endif()

function( install_library )
	cmake_parse_arguments(
		ARGS
		""
		"TARGET;EXECUTABLE;INSTALL_OUTNAME;INSTALL_DEST"
		""
		${ARGN}
	)

	# use ARGS_TARGET if OUTNAME is not set
	if( NOT ARGS_INSTALL_OUTNAME )
		set( ARGS_INSTALL_OUTNAME "${ARGS_TARGET}" )
	endif()

	# append executable subname for executables
	if( ARGS_EXECUTABLE )
		set( ARGS_INSTALL_OUTNAME "${ARGS_INSTALL_OUTNAME}${EXECUTABLE_SUBNAME}" )
	endif()

	set_target_properties( ${ARGS_TARGET} PROPERTIES OUTPUT_NAME "${ARGS_INSTALL_OUTNAME}" )

	# Set VS debugger stuff here (ignored by non-VS generators)
	if( ARGS_EXECUTABLE )
		set_target_properties( ${ARGS_TARGET} PROPERTIES
			VS_DEBUGGER_COMMAND		"${ARGS_INSTALL_DEST}/${ARGS_INSTALL_OUTNAME}"
			VS_DEBUGGER_COMMAND_ARGUMENTS	"-novid -console +developer 5" # always run game with console and developer enabled
			VS_DEBUGGER_WORKING_DIRECTORY	"${ARGS_INSTALL_DEST}"
		)
	endif()

	if( NOT MSVC )
		install(
			TARGETS ${ARGS_TARGET}
			DESTINATION ${ARGS_INSTALL_DEST}

			PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE	#
				    GROUP_READ GROUP_EXECUTE			# chmod 755
				    WORLD_READ WORLD_EXECUTE			#
		)

		if( NOT ARGS_NO_STRIP )
			# DBG
			install(
				FILES "$<TARGET_FILE:${ARGS_TARGET}>.dbg"
				DESTINATION ${ARGS_INSTALL_DEST}

				PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE	#
					    GROUP_READ GROUP_EXECUTE			# chmod 755
					    WORLD_READ WORLD_EXECUTE			#
			)
		endif()
	else()
		install(
			TARGETS ${ARGS_TARGET}
			RUNTIME DESTINATION ${ARGS_INSTALL_DEST}
			LIBRARY DESTINATION ${ARGS_INSTALL_DEST}
		)

		# PDB
		install(
			FILES $<TARGET_PDB_FILE:${ARGS_TARGET}>
			DESTINATION ${ARGS_INSTALL_DEST}
		)
	endif()
endfunction()