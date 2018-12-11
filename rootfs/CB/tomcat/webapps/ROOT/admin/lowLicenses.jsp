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
 *
 * $Revision$ $Date$
--%>
<meta name="decorator" content="main"/>
<meta name="module" content="login"/>
<meta name="moduleCSSClass" content="workspaceModule loginModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:set var="link"
	value="mailto:support@intland.com?subject=License%20Request%20for%20Host-ID:%20${HOSTID}" />

<ui:showErrors />

<TABLE WIDTH="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD BGCOLOR="white" ALIGN="center">

		<TABLE WIDTH="600" BORDER="0" CELLPADDING="0" CELLSPACING="0">
		<c:if test="${!empty ACTIVATED_USERS}">
			<TR>
				<TD CLASS="warningtext"><ui:showErrors /></TD>
			</TR>

			<TR>
				<TD CLASS="warningtext">
					<spring:message code="sysadmin.lowLicenses.warning" text="The number of {0} accounts ({1}) exceeds the number of licensed users ({2}) !" arguments="${licenseCode.type},${ACTIVATED_USERS},${MAX_USERS}"/>
				</TD>
			</TR>
		</c:if>

		<TR>
			<TD>&nbsp;</TD>
		</TR>

		<TR>
			<TD>
				<spring:message code="sysadmin.lowLicenses.hint" text="Please Contact {0} Intland for a License Key." arguments="${link}"/>
			</TD>
		</TR>

		<TR>
			<TD>&nbsp;</TD>
		</TR>

		<TR>
			<TD><html:link page="/"><spring:message code="button.continue" text="Continue"/></html:link></TD>
		</TR>

		<TR>
			<TD>&nbsp;</TD>
		</TR>

		</TABLE>
	</TD>
</TR>

</TABLE>
