@ECHO OFF
REM DO NOT MODIFY THIS FILE UNLESS YOU KNOW WHAT YOU ARE DOING
REM Processing only if it was NOT started by codeBeamer smart scm servlet.
IF NOT "%CODEBEAMER_SMART_SCM_SERVLET%" == "" goto donothing
	"/your_install_dir/scmloop\scmloop.bat" -mode %1 -nodeid %HG_NODE% -source %HG_SOURCE% -hgurl %HG_URL% ^
		%1 %2 %3 %4 %5 %6 %7 %8
:donothing
