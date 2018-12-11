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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<c:choose>
	<c:when test="${licenseDisabled}">
		<div class="warning">
			<spring:message code="sysadmin.serviceDesk.no.license.warning" text="You cannot use this feature because you don't have the necessary license. To read more about this feature visit our <a href='https://codebeamer.com/cb/wiki/635003'>Knowledge base</a>."></spring:message>
		</div>
	</c:when>
	<c:otherwise>
		<c:url value="/proj/tracker/trackerServiceDeskConfig.spr" var="submitUrl">
			<c:param name="tracker_id" value="${tracker.id}"></c:param>
		</c:url>
		<form action="${submitUrl}" method="post">
			<ui:actionBar>
				<c:if test="${canAdminTracker}">
					<spring:message var="saveButton" code="button.save" text="Save"/>
					<input type="submit" class="button" name="SAVE" value="${saveButton}" />
				</c:if>

				<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
				<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}" onclick="return cancelServiceDeskForm(this);"/>

				<c:url value="/servicedesk/serviceDesk.spr" var="serviceDeskUrl"/>
				<spring:message code="tracker.serviceDesk.open.label" var="openLabel" text="Open Service Desk"/>
				<div class="rightAlignedDescription" style="padding-left: 15px;">
					<a href="${serviceDeskUrl}" title="${openLabel}" target="_blank">${openLabel }</a>
				</div>

				<div class="rightAlignedDescription">
					<spring:message code="tracker.serviceDesk.tooltip" text="You can add this tracker to service desk" />
				</div>
			</ui:actionBar>

			<c:set var="controlDisabled" value=""/>
			<c:if test="${!canAdminTracker}">
				<c:set var="controlDisabled" value="disabled='disabled'"/>
			</c:if>

			<table class="formTableWithSpacing" border="0" cellpadding="0" s>
				<tr>
					<td class="optional labelcell"><spring:message text="Show on Service Desk" code="tracker.serviceDesk.field.enabled.label"/>:</td>
					<td>
						<input type="checkbox" id="enabled" name="enabled" value="true" <c:if test="${showOnServiceDesk}">checked="checked"</c:if> ${controlDisabled}/>
					</td>
				</tr>
				<tr>
					<spring:message code="tracker.serviceDesk.field.title.tooltip" var="titleTooltip" text="The title that will be shown on service desk"/>
					<td class="optional labelcell"><spring:message code="tracker.serviceDesk.field.title.label" text="Title"/>:</td>
					<c:set var="titleEscaped"><c:out value="${titleOnServiceDesk }" escapeXml="true" ></c:out></c:set>
					<td><input type="text" width="80%" value="${titleEscaped }" name="title" title="${titleTooltip }" ${controlDisabled}/></td>
				</tr>
				<tr>
					<td class="optional labelcell"><spring:message code="tracker.serviceDesk.field.description.label" text="Description"/>:</td>
					<td class="expandTextArea">
						<spring:message code="tracker.serviceDesk.field.description.tooltip" var="descriptionTooltip" text="A short description of the tracker that will be shown on service desk"/>
						<wysiwyg:editor editorId="serviceDeskDescriptionArea" useAutoResize="false" height="250" uploadConversationId="" overlayHeaderKey="wysiwyg.tracker.description.editor.overlay.header">
							<textarea name="description" id="serviceDeskDescriptionArea" rows="15" cols="80" title="${descriptionTooltip}" ${controlDisabled}>${descriptionOnServiceDesk}</textarea>
						</wysiwyg:editor>
					</td>
				</tr>
				<tr>
					<td class="optional labelcell"><spring:message code="tracker.serviceDesk.field.image.label" text="Image"/>:</td>
					<td>
						<input type="hidden" name="removeImage" value="false"/>
						<c:if test="${serviceDeskIconId != null }">
							<c:url var="iconUrl" value="/displayDocument?doc_id=${serviceDeskIconId}"/>
							<img src="${iconUrl}" width="64" height="64" class="service-desk-icon"/>
							<c:if test="${canAdminTracker}">
								<spring:message code="tracker.serviceDesk.delete.image.label" text="Delete image" var="removeImageLabel"/>
								<input type="button" class="button linkButton remove-file" value="${removeImageLabel}"/>
							</c:if>
						</c:if>
						<c:if test="${canAdminTracker}">
							<ui:fileUpload uploadConversationId="${uploadConversationId}" conversationFieldName="uploadConversationId" single="true"
										   cssClass="inlineFileUpload" onCompleteCallback="clearPreviousError"/>
						</c:if>
					</td>
				</tr>
				<tr>
					<td class="optional labelcell"><spring:message text="Letter icon background color" code="tracker.serviceDesk.field.letter.color"/>:</td>
					<td>
						<input name="colorCode" id="letterIconColor" value="${colorCode}" ${controlDisabled}/>
						<c:if test="${canAdminTracker}">
							<ui:colorPicker fieldId="letterIconColor" />
						</c:if>
					</td>
				</tr>
			</table>
		</form>

		<script type="text/javascript">
			$(document).ready(function () {
				$(".remove-file").click(function () {
					var $button = $(this);
					$("[name=removeImage]").val(true);
					$button.remove();
					$(".service-desk-icon").remove();
				});
			});

			function cancelServiceDeskForm(button) {
				if (${!canAdminTracker}) {
					$(button).closest("form").find('input[name="title"], input[name="colorCode"], textarea').prop("disabled", false);
				}
				return true;
			}

		</script>
	</c:otherwise>
</c:choose>


