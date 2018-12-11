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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<table cellspacing="0" cellpadding="0">
	<tr>
		<td class="labelColumn"><spring:message code="useradmin.importUsers.fieldSeparator.label" text="Field Separator"/>:</td>
		<td>
			<form:select path="fieldSeparator">
				<form:option value="\t">&lt;TAB&gt;</form:option>
				<form:option value=","/>
				<form:option value=";"/>
				<form:option value="#"/>
			</form:select>
			<BR/>
			<form:errors path="fieldSeparator" cssClass="invalidfield"/>
		</td>
	</tr>
	<tr>
		<td class="labelColumn"><spring:message code="useradmin.importUsers.charsetName.label" text="Character Set"/>:</td>
		<td>
			<form:select path="charsetName">
				<form:options items="${importForm.availableCharsetNames}" itemLabel="name" itemValue="value" />
			</form:select>
			<BR/>
			<form:errors path="charsetName" cssClass="invalidfield"/>
		</td>
	</tr>
</table>
