<%--
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="windowsPlatform" value="${databaseConnectionForm.windowsPlatform}"/>

<spring:message var="databaseSchema" code="post.installer.database.schema.label" text="Database schema"/>
<spring:message var="databaseSid" code="post.installer.database.sid.label" text="Service Name/SID"/>

<div class="form-container">
	<jsp:include page="includes/header.jsp?step=database&stepIndex=3"/>

	<div class="info">
		<spring:message code="post.installer.database.info" text="Please set up and test your database connection below."/>
	</div>

	<form:form method="POST" modelAttribute="databaseConnectionForm">
		<div class="form-fields">
			<div class="field">
				<label class="db-type-label"> <spring:message code="post.installer.database.type.label" text="Select database type" /></label>
			</div>
			<div class="field radio-group">
				<label></label>
				<form:radiobutton path="type" value="builtin" id="builtin" cssClass="db-radio" disabled="${databaseConnectionForm.builtInDisabled}"/>
				<label for="builtin" class="db-label"><spring:message code="post.installer.database.type.builtin.label" text="Built-in (only for evaluation)" /></label>
			</div>
			<div class="field radio-group">
				<label></label>
				<form:radiobutton path="type" value="mysql" id="mysql" cssClass="db-radio" />
				<label for="mysql" class="db-label db-label-fixed"><spring:message code="post.installer.database.type.mysql.label" text="MySQL" /></label>
				<div class="db-info" id="windowsMysqlInstallInfo">
					<a href="https://codebeamer.com/cb/wiki/578644" target="_blank"><spring:message	code="post.installer.database.help.mysql.install.windows" text="Installing MySQL database on Windows." /></a>
				</div>
			</div>
			<div class="field radio-group">
				<label></label>
				<form:radiobutton path="type" value="oracle" id="oracle" cssClass="db-radio"/>
				<label for="oracle" class="db-label db-label-fixed"><spring:message	code="post.installer.database.type.oracle.label" text="Oracle" /></label>
			</div>

			<fieldset id="db-specific-fields"
				class="db-fieldset">
				<div class="field">
					<label for="host"><spring:message code="post.installer.database.hostname.label" text="Hostname" />*</label>
					<form:input path="host" id="host" cssErrorClass="error" />
				</div>
				<div class="field">
					<label for="port"><spring:message code="post.installer.database.port.label" text="Port" /></label>
					<form:input path="port" id="port" cssErrorClass="error" />
				</div>
				<div class="field">
					<label for="schema" id="dbSchemalabel"><spring:message code="post.installer.database.schema.label" text="Schema" />*</label>
					<form:input path="schema" id="schema" cssErrorClass="error" />
				</div>
				<div id="oracleSchemaPanel" style="display: none;">
					<div class="field oracleSchemaUser">
						<label for="oracleSchemaUser"><spring:message	code="post.installer.database.schema.user" text="Schema username" />*</label>
						<input type="text" id="oracleSchemaUser" cssErrorClass="error" />
					</div>
					<div class="field oracleSchemaPassword">
						<label for="oracleSchemaPassword"><spring:message	code="post.installer.database.schema.password" text="Schema password" />*</label>
						<input type="password" id="oracleSchemaPassword" cssErrorClass="error" showPassword="true"/>
					</div>
					<div class="info" style="margin: 0px;">
						<div class="information  howToLink">
							<a href="https://codebeamer.com/cb/wiki/93596" target="_blank">
							<spring:message
								code="post.installer.database.oracle.schema.creation"
								text="How to create a codeBeamer Orcale schema manually" />
							</a>
						</div>
					</div>
				</div>
				<div>
					<div id="oracleAdminCheckboxPanel" field class="field customSchema" style="display: none; padding-bottom: 15px;">
						<label for="oracleAdminCheckbox" style="cursor: pointer;">
							<spring:message code="post.installer.database.sysadmin.oracle.checkbox" text="Use custom schema user/password"/>
						</label>
						<form:checkbox path="oracleAdminCheckbox" id="oracleAdminCheckbox" />
					</div>
					<div id="adminFields">
						<div class="field">
							<label for="adminUser"><spring:message code="post.installer.database.sysadmin.name.label" text="Sysadmin username" />*</label>
							<form:input path="adminUser" id="adminUser" cssErrorClass="error" />
						</div>
						<div class="field">
							<label for="adminPassword"><spring:message code="post.installer.database.sysadmin.password.label" text="Sysadmin password" /></label>
							<form:password path="adminPassword" id="adminPassword"
								cssErrorClass="error" autocomplete="off" />
						</div>
						<div class="field">
							<label for="passwordStorageType"><spring:message code="post.installer.database.sysadmin.password.type.label" text="Type of password storage" /></label>
							<form:select path="passwordStorageType" id="passwordStorageType" style="left: 0px;">
								<form:option value="PLAIN">Plain</form:option>
								<form:option value="ENCRYPTED">Encrypted</form:option>
								<form:option value="EXTERNAL">External</form:option>
							</form:select>
						</div>
					</div>
				</div>
				<div class="field customSchema">
					<label for="useCustomSchemaCredentials" style="cursor: pointer;">
						<spring:message code="post.installer.database.sysadmin.password.default" text="Use custom schema user/password"/>
					</label>
					<form:checkbox path="useCustomSchemaCredentials" id="useCustomSchemaCredentials" />
					<div class="notificationText schemaInfo" style="margin-bottom: 0px;"><spring:message code="post.installer.database.schema.account.info"
						arguments="cbroot,CbPassword01!"/></div>
					<div class="field schemaUser">
						<label for="schemaUser"><spring:message	code="post.installer.database.schema.user" text="Schema username" />*</label>
						<form:input path="schemaUser" id="schemaUser" cssErrorClass="error" />
					</div>
					
					<div class="field schemaPassword">
						<label for="schemaPassword"><spring:message	code="post.installer.database.schema.password" text="Schema password" />*</label>
						<form:password path="schemaPassword" id="schemaPassword" cssErrorClass="error" showPassword="true"/>
					</div>
				</div>
			</fieldset>

			<div id="builtinhint" style="display: none;">
				<div class="notificationText">
					<spring:message code="post.installer.database.sysadmin.builtinhint"	text="Please note that the built-in database schema is not supported. We do NOT recommend using it on <b>production</b> servers!" htmlEscape="false" />
				</div>
			</div>
			<div id="mysqlhint" style="display: none;">
				<div class="notificationText">
					<spring:message code="post.installer.database.sysadmin.hint" htmlEscape="false"	text="Please note that in order to complete this step, the database admin needs to have permission to create a new database schema/user!" />
				</div>
			</div>

			<spring:message code="post.installer.test.connection.label"
				text="Test connection" var="testConnectionLabel" />

			<div id="oracleRemoteConnectionInfo">
				<div class="notificationText">
					<spring:message
						code="post.installer.database.oracle.connection.info2"
						text="To create a new database schema, please provide a system DBA account with remote login permission.<br>codeBeamer ALM will automatically add C## prefix before the specified schema name when the Oracle Multitenant database is created." />
				</div>
			</div>
			
			<input type="button" class="button field" name="test-connection"
				id="test-connection" value="${testConnectionLabel}" />
		</div>
		<jsp:include page="includes/footer.jsp?step=database&formName=databaseConnectionForm"/>
	</form:form>
</div>

<script type="text/javascript">
	// for IE8
	$("#windowsMysqlInstallInfo").hide();
	$("#oracleRemoteConnectionInfo").hide();

	var windowsPlatform = "${windowsPlatform}";
	var defaultSchemaUser = "cbroot";

	$(document).ready(function () {
		$("#nextButton").attr('disabled','disabled');
		$("#nextButton").addClass('next-button-disabled');
		
		$("#host").change(function() {
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleHost = $("#host").val();
			} else if (value == "mysql") {
				mysqlHost = $("#host").val();
			}
		});
		
		$("#port").change(function() {
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oraclePort = $("#port").val();
			} else if (value == "mysql") {
				mysqlPort = $("#port").val();
			}
		});
		
		$("#schema").change(function() {
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleSchema = $("#schema").val();
			} else if (value == "mysql") {
				mysqlSchema = $("#schema").val();
			}
		});
		
		var mysqlSchemaUser = "";
		var mysqlSchemaPassword = "";
		var oracleSchemaUser = "";
		var oracleSchemaPassword = "";
		
		var mysqlAdminUser = "";
		var mysqlAdminPassword = "";
		var oracleAdminUser = "";
		var oracleAdminPassword = "";
		
		var mysqlSchema = "";
		var oracleSchema = "";
		
		var mysqlPort = "";
		var oraclePort = "";
		
		var mysqlHost = "";
		var oracleHost = "";
		
		/*if (mysqlAdminUser == "") {
			mysqlAdminUser = "root";
		}*/
		$("#adminUser").change(function() {
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleAdminUser = $("#adminUser").val();
			} else if (value == "mysql") {
				mysqlAdminUser = $("#adminUser").val();
			}
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
		});
		$("#adminPassword").change(function() {
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleAdminPassword = $("#adminPassword").val();
			} else if (value == "mysql") {
				mysqlAdminPassword = $("#adminPassword").val();
			}
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
		});
		$("#schemaUser").change(function() {
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleSchemaUser = $("#schemaUser").val();
			} else if (value == "mysql") {
				mysqlSchemaUser = $("#schemaUser").val();
			}
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
		});
		$("#schemaPassword").change(function() {
			var value = $("input[type='radio']:checked").val()
			if (value == "oracle") {
				oracleSchemaPassword = $("#schemaPassword").val();
			} else if (value == "mysql") {
				mysqlSchemaPassword = $("#schemaPassword").val();
			}
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
		});
		
		var showOracleDatabaseOptions = function() {
			$("#builtinhint").hide();
			$("#mysqlhint").hide();
			$(".schemaUser").show();
			$("#dbSchemalabel").text("${databaseSid}");
			
			if ($("#oracleAdminCheckbox").is(':checked')) {
				$("#oracleRemoteConnectionInfo").show();
			} else {
				$("#oracleRemoteConnectionInfo").hide();
			}
			if (oracleHost == "") {
				oracleHost = "localhost"
			}
			$("#host").val(oracleHost);
			if (oraclePort == "") {
				oraclePort = 1521;
			}
			$("#port").val(oraclePort);
			if (oracleSchema == ""){
				oracleSchema = "orcl";
			}
			$("#schema").val(oracleSchema);
			if (oracleAdminUser == "") {
				oracleAdminUser = "sys as sysdba";
			}
			$("#adminUser").val(oracleAdminUser);
			$("#adminPassword").val(oracleAdminPassword);
			
			if (oracleSchemaUser == "") {
				oracleSchemaUser = "cbroot";
			}
			$("#schemaUser").val(oracleSchemaUser);
			$("#schemaPassword").val(oracleSchemaPassword);
			
			$("#dbSchemalabel").text("${databaseSid}");
			
			$(".customSchema").hide();
			$("#oracleSchemaPanel").show();
			$("#oracleAdminCheckboxPanel").show();
			if ($("#oracleAdminCheckbox").is(':checked')) {
				$("#adminFields").show();
			} else {
				$("#adminFields").hide();
			}
			
			// deafult values
			if ($("#schema").val() == "codebeamer"){
				$("#schema").val("orcl");
			}
			if (!$("#oracleSchemaUser").val()) {
				$("#oracleSchemaUser").val("cbroot");
				$("#schemaUser").val(defaultSchemaUser);
			}
		}

		$("#windowsMysqlInstallInfo").hide();
		$("#oracleRemoteConnectionInfo").hide();

		var $fieldSet = $("#db-specific-fields");

		var toggleFieldSet = function(disable) {
			var attr = disable ? "disabled" : false;
			$fieldSet.attr("disabled", attr);
		};

		var updateSchemaCredentialsVisibility = function(visible) {

			if (!visible){
				$(".schemaUser").hide();
				$(".schemaPassword").hide();
				$(".schemaInfo").show();
			}
			else {
				$(".schemaUser").show();
				$(".schemaPassword").show();
				$(".schemaInfo").hide();
			}
		};

		$("#useCustomSchemaCredentials").change(function() {
			var $this = $(this);
			updateSchemaCredentialsVisibility($this.is(':checked'));
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
		});

		updateSchemaCredentialsVisibility($("#useCustomSchemaCredentials").is(':checked'));

		$("#oracleSchemaUser").change(function() {
			$("#schemaUser").val($("#oracleSchemaUser").val());
			oracleSchemaUser = $("#oracleSchemaUser").val();
		});
		
		$("#oracleSchemaPassword").change(function() {
			$("#schemaPassword").val($("#oracleSchemaPassword").val());
			oracleSchemaPassword = $("#oracleSchemaPassword").val();
		});
		
		$(".radio-group input").click(function () {
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
			var $fieldSet = $("#db-specific-fields");
			var value = $(this).val();
			$("#dbSchemalabel").text("${databaseSchema}");

			if (value == "mysql" && $("#useCustomSchemaCredentials").is(':checked')) {
				$(".schemaUser").show();
				$(".schemaPassword").show();
			} else {
				$(".schemaUser").hide();
				$(".schemaPassword").hide();
			}
			
			if (value != "oracle") {
				$("#oracleRemoteConnectionInfo").hide();
			} else if ($("#oracleAdminCheckbox").is(':checked')) {
				$("#oracleRemoteConnectionInfo").show();
			}

			if (!$("#host").val()){
				$("#host").val("localhost");
			}

			$(".customSchema").show();
			$("#oracleSchemaPanel").hide();
			$("#oracleAdminCheckboxPanel").hide();
			$("#adminFields").show();

			
			if (value == "builtin"){
				$("#builtinhint").show();
				$("#mysqlhint").hide();
				toggleFieldSet(true);
				$("#test-connection").hide();
				$(".customSchema").hide();
				$("#schemaUser").val(defaultSchemaUser);
				$("#nextButton").removeAttr('disabled');
				$("#nextButton").removeClass('next-button-disabled');
			} else {
				toggleFieldSet(false);
				$("#test-connection").show();

				if (value == "oracle"){
					showOracleDatabaseOptions();
				} else if (value == "mysql"){
					$("#builtinhint").hide();
					$("#mysqlhint").show();
					if (mysqlHost == "") {
						mysqlHost = "localhost"
					}
					$("#host").val(mysqlHost);
					if (mysqlPort == "") {
						mysqlPort = 3306;
					}
					$("#port").val(mysqlPort);
					if (mysqlSchema == ""){
						mysqlSchema = "codebeamer";
					}
					$("#schema").val(mysqlSchema);
					/* $("#adminUser").val("root");
					$("#schemaUser").val(defaultSchemaUser); */
					if (mysqlAdminUser == "") {
						mysqlAdminUser = "root";
					}
					$("#adminUser").val(mysqlAdminUser);
					$("#adminPassword").val(mysqlAdminPassword);
					
					if (mysqlSchemaUser == "") {
						mysqlSchemaUser = "cbroot";
					}
					$("#schemaUser").val(mysqlSchemaUser);
					$("#schemaPassword").val(mysqlSchemaPassword);

				}
			}
		});

		$("#oracleAdminCheckbox").change(function() {
			$("#nextButton").attr('disabled','disabled');
			$("#nextButton").addClass('next-button-disabled');
			var $this = $(this);
			if ($this.is(':checked')) {
				$("#adminFields").show();
				$("#oracleRemoteConnectionInfo").show();
			} else {
				$("#adminFields").hide();
				$("#oracleRemoteConnectionInfo").hide();
			}
		});
		
		if ($("#builtin").is(":checked")) {
			toggleFieldSet(true);
		}

		var databaseType =  $("input[type='radio']:checked").val();
		var portValue = $("#port").val();

		if (databaseType == "mysql"){
			$("#builtinhint").hide();
			$("#mysqlhint").show();
			if (mysqlHost == "") {
				mysqlHost = "localhost"
			}
			$("#host").val(mysqlHost);
			if (mysqlPort == "") {
				mysqlPort = 3306;
			}
			$("#port").val(mysqlPort);
			if (mysqlSchema == ""){
				mysqlSchema = "codebeamer";
			}
			$("#schema").val(mysqlSchema);
			if (mysqlAdminUser == "") {
				mysqlAdminUser = "root";
			}
			$("#adminUser").val(mysqlAdminUser);
			$("#adminPassword").val(mysqlAdminPassword);
			
			if (mysqlSchemaUser == "") {
				mysqlSchemaUser = "cbroot";
			}
			$("#schemaUser").val(mysqlSchemaUser);
			$("#schemaPassword").val(mysqlSchemaPassword);
		} else if (databaseType == "oracle"){
			showOracleDatabaseOptions();
		}
		else if (databaseType == "builtin"){
			$("#builtinhint").show();
			$("#mysqlhint").hide();
			$("#test-connection").hide();
			if (windowsPlatform == "true"){
				$("#windowsMysqlInstallInfo").show();
			}
			$(".customSchema").hide();
			$("#nextButton").removeAttr('disabled');
			$("#nextButton").removeClass('next-button-disabled');
		}

		$("#test-connection").click(function() {
			codebeamer.installer.testConnection(contextPath, $('form').first());
			return false;
		});
	});
</script>

