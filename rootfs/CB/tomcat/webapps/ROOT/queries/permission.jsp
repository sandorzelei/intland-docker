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
<meta name="decorator" content="popup"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<%@page import="java.util.Map"%>
<%@page import="org.apache.commons.lang.StringUtils"%>

<link rel="stylesheet" type="text/css" href="<ui:urlversioned value='/bugs/tracker/includes/viewConfiguration.css'/>" />
<style>

	.permissionRow {
		margin-bottom: 5px;
	}

	.queryPermissionTable {
		width: 100%;
	}
	.queryPermissionTable th {
		padding: 5px;
		background-color: white;
		border-bottom: 1px solid #D1D1D1;
		font-weight: bold;
		text-align: left;
		color: black;
	}
	.queryPermissionTable.withoutBorder th {
		border-bottom: none;
	}
	.queryPermissionTable th.project,
	.queryPermissionTable th.role  {
		width: 42%;
	}
	.queryPermissionTable th.project button,
	.queryPermissionTable th.role button  {
		width: 100%;
	}
	.queryPermissionTable th.access {
		width: 10%;
	}
	.queryPermissionTable th.remove  {
		width: 6%;
	}
</style>


<form:form commandName="query" action="${pageContext.request.contextPath}/proj/query/permission.spr" method="POST">
	<c:if test="${!reportSelector}">
		<input type="hidden" name="advanced" value="<c:out value="${advanced}"/>" />
		<input type="hidden" id="duplicate" name="duplicate" value="<c:out value="${duplicate}"/>" />
		<input type="hidden" name="fields" value="<c:out value="${fields}"/>" />
		<input type="hidden" id="addedPermissions" name="addedPermissions" value="[]">
		<input type="hidden" id="overwriteQueryId" name="overwriteQueryId" value="" />
		<c:if test="${not empty columnWidths}">
			<input type="hidden" name="columnWidths" value="<c:out value="${columnWidths}"/>">
		</c:if>
	</c:if>
	<input type="hidden" id="cbQl" name="cbQl" value="${trackerQuery ? query.getQuery() : ''}" />
	<input type="hidden" id="queryId" name="queryId" value="<c:out value="${queryId}"/>" />
	<input type="hidden" id="reportSelectorContainerId" name="reportSelectorContainerId" value="${ui:removeXSSCodeAndHtmlEncode(reportSelectorContainerId)}" />
	<input type="hidden" id="logicString" name="logicString" value="">
	<input type="hidden" id="logicSlicesString" name="logicSlicesString" value="">
	<input type="hidden" id="extraInfoString" name="extraInfoString" value="">

	<ui:actionMenuBar>
		<c:choose>
			<c:when test="${reportSelector}">
				<spring:message code="report.selector.view.properties.label" text="View Properties"/>
			</c:when>
			<c:otherwise>
				<spring:message code="queries.permission.title.label" text="Report Properties"/>
			</c:otherwise>
		</c:choose>
		<br/>
	</ui:actionMenuBar>

	<div class="actionBar">
		<spring:message var="saveButton" code="button.save"/>
		<input type="submit" class="button" name="SAVE" id="saveButton" value="${saveButton}"/>

		<spring:message var="cancelButton" code="button.cancel"/>
		<input type="submit" class="button cancelButton" name="_cancel" value="${cancelButton}" onclick="inlinePopup.close(); return false;"/>
	</div>

	<div class="contentWithMargins" >
		<ui:message type="error" isSingleMessage="true" containerId="queryGlobalMessages" style="${empty errorMessage ? 'display:none' : ''}">
			<ul><li><c:out value="${errorMessage}" /></li></ul>
		</ui:message>

		<table border="0" class="formTableWithSpacing" cellpadding="1">
			<tr valign="top">
				<td nowrap width="10%" class="labelCell mandatory">
					<spring:message code="queries.permission.name.label" text="Name"/>
				</td>
				<td nowrap width="80%">
					<%--set focus to end on input box, http://stackoverflow.com/questions/511088/use-javascript-to-place-cursor-at-end-of-text-in-text-input-element --%>
					<form:input path="name" style="width: 90%" onfocus="this.value = this.value;" ></form:input>
				</td>
			</tr>

			<c:if test="${reportSelector && not empty reportSelectorTrackerId && canUserAdminPublicReport}">
				<tr valign="top">
					<td></td>
					<td>
						<input type="checkbox" name="isPublic" id="isPublic"<c:if test="${isPublic}"> checked="checked"</c:if>>
						<label for="isPublic"><spring:message code="report.selector.public.report.label" text="Public View"/></label>
					</td>
				</tr>
			</c:if>

			<tr valign="top">
				<td nowrap width="10%" class="labelCell optional">
					<spring:message code="queries.permission.description.label" text="Description"/>
				</td>
				<td nowrap width="80%">
					<form:textarea path="description" style="width: 90%" rows="3"></form:textarea>
				</td>
			</tr>

			<c:if test="${!reportSelector}">
				<tr valign="top">
					<td nowrap width="10%" style="vertical-align: top;" class="labelCell optional">
						<spring:message code="queries.permission.permissions.label" text="Permissions"/>
					</td>
					<td nowrap width="80%">
						<spring:message code="queries.permission.share.label" text="Select a project and a role you want to share this Query with"/>
						<br> <br>
						<div class="warning noRoleWarningContainer">
							<spring:message code="queries.permission.no.role"/>
						</div>
						<table class="queryPermissionTable withoutBorder">
							<tr>
								<th class="project">
									<select id="projectSelector" name="project" multiple="multiple">
										<optgroup label="<spring:message code="widget.editor.project.recent"/>">
											<c:forEach items="${projects.get('recent')}" var="project">
												<option value="${project.id}">
													<c:out value="${project.name}"/>
												</option>
											</c:forEach>
										</optgroup>
										<optgroup label="<spring:message code="widget.editor.project.all"/>">
											<c:forEach items="${projects.get('all')}" var="project">
												<option value="${project.id}">
													<c:out value="${project.name}"/>
												</option>
											</c:forEach>
										</optgroup>
									</select>
								</th>
								<th class="role">
									<select id="roleSelector" name="role" multiple="multiple"></select>
								</th>
								<th class="access"></th>
								<th class="remove"></th>
							</tr>
						</table>

					</td>
				</tr>

				<tr valign="top">
					<td nowrap width="10%" class="labelCell optional">
					</td>
					<td nowrap width="80%" id="permissionsCell">
						<strong id="notSharedMsg" style="${fn:length(permissions) ne 0 ? 'display:none;' : ''}"><spring:message code="queries.permission.notshared.label" text="This Query is not shared with anybody yet"/></strong>
						<table id="queryPermissionTable" class="queryPermissionTable" style="${fn:length(permissions) eq 0 ? 'display:none;' : ''}">
							<tr>
								<th class="project"><spring:message code="queries.permission.project.label"/></th>
								<th class="role"><spring:message code="queries.permission.role.label"/></th>
								<th class="access"><spring:message code="queries.permission.access.label"/></th>
								<th class="remove"></th>
							</tr>
							<c:forEach items="${permissions}" var="permission">
								<% Map<String, String> permission = (Map) pageContext.getAttribute("permission");%>
								<tr class="permissionRow" data-new="false" data-projectId="${permission.projectId}" data-roleId="${permission.roleId}" data-access="${permission.access}">
									<td><c:out value="<%= StringUtils.abbreviate(permission.get(\"projectName\"), 45) %>" /></td>
									<td><c:out value="<%= StringUtils.abbreviate(permission.get(\"roleName\"), 45) %>" /></td>
									<td>
										<select class="permissionSelector">
											<option value="1"<c:if test="${permission.access eq 1}"> selected="selected"</c:if>><spring:message code="queries.permission.read.label" text="READ"/></option>
											<option value="2"<c:if test="${permission.access eq 2}"> selected="selected"</c:if>><spring:message code="queries.permission.write.label" text="WRITE"/></option>
										</select>
									</td>
									<td><span class="removeButton">&nbsp;</span></td>
								</tr>
							</c:forEach>
						</table>
					</td>
				</tr>
			</c:if>

		</table>
	</div>
