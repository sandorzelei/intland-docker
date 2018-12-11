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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<div id="author">
	<ui:submission userId="${user.id}" userName="${user.name}" date="${now}"/>
</div>

<spring:message var="commentText" code="comment.label" />
<spring:message var="cancelText" code="button.cancel" />

<div id="newcomment-form" class="inplace-form">
	<c:url var="actionUrl" value="/proj/scm/pullrequest/addcomment.spr?task_id=${pullRequest.id}"/>
	<form:form action="${actionUrl}" commandName="addPullRequestCommentForm" onsubmit="return validateCommentEditor(this)" method="post">
		<form:hidden path="comment.trackerItem.id"/>
		<form:textarea path="comment.description" cols="80" rows="8"/>
		<div class="okcancel">
			<input type="submit" class="button" value="${commentText}" />
			<a href="#" onclick="closeCommentEditor(); return false;">${cancelText}</a>
		</div>
	</form:form>
</div>

<div id="updatecomment-form" class="inplace-form">
	<c:url var="actionUrl" value="/proj/scm/pullrequest/updatecomment.spr"/>
	<form:form action="${actionUrl}" commandName="addPullRequestCommentForm" onsubmit="return validateCommentEditor(this)" method="post">
		<form:hidden path="comment.trackerItem.id"/>
		<form:hidden path="comment.id"/>
		<form:textarea path="comment.description" cols="80" rows="8"/>
		<div class="okcancel">
			<input type="submit" class="button" value="${commentText}" />
			<a href="#" onclick="return false;">${cancelText}</a>
		</div>
	</form:form>
</div>

<script language="javascript" type="text/javascript">
$(document).ready(function() {
	<%-- build the invisible topmost row for new comments --%>
	$("table#comment").prepend("<tr id='commentrow'><td id='author-cell' class='textData columnSeparator'></td><td id='commentbox-cell'></td><td></td></tr>");
	$("table#comment td#author-cell").prepend($("div#author"));
	$("table#comment td#commentbox-cell").prepend($("div#newcomment-form"));

	<%-- make existing comments updateable --%>
	$("table#comment .editable").dblclick(function() {
		var currentlyEditedComments = $("table#comment tr.edited").length;
		if(currentlyEditedComments != 0) {
			return;
		}
		var $this = $(this);

		var writable = $this.hasClass("writable");
		if(! writable) {
			return;
		}

		var id = $(this).find("span[id]").attr("id");
		var oldComment = $(this).find("span.raw").text();
		$(this).get(0).oldHtml = $(this).html();

		$(this).closest("tr").addClass("edited");
		$(this).html($("div#updatecomment-form").html());
		$(this).find("input[name='comment.id']").val(id);
		$(this).find("textarea").val(oldComment).focus();
		$(this).find("a").click(function() {
			$(this).closest("tr").removeClass("edited");
			var $editable = $(this).closest(".editable");
			$editable.html($editable.get(0).oldHtml);
			return false;
		});
	});
});

function openCommentEditor() {
	$("#commentrow").show();
	$("#commentrow .inplace-form").show();
	$("#commentrow textarea").focus();
}

function closeCommentEditor() {
	$("#commentrow").hide();
}

function validateCommentEditor(form) {
	var commentText = form.elements["comment.description"].value;
	if (trim(commentText).length == 0) {
		alert('"Comment" is required!');
		return false;
	}
	return true;
}

function confirmAndDeleteComment(url) {
	if (confirm('<spring:message code="tracker.delete.comment.confirm" />')) {
		submitWithPost(url);
	}
}
</script>

<div class="actionBar">
	<ui:actionLink keys="addComment" builder="scmPullRequestActionMenuBuilder" subject="${pullRequest}" />
</div>

<display:table excludedParams="orgDitchnetTabPaneId" class="expandTable" requestURI="${requestURI}" name="${comments}" id="comment" cellpadding="0"	defaultsort="1" defaultorder="descending" export="false">

	<c:set var="limitedVisibility" value="${! empty comment.visibility && comment.visibility != 0 && comment.visibility != 1}" />

	<spring:message var="submittedTitle" code="comment.submittedAt.label" text="Submitted"/>
	<display:column title="${submittedTitle}" sortProperty="submittedAt" headerClass="textData" class="textData columnSeparator" style="width:10%; padding-top:2px; padding-bottom:15px;">
		<ui:submission userId="${comment.submitter.id}" userName="${comment.submitter.name}" date="${comment.submittedAt}"/>
	</display:column>

	<spring:message var="commentTitle" code="comment.label" text="Comment"/>
	<c:set var="writable" value="${comment.submitter.id == user.id}" />
	<display:column title="${commentTitle}" headerClass="textData" class="textDataWrap editable ${writable ? 'writable' : '' }">
		<span id="${comment.id}">
			<tag:transformText value="${comment.description}" format="${comment.descriptionFormat}" />
		</span>
		<%-- store some redundant data in the DOM in its original format for later editing --%>
		<span class="raw"><c:out value="${comment.description}"/></span>
		<c:if test="${limitedVisibility}">
			<spring:message var="roleName" code="role.${comment.role.name}.label" text="${comment.role.name}"/>
			<p class="subtext" style="margin-bottom:0;" title="<spring:message code='issue.attachment.limited.visibility.tooltip'/>">
				<img src='<c:url value="/images/shield.png"/>' style="vertical-align: bottom;" />
				<spring:message code="issue.attachment.limited.visibility.info" arguments="${roleName}"/>
			</p>
		</c:if>
	</display:column>

	<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth" style="padding:5px;">
		<c:if test="${writable}">
			<a href="#" onclick="confirmAndDeleteComment('<c:url value="/proj/scm/pullrequest/deletecomment.spr?comment_id=${comment.id}"/>'); return false;" title="Delete this comment"><img src="<c:url value="/images/edittrash.gif"/>"></a>
		</c:if>
	</display:column>
</display:table>
