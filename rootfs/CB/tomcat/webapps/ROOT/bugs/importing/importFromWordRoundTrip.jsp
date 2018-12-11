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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>

<meta name="decorator" content="main"/>
<meta name="module" content="tracker"/>
<meta name="moduleCSSClass" content="trackersModule newskin ${importForm.tracker.isBranch() ? 'tracker-branch' : ''}" />

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="issue.import.roundtrip.title" text="Importing Items"/></ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<%-- TODO: adjust look... --%>
<style type="text/css">
	table#roundTripChanges {
		width: 100%;
		border: none;
	}
	table#roundTripChanges th {
		color: #2b2b2b;
	}

	table#roundTripChanges td {
		padding: 5px !important;
		vertical-align: top;
	}
	table#roundTripChanges td.label {
		color: gray;
		width: 1%;
	}
	table#roundTripChanges td.description {
		width: 40%;
		min-width: 20em;
	}
	table#roundTripChanges .wikiText {
		white-space: pre-wrap;
	}

	table#roundTripChanges tr.separator {
		border-top: solid 1px #eee !important;
		margin-bottom: 5px 0px;
	}
	table#roundTripChanges td.action {
		width: 1%;
		white-space: nowrap;
	}
	table#roundTripChanges input[type="checkbox"] {
		vertical-align: text-bottom;
	}

	.missingEntity, .notEditable, .notEditableProperty {
		color: #b31317;
		font-weight: bold;
	}
	.notEditableProperty {
		text-decoration: line-through;
	}

	table#roundTripChanges .sameContent {
		color: gray;
	}
	table#roundTripChanges .comment {
		border-top: solid 1px #eee;
	}
</style>

<spring:message var="saveButton" code="button.save"/>
<spring:message var="backButton" code="button.back"/>
<spring:message var="cancelButton" code="button.cancel"/>

<script type="text/javascript">
function onNextButton() {
	ajaxBusyIndicator.showProcessingPage();
}
</script>

<form:form commandName="importForm" action="${flowUrl}">
<ui:actionBar>
	<form:hidden path="trackerId" id="trackerIdInput"/>
	&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_back" value="${backButton}" />
	<c:if test="${! empty importForm.roundTripChanges}">
		&nbsp;&nbsp;<input type="submit" class="button" name="_eventId_next" value="${saveButton}" onclick="onNextButton();" />
	</c:if>
	<input type="submit" class="button cancelButton" name="_eventId_cancel" value="${cancelButton}" />
</ui:actionBar>

<ui:showErrors/>

<%-- hidden fields to clear checkboxes when nothing is selected --%>
<input type="hidden" name="_namesToImport" value="" />
<input type="hidden" name="_descriptionsToImport" value=""/>
<input type="hidden" name="_propertiesToImport" value="" />
<input type="hidden" name="_commentsToImport" value=""/>

<c:if test="${! empty importForm.roundTripChanges}">
<c:set var="sameContent"><span class="sameContent"><spring:message code="issue.import.roundtrip.same.value"/></span></c:set>
<spring:message var="applyChangeMessage" code="issue.import.roundtrip.apply.change" />
<c:set var="notEditableContent">
	<span class="notEditable"><spring:message code="issue.import.roundtrip.field.not.editable" /></span>
</c:set>