</form:form>

<script type="text/javascript">
	$(document).ready(function() {
		var widgetContainerId = "${not empty reportSelectorContainerId ? reportSelectorContainerId : 'reportPageWidget'}";
		if (parent.codebeamer.ReportSupport.logicEnabled(widgetContainerId)) {
			var logicString = parent.codebeamer.ReportSupport.getLogicString(widgetContainerId);
			if (logicString.length > 0) {
				$("#logicString").val(logicString);
				var result = parent.codebeamer.ReportSupport.buildQueryStructure(widgetContainerId, false, true);
				var logicSlices = result.where;
				delete result.where;
				var extraInfo = result;
				$("#logicSlicesString").val(JSON.stringify(logicSlices));
				$("#extraInfoString").val(JSON.stringify(extraInfo));
			}
		}
	});
</script>

<c:if test="${reportSelectorSaveMode}">
	<script type="text/javascript">
		$(document).ready(function() {
			var $form = $("#query");
			$form.submit(function() {
				var name = $form.find('input[name="name"]').val();
				if (name.length > 0) {
					var description = $form.find('textarea[name="description"]').val();
					var isPublic = $("#isPublic").length > 0 ? $("#isPublic").is(":checked") : false;

					var save = function() {
						parent.codebeamer.ReportSupport.saveReport("${reportSelectorContainerId}", name, description, isPublic,
							$("#logicString").val(), $("#logicSlicesString").val(), $("#extraInfoString").val());
						inlinePopup.close();
					};

					<c:choose>
						<c:when test="${not empty reportSelectorTrackerId}">
							$.get(contextPath + "/proj/queries/findQueryByName.spr", {"name" : name, "trackerId" : ${reportSelectorTrackerId}} ).done(function(data) {
								var id = JSON.parse(data)['id'];
								if (id) {
									showFancyConfirmDialogWithCallbacks(i18n.message("report.selector.overwrite.confirm"), function() {
										save();
									});
								} else {
									save();
								}
							});
						</c:when>
						<c:otherwise>
							save();
						</c:otherwise>
					</c:choose>

				} else {
					showFancyAlertDialog(i18n.message("queries.save.noname.error"));
				}
				return false;
			});
		});
	</script>
