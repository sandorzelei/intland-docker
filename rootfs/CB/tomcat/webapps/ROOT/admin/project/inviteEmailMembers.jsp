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

<style type="text/css">

	.emailSelectionTable{
		width: 100%;
	    margin-bottom: 1em;
	}

	.emailSelectionTable .step1{
		width: 60%;
	}

	.emailSelectionTable .step2{
		width: 40%;
		padding-left: 25px;
		padding-top: 0px;
		vertical-align: baseline;
	}

	.emailSelectionTable .roles{
	    float: left;
	    position: relative;
	    font-size: 12px;
	    top: 0px !important;
	    width: 94%;
	}

	.emailSelectionTable .email{
		width: 50%;
	}

	.ldapSearchDiv {
	    margin-bottom: 15px;
	}

	.emailSelectionTable li.token-input-token-facebook {
    	font-size: 14px;
    }

	.addedEmail {
		display: block;
    	width: 60%;
    	margin-bottom: 5px;
    	margin-top: 0px;
	}

	.named-user-warn {
		display: inline-block;
		margin-left: 25px;
	}

	.emailComment {
		margin-bottom: 10px;
	}

	.emailAddresses {
	    vertical-align: top;
	}

	.invalidfield {
		display: inline-block;
		margin-bottom: 5px;
	}
</style>

<script type="text/javascript">

		function addMore(){
			for (i = 0; i < 3; i++) {
				 $("<input type=\"text\" name=\"addedEmails\" class=\"addedEmail\"/>").insertBefore(".addMoreButton");
			}
		}

		$(function () {

			var commentWatermark = i18n.message('project.newMember.invite.comment.tooltip');
			applyHintInputBox("#emailComment", commentWatermark);

			$('input[name="ADDEMAIL"]').click(function() {

				var hasEmail = false;
				$('.addedEmail').each(function() {
					if ($(this).val().trim() != "") {
						hasEmail = true;
					}
				});

				if (!hasEmail) {
					alert(i18n.message("project.newMember.invite.email.empty"));
					return;
				}

				// roles validation
				var hasSelectedRole = false;
				$('#addEmailUsersForm .roles input').each(function() {
					if ($(this).is(':checked')) {
						hasSelectedRole = true;
					}
				});

				if (!hasSelectedRole) {
					alert(i18n.message("proj.member.roles.required"));
					return;
				}

				$("#addEmailUsersForm").submit();
			});



		});

	</script>

<c:url var="actionUrl" value="/proj/inviteViaEmail.spr"/>

<ui:actionBar cssStyle="padding-left: 10px;">
	<div class="okcancel" style="margin-top: 0px;">
		<spring:message var="addButton" code="project.newMember.invite.button.label" text="Send Invitation" />
		<spring:message var="addTitle" code="project.newMember.add.tooltip" text="Add Selected Accounts as Project Members" />
		<input type="button" class="button" name="ADDEMAIL" value="${addButton}" title="${addTitle}"  />

		<spring:message var="cancelButton" code="button.cancel" />
		<a onclick="closePopupInline(); return false;">${cancelButton}</a>
		<c:if test="${availableLicense > 0}">
			<div class="textHint named-user-warn "><spring:message code="project.newMember.invite.licaense.warning" arguments="${availableLicense}"/></div>
		</c:if>
	</div>
</ui:actionBar>

<c:if test="${not empty emailErrorMessage}">
	<div class="error onlyOneMessage">${emailErrorMessage}</div>
</c:if>

<div class="contentWithMargins addMember">

	<table class="emailSelectionTable">
		<tr>
			<td class="step1">
				<h3>
					<spring:message code="project.newMember.info.step1.title" text="Step 1" />
				</h3>
				<spring:message	code="project.newMember.invite.title.hint"/>
			</td>

			<td class="step2">
				<h3>
					<spring:message code="project.newMember.info.step2.title" text="Step 2" />
				</h3>
				<spring:message	code="project.newMember.invite.members.step2"/>
			</td>
		</tr>
	</table>

	<form:form action="${actionUrl}" method="post" id="addEmailUsersForm" modelAttribute="selectedEmailUsers">

		<input type="hidden" name="projectId"  value="<c:out value='${project.id}'/>" />
		<input type="hidden" name="referer" value="<c:out value='${referrer}'/>" />

		<table class="emailSelectionTable">
			<tr>
				<td class="step1 emailAddresses">
					<c:set var="textboxNumber" value="7"/>
					<c:if test="${not empty userEmails}">
						<c:forEach items="${userEmails}" var="userEmail" varStatus="iterationStatus">
							<input type="text" name="addedEmails" class="addedEmail" value="<c:out value='${userEmail}'/>"/>
							<c:set var="emailError" value="${emailErrors[userEmail]}"/>
							<c:if test="${not empty emailError}">
								<div>
									<span class="invalidfield"><c:out value="${emailError}"/></span>
								</div>
							</c:if>
						</c:forEach>
						<c:set var="textboxNumber" value="${7 - fn:length(userEmails)}"/>
					</c:if>

					<c:forEach var="i" begin="1" end="${textboxNumber < 0 ? 0 : textboxNumber}">
						<input type="text" name="addedEmails" class="addedEmail"/>
					</c:forEach>

					<spring:message code="button.add.more" var="addLabel" />
					<input type="button" class="button addMoreButton" value="${addLabel}" onclick="addMore();">

				</td>
				<td class="step2">
					<%-- role selection part --%>
					<div class="roles">
						<div style="height: 305px; overflow-y: auto;">
							<c:forEach items="${roles}" var="role" varStatus="iterationStatus">
								<div style="padding-bottom: 10px; ${iterationStatus.first ? (empty showParam ? 'padding-top: 20px;' : 'padding-top: 10px;') : ''}">
									<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true" />
									<input id="role_${role.id}_email" type="checkbox" title="${roleTitle}" <c:if test="${selectedRoles[role.id]}">checked="checked"</c:if>
										value="${role.id}" name="roleId" /> <label for="role_${role.id}_email"><spring:message code="role.${role.name}.label" text="${role.name}"
											htmlEscape="true" /></label>
								</div>
							</c:forEach>
						</div>
					</div>
				</td>
			</tr>
		</table>
		<textarea class="expandTextArea emailComment" id="emailComment" name="emailComment" cols="80" maxlength="255"><c:out value="${emailComment}"/></textarea>
	</form:form>
</div>