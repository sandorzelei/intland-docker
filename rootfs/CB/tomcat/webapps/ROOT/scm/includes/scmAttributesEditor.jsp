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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="uitaglib" prefix="ui" %>


<%-- JSP fragment edits SCM repository properties during project creation or repo-creation

  Inputs:
  request.scmForm	The form-bean (project creation or repo-creation
  param.projCreation True if this is called during project creation		// TODO: why there is a difference? the SCM description should be editable during SCM creation too !
--%>

<c:set var="projCreation" value="${param.projCreation == 'true'}"/>

<c:set var="scmPackageLabel" value="scc.module.label" />

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>

<c:choose>
	<c:when test="${scmForm.type eq 'svn'}">
		<c:set var="scmPackageRequirement" value="optional" />
		<c:set var="scmPackageLabel" value="scc.folder.label" />
	</c:when>
	<c:when test="${scmForm.type eq 'synergy'}">
		<c:set var="scmPackageLabel" value="scc.project.label" />
	</c:when>
	<c:when test="${scmForm.type eq 'vss'}">
		<c:set var="scmPackageLabel" value="scc.project.label" />
	</c:when>
	<c:when test="${scmForm.type eq 'pvcs'}">
		<c:set var="scmPackageLabel" value="scc.project.label" />
	</c:when>
</c:choose>

<c:forEach items="${scmForm.attributeNames}" var="attribute">
	<c:if test="${attribute eq 'host'}">
		<c:set var="supportHost" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'repository'}">
		<c:set var="supportRepository" value="true"/>
	</c:if>
	<%-- is this the correct replacement of supportUrl? --%>
	<c:if test="${attribute eq 'access-url'}">
		<c:set var="supportUrl" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'protocol'}">
		<c:set var="supportProtocol" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'port'}">
		<c:set var="supportPort" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'package'}">
		<c:set var="supportPackage" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'tag'}">
		<c:set var="supportTag" value="true"/>
	</c:if>
	<%--<c:if test="${capability.value && capability.key eq 'supportTrackerChain'}">
		<c:set var="supportTrackerChain" value="true"/>
	</c:if>--%>
	<c:if test="${attribute eq 'checkout'}">
		<c:set var="supportSyncCheckout" value="true"/>
	</c:if>
	<c:if test="${attribute eq 'update'}">
		<c:set var="supportSyncUpdate" value="true"/>
	</c:if>
	<%--<c:if test="${capability.value && capability.key eq 'supportProjectList'}">
		<c:set var="supportProjectList" value="true"/>
	</c:if>--%>
</c:forEach>

<tr>
	<td class="mandatory"><spring:message code="project.administration.scm.managed.repository.name.label" text="Repository Name"/>:</td>
	<td NOWRAP>
		<form:input path="repositoryName" size="80" maxlength="255" />
		<br/>
		<form:errors path="repositoryName" cssClass="invalidfield"/>
	</td>
</tr>

<%-- TODO: if the repo description should be editable during SCM creation too? --%>
<c:if test="${projCreation}">
<tr>
	<td class="optional labelcell">
		<spring:message code="scm.repository.description.label" text="Description"/>:
	</td>
	<td>
		<wysiwyg:editor editorId="editor" disablePreview="true" useAutoResize="false" formatSelectorSpringPath="descriptionFormat" height="200" overlayHeaderKey="wysiwyg.repository.description.editor.overlay.header">
		    <form:textarea id="editor" path="repositoryDescription" rows="10" cols="10" />
		</wysiwyg:editor>
		<br/>
		<form:errors path="repositoryDescription" cssClass="invalidfield"/>
	</td>
</tr>
</c:if>

<c:if test="${supportHost}">
	<TR>
		<TD class="optional"><spring:message code="scm.repository.host.label" text="Host"/>:</TD>
		<TD CLASS="expandText">
			<form:input size="60" path="host" cssClass="expandText" />
			<BR/>
			<form:errors path="host" cssClass="invalidfield"/>
		</TD>
	</TR>
</c:if>

<c:if test="${supportRepository}">
	<TR>
		<TD class="mandatory">
			<c:choose>
				<c:when test="${scmForm.type == 'cvs'}">
					<spring:message code="scm.repository.repositoryPath.label" text="Repository path"/>:
				</c:when>
				<c:when test="${scmForm.type == 'perforce'}">
					<spring:message code="scm.repository.repositoryUrl.perforce.label" text="Perforce Server Url"/>:
				</c:when>
				<c:otherwise>
					<spring:message code="scm.repository.repositoryUrl.label" text="Url"/>:
				</c:otherwise>
			</c:choose>
		</TD>
		<TD CLASS="expandText">
			<form:input size="60" path="repository" cssClass="expandText" />
			<BR/>
			<form:errors path="repository" cssClass="invalidfield"/>
		</TD>
	</TR>
