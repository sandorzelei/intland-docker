@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  cb-msoffice-integration-publish startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and CB_MSOFFICE_INTEGRATION_PUBLISH_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\velocity-1.7.jar;%APP_HOME%\lib\mbassador-1.2.4.2.jar;%APP_HOME%\lib\jetty-util-9.2.3.v20140905.jar;%APP_HOME%\lib\javax.servlet-api-3.1.0.jar;%APP_HOME%\lib\org.eclipse.persistence.asm-2.5.0.jar;%APP_HOME%\lib\spring-core-4.3.18.RELEASE.jar;%APP_HOME%\lib\jersey-container-servlet-core-2.7.jar;%APP_HOME%\lib\httpcore-4.4.4.jar;%APP_HOME%\lib\guava-19.0.jar;%APP_HOME%\lib\jaxb-svg11-1.0.2.jar;%APP_HOME%\lib\jackson-annotations-2.7.0.jar;%APP_HOME%\lib\jersey-client-2.7.jar;%APP_HOME%\lib\jetty-server-9.2.3.v20140905.jar;%APP_HOME%\lib\jersey-common-2.7.jar;%APP_HOME%\lib\stringtemplate-3.2.1.jar;%APP_HOME%\lib\commons-logging-1.2.jar;%APP_HOME%\lib\org.eclipse.persistence.core-2.5.0.jar;%APP_HOME%\lib\hk2-locator-2.2.0.jar;%APP_HOME%\lib\docx4j-3.3.7.jar;%APP_HOME%\lib\jersey-guava-2.7.jar;%APP_HOME%\lib\hk2-utils-2.2.0.jar;%APP_HOME%\lib\slf4j-log4j12-1.7.21.jar;%APP_HOME%\lib\javax.inject-2.2.0.jar;%APP_HOME%\lib\jetty-security-9.2.3.v20140905.jar;%APP_HOME%\lib\jersey-server-2.7.jar;%APP_HOME%\lib\commons-lang3-3.4.jar;%APP_HOME%\lib\commons-codec-1.10.jar;%APP_HOME%\lib\jcl-over-slf4j-1.7.21.jar;%APP_HOME%\lib\avalon-framework-api-4.3.1.jar;%APP_HOME%\lib\validation-api-1.1.0.Final.jar;%APP_HOME%\lib\spring-context-4.3.18.RELEASE.jar;%APP_HOME%\lib\lorem-2.0.jar;%APP_HOME%\lib\wmf2svg-0.9.8.jar;%APP_HOME%\lib\org.eclipse.persistence.moxy-2.5.0.jar;%APP_HOME%\lib\jetty-servlet-9.2.3.v20140905.jar;%APP_HOME%\lib\jersey-entity-filtering-2.7.jar;%APP_HOME%\lib\jetty-continuation-9.1.1.v20140108.jar;%APP_HOME%\lib\jackson-core-2.7.3.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\jackson-databind-2.7.3.jar;%APP_HOME%\lib\commons-collections-3.2.1.jar;%APP_HOME%\lib\velocity-tools-2.0.jar;%APP_HOME%\lib\javax.ws.rs-api-2.0.jar;%APP_HOME%\lib\log4j-1.2.17.jar;%APP_HOME%\lib\javax.annotation-api-1.2.jar;%APP_HOME%\lib\org.eclipse.persistence.antlr-2.5.0.jar;%APP_HOME%\lib\jersey-container-jetty-http-2.7.jar;%APP_HOME%\lib\spring-web-4.3.18.RELEASE.jar;%APP_HOME%\lib\javassist-3.18.1-GA.jar;%APP_HOME%\lib\avalon-framework-impl-4.3.1.jar;%APP_HOME%\lib\aopalliance-repackaged-2.2.0.jar;%APP_HOME%\lib\xmlgraphics-commons-2.1.jar;%APP_HOME%\lib\spring-beans-4.3.18.RELEASE.jar;%APP_HOME%\lib\antlr-runtime-3.5.2.jar;%APP_HOME%\lib\jetty-io-9.2.3.v20140905.jar;%APP_HOME%\lib\xalan-2.7.2.jar;%APP_HOME%\lib\antlr-2.7.7.jar;%APP_HOME%\lib\jersey-media-moxy-2.7.jar;%APP_HOME%\lib\serializer-2.7.2.jar;%APP_HOME%\lib\slf4j-api-1.7.21.jar;%APP_HOME%\lib\osgi-resource-locator-1.0.1.jar;%APP_HOME%\lib\gson-2.3.1.jar;%APP_HOME%\lib\commons-io-2.4.jar;%APP_HOME%\lib\httpclient-4.5.2.jar;%APP_HOME%\lib\spring-expression-4.3.18.RELEASE.jar;%APP_HOME%\lib\cb-msoffice-integration.jar;%APP_HOME%\lib\spring-aop-4.3.18.RELEASE.jar;%APP_HOME%\lib\commons-lang-2.6.jar;%APP_HOME%\lib\jetty-http-9.2.3.v20140905.jar;%APP_HOME%\lib\hk2-api-2.2.0.jar

@rem Execute cb-msoffice-integration-publish
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %CB_MSOFFICE_INTEGRATION_PUBLISH_OPTS%  -classpath "%CLASSPATH%" com.intland.codebeamer.export.msword.application.WordExportAppMain %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable CB_MSOFFICE_INTEGRATION_PUBLISH_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%CB_MSOFFICE_INTEGRATION_PUBLISH_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
