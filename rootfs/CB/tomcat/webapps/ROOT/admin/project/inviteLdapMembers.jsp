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
<meta name="decorator" content="popup" />
<meta name="module" content="members" />
<meta name="moduleCSSClass" content="newskin membersModule" />

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<c:set var="commentEditorBlock">

</c:set>

<c:if test="${!ldapEnabled}">

	<style type="text/css">

		.ldapDisabled {
			margin-top: 10px !important;
			margin-bottom: 450px !important;
		}

	</style>

	<ui:actionBar/>
	<c:url var="systemSettingsUrl" value="/sysadmin/configLDAP.spr"/>
	<div class="warning ldapDisabled"><spring:message code="project.newMember.invite.ldap.disabled" arguments="${systemSettingsUrl}"/></div>
</c:if>

<c:if test="${ldapEnabled}">

	<style type="text/css">

		.ldapMemberSelector {
			float: left;
		    height: 235px;
		    padding: 10px;
		    border: 1px solid #d1d1d1;
		    margin-bottom: 10px;
		    overflow-y: auto;
		    width: 100%;
		}

		.ldapSelectionTable{
			width: 100%;
		}

		.ldapSelectionTable .step1{
			width: 70%;
		}

		.ldapSelectionTable .step2{
			width: 30%;
			padding-left: 25px;
			padding-top: 0px;
			vertical-align: baseline;
		}

		.ldapSelectionTable .roles{
		    float: left;
		    position: relative;
		    font-size: 12px;
		    top: 0px !important;
		}

		.ldapSelectionTable .email{
			width: 50%;
		}

		.ldapSearchDiv {
		    margin-bottom: 15px;
		}

		.textSizeWarn  {
			background-color: #fff7eb;
		}

		.addLdapMember  {
			height: 100%;
		}

		.named-user-warn  {
			display: inline-block;
			margin-left: 25px;
		}

		.sendNotification {
			margin-top: 15px !important;
		}

	</style>

	<script type="text/javascript">

		var showAjaxLoader = function() {
			var centerPaneOverflow = $("#ldapUsersContainer").find(".center-pane");
			centerPaneOverflow.text("");
			var p = centerPaneOverflow.get(0);
			return ajaxBusyIndicator.showBusysign(p, i18n.message("ajax.loading"), false, {
				width: "12em",
			});
		};

		function searchForLDAPUser(){
			var filterValue = $("#ldapNameFilter").val();
			// TODO validations

			if (filterValue.length < 3){
				$(".textSizeWarn").show();
				return;
			}

			var busySign = showAjaxLoader();

			$.post(contextPath + "/ajax/proj/ldapMembers.spr?filterParam=" + filterValue, function(data) {
				$("#ldapUsersContainer").find(".center-pane").html(data);
				ajaxBusyIndicator.close(busySign);
			});
		}

		$(function () {

			var commentWatermark = i18n.message("project.newMember.comment.tooltip");
			applyHintInputBox("#notificationComment", commentWatermark);

			$('input[name="ADDLDAP"]').click(function() {

				// member input validation
				var hasSelectedRole = false;
				$('.ldapUsers input').each(function() {
					if ($(this).is(':checked')) {
						hasSelectedRole = true;
					}
				});

				if (!hasSelectedRole) {
					alert(i18n.message("project.members.required"));
					return;
				}

				// role input validation
				var hasSelectedMember = false;
				$('#addLdapUsersForm .roles input').each(function() {
					if ($(this).is(':checked')) {
						hasSelectedMember = true;
					}
				});

				if (!hasSelectedMember) {
					alert(i18n.message("proj.member.roles.required"));
					return;
				}

				$("#addLdapUsersForm").submit();
			});

			$("#ldapNameFilter").on("keypress", function (e) {
			    var code = e.keyCode || e.which;
			    if (code == 13) {
			    	searchForLDAPUser();
			        e.preventDefault();
			        return false;
			    }
			    $(".textSizeWarn").hide();
			});

			$( "#ldapNameFilter" ).change(function() {
				$(".textSizeWarn").hide();
			});

			$(".textSizeWarn").hide();
		});

	</script>

	<c:url var="actionUrl" value="/proj/addLdapMembers.spr"/>

	<ui:actionBar cssStyle="padding-left: 10px;">
		<div class="okcancel" style="margin-top: 0px;">
			<spring:message var="addButton" code="button.add" text="Add" />
			<spring:message var="addTitle" code="project.newMember.add.tooltip" text="Add Selected Accounts as Project Members" />
			<input type="button" class="button" name="ADDLDAP" value="${addButton}" title="${addTitle}"  />

			<spring:message var="cancelButton" code="button.cancel" />
			<a onclick="closePopupInline(); return false;">${cancelButton}</a>
			<c:if test="${availableLicense > 0}">
				<div class="textHint named-user-warn"><spring:message code="project.newMember.invite.licaense.warning" arguments="${availableLicense}"/></div>
			</c:if>
		</div>
	</ui:actionBar>

	<c:if test="${not empty ldapErrorMessage}">
		<div class="error onlyOneMessage">${ldapErrorMessage}</div>
	</c:if>

	<div class="addMember addLdapMember">

		<table class="ldapSelectionTable">
			<tr>
				<td class="step1">
					<h3>
						<spring:message code="project.newMember.info.step1.title" text="Step 1" />
					</h3>
					<spring:message	code="project.newMember.invite.ldap.step1" arguments="${ldapServerUrl},${ldapUserBase}"/>
				</td>
				<td class="step2">
					<h3>
						<spring:message code="project.newMember.info.step2.title" text="Step 2" />
					</h3>
					<spring:message code="project.newMember.invite.ldap.step2" />
				</td>
			</tr>
		</table>

		<form:form action="${actionUrl}" method="post" id="addLdapUsersForm" modelAttribute="selectedLdapUsers">

			<input type="hidden" name="projectId"  value="<c:out value='${project.id}'/>" />
			<input type="hidden" name="referrer" value="<c:out value='${referrer}'/>" />

			<table class="ldapSelectionTable">
				<tr>
					<td class="step1">
						<%-- member selection part --%>
						<spring:message code="button.search" var="searchLabel" />
						<div class="ldapSearchDiv">
							<input type="text" class="email" id="ldapNameFilter" title=""/>
							<input type="button" class="button" value="${searchLabel}" onclick="searchForLDAPUser();" style="margin-left: 10px;">
							<span class="textSizeWarn"><br/><spring:message code="project.newMember.invite.ldap.text.short"/></span>
						</div>
						<div class="ldapMemberSelector">
							<div class="inviteLDAP">
								<div id="ldapUsersContainer">
									<div class="center-pane">
										<jsp:include page="ldapMembers.jsp"/>
									</div>
								</div>
							</div>
						</div>

					</td>
					<td class="step2">
						<%-- role selection part --%>
						<div class="roles">
							<div style="height: 305px; overflow-y: auto;">
								<c:forEach items="${roles}" var="role" varStatus="iterationStatus">
									<div style="padding-bottom: 10px; ${iterationStatus.first ? (empty showParam ? 'padding-top: 20px;' : 'padding-top: 10px;') : ''}">
										<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true" />
										<input id="role_${role.id}" type="checkbox" title="${roleTitle}" <c:if test="${selectedRoles[role.id]}">checked="checked"</c:if>
											value="${role.id}" name="roleId" /> <label for="role_${role.id}"><spring:message code="role.${role.name}.label" text="${role.name}"
												htmlEscape="true" /></label>
									</div>
								</c:forEach>
							</div>
						</div>
					</td>
				</tr>
			</table>

			<div class="sendEmailNotification">
				<spring:message var="sendNotificationTitle" code="project.newMember.invite.ldap.notify.send" />
				<input id="notificationEnabled" name="notificationEnabled" class="notificationEnabled" type="checkbox" title="${sendNotificationTitle}"	<c:if test="${notificationEnabled}">checked="checked"</c:if> />
				<label for="sendNotification">${sendNotificationTitle}</label>

				<textarea class="expandTextArea notificationComment" id="notificationComment" name="notificationComment" cols="80" maxlength="255"><c:out value="${notificationComment}"/></textarea>
			</div>
		</form:form>
	</div>
</c:if>

