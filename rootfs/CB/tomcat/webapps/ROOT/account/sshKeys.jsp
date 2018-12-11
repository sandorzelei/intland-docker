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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="uitaglib" prefix="ui"%>

<meta name="decorator" content="main" />
<meta name="module" content="mystart" />
<meta name="moduleCSSClass" content="workspaceModule newskin" />

<spring:message var="textAreaTitle"
	code="user.AccountSshKeys.sshkey.editor.title"
	text="Set it blank to get it deleted." />

<script type="text/javascript">
	function addTextArea() {

		var title = "${textAreaTitle}";
		var rowCount = $('.textbox-table tr').length;
		var key = "sshkey_" + (rowCount - 1);
		var lastRowText = "";

		var lastRowTextArea = $('.textbox-table tr:last td textarea');

		console.log(lastRowTextArea);
		console.log(lastRowTextArea.val());

		if (lastRowTextArea.val().length > 0) {
			lastRowText = lastRowTextArea.val();
			lastRowTextArea.val("");
		}
		$('.textbox-table tr:last')
				.before(
						"<tr><td class=\"expandTextArea\" title=\"" + title + "\">"
								+ "<textarea name=\"" + key + "\" rows=\"5\" class=\"expandTextArea\">"
								+ lastRowText + "</textarea></td></tr>");

		/* prevents post event */
		return false;
	}
</script>

<style type="text/css">
.expandTextArea {
	width: 98%;
}

textarea {
	width: 100%;
	white-space: normal;
	padding: 10px;
	border: solid 1px #d1d1d1;
}

span.invalidfield {
	padding: 2px 4px;
	background: yellow;
	color: #F00 !important;
	font-size: 8pt;
	font-weight: bold;
}

#uploadBlock {
	margin: 15px 0;
}

.newskin .actionBar {
	margin-bottom: 25px;
}

#content {
	margin: 15px;
}

#content td {
	padding-bottom: 15px;
}

.textbox-table {
	border: 0px;
	width: 100%;
}
</style>

<ui:actionMenuBar cssClass="accountHeadLine">
	<ui:pageTitle>
		<spring:message code="user.AccountSshKeys.page.title" />
	</ui:pageTitle>
</ui:actionMenuBar>

<form:form commandName="sshKeysForm" autocomplete="off" action="updateaccountsshkeys.spr"
	enctype="multipart/form-data">

	<ui:actionBar>
		<spring:message var="saveButton" code="button.save" text="Save" />
		<spring:message var="cancelButton" code="button.cancel" text="Cancel" />

		<input type="submit" class="button" name="save" value="${saveButton}" />
		<input type="submit" class="button cancelButton" name="cancel"
			value="${cancelButton}" />
	</ui:actionBar>


	<div id="content">
		<spring:message code="user.AccountSshKeys.page.explanation" />
		<div id="uploadBlock">
			<spring:message code="user.AccountSshKeys.upload" />
			<input type="file" name="file" size="30"
				onchange="$('#uploadSubmit').click();" /> &nbsp;<input
				type="submit" name="upload" value="upload" class="button"
				id="uploadSubmit" style="display: none;" />
		</div>

		<table class="textbox-table">
			<c:forEach items="${sshKeys}" var="sshKey" varStatus="loop">
				<c:set var="key" value="sshkey_${loop.index}" />
				<c:set var="invalidMessage" value="${invalidFields[key]}" />
				<tr>
					<td class="expandTextArea" title="${textAreaTitle}"><c:if
							test="${invalidMessage != null}">
							<span class="invalidfield"> ${invalidMessage} </span>
						</c:if> <textarea name="${key}" rows="5" class="expandTextArea">${sshKey}</textarea>
					</td>
				</tr>
			</c:forEach>
			<tr>
				<td class="expandTextArea" title="${textAreaTitle}"><textarea
						name="sshkey_new" rows="5" class="expandTextArea"></textarea></td>
			</tr>
		</table>
		<spring:message var="addButtonTitle"
			code="user.AccountSshKeys.add.more.button.title"
			text="Add more SSH keys" />
		<spring:message var="addButtonValue" code="button.add.more"
			text="Add more" />
		<a href="#" onclick="return addTextArea();" >${addButtonTitle}</a>
	</div>
</form:form>
