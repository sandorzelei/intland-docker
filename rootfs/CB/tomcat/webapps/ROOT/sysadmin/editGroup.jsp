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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag"%>

<meta name="decorator" content="main"/>
<meta name="module" content="sysadmin"/>
<meta name="moduleCSSClass" content="sysadminModule newskin"/>

<c:url var="historicPermissionsUrl" value="/sysadmin/groupPermissions.spr">
	<c:param name="groupId"  value="${group.id}"/>
	<c:param name="revision" value=""/>
</c:url>

<script language="JavaScript" type="text/javascript">
	function confirmDelete(form) {
		return confirm('<spring:message code="group.delete.item.confirm" />');
	}

	function showHistoricPermissions(selector) {
		var version = selector.value;
		if (version == null || version == "") {
			$('input[type="checkbox"][name="historicPermission"]').hide();
		} else {
			$.getJSON('${historicPermissionsUrl}' + version, function(data) {
				$.each(data, function(key, val) {
					$("#historicPermission_" + key).attr('checked', val);
				});
				$('input[type="checkbox"][name="historicPermission"]').show();
			});
		}
	}
</script>

<ui:actionMenuBar>
	<span class="titlenormal">
		<ui:pageTitle>
			<spring:message code="group.${actionType}.title" text="${actionType} ${roleType}"/>
		</ui:pageTitle>
	</span>
</ui:actionMenuBar>

<c:url var="actionUrl" value="/sysadmin/editGroup.spr"/>

<form action="${actionUrl}" method="post">
	<input type="hidden" name="groupId" value="${group.id}"/>

	<div class="actionBar">
		<c:if test="${editable}">
			<spring:message var="submitButton" code="button.save" text="Save"/>
			&nbsp;&nbsp;<input type="submit" class="button" value="${submitButton}" name="SUBMIT"/>
		</c:if>

		<c:if test="${group.id != null and editable}">
			<spring:message var="deleteButton" code="button.delete" text="Delete..."/>
			&nbsp;&nbsp;<input type="submit" class="button" value="${deleteButton}" name="DELETE" onclick="return confirmDelete(this);" />
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		&nbsp;&nbsp;<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" />
	</div>

	<ui:globalMessages/>

<div class="contentWithMargins">
	<table border="0" cellpadding="5" cellspacing="0">
		<c:choose>
			<c:when test="${editable}">
				<tr>
					<td class="mandatory"><spring:message code="group.name.label" text="Group"/>:</td>
					<td class="expandText" nowrap>
						<input id="groupName" type="text" name="name" value="<c:out value='${name}'/>" size="80" maxlength="80" />

						<c:if test="${!empty templates}">
							&nbsp;
							<spring:message code="role.template.label" text="Based on"/>
							<select name="templateId" onchange="document.location.href='${actionUrl}?templateId=' + this.value + '&amp;name=' + encodeURI($('#groupName').val()) + '&amp;description=' + encodeURI($('#groupDesc').val());">
								<option value="">--</option>
								<c:forEach items="${templates}" var="template">
									<spring:message var="templateTitle" code="group.${template.name}.tooltip" text="${template.shortDescription}" htmlEscape="true"/>
									<option value="${template.id}" title="${templateTitle}" <c:if test="${param.templateId eq template.id}">selected="selected"</c:if>>
										<spring:message code="group.${template.name}.label" text="${template.name}"/>
									</option>
								</c:forEach>
							</select>
						</c:if>
					</td>
					<c:if test="${group.id != null}">
						<td class="optional"><spring:message code="document.createdBy.label" text="Created by"/>:</td>
						<td nowrap>&nbsp;<c:out value="${group.owner.name}"/>, <tag:formatDate value="${group.createdAt}"/> &nbsp;</td>
					</c:if>
				</tr>
				<tr>
					<td class="optional"><spring:message code="group.details.label" text="Description"/>:</td>
					<td class="expandText" nowrap>
						<input id="groupDesc" type="text" name="description" value="<c:out value='${description}'/>" size="120" maxlength="255" cssClass="expandText" />
					</td>
					<c:if test="${group.id != null}">
						<td class="optional"><spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/>:</td>
						<td nowrap>&nbsp;<c:out value="${group.lastModifiedBy.name}"/>, <tag:formatDate value="${group.lastModifiedAt}"/>&nbsp;</td>
					</c:if>
				</tr>
				<tr>
					<td class="optional"><spring:message code="group.ldap.label" text="LDAP/Active directory group name"/>:</td>
					<td nowrap>
						<input id="ldapGroup" type="text" name="ldapGroup" value="<c:out value='${ldapGroup}'/>" size="80" maxlength="80" />
					</td>
				</tr>
			</c:when>

			<c:otherwise>
				<tr>
					<td class="optional"><spring:message code="group.name.label" text="Group"/>:</td>
					<td class="tableItem">&nbsp;<c:out value="${name}" />&nbsp;</td>
					<td class="optional"><spring:message code="document.createdBy.label" text="Created by"/>:</td>
					<td nowrap>&nbsp;<c:out value="${group.owner.name}"/>, <tag:formatDate value="${group.createdAt}"/> &nbsp;</td>
				</tr>
				<tr>
					<td class="optional"><spring:message code="group.details.label" text="Description"/>:</td>
					<td class="tableItem">&nbsp;<c:out value="${description}" />&nbsp;</td>
					<td class="optional"><spring:message code="document.lastModifiedBy.tooltip" text="Last modified by"/>:</td>
					<td nowrap>&nbsp;<c:out value="${group.lastModifiedBy.name}"/>, <tag:formatDate value="${group.lastModifiedAt}"/>&nbsp;</td>
				</tr>
			</c:otherwise>
		</c:choose>

	</table>

				<spring:message var="toggleButton" code="search.what.toggle" text="Select/Clear All"/>
				<c:set var="checkAll">
					<input type="checkbox" title="${toggleButton}" name="select_all" value="on" onclick="setAllStatesFrom(this, 'permission')" <c:if test="${!editable}">disabled="disabled"</c:if>>
				</c:set>

				<display:table name="${permissions}" id="permission" cellpadding="0" export="false" sort="external">
					<display:column title="${checkAll}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" class="checkbox-column-minwidth" style="text-align: center;">
						<input id="permission_${permission.key.id}" type="checkbox" name="permission" value="${permission.key.id}" <c:if test="${permission.value}">checked="checked"</c:if><c:if test="${!editable}">disabled="disabled"</c:if> />
					</display:column>

					<spring:message var="permissionLabel" code="permission.label" text="Permission"/>
					<display:column title="${permissionLabel}" headerClass="textData" class="textDataWrap columnSeparator" >
						<label for="permission_${permission.key.id}"><spring:message code="permission.${permission.key.name}.label"/></label>
					</display:column>

					<spring:message var="permissionDesc" code="permission.description.label" text="Description"/>
					<display:column title="${permissionDesc}" headerClass="textData" class="textDataWrap columnSeparator">
						<spring:message code="permission.${permission.key.name}.tooltip"/>
					</display:column>

					<c:if test="${group.id != null and !empty history}">
						<c:set var="historicPermissionLabel">
							<spring:message code="document.history.title" text="History"/>:
							<select onchange="showHistoricPermissions(this);">
								<option value=""><spring:message code="document.baselines.head.label" text="Head revision"/></option>
								<c:forEach items="${history}" var="revision">
									<option value="${revision.version}">
										<c:out value="${revision.lastModifiedBy.name}"/>, <tag:formatDate value="${revision.lastModifiedAt}"/>
									</option>
								</c:forEach>
							</select>
						</c:set>

						<display:column title="${historicPermissionLabel}" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" class="checkbox-column-minwidth" style="text-align: center;">
							<input id="historicPermission_${permission.key.id}" type="checkbox" name="historicPermission" value="${permission.key.id}" disabled="disabled" style="display:none;" />
						</display:column>
					</c:if>
				</display:table>
</div>
</form>
