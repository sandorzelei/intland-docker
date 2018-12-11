@ECHO OFF
REM DO NOT MODIFY THIS FILE UNLESS YOU KNOW WHAT YOU ARE DOING
REM $Id$

SET CBPATH=.
SET CB_BASE_URL=http://localhost:8080/cb
SET JAVA=java
SET SCM_DIR=/your_install_dir/scmloop

REM We need english messages (for example from svnlook)
SET LC_MESSAGES=en

REM SET CP=%SCM_DIR%;%SCM_DIR%/scmloop.jar;%SCM_DIR%/svnkit.jar;%SCM_DIR%/sequence-library.jar;%SCM_DIR%/trilead.jar;%SCM_DIR%/platform.jar;%SCM_DIR%/log4j.jar;%SCM_DIR%ant.jar;%SCM_DIR%/jgit.jar;%SCM_DIR%/commons-lang.jar;%SCM_DIR%/commons-lang3.jar;%SCM_DIR%/commons-io.jar;%SCM_DIR%/guava.jar;%SCM_DIR%/hessian.jar
SET CP=%SCM_DIR%;%SCM_DIR%/*.jar;%SCM_DIR%/*

REM "PROXY_OPTIONS" are optional HTTP Proxy settings
REM SET PROXY_OPTIONS=-Dhttp.proxyHost=<hostname> -Dhttp.proxyPort=<portno>

REM Variables for Subversion
SET SVN_DIR=%CBPATH%\libexec\svn
SET PATH=%SVN_DIR%\bin;%PATH%;%CBPATH%\libexec\hg
SET APR_ICONV_PATH=%SVN_DIR%\iconv

"%JAVA%" -Xmx256M -cp "%CP%" %PROXY_OPTIONS% ^
	"-DCVS_USER=%CVS_USER%" ^
	"-DCVSROOT=%CVSROOT%" ^
	"-DSCM_DIR=%SCM_DIR%" ^
		com.intland.codebeamer.scm.chain.client.CommitClient ^
		-url "%CB_BASE_URL%/sccCommitInfo" -stdin "#" %SCM_OPTIONS% %*