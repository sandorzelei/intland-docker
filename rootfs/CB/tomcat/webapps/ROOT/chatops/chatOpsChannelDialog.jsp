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

<%@page import="com.intland.codebeamer.Config"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
		pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="acltaglib" prefix="acl" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>

<meta name="decorator" content="popup"/>

<script type="text/javascript">
function clearMessages() {
	$(".notification").hide();
	$(".warning").hide();
	$(".error").hide();
	$(".information").hide();
}

function showErrorMessage( errorMessage, permissionAuthUrl ) {
	if (errorMessage) {
		var errorSpan = $(".error").text(errorMessage);
		if (permissionAuthUrl) {
			var workspaceDomain = "${workspaceDomain}";
			var workspaceInfo = $("<span></span>").text(i18n.message("slack.permissions.missing.workspaceInfo", workspaceDomain)).append(" ");
			errorSpan.append($("<br>")).append(workspaceInfo);
			var authLink = $("<a>").attr('href', permissionAuthUrl).attr("target", "_blank").text(i18n.message("slack.permissions.missing.requestMissingPermissions"));
			errorSpan.append(authLink);
		}
		errorSpan.show();
	}
}

function clearInputs() {
	$("#newChannelNameInput").val("");
	$("#channelInitialMessageInput").val("");
	$("#channelPurposeInput").val("");
	var values = $("input[name=inviteUsers][type=hidden]").val();
	ajaxReferenceFieldAutoComplete.removeValueBoxes("userSelector", values.split(","));
}

function removeChannelSelectOptions() {
	$('#existingChannelSelector').find('optgroup').remove();
}

function getChatOpsChannelOptions(isPrivate) {
	var bs = ajaxBusyIndicator.showBusyPage();
	removeChannelSelectOptions();
	$("#existingChannelSelector").attr("disabled", true);
	$("#attachToExisting").attr("disabled", true);
	$.ajax({
		url: contextPath + "/chatops/getSelectableChatOpsChannels.spr?workItem_id=${workItem.id}&isPrivate=" + isPrivate,
		type: 'get',
		dataType: 'json',
		success: function(result) {
			if (result) {
				if (result.channels) {
					if (!result.channels.length) {
						return;
					}
					var select = $("#existingChannelSelector");
					var code = "slack.manageChannels.publicChannels";
					if (isPrivate) {
						code = "slack.manageChannels.privateChannels";
					}
					var channelOptionGroup = $("<optgroup>").attr("label", i18n.message(code));

					for (var i = 0; i < result.channels.length; i++) {
						var channel = result.channels[i];
						channelOptionGroup.append( $("<option>", { value: channel.id, text: channel.name }) );
					}
					select.append(channelOptionGroup);
					$("#existingChannelSelector").attr("disabled", false);
					$("#attachToExisting").attr("disabled", false);
				} else {
					if (result.warning) {
						$(".warning").text(result.warning).show();
					}
					showErrorMessage(result.error, result.permissionAuthUrl);
				}
			} else {
				showErrorMessage(i18n.message("slack.errorOccurred"));
			}
		},
		complete: function() {
			if (bs) {
				ajaxBusyIndicator.close(bs);
			}
		}
	});
}

function updateRemoveButtonAction() {
	$(".removeButton").click(function () {
		clearMessages();
		var workItemId = "${workItem.id}";
		var workItemName = "${ui:escapeJavaScript(workItem.name)}";
		var channelName = $(this).parent().find(".channelLink").text();
		var listItem  = $(this).parent();
		var channelDtoId =  listItem.attr("id");
		showFancyConfirmDialogWithCallbacks(i18n.message("slack.manageChannels.confirm.removeChannel", channelName, workItemName),
			function() {
				var bs = ajaxBusyIndicator.showBusyPage();
				var getUrl = contextPath + "/chatops/removeChannelFromWorkItem.spr?workItem_id=" + workItemId
						+ "&channel_id=" + channelDtoId;
				$.ajax({
					url: getUrl,
					type: 'get',
					dataType: 'json',
					success: function(result) {
						if (result) {
							if (result.success) {
								$(".notification").text(result.success).show();
								listItem.remove();
								var isPrivate = $("#includePrivateChannels").prop("checked") == true;
								getChatOpsChannelOptions(isPrivate);
							} else {
								showErrorMessage(result.error);
							}
						} else {
							showErrorMessage(i18n.message("slack.errorOccurred"));
						}
					},
					complete: function() {
						if (bs) {
							ajaxBusyIndicator.close(bs);
						}
						checkAttachedChannelExistence();
					}
				});
			});
	});
}

function addAttachedChannelToList( attachedChannelDto ) {
	var anchor = $("<a></a> ").attr("href", attachedChannelDto.channelURL).attr("target", "_blank").text(attachedChannelDto.name);
	anchor.addClass("channelLink");
	var lockImage = $("<img></img> ").attr("src", contextPath + "/images/newskin/action/lock.png").attr("title", i18n.message("slack.manageChannels.privateChannel.title"));
	var label = $("<label></label>\n");
	if (attachedChannelDto.isPrivate) {
		label.append(lockImage);
		label.append(" ");
	}
	label.append(anchor);
	label.append(" ");
	var span = $("<span></span>").attr("title", i18n.message("slack.manageChannels.detachChannelHint")).addClass("removeButton");

	var userSpan = $("<span></span>").append( i18n.message("slack.manageChannels.attachedChannels.attachedBy") + ": ");
	var userLink = $("<a></a>").attr("href", contextPath + attachedChannelDto.attacher.urlLink).attr("title", attachedChannelDto.attacher.realName).text(attachedChannelDto.attacher.name);
	userLink.append(" ");
	var lastModifiedAtSpan = $("<span></span>").append(attachedChannelDto.lastModifiedAt);
	var userDiv = $("<div></div>").addClass("attacherInfo").append(userSpan).append(userLink).append(lastModifiedAtSpan);

	var listItem = $("<li></li>").attr("id", attachedChannelDto.id).append(span).append(" ").append(label).append(userDiv);

	$("#attachedChannels").append(listItem);
	checkAttachedChannelExistence();
	updateRemoveButtonAction();
}

function isAttachedToChannel() {
	return $("#attachedChannels").has("li").length;
}

function checkAttachedChannelExistence() {
	$("#noAttachedMessage").hide();
	if (!isAttachedToChannel()) {
		$("#noAttachedMessage").show();
	}
}

jQuery(function($) {

	var $accordion = $('.accordion');
	$accordion.cbMultiAccordion();
	var messageThreadUrl = "${ui:escapeJavaScript(threadURL)}";
	$accordion.cbMultiAccordion("closeAll");
	if (messageThreadUrl) {
		$accordion.cbMultiAccordion("open", 0);
	} else {
		if (!isAttachedToChannel()) {
			$accordion.cbMultiAccordion("open", 1);
		} else {
			$accordion.cbMultiAccordion("open", 0);
		}
	}

	var defaultChannelName = "${ui:escapeJavaScript(workItem.tracker.keyName)}-${workItem.id}";
	$("#channelInitialMessageInput").val("${ui:escapeJavaScript(defaultInitialMessage)}");

	$('input[type=radio][name=actionType]').change(function() {
		if (this.value == 'new') {
			$('.attachToExistingChannelContainer').hide();
			$(".optionalTextareaContainer").show();
			$('.attachToNewChannelContainer').show();
			var newChannelName = $("#newChannelNameInput").val();
			if (newChannelName == null || newChannelName == "") {
				$("#newChannelNameInput").val(defaultChannelName);
			}
		}
		else if (this.value == 'existing') {
			$('.attachToNewChannelContainer').hide();
			$('.attachToExistingChannelContainer').show();
			$(".optionalTextareaContainer").hide();
			getChatOpsChannelOptions($("#includePrivateChannels").prop("checked"));
		}
	});

	$("#includePrivateChannels").click( function() {
		clearMessages();
		getChatOpsChannelOptions(this.checked);
	});

	$("#attachToExisting").click(function(){
		clearMessages();
		var selectedChannelId = $("#existingChannelSelector").val();
		if (selectedChannelId == null) {
			showErrorMessage(i18n.message("slack.manageChannels.errors.missing.channelId"));
			return;
		}
		var getUrl = contextPath + "/chatops/joinWorkItemToChatOpsChannel.spr"
				+ "?workItem_id=${workItem.id}"
				+ "&channel_id=" + selectedChannelId
				+ "&channel_name=" + encodeURI($("#existingChannelSelector option:selected").text())
				+ "&is_private=" + ($("#includePrivateChannels").prop("checked") == true)
				+ "&inviteUsers=" + $("input[name=inviteUsers][type=hidden]").val();
		var bs = ajaxBusyIndicator.showBusyPage();
		$.ajax({
			url: getUrl,
				type: 'get',
				dataType: 'json',
				success: function(result) {
					if (result) {
						if (result.success) {
							window.parent.location.href = result.attachedChannel.channelURL;
						}
						showErrorMessage(result.error, result.permissionAuthUrl);
					} else {
						showErrorMessage(i18n.message("slack.errorOccurred"));
					}
				},
				complete: function() {
					if (bs) {
						ajaxBusyIndicator.close(bs);
					}
				}
		});
	});

	$("#attachToNew").on('click', function(){
		var newChannelName = $("#newChannelNameInput").val();
		clearMessages();
		if (newChannelName == null || newChannelName == "") {
			showErrorMessage(i18n.message("slack.createchannel.missingChannelName"));
			return;
		}
		var getUrl = contextPath + "/chatops/createChatOpsChannelAndJoinhWorkItem.spr"
				+ "?workItem_id=${workItem.id}"
				+ "&channel_name=" + encodeURI(newChannelName)
				+ "&is_private=" + ($("#createPrivateChannel").prop('checked') == true)
				+ "&channel_purpose=" + encodeURI($("#channelPurposeInput").val())
				+ "&initial_message=" + encodeURI($("#channelInitialMessageInput").val())
				+ "&inviteUsers=" + $("input[name=inviteUsers][type=hidden]").val();
		var bs = ajaxBusyIndicator.showBusyPage();
		$.ajax({
			url: getUrl,
			type: 'get',
			dataType: 'json',
			success: function(result) {
				if (result) {
					if (result.success) {
						window.parent.location.href = result.attachedChannel.channelURL;
					}
					showErrorMessage(result.error, result.permissionAuthUrl);
				} else {
					showErrorMessage(i18n.message("slack.errorOccurred"));
				}
			},
			complete: function() {
				if (bs) {
					ajaxBusyIndicator.close(bs);
				}
			}
		});
	});

	clearMessages();
	$("#attachToExistingChannelOption").attr('checked', true).change();
	checkAttachedChannelExistence();
	updateRemoveButtonAction();

	var errorMessage = "${ui:escapeJavaScript(errorMessage)}";
	var permissionAuthUrl = "${permissionAuthUrl}";
	showErrorMessage(errorMessage, permissionAuthUrl);
	var warningMessage = "${ui:escapeJavaScript(warningMessage)}";
	if (warningMessage) {
		$(".warning").text(warningMessage).show();
	}
});
</script>

<style>
div.attacherInfo {
	display: inline-block;
}
table.formTableWithSpacing {
	width: 90%;
}
table.formTableWithSpacing td.memberSelector td {
	padding: 0px;
	margin: 0px;
}
textarea {
	width: 100%
}
table.formTableWithSpacing td.optional+td {
	width: 90%;
}
hr.divider {
	border: 1px solid #e2e2e2;
}
.middleAligned {
	vertical-align: middle;
}
</style>

<ui:actionMenuBar >
	<spring:message code="slack.manageChannels.menubarTitle" arguments="${workItem.name}"></spring:message>
</ui:actionMenuBar>

<span class="error"></span>
<span class="notification"></span>
<span class="warning"></span>

<c:if test="${not empty threadURL}">
	<div class="accordion">
		<h3 class="accordion-header">
			<spring:message code="slack.manageChannels.messageThreadId.title"></spring:message>
		</h3>
		<spring:message var="messageThreadLinkName" code="slack.manageChannels.messageThreadId.urlName"></spring:message>
		<div class="accordion-content">
			<a class="channelLink" href="${threadURL}" target="_blank">
				<c:out value="${messageThreadLinkName}"></c:out>
			</a>
		</div>
	</div>
</c:if>

<div class="accordion">
	<h3 class="accordion-header">
		<spring:message code="slack.manageChannels.attachedChannels.label"></spring:message>
	</h3>
	<spring:message var="detachChannelTitle" code="slack.manageChannels.detachChannelHint"></spring:message>
	<div class="accordion-content">
		<div id="noAttachedMessage">
			<spring:message code="slack.manageChannels.noAttachedChannels"></spring:message>
		</div>
		<ul id="attachedChannels">
			<c:forEach var="attachedChannel" items="${attachedChannels}">
				<c:set var="attacherUser" value="${attachedChannel.attacher}"></c:set>
				<li id="${attachedChannel.id}">
					<c:choose>
						<c:when test="${not accountNotConnected}">
							<span class="removeButton" title="${detachChannelTitle}"></span>
						</c:when>
					</c:choose>
					<label>
						<c:if test="${attachedChannel.isPrivate}">
							<spring:message code="slack.manageChannels.privateChannel.title" var="lockTitle"></spring:message>
							<img src="${pageContext.request.contextPath}/images/newskin/action/lock.png" title="${lockTitle}"></img>
						</c:if>
						<a class="channelLink" href="${attachedChannel.channelURL}" target="_blank">
							<c:out value="${attachedChannel.name}"></c:out>
						</a>
					</label>
					<div class="attacherInfo">
						<span>
							<spring:message code="slack.manageChannels.attachedChannels.attachedBy"></spring:message>:
						</span>
						<a href="${pageContext.request.contextPath}${attacherUser.getUrlLink()}" title="${attacherUser.getRealName()}">
							<c:out value="${attacherUser.name}"></c:out>
						</a>
						<span>
							<c:out value="${attachedChannel.lastModifiedAt}"></c:out>
						</span>
					</div>

				</li>
			</c:forEach>
		</ul>
	</div>
</div>

<c:choose>
	<c:when test="${not accountNotConnected}">
	<div class="accordion">
		<h3 class="accordion-header">
			<spring:message code="slack.manageChannels.title"></spring:message>
		</h3>
		<div class="accordion-content">
			<div style="display: inline-block;">
				<input type="radio" id="attachToExistingChannelOption" name="actionType" value="existing" class="middleAligned"></input>
				<label for="attachToExistingChannelOption" class="middleAligned">
					<spring:message code="slack.manageChannels.actionSelectionCheckbox.existing.label"></spring:message>
				</label>
			</div>
			<div style="display: inline-block;">
			<input type="radio" id="attachToNewChannelOption" name="actionType" value="new" class="middleAligned"></input>
				<label for="attachToNewChannelOption" class="middleAligned">
					<spring:message code="slack.manageChannels.actionSelectionCheckbox.new.label"></spring:message>
				</label>
			</div>

			<hr class="divider">
			<table class="formTableWithSpacing">
				<tbody class="attachToExistingChannelContainer">
					<tr>
						<td class="optional">
							<label for="existingChannelSelector">
								<spring:message code="slack.manageChannels.selectChannel"></spring:message>:
							</label>
						</td>
						<td>
							<spring:message var="publicChannelsLabel" code="slack.manageChannels.selectableChannels"></spring:message>
							<select id="existingChannelSelector" style="width: 100%;">
							</select>
						</td>
					</tr>
					<tr>
						<td class="optional">
						</td>
						<td>
							<label for="includePrivateChannels">
								<input id="includePrivateChannels" type="checkbox" style="vertical-align: middle;"></input>
								<spring:message code="slack.manageChannels.includePrivateChannels"></spring:message>
							</label>
						</td>
					</tr>
				</tbody>
				<tbody class="attachToNewChannelContainer">
					<tr>
						<td class="optional">
							<label for="newChannelNameInput">
								<spring:message code="slack.manageChannels.newChannelName.label"></spring:message>:
							</label>
						</td>
						<td>
							<input id="newChannelNameInput" type="text"/>
							<label for="createPrivateChannel">
								<input id="createPrivateChannel" type="checkbox" checked></input>
								<spring:message code="slack.manageChannels.createPrivateChannel"></spring:message>
							</label>
						</td>
					</tr>
				</tbody>
				<tbody>
					<tr>
						<td class="optional">
							<spring:message code="slack.manageChannels.inviteUsers"></spring:message>:
						</td>
						<td class="memberSelector">
							<bugs:userSelector htmlId="userSelector" singleSelect="false" allowRoleSelection="false"
											onlyCurrentProject="true" setToDefaultLabel="dummy.label"
											ids="${defaultInviteUsers}" fieldName="inviteUsers"
											searchOnAllUsers="false" showPopupButton="false"/>
						</td>
					</tr>
				</tbody>
				<tbody class="optionalTextareaContainer">
					<tr>
						<td class="optional">
							<spring:message code="slack.manageChannels.firstMessage.label"></spring:message>:
						</td>
						<td>
							<textarea id="channelInitialMessageInput" maxlength="250"></textarea>
						</td>
					</tr>
					<tr>
						<td class="optional">
							<spring:message code="slack.manageChannels.purpose.label"></spring:message>:
						</td>
						<td>
							<textarea id="channelPurposeInput" maxlength="250"></textarea>
						</td>
					</tr>
				</tbody>
				<tbody class="attachToExistingChannelContainer">
					<tr>
						<td class="optional"></td>
						<td>
							<button id="attachToExisting" class="button">
								<spring:message code="slack.manageChannels.attach.label"></spring:message>
							</button>
						</td>
					</tr>
				</tbody>
				<tbody class="attachToNewChannelContainer">
					<tr>
						<td class="optional"></td>
						<td>
							<button id="attachToNew" class="button">
								<spring:message code="slack.manageChannels.attachToNew.label"></spring:message>
							</button>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</c:when>
</c:choose>
