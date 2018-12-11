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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
	.ditch-tab-skin-cb-box {
		padding: 0px !important;
	}
	.smallLink {
		padding-right: 20px;
	}
	.formTableWithSpacing {
		border-spacing: 0 !important;
	}
	#editor_path_row {
		width: 5px !important;
		height: 5px !important;
	}
	#editor_resize {
		width: 5px !important;
		height: 5px !important;
	}
	.ditch-tab-skin-cb-box {
		margin-top: 15px;
	}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		codebeamer.prefill.prevent($("input[type=password]"), getBrowserType());
	});
</script>

<%-- JSP fragment shows the repository properties editable --%>
<wysiwyg:froalaConfig />

<div class="contentWithMargins">
	<table border="0" class="formTableWithSpacing">
		<tr valign="middle">
			<spring:message var="repositoryNameTitle" code="project.administration.scm.managed.repository.name.label" text="Repository name"/>
			<td class="mandatory labelcell">
				${repositoryNameTitle}
			</td>
			<td>
				<c:choose>
					<c:when test="${param.propertyNameEditable == true}">
						<form:input path="repositoryName" title="${repositoryNameTitle}" style='width: 100%;' maxlength="255"/>
						<div class="invalidfield"><form:errors path="repositoryName" cssClass="invalidfield"/></div>
					</c:when>
					<c:otherwise>
						<c:out value="${command.repositoryName}" />
						<form:hidden path="repositoryName"/>
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
		<c:if test="${!command.managed and command.possibleToManage}">
			<tr>
				<td class="mandatory"><spring:message code="scm.repository.repositoryURL.label" text="Url"/>:</td>
				<td CLASS="expandText">
					<c:out value="${command.repositoryUrl}" />
					<form:hidden path="repositoryUrl"/>
					<div class="invalidfield"><form:errors path="repository" cssClass="invalidfield"/></div>
				</td>
			</tr>
			<tr>
				<spring:message code="scm.repository.user.label" text="User" var="userTitle"/>
				<td class="optional">${userTitle}:</td>
				<td class="expandText">
					<form:input path="user" title="${userTitle}" size="80"/>
					<div class="invalidfield"><form:errors path="user" cssClass="invalidfield"/></div>
				</td>
			</tr>
			<tr>
				<spring:message code="scm.repository.password.label" text="Password" var="passwordTitle"/>
				<td class="optional">${passwordTitle}:</td>
				<td class="expandText">
					<ui:password path="password" title="${passwordTitle}" size="80" autocomplete="off"/>
					<div class="invalidfield"><form:errors path="password" cssClass="invalidfield"/></div>
				</td>
			</tr>
			<c:if test="${supportsPackage}">
				<tr>
					<spring:message var="moduleNameTitle" code="scc.module.label" text="Package"/>
					<c:if test="${command.scmType == 'perforce'}">
						<spring:message var="moduleNameTitle" code="scm.repository.perforce.depot.path"/>
					</c:if>
					<td class="optional">${moduleNameTitle}:</td>
					<td class="expandText">
						<form:input path="sourcePackage" title="${moduleNameTitle}" size="80"/>
						<div class="invalidfield"><form:errors path="sourcePackage" cssClass="invalidfield"/></div>
					</td>
				</tr>
			</c:if>
			<c:if test="${supportsTag}">
				<tr>
					<spring:message code="scm.repository.tag.label" text="Tag/Branch" var="tagTitle"/>
					<td class="optional">${tagTitle}:</td>
					<td class="expandText">
						<form:input path="tag" title="${tagTitle}" size="80"/>
						<div class="invalidfield"><form:errors path="tag" cssClass="invalidfield"/></div>
					</td>
				</tr>
			</c:if>
		</c:if>
		<c:if test="${command.possibleToManage && supportPublicRead}">
			<tr>
				<td class="optional labelcell"><spring:message code="scm.repository.publicRead.label" text="Public access"/>:</td>
				<td class="expandText">
					<form:checkbox path="publicRead"/>
				</td>
			</tr>
		</c:if>
		<tr>
			<td class="optional"><spring:message code="scm.repository.scmLoop.label" text="Tracker SCM Loop"/>:</td>
			<td>
				<form:checkbox path="commitOnlyWithTaskId" id="commitOnlyWithTaskId"/>
				<label for="commitOnlyWithTaskId">
					<spring:message code="scm.repository.commitOnlyWithTaskId.label" text="Allow checkins/commits only with valid CodeBeamer Issue IDs"/>
				</label>

				<br/>
				<form:checkbox path="commitNeedsRole" id="commitNeedsRole" />
				<label for="commitNeedsRole">
					<spring:message code="scm.repository.commitOnlyWithRole.label" text="Allow checkins/commits only for members with SCM - Commit permission"/>
				</label>
			</td>
		</tr>
		<c:if test="${command.possibleToManage && distributed}">
			<tr>
				<td class="optional labelcell"><spring:message code="scm.repository.votesRequired.label" text="Votes required"/>:</td>
				<td class="expandText">
					<form:input type="number" min="0" max="100"  path="votesRequired" size="5"/>
					<label><spring:message code="scm.repository.votesRequired.hint" text="Number of votes required for Pull-Request merging" /></label>
					<div class="invalidfield"><form:errors path="votesRequired" cssClass="invalidfield"/></div>
				</td>
			</tr>
		</c:if>
		<tr>
			<td class="optional labelcell">
				<spring:message code="project.description.label" text="Description"/>:
			</td>
			<td class="expandTextArea">
				<wysiwyg:editor editorId="editor" disablePreview="true" useAutoResize="false" formatSelectorSpringPath="descriptionFormat" resizeEditorToFillParent="true">
					<form:textarea id="editor" path="description" rows="13" cols="90" />
				</wysiwyg:editor>
			</td>
		</tr>
		<tr>
			<td>
				<form:errors path="description" cssClass="invalidfield"/>
			</td>
		</tr>
	</table>
</div>
