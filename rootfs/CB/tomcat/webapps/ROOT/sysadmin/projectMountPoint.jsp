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
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<%@page import="com.intland.codebeamer.persistence.dao.impl.ProjectDaoImpl"%>

<div class="warning">
	<spring:message code="project.mountPoint.warning" arguments="${licenseCode.type}"/>
</div>

<ui:showErrors/>

<html:form action="/sysadmin/setProjectMountPoint">
	<html:hidden property="proj_id" value="${project.id}" />

	<TABLE BORDER="0" class="formTableWithSpacing" CELLPADDING="2">

		<TR>
			<TD class="mandatory"><spring:message code="project.mountPoint.label" text="Mount Point"/>:</TD>
			<TD CLASS="expandText">
				<html:text styleClass="expandText" size="80" property="mountPoint" value="${project.mountPoint}" />
				<span class="subtext">
					<spring:message code="project.mountPoint.tooltip" text="Enter the full filesystem path for the new repository location, or leave it blank if you want to use the default repository."/>
				</span>
			</TD>
		</TR>

		<TR>
			<TD COLSPAN="2">
				<spring:message var="saveButton" code="button.save" text="Save"/>
				<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>

				&nbsp;&nbsp;<html:submit styleClass="button" property="SAVE" value="${saveButton}" />
				&nbsp;&nbsp;<html:cancel styleClass="button" value="${cancelButton}"/>
			</TD>
		</TR>

	</TABLE>
</html:form>