</c:if>

<c:if test="${!reportSelector}">
	<script type="text/javascript">
		$(document).ready(function() {

			var widgetContainerId = "reportPageWidget";

			var cbQl = parent.codebeamer.ReportSupport.getCbQl(widgetContainerId);
			parent.codebeamer.ReportSupport.initAdvancedEditorWithQueryString(widgetContainerId, parent.codebeamer.ReportSupport.getAdvancedQueryString(widgetContainerId, false));
			$("#cbQl").val(cbQl);

			function truncate(str, length){
				return (str.length > length) ? str.substr(0, length-3) + '...' : str;
			}

			function selectInMultiselect(selector, id) {
				var $input = $(selector).multiselect("widget").find("input[value=" + id + "]").first();
				$input.click();
				$input.prop("checked", true);
				$(selector).val(id);
				$(selector).change();
			}

			function fillPermissionInput() {
				var json = [];
				$("#queryPermissionTable").find(".permissionRow").each(function() {
					json.push({ projectId: $(this).attr("data-projectId"), roleId: $(this).attr("data-roleId"), access: $(this).attr("data-access")});
				});
				$("#addedPermissions").val(JSON.stringify(json));
			}

			function initRoleSelector() {
				var multiselect = $("#roleSelector").multiselect({
					classes: 'ui-multiselect-menu-newskin',
					noneSelectedText: i18n.message("queries.permission.role.selector.empty"),
					selectedText: function(selNum, allNum, items) {
						var result = [];
						for(var i = 0; i < items.length; i++) {
							result.push($(items[i]).next().text());
						}
						return truncate(result.join(", "), 45);
					},
					multiple: true,
					minWidth: 300,
					// open above the select list
					position: {
						my: 'left bottom',
						at: 'left top'
					},
					click: function(event, ui) {
						var roleId = parseInt(ui.value, 10);
						var roleName = $('#roleSelector option[value="'+ roleId +'"]').text().trim();
						if (ui.checked) {
							addPermission(roleId, roleName);
						} else {
							removePermission(roleId)
						}
					},
					checkAll: function() {
						$("#roleSelector option").each(function() {
							addPermission($(this).val(), $(this).html());
						});
					},
					uncheckAll: function() {
						$("#roleSelector option").each(function() {
							removePermission($(this).val());
						});
					}
				});
			}

			function initProjectSelector() {
				var multiselect = $("#projectSelector").multiselect({
					classes: 'ui-multiselect-menu-newskin',
					noneSelectedText: i18n.message("queries.permission.project.selector.empty"),
					selectedText: function(selNum, allNum, items) {
						var result = [];
						for(var i = 0; i < items.length; i++) {
							result.push($(items[i]).next().text());
						}
						return truncate(result.join(", "), 45);
					},
					multiple: false,
					minWidth: 300,
					// open above the select list
					position: {
						my: 'left bottom',
						at: 'left top'
					},
					open: function(event, ui) {
						$(".ui-multiselect-filter input").first().focus();
					}
				});

				multiselect.multiselectfilter({
					placeholder: "<spring:message code='multiselectfilter.text'/>"
				});

				var $noRoleWarning = $(".noRoleWarningContainer");
				$noRoleWarning.hide();

				$('#projectSelector').change(function(e) {
					var projectId = $(e.target).val();
					if (projectId) {
						var select = $('#roleSelector');
						$.get(contextPath + "/proj/queries/projectPermissions.spr?projectId="+projectId, function(data) {
							var abbrLength = 45;
							var json = JSON.parse(data);
							if (json.length == 0) {
								$noRoleWarning.show();
							} else {
								$noRoleWarning.hide();
							}
							var options = "";
							var selectedRoleIds = getSelectedRoleIdsFromTable(projectId);
							for (var i = 0; i < json.length; i++) {
								var roleId = parseInt(json[i]['roleId'].trim(), 10);
								var trimmedName = json[i]['roleName'].trim();
								var abbrName = truncate(trimmedName, abbrLength);
								var isSelected = $.inArray(roleId, selectedRoleIds) > -1;
								options += '<option value="' + roleId + '"' + (isSelected ? ' selected="selected"' : '') + '>' + abbrName + '</option>';
							}
							select.empty().append(options);
							$("#roleSelector").multiselect("refresh");
						});
					}
				});

				var selectedId = "${selectedProjectId}";
				if (selectedId && selectedId > 0) {
					selectInMultiselect('#projectSelector', selectedId);
				}

			}

			var getSelectedRoleIdsFromTable = function(projectId) {
				var result = [];
				$("#queryPermissionTable").find(".permissionRow").each(function() {
					if ($(this).attr("data-projectId") == projectId) {
						result.push(parseInt($(this).attr("data-roleId"), 10));
					}
				});
				return result;
			};

			function focusName() {
				setTimeout(function(){ $('#name').focus(); }, 0); //focus not working without timeout
			}

			function submitForm() {
				$("#query").submit();
			}

			$('.contentWithMargins').on('click', '.removeButton', function(e) {
				var permRow = $(e.target).closest("tr");
				var projectId = permRow.attr("data-projectId");
				var roleId = permRow.attr("data-roleId");
				var access = permRow.attr("data-access");

				var projectIdSelected = $('#projectSelector').val();
				if (projectIdSelected == projectId) {
					$("#roleSelector").multiselect("widget").find('input[value="' + roleId + '"]').click();
				} else {
					permRow.remove();
				}

				if ($('.permissionRow').length == 0) {
					$("#notSharedMsg").show();
					$("#queryPermissionTable").hide();
				}
			});

			function addPermission(roleId, roleName) {
				var projectId = $('#projectSelector').val();
				var projectName = $("#projectSelector option:selected").text();
				var $table = $("#queryPermissionTable");

				var existingPermissions = [];
				$table.find(".permissionRow").each(function() {
					existingPermissions.push({projectId: $(this).attr("data-projectId"), roleId: $(this).attr("data-roleId")});
				});

				if ($.inArray({projectId: projectId, roleId: roleId}, existingPermissions) == -1) {
					var $permissionSelector = $("<select>", {"class": "permissionSelector"});
					$permissionSelector.append($("<option>", { value: "1"}).html(i18n.message("queries.permission.read.label")));
					$permissionSelector.append($("<option>", { value: "2"}).html(i18n.message("queries.permission.write.label")));

					var $tr = $("<tr>", {'class': 'permissionRow', 'data-projectId': projectId, 'data-roleId': roleId, 'data-access': 1 });
					$tr.append($("<td>").html(projectName.trim()))
						.append($("<td>").html(roleName.trim()))
						.append($("<td>").append($permissionSelector))
						.append($("<td>").append($('<span>', {'class': 'removeButton'}).html('&nbsp;')));;

					$table.append($tr);
				}

				$("#notSharedMsg").hide();
				$table.show();

			}

			function removePermission(roleId) {
				var projectId = $('#projectSelector').val();
				$("#queryPermissionTable").find(".permissionRow").each(function() {
					if ($(this).attr("data-projectId") == projectId && $(this).attr("data-roleId") == roleId) {
						$(this).remove();
					}
				});
				if ($("#queryPermissionTable").find(".permissionRow").length == 0) {
					$("#notSharedMsg").show();
					$("#queryPermissionTable").hide();
				}
			}

			$('.contentWithMargins').on('change', '.permissionSelector', function() {
				var access = $(this).val();
				$(this).closest(".permissionRow").attr("data-access", access);
			});

			$('#saveButton').click(function(e) {
				e.preventDefault();
				fillPermissionInput();
				var name = $('#name').val();
				if (name.trim() != "") {
					$.get(contextPath + "/proj/queries/findQueryByName.spr", {"name" : name}).done(function(data) {
						var id = JSON.parse(data)['id'];
						var currentId = $("#queryId").val();
						var duplicate = $("#duplicate").val();

						if (id && id != currentId) {
							showFancyConfirmDialogWithCallbacks(i18n.message("queries.save.samename.overwrite"), function() {
								$("#overwriteQueryId").val(id);
								submitForm();
							}, function() {
								focusName();
							});
						} else {
							submitForm();
						}
					});
				} else {
					$("#queryGlobalMessages li").html(i18n.message("queries.save.noname.error"));
					$("#queryGlobalMessages").show();
				}
			});

			initProjectSelector();
			initRoleSelector();
			focusName();

		});
	</script>
</c:if>