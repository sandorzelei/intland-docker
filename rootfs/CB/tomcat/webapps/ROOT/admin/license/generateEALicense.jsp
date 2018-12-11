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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib"   prefix="tag"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<meta name="decorator" content="main"/>
<meta name="module" content="admin"/>
<meta name="moduleCSSClass" content="newskin adminModule"/>

<style type="text/css">

	.fieldWidth {
		width: 220px;
		padding: 4px;
	}

	.formTable {
		border-collapse: separate;
		border-spacing: 1px;
		padding-top: 15px;
		padding-left: 10px;
		vertical-align: middle;
		border: 0px;
	}

	.formtable th,td {
    	padding: 2px;
	}

	.readyLicense {
		margin-top: 10px;
		background-color: #D6F5D7;
	}

	.licenseWidth {
		width: 420px;
		padding: 4px;
	}

	.generatedLicense {
	    padding-right: 10px;
    	margin: 0px;
	}

</style>

<!-- controller for this view: EALicenseGeneratorController.java -->

<ui:actionMenuBar showGlobalMessages="false">
	<span class="titlenormal">
		<ui:pageTitle><spring:message code="sysadmin.license.ea.generate" text="Generate License for Enterprise Architect Connector"/></ui:pageTitle>
	</span>
</ui:actionMenuBar>

<c:url var="generateEALicenseUrl" value="/sysadmin/generateEALicense.spr"/>

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>

<form action="${generateEALicenseUrl}" method="post">

	<ui:actionBar>
		<c:if test="${not valid}">
			<spring:message var="generateButton" code="sysadmin.license.create.label" text="Generate License"/>
			&nbsp;&nbsp;<input type="submit" class="button" value="${generateButton}" />
		</c:if>
		<c:if test="${valid}">
			<spring:message var="generateButton" code="sysadmin.license.ea.create" text="Create New License"/>
			<a href="${generateEALicenseUrl}">${generateButton}</a>
		</c:if>
	</ui:actionBar>

	<table class="formTableWithSpacing formTable">

		<c:if test="${not valid}">

			<!-- License user name  -->
			<tr>
				<td nowrap class="mandatory labelcell">
					<spring:message code="sysadmin.license.ea.user" text="License User"/>:
				</td>
				<td>
					<input type="text" name="licenseUser" class="fieldWidth" maxlength="100" value="<c:out value='${licenseUser}'/>" />
				</td>
			</tr>

			<!-- License expire date -->
			<tr>
				<td nowrap class="mandatory labelcell">
					<spring:message code="sysadmin.license.validUntil" text="Valid Until"/>:
				</td>
				<td>
					<input id="expires" class="fieldWidth" type="text" name="expires" size="20" maxlength="30" value="<tag:formatDate value="${expires}" type="date"/>" />&nbsp;
					<ui:calendarPopup textFieldId="expires"/>
				</td>
			</tr>

			<!-- License version -->
			<tr>
				<td nowrap class="optional labelcell">
					<spring:message code="cmdb.version.label" text="Release"/>:
				</td>
				<td>
					<select id="versionSelector" name="eaVersion" class="fieldWidth">
						<c:forEach items="${versions}" var="version">
							<option value="${version}" <c:if test="${version eq eaVersion}">selected="selected"</c:if>>
								${version}
							</option>
						</c:forEach>
					</select>
				</td>
			</tr>

			<!-- License type -->
			<tr>
				<td nowrap class="optional labelcell">
					<spring:message code="sysadmin.license.ea.type" text="License Type"/>:
				</td>
				<td>
					<select id="typeSelector" name="eaType" class="fieldWidth">
						<c:forEach items="${types}" var="type">
							<option value="${type}" <c:if test="${type eq eaType}">selected="selected"</c:if>>
								${type}
							</option>
						</c:forEach>
					</select>
				</td>
			</tr>

			<!-- Password -->
			<tr>
				<td nowrap class="mandatory labelcell">
					<spring:message code="user.password.label" text="Password"/>:
				</td>
				<td>
					<input type="password" name="password" class="fieldWidth" maxlength="100" autocomplete="off" />
				</td>
			</tr>
		</c:if>

		<c:if test="${valid}">

			<!-- Generated license, if the generation was sucessful -->
			<tr class="readyLicense">
				<td nowrap class="optional labelcell">
					<spring:message code="sysadmin.license.label" text="License"/>:
				</td>
				<td>
					<pre class="generatedLicense">${generatedLicense}</pre>
				</td>
			</tr>

		</c:if>

	</table>

</form>