</c:if>

<c:choose>
	<c:when test="${scmForm.type == 'perforce'}">
		<c:set var="supportPackage" value="false"/>
		<TR>
			<TD class="mandatory" NOWRAP>&nbsp;<spring:message code="scm.repository.perforce.depot.path"/>:&nbsp;</TD>
			<TD NOWRAP CLASS="expandText">
				<form:input path="scmPackage" size="60" cssClass="expandText" />
				<BR/>
				<form:errors path="scmPackage" cssClass="invalidfield"/>
			</TD>
		</TR>
		<TR>
			<TD class="optional" NOWRAP>&nbsp;<spring:message code="scm.repository.perforce.encoding"/>:&nbsp;</TD>
			<TD NOWRAP CLASS="expandText">
				<form:input path="encoding" size="60" cssClass="expandText" />
				<BR/>
				<form:errors path="encoding" cssClass="invalidfield"/>
			</TD>
		</TR>
	</c:when>
</c:choose>

<TR>
	<TD class="optional"><spring:message code="scm.repository.user.label" text="User"/>:</TD>
	<TD CLASS="expandText">
		<form:input path="user" size="60" cssClass="expandText" autocomplete="off" />
		<BR/>
		<form:errors path="user" cssClass="invalidfield"/>
	</TD>
</TR>

<TR>
	<TD class="optional"><spring:message code="scm.repository.password.label" text="Password"/>:</TD>
	<TD CLASS="expandText">
		<ui:password path="password" size="60" cssClass="expandText" showPlaceholder="false" autocomplete="off" />
		<BR/>
		<form:errors path="password" cssClass="invalidfield"/>
	</TD>
</TR>

<c:if test="${supportProtocol}">
	<TR>
		<TD class="mandatory" ><spring:message code="scm.repository.protocol.label" text="Connection type"/>:</TD>

		<TD><form:radiobutton path="protocol" value="pserver" label="pserver"/>
			<form:radiobutton path="protocol" value="ext" label="ext"/>
			<form:radiobutton path="protocol" value="ssh" label="ssh"/>
			<form:radiobutton path="protocol" value="" label="local (on the CodeBeamer server)"/>
		</TD>
	</TR>
</c:if>

<c:if test="${supportPort}">
	<TR>
		<TD class="optional"><spring:message code="scm.repository.port.label" text="Port"/>:</TD>
		<TD CLASS="expandText">
			<form:input path="port" size="10" cssClass="expandText" />
			<BR/>
			<form:errors path="port" cssClass="invalidfield"/>
		</TD>
	</TR>
</c:if>

<c:if test="${supportPackage}">
	<TR>
		<TD CLASS="<c:out value="${scmPackageRequirement}" />" NOWRAP>&nbsp;<spring:message code="${scmPackageLabel}"/>:&nbsp;</TD>
		<TD NOWRAP CLASS="expandText">
			<form:input path="scmPackage" size="60" cssClass="expandText" />
			<BR/>
			<form:errors path="scmPackage" cssClass="invalidfield"/>
		</TD>
	</TR>
</c:if>

<c:if test="${supportTag}">
	<TR>
		<TD class="optional"><spring:message code="scm.repository.tag.label" text="Tag/Branch"/>:</TD>
		<TD CLASS="expandText"><form:input size="60" path="tag" /><br/><form:errors path="tag" cssClass="invalidfield"/></TD>
	</TR>
</c:if>

<c:if test="${scmForm.supportCommitOnlyWithTaskId}">
	<TR VALIGN="top">
		<TD class="optional"><spring:message code="scm.repository.scmLoop.label" text="Tracker SCM Loop"/>:</TD>

		<TD>
			<form:checkbox path="commitOnlyWithTaskId" id="commitOnlyWithTaskId"/>
			<label for="commitOnlyWithTaskId">
				<spring:message code="scm.repository.commitOnlyWithTaskId.label" text="Allow checkins/commits only with valid CodeBeamer Issue IDs"/>
			</label>
			<c:if test="${projCreation}">
				<br/>
				<form:checkbox path="commitOnlyWithRole" id="commitOnlyWithRole" />
				<label for="commitOnlyWithRole">
					<spring:message code="scm.repository.commitOnlyWithRole.label" text="Allow checkins/commits only for members with SCM - Commit permission"/>
				</label>
			</c:if>
		</TD>
	</TR>
</c:if>