<!-- <input type="hidden" name="issues[]" id="checkedIssues" value=""/>-->
<div class="contentWithMargins">
	<table class="displaytag" id="roundTripChanges" cellpadding="0" cellspacing="0">
		<tr>
			<th colspan="2" style="text-align:left; padding-left:0;">
				<b>${fn:length(importForm.roundTripChanges)}</b> changes found of ${importForm.numberOfRoundtripEntities} total.
			</th>
			<th>Original</th>
			<th>Changes in <c:out value="${importForm.uploadFileName}" /></th>
			<th>
				<label for="checkAll">
					<input type="checkbox" id="checkAll" checked="checked" />Apply all?
				</label>
				<script type="text/javascript">
					//check/uncheck all "apply" checkboxes
					$(function() {
						$("#checkAll").click(function() {
							var checked = $(this).is(":checked");
							$("#roundTripChanges input[type='checkbox']").not(this).attr("checked", checked);
						});
					});
				</script>
			</th>
		</tr>
		<c:forEach var="change" items="${importForm.roundTripChanges}" varStatus="status">
		<tr class="${! status.first ? 'separator' : ''}">
			<td class="label">
				<a id="${change.interwikiLink}" ></a>
				<c:set var="link"><c:out value="${change.interwikiLink}" /></c:set>
				<c:choose>
					<c:when test="${!empty change.original}">
						<a href="<c:url value='${change.original.urlLink}'/>" target="_blank">${link}</a>
					</c:when>
					<c:otherwise>${link}</c:otherwise>
				</c:choose>
			</td>
			<td class="label">
				<spring:message code="tracker.field.Summary.label"/>:
			</td>
			<td class="name">
				<c:choose>
					<c:when test="${! empty change.original}">
						<c:out value="${change.original.name}" />
					</c:when>
					<c:otherwise>
						<span class="missingEntity"><spring:message code="issue.import.roundtrip.entity.missing" /></span>
					</c:otherwise>
				</c:choose>
			</td>
	<c:choose>
		<c:when test="${change.nameDiffers}">
			<td class="name">
				${change.nameDiff}
			</td>
			<td class="action">
				<c:choose>
					<c:when test='${change.nameEditable}'>
						<c:set var="id" value="namesToImport_${status.index}" />
						<label for="${id}">
							<form:checkbox id="${id}" path="namesToImport" value="${change.interwikiLink}" />${applyChangeMessage}
						</label>
					</c:when>
					<c:otherwise>
						<c:choose>
							<c:when test="${! empty change.nameNotEditableReason}"><span class="notEditable"><spring:message code="${change.nameNotEditableReason}"/></span></c:when>
							<c:otherwise>${notEditableContent}</c:otherwise>
						</c:choose>
					</c:otherwise>
				</c:choose>
			</td>
		</c:when>
		<c:otherwise>
			<td colspan="2">${sameContent}</td>
		</c:otherwise>
	</c:choose>

		</tr>
		<tr>
			<td/>
			<td class="label">
				<spring:message code="tracker.description.label"/>:
			</td>
	<c:choose>
		<c:when test="${change.descriptionDiffers}">
			<td class="description">
				<c:if test="${! empty change.original}">
					<c:set var="description"><c:out value="${change.original.description}" /></c:set>
					<div class="wikiText">${fn:trim(description)}</div>
				</c:if>
			</td>
			<td class="description">
				<%--
				<c:set var="description"><c:out value="${change.modified.description}" /></c:set>
				${fn:trim(description)}
				--%>
				<div class="wikiText">${change.descriptionDiff}</div>
			</td>
			<td class="action">
				<c:choose>
					<c:when test="${change.descriptionEditable}">
						<c:set var="id" value="descriptionsToImport_${status.index}" />
						<label for="${id}">
							<form:checkbox id="${id}" path="descriptionsToImport" value="${change.interwikiLink}" />${applyChangeMessage}
						</label>
						</c:when>
					<c:otherwise>${notEditableContent}</c:otherwise>
				</c:choose>
			</td>
		</c:when>
		<c:otherwise><td/><td colspan="2">${sameContent}</td></c:otherwise>
	</c:choose>

		</tr>

		<c:if test="${! empty change.referencedImages}">
			<tr>
				<td/>
				<td class="label">
					<spring:message code="attachments.label" />:
				</td>
				<td/>
				<td class="description">
					<span class="subtext">
					<c:forEach var="image" items="${change.referencedImages}" varStatus="imgstatus" >
						<c:if test="${! imgstatus.first}">, </c:if><c:out value="${image.name}"/>
					</c:forEach>
					</span>
				</td>
			</tr>
		</c:if>

		<c:if test="${! empty change.propertiesChanges}" >
			<tr>
				<td/>
				<td class="label">
					<spring:message code="document.properties.label" text="Properties"/>:
				</td>
				<td class="description">
					<c:forEach var="prop" items="${change.propertiesChanges}">
						<div><c:out value='${prop.key}'/> = <c:out value='${prop.value.left}'/></div>
					</c:forEach>
				</td>
				<td class="description">
					<c:set var="hasNotEditableProperty" value="false" />
					<c:forEach var="prop" items="${change.propertiesChanges}">
						<ct:call return="editableProperty" object="${change.propertiesWritable}" method="contains" param1="${prop.key}" />
						<c:set var="title" value="" />
						<c:if test="${! editableProperty}">
							<c:set var="hasNotEditableProperty" value="true" />
							<spring:message var="title" code="issue.import.roundtrip.property.can.not.be.saved.tooltip" />
						</c:if>
						<div class="${editableProperty ? '' : 'notEditableProperty'}" title='${title}' >
							<c:out value="${prop.key}"/> = <c:out value="${prop.value.right}"/>
						</div>
					</c:forEach>
				</td>
				<td class="action">
					<c:set var="id" value="propertiesToImport_${status.index}" />
					<label for="${id}">
						<form:checkbox id="${id}" path="propertiesToImport" value="${change.interwikiLink}" />${applyChangeMessage}
						<c:if test="${hasNotEditableProperty}">
							<div class="notEditable"><spring:message code="issue.import.roundtrip.property.can.not.be.saved" /></div>
						</c:if>
					</label>
				</td>
			</tr>
		</c:if>

		<c:if test="${! empty change.comments}">
			<c:forEach var="comment" items="${change.comments}" varStatus="commentStatus">
			<tr>
				<td/>
				<td class="label">
					<c:if test="${commentStatus.first}"><spring:message code="comments.label"/>:</c:if>
				</td>
				<td/>
				<td class="description comment ${! commentStatus.first ? 'firstComment' :''}">
					<c:set var="commentObject" value="${change.commentsAndArtifacts[comment]}"/>
					<c:set var="uploadConversationId" value="${commentObject.docxImages.uploadConversationId}" />
					<tag:transformText value="${comment.description}" format="${comment.descriptionFormat}" uploadConversationId="${uploadConversationId}" />
				</td>
				<td class="action">
					<c:choose>
						<c:when test="${change.canAttachOrComment}">
							<c:set var="id" value="commentsToImport_${comment.id}" />
							<label for="${id}">
								<form:checkbox id="${id}" path="commentsToImport" value="${comment.id}" />${applyChangeMessage}
							</label>
						</c:when>
						<c:otherwise>${notEditableContent}</c:otherwise>
					</c:choose>
				</td>
			</tr>
			</c:forEach>
		</c:if>

		</c:forEach>
	</table>
</div>
</c:if>
</form:form>
