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
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="bugstaglib" prefix="bugs" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<%@ page import="com.intland.codebeamer.persistence.dto.TrackerLayoutLabelDto"%>
<%@ page import="com.intland.codebeamer.controller.ControllerUtils"%>
<%@ page import="com.intland.codebeamer.servlet.bugs.controller.AddUpdateTaskController"%>
<%@ page import="com.intland.codebeamer.ui.view.table.TrackerSimpleLayoutDecorator"%>


<c:if test="${empty param.editable}">
    <wysiwyg:froalaConfig />
</c:if>
<!-- Hide the whole table on page and show only after layout initialization to avoid flashing scrollbars -->
<style type="text/css">
	.fieldsTable {
		display: none;
	}
</style>
<c:set var="tracker" value="${addUpdateTaskForm.trackerItem.tracker}" />
<c:if test="${empty param.noMeta or param.noMeta == false}">
	<meta name="decorator" content="${param.isPopup ? 'popup' : 'main' }"/>
	<meta name="module" content="${empty tracker.parent.id ? (tracker.category ? 'cmdb' : 'tracker') : 'docs'}"/>
	<meta name="moduleCSSClass" content="newskin ${empty tracker.parent.id ? (tracker.category ? 'CMDBModule' : 'trackersModule') : ''}  ${addUpdateTaskForm.trackerItem.branchItem or tracker.branch or not empty param.branchId? 'tracker-branch' : ''}"/>
</c:if>


<bugs:branchStyle branch="${tracker}"/>

<c:if test="${!param.skipScripts }">
	<link rel="stylesheet" href="<ui:urlversioned value="/bugs/addUpdateTask/addUpdateTask.css" />" type="text/css" media="all" />

	<script type="text/javascript" src="<ui:urlversioned value='/bugs/tracker/includes/embeddedTable.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/bugs/addUpdateTask.js'/>"></script>
</c:if>

<c:if test="${!empty param.task_id}">
	<c:set var="task_id" value="${param.task_id}" />
</c:if>

<c:if test="${!empty param.tracker_id}">
	<c:set var="tracker_id" value="${param.tracker_id}" />
</c:if>
<c:if test="${empty param.tracker_id}">
	<c:set var="tracker_id" value="${requestScope.tracker_id}" />
</c:if>

<c:if test="${!empty task_id}">
	<c:set var="trackerItem" value="${requestScope.PROJECT_AWARE_DTO}" />
	<c:set var="tracker_id" value="${trackerItem.tracker.id}" />
</c:if>

<c:set var="isCmdb" value="${addUpdateTaskForm.trackerItem.configItem}" />
<c:set var="isTestCase" value="${not empty addUpdateTaskForm.tracker and addUpdateTaskForm.tracker.testCase}" />

<%
	boolean isCmdb = Boolean.TRUE.equals(pageContext.getAttribute("isCmdb"));

	String thisUrl = ControllerUtils.getOriginatingRequestUrl(request);
	pageContext.setAttribute("targetURL", thisUrl);

	pageContext.setAttribute("NAME_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.NAME_LABEL_ID));
	pageContext.setAttribute("SUPERVISOR_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.SUPERVISOR_LABEL_ID));
	pageContext.setAttribute("DESCRIPTION_LABEL_ID", Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_LABEL_ID));
	pageContext.setAttribute("DESCRIPTION_FORMAT_ID", Integer.valueOf(TrackerLayoutLabelDto.DESCRIPTION_FORMAT_ID));

	pageContext.setAttribute("isCmdb", Boolean.valueOf(isCmdb));
%>

<c:set var="templateLabelId" value="<%= TrackerLayoutLabelDto.TEMPLATE_LABEL_ID %>" />

<c:set var="blockSeparatorRow">
	<tr class="blockSeparator">
		<td colSpan="2"><div class="blockSeparatorTop"></div></td>
	</tr>
</c:set>

<c:if test="${empty itemLabel}">
	<spring:message var="itemLabel" code="${isCmdb ? 'cmdb.category.item.label' : 'issue.label' }" />
</c:if>
<c:if test="${empty trackerLabel}">
	<spring:message var="trackerLabel" code="tracker.label"  />
</c:if>

<c:if test="${param.noActionMenuBar != 'true'}">
	<jsp:include page="/bugs/addUpdateTaskActionMenuBar.jsp">
		<jsp:param name="isCmdb" value="${isCmdb}"/>
	</jsp:include>
</c:if>

<c:set var="user" value="${pageContext.request.userPrincipal}" />

<c:set var="enctype" value="multipart/form-data" />
<script type="text/javascript">
	// correct the form's encoding
	$(function() {
		$("#editor").closest("form").attr("enctype", "${enctype}");
	});
</script>


<c:if test="${empty controlButtons}">
	<c:set var="controlButtons">
		<c:if test="${!empty addUpdateTaskForm.layoutList}">
			<spring:message var="buttonSave" code="${duplicate ? 'button.duplicate' : 'button.save'}"/>
			<input type="submit" class="button"
					 onclick="return submitAction(this.form);  ${param.isPopup ? 'inlinePopup.close(); return false;' : ''}"
					 name="SUBMIT" value="${buttonSave}"/>

			<c:if test="${duplicate}">
				<input type="hidden" name="duplicate" value="true" />
			</c:if>

			<c:if test="${canSubmitNew and ! addUpdateTaskForm.creatingSubTask and !param.isPopup}">
				<spring:message var="submitNewTitle" code="issue.submitAndNew.tooltip" text="Submit {0} and New" arguments="${itemLabel}"/>
				<c:set var="submitAndNew">
					<spring:message code="button.save"/> &amp; <spring:message code="button.new" text="New"/>
				</c:set>
				<input type="submit" class="linkButton" onclick="return submitAction(this.form);" name="SUBMIT_AND_NEW" title="${submitNewTitle}" value="${submitAndNew}"/>
			</c:if>
		</c:if>

		<spring:message var="cancelTitle" code="button.cancel" text="Cancel"/>
		<input type="hidden" name="_previous_view_id" value="<c:out value='${_previous_view_id}'/>" />
		<input type="hidden" name="source_task_id" value="<c:out value='${param.source_task_id}'/>" />
		<c:choose>
			<c:when test="${param.isPopup}">
				<input type="submit" class="cancelButton" onclick="inlinePopup.close(); return false;" value="${cancelTitle}"/>
			</c:when>
			<c:otherwise>
				<input type="submit" class="cancelButton" name="_cancel" value="${cancelTitle}" onclick="codebeamer.NavigationAwayProtection.reset()" />
			</c:otherwise>
		</c:choose>
	</c:set>
</c:if>

<c:set var="actionBar">
	<ui:actionBar>
		<c:out value="${controlButtons}" escapeXml="false" />
		<div class="switch layoutControl">
			<a data-layout-mode="mandatory"><spring:message code="issue.edit.layout.required.label" text="Required fields"/></a><a data-layout-mode="editable"><spring:message code="issue.edit.layout.editable.label" text="Editable fields"/></a><a data-layout-mode="all"><spring:message code="issue.edit.layout.all.label" text="All fields"/></a>
		</div>
	</ui:actionBar>

	<%-- validation errors and explanations must follow actionBar --%>
	<ui:showErrors errors="${errors}"/>

	<c:if test="${!empty addUpdateTaskForm.transition and !empty addUpdateTaskForm.transition.description}">
		<div class="descriptionBox scrollable">
			<tag:transformText value="${addUpdateTaskForm.transition.description}" format="${addUpdateTaskForm.transition.descriptionFormat}" />
		</div>
	</c:if>

	<c:set var="disableRiskWarning" value="${not empty param.disableMitigationReqWarning ? param.disableMitigationReqWarning : false}"/>
	<c:if test="${tracker.isRisk() && !disableRiskWarning}">
		<div class="warning"><spring:message code="tracker.riskManagement.mitigation.req.warning"/></div>
	</c:if>

</c:set>

<c:set var="propertyEditor">
	<%-- you can insert stuff here using this request parameter --%>
	${beforePropertyEditorFragment}

	<c:if test="${testSetOrTestCaseMissing }">
		<div class="warning">
			<spring:message code="tracker.testRun.has.no.test.cases.error" text="You cannot run this test run because it has no Test Sets or Test Cases."/>
		</div>
	</c:if>
	<%-- Use a nestedPath param to control the bind path of the fields. Use nestedPath=null parameter when already inside a form (null used because can not pass an empty string as parameter) --%>
	<c:set var="nestedPath" value="${empty param.nestedPath ? 'addUpdateTaskForm' : (param.nestedPath == 'null' ? '' : param.nestedPath)}" />
	<spring:nestedPath path="${nestedPath}" >
		<c:if test="${param.isPopup}">
			<input type="hidden" name="isPopup" value="<c:out value='${param.isPopup}'/>"/>
			<input type="hidden" name="noReload" value="<c:out value='${param.noReload}'/>"/>
			<input type="hidden" name="callback" value="<c:out value='${param.callback}'/>"/>
		</c:if>

		<c:choose>
			<c:when test="${!empty task_id}">
				<form:hidden path="task_id" />
			</c:when>
			<c:otherwise>
				<form:hidden path="tracker_id"/>
			</c:otherwise>
		</c:choose>
		<form:hidden path="version" />
		<form:hidden path="parent_id" />
		<form:hidden path="position" />
		<form:hidden path="transition_id" />
		<form:hidden path="referrerUrl" />
		<form:hidden path="forwardUrlAfterSaveAndNew"/>

		<c:if test="${!empty addUpdateTaskForm.layoutList}">

			<div class="fieldsTable initializing">

				<div class="dynamicLayout">

					<%-- Tracker (e.g. "Work tracker: Bugs"), this is a fixed field, appears in all cases --%>
					<c:if test="${empty tracker.parent.id and param.noTrackerField != 'true'}">
						<div class="fieldInputControl optional">
							<div class="fieldLabel"><span class="labelText"><c:out value="${trackerLabel}"/>:</span></div>
							<div class="fieldValue dataCell" id="trackerLabel">
								<spring:message code="tracker.${addUpdateTaskForm.tracker.name}.label" text="${addUpdateTaskForm.tracker.name}" htmlEscape="true"/>
							</div>
						</div>
					</c:if>

					<c:set var="hiddenFields" value="" scope="request" />

					<jsp:useBean id="addUpdateTaskForm" beanName="addUpdateTaskForm" scope="request" type="com.intland.codebeamer.servlet.bugs.AddUpdateTaskForm" />
					<%
						TrackerSimpleLayoutDecorator decorator = new TrackerSimpleLayoutDecorator(request);
						pageContext.setAttribute("decorator", decorator);
						decorator.initRow(addUpdateTaskForm.getTrackerItem(), 0, 0);
					%>

					${insertAtBeginningOfDynamicLayoutFragment}
					<c:forEach items="${addUpdateTaskForm.layoutList}" var="fieldLayout">
						<%-- do not show the fields that are already shown on the extended document view's center panel --%>
						<c:if test="${extendedViewFields == null || !extendedViewFields.contains(fieldLayout.id) }">
						   <tag:joinLines>
								<c:set var="layout_addUpdateTaskForm" value="${addUpdateTaskForm}" scope="request" />
								<c:set var="layout_decorator" value="${decorator}" scope="request" />
								<c:set var="layout_fieldLayout" value="${fieldLayout}" scope="request" />
								<c:set var="layout_task_id" value="${task_id}" scope="request" />
								<c:set var="layout_tracker_id" value="${tracker_id}" scope="request" />
								<c:set var="layout_templateLabelId" value="${templateLabelId}" scope="request" />
								<c:set var="layout_canConfigChoiceList" value="${canConfigChoiceList}" scope="request" />
								<c:set var="layout_targetURL" value="${targetURL}" scope="request" />
								<c:set var="layout_tooltip" value="${tooltip}" scope="request" />
								<c:set var="layout_hiddenFields" value="${hiddenFields}" scope="request" />
								<c:set var="layout_labelIdsToHighlight" value="${labelIdsToHighlight}" scope="request" />
								<c:set var="layout_isTestCase" value="${isTestCase}" scope="request" />
								<c:set var="fieldRendered"><jsp:include page="includes/singleItemField.jsp" /></c:set>
								<c:set var="fieldRendered" value="${fn:trim(fieldRendered)}" />
							</tag:joinLines>
							<c:choose>
								<c:when test="${!fieldLayout.hidden}">${fieldRendered}</c:when>
								<c:otherwise>
									<%-- hidden choice fields may be cascades of other choice fields: In this case the field is already rendered and must not be rendered again --%>
									<%
										TrackerLayoutLabelDto hiddenField = (TrackerLayoutLabelDto) pageContext.getAttribute("fieldLayout");
								        Integer dependsOnId = null;
										if (hiddenField.isChoiceField() && (dependsOnId = hiddenField.getDependsOn()) != null) {
											TrackerLayoutLabelDto baseField = addUpdateTaskForm.getLayout().getField(dependsOnId);
											if (baseField != null && baseField.isChoiceField()) {
											    Integer cascadeId = baseField.getInteger("cascade");
												if (cascadeId != null && cascadeId.equals(hiddenField.getId())) {
													pageContext.setAttribute("fieldRendered", "\n<!-- " + hiddenField + " is rendered as cascade of " + baseField + " -->\n");
												}
											}
										}
									%>

									<%-- hidden fields show as hidden because they may contain valuable data or preset values set by the controller before showing the edit form --%>
									<c:set var="hiddenFields" scope="request">${hiddenFields}
										${fieldRendered}
									</c:set>
								</c:otherwise>
							</c:choose>
						</c:if>
					</c:forEach>
				</div>

				<table class="staticLayout">

					<colgroup>
						<col class="fieldLabel">
						<col class="fieldValue">
					</colgroup>

					${blockSeparatorRow}

					<c:set var="fieldLayout" value="${addUpdateTaskForm.layoutField[NAME_LABEL_ID]}" />
					<c:set var="labelStyle" value="optional" />
					<c:set var="extraClass" value=""/>
					<c:if test="${fieldLayout.required}">
						<c:set var="labelStyle" value="mandatory" />
						<%-- check if the mandatory field is empty; if yes then mark it with an extra class --%>
						<ct:call object="${fieldLayout}" method="getValue" param1="${addUpdateTaskForm.trackerItem}" return="fieldValue"/>
						<c:if test="${empty fieldValue && hasErrors}">
							<c:set var="extraClass" value="nullValue"/>
						</c:if>
					</c:if>

					<c:if test="${!empty fieldLayout.label}">
						<c:set var="disabled" value="${!addUpdateTaskForm.editable[NAME_LABEL_ID]}" />
						<c:if test="${!(disabled and empty task_id)}">
							<%-- Summary field (e.g. issue name) --%>
							<tr id="summaryField" title='<c:out value="${fieldLayout.description}"/>'>
								<c:set var="cssClasses" value="fieldInputControl ${labelStyle} ${extraClass}" />
								<td class="fieldLabel ${cssClasses}"><span class="labelText"><spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>:</span></td>
								<td class="fieldValue dataCell ${cssClasses}" id="summaryCell">
									<form:input id="summary" disabled="${disabled}" path="summary" maxlength="254" size="80" tabindex="0" cssClass="expandText"/>
								</td>
							</tr>
						</c:if>
					</c:if>

					<c:set var="fieldLayout" value="${addUpdateTaskForm.layoutField[DESCRIPTION_LABEL_ID]}" />
					<c:set var="labelStyle" value="optional" />
					<c:set var="extraClass" value=""/>
					<c:if test="${fieldLayout.required}">
						<c:set var="labelStyle" value="mandatory" />
						<%-- check if the mandatory field is empty; if yes then mark it wit an extra class --%>
						<ct:call object="${fieldLayout}" method="getValue" param1="${addUpdateTaskForm.trackerItem}" return="fieldValue"/>
						<c:if test="${empty  fieldValue && hasErrors}">
							<c:set var="extraClass" value="nullValue"/>
						</c:if>
					</c:if>
					<c:if test="${not empty labelIdsToHighlight}">
						<ct:call object="${labelIdsToHighlight}" method="contains" param1="${DESCRIPTION_LABEL_ID}" return="toBeHighlighted" />
						<c:if test="${toBeHighlighted}">
							<c:set var="extraClass" value="highlightedValue ${extraClass}"/>
						</c:if>
					</c:if>

					<c:if test="${!empty fieldLayout.label}">
						<c:set var="disabled" value="${!addUpdateTaskForm.editable[DESCRIPTION_LABEL_ID]}" />
						<c:if test="${!(disabled and empty task_id)}">
							<c:set var="showDescription" value="true"/>
							<%-- don't collapse description if that is required ! --%>
							<c:set var="collapseDescriptionIfEmpty" value="${(! fieldLayout.required) && (param.collapseDescriptionIfEmpty == true)}" />
							<c:set var="fieldLabel"><spring:message code="tracker.field.${fieldLayout.label}.label" text="${fieldLayout.label}"/>:</c:set>
							<c:set var="fieldTitle"><c:out value="${fieldLayout.description}"/></c:set>
							<c:if test="${collapseDescriptionIfEmpty}">
								<ct:call object="${fieldLayout}" method="getValue" param1="${addUpdateTaskForm.trackerItem}" return="descriptionValue"/>
								<c:set var="showDescription" value="${! empty descriptionValue}" />
								<tr id="descriptionFieldCollapsing">
									<td colspan="2">
										<ui:collapsingBorder label="Description"
											hideIfEmpty="false" open="${showDescription}" toggle="#descriptionField"
											cssClass="separatorLikeCollapsingBorder" cssStyle="margin-bottom: 0;"
										/>
									</td>
								</tr>
							</c:if>

							<c:set var="descFormat" value="${addUpdateTaskForm.layoutField[DESCRIPTION_FORMAT_ID]}" />
							<tr id="descriptionField" style="${showDescription ? '' : 'display:none'}">
								<td class="<c:out value="fieldLabel fieldInputControl ${labelStyle}" />" style="vertical-align: top; padding-top: 10px;">
									<c:if test="${! collapseDescriptionIfEmpty }">
										<span class="labelText" title="${fieldTitle}">${fieldLabel}</span>
									</c:if>
								</td>
								<td class="fieldValue dataCell fieldInputControl ${extraClass}">
									<div id="descriptionCell" class="${extraClass}">
										<c:choose>
											<c:when test="${disabled}">
												<div class="descriptionBox scrollable">
													<%=decorator.getDescription()%>
												</div>
											</c:when>
											<c:otherwise>
                                                <c:set var="format_disabled" value="${!addUpdateTaskForm.editable[DESCRIPTION_FORMAT_ID]}" />
												<wysiwyg:editor editorId="editor" entity="${trackerItem}" uploadConversationId="${addUpdateTaskForm.uploadConversationId}" useAutoResize="true" heightMin="400" toolbarSticky="${not isTestCase}"
												    insertNonImageAttachments="true" formatSelectorSpringPath="${empty descFormat ? '' : 'descriptionFormat'}" formatSelectorDisabled="${format_disabled}" allowTestParameters="${isTestCase}"
												    ignorePreviouslyUploadedFiles="${empty errors}">

													<form:textarea disabled="${disabled}" path="details" cols="80" id="editor" autocomplete="off" />
												</wysiwyg:editor>
											</c:otherwise>
										</c:choose>
									</div>
								</td>
							</tr>
						</c:if>
					</c:if>

					<c:if test="${!empty task_id and (canAddComment or canViewComment)  && (!param.noComment == 'true')}">
						${blockSeparatorRow}
						<tr id="comments">
							<td class="fieldLabel fieldInputControl optional commentCell">
	                            <c:if test="${canAddComment}">
	                                <span class="labelText">
	                                    <spring:message code="comment.label" text="Comment"/>:
	                                </span>
	                            </c:if>
								<c:if test="${canViewComment}">
									<c:url var="link" value="/proj/tracker/listComments.do">
										<c:param name="task_id" value="${task_id}" />
									</c:url>
									<c:set var="onclick" value="inlinePopup.show('${link}', { cssClass: 'overlayButtonsOnWhite'}); return false;" />
									<a href="#" onclick="${onclick}">
										<spring:message code="comments.view.label" text="Comments"/>
									</a>
								</c:if>
							</td>
							<c:if test="${canAddComment}">
								<td class="fieldValue dataCell fieldInputControl" style="vertical-align: top">
								    <div class="task-item-edit-comment">
										<wysiwyg:editor editorId="comment-editor" entity="${trackerItem}" heightMin="100" uploadConversationId="${addUpdateTaskForm.uploadConversationId}" disableFormattingOptionsOpening="true"
	                                        insertNonImageAttachments="true" useAutoResize="true" toolbarSticky="${isCmdb ? 'false' : 'true'}" overlayHeaderKey="wysiwyg.comment.overlay.header" ignorePreviouslyUploadedFiles="${empty errors}">

											<form:textarea path="comment" id="comment-editor" rows="5" cols="80" autocomplete="off" />
										</wysiwyg:editor>
										<div class="issueCommentVisibilityControl">
										    <table border="0" cellspacing="0" cellpadding="0">
										        <tr valign="middle">
										            <td style="color: white; font-weight: bold;" nowrap>
										                <label for="visibility" class="visible-for-label">
										                    <img src='<ui:urlversioned value="/images/shield.png"/>'/>
										                    <spring:message code="attachment.visibility.label" text="Visible for"/>:&nbsp;
										                </label>
										            </td>
										            <td id="visibilityContainer">
										                <input id="visibility" type="hidden" name="visibility" value="<c:out value='${defaultVisibility}'/>"/>
										            </td>
										        </tr>
										    </table>
										</div>
									</div>
								</td>
							</c:if>
						</tr>
					</c:if>

					<c:if test="${empty task_id && (!param.noAssociation == 'true') && canCreateAssociation}">
						${blockSeparatorRow}
						<tr>
							<td class="fieldLabel fieldInputControl optional"><spring:message code="association.label" text="Association" />:</td>
							<td class="fieldValue fieldInputControl optional dataCell"><jsp:include page="./includes/issueEditorAddAssociation.jsp"/></td>
						</tr>
					</c:if>

					${insertAtEndOfTableFragment}	<%-- use this attribute to put something INSIDE the table at the end of that! --%>
				</table><!-- staticLayout -->

			</div><!-- fieldsTable -->

			<!-- hidden-fields for the fields table cells above -->
			<div style="display:none;" class="hiddenFields">${hiddenFields}</div>
			<input type="hidden" name="tracker_id" value="<c:out value='${tracker_id}'/>" /> <%-- keep the tracker_id as default unless something else is specified --%>
		</c:if>

	</spring:nestedPath>
</c:set>

<c:choose>
	<%-- the form wrapper can be turned off to avoid nesting forms --%>
	<c:when test="${param.noForm == 'true'}">
		${actionBar}
		<div class="contentWithMargins">
				${propertyEditor}
		</div>
	</c:when>
	<c:otherwise>
		<c:set var="action" value="<%=isCmdb ? AddUpdateTaskController.EDIT_CMDB_ITEM_URL : AddUpdateTaskController.EDIT_ISSUE_URL%>" />
		<c:url var="actionUrl" value="${action}" />
		<form:form action="${actionUrl}" enctype="${enctype}" id="addUpdateTaskForm" commandName="addUpdateTaskForm" class="dirty-form-check">
			${actionBar}
			<div class="contentWithMargins">
					${propertyEditor}
			</div>
		</form:form>
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	jQuery(function($) {
		setupKeyboardShortcuts("addUpdateTaskForm");
		<c:forEach items="${staticChoiceFieldInitializers}" var="staticChoiceFieldInitializer">
		${staticChoiceFieldInitializer}
		</c:forEach>

		(function forceBreakOneWordFieldLabelsToMultipleLines() {
			$(".fieldInputControl .labelText").each(function() {
				var label = $(this);
				var text = label.text();
				if (text.length > 15 && text.indexOf(" ") == -1) {
					label.css({
						"word-break": "break-all",
						"-moz-hyphens": "auto",
						"hyphens": "auto"
					});
				}
			});
		})();
	});

	function submitAction(frm) {
		try {
			if (window.parent != window) {   // window.parent is never null, but contains the window itself if that has no parent
				var editorId = window.parent.frameElement.getAttribute('data-editor-id'),
				    editor = parent.parent.codebeamer.WYSIWYG.getEditorInstance(editorId);

				if (editor) {
				    editor.$oel.addClass('dirty');
				}
				window.parent.codebeamer.NavigationAwayProtection.reset();
			}
		} catch(e) { // accessing cross-origin related error in case of remote issue reporting
			console.log('Could not access parent window:', e.message);
		}

		// updates comment visibility
		var $container = $('#visibilityContainer');
		if ($container.length) {
		    $('input[type="hidden"][name="visibility"]', $container).val($container.getCommentVisibility());
		}

		disableDoubleSubmit(frm);

		var $testStepsTable = $('#testSteps');
		if ($testStepsTable.length) {
			var openEditor = $testStepsTable.find('.editor-wrapper textarea');

			if (openEditor.length) {
				codebeamer.WYSIWYG.destroyEditor(openEditor, true, true, true);
			}
		}
		return true;
	}

	var normalizeClasses = function(classString) {
		var unique = function(list) {
			var result = [];
			$.each(list, function(i, e) {
				if ($.inArray(e, result) == -1) result.push(e);
			});
			return result;
		};
		var classNames = $.trim(classString).split(/\s+/);
		return unique(classNames).join(" ");
	};

	var convertInitialStateToCells = function() {

		var createCell = function(baseClassName, labelElem, inheritedClassName) {
			var classNames = baseClassName + " " + labelElem.get(0).className + " " + inheritedClassName;

			var cell = $("<td></td>").addClass(normalizeClasses(classNames));
			var fieldId = $(labelElem).attr("data-field-id");
			var title = $(labelElem).attr("title");
			if (fieldId) {
				$(cell).attr("data-field-id", fieldId);
			}
			if (title) {
				$(cell).attr("title", title);
			}

			return cell;
		};

		var cells = [];
		$(".dynamicLayout .fieldInputControl").each(function() {
			var elem = this;
			var className = elem.className;
			var contents = $(elem).contents().detach();
			contents.find("script").remove(); // remove JS to prevent re-executing it while re-attaching
			try {
				var fieldLabel = contents.filter(".fieldLabel");
				var fieldValue = contents.filter(".fieldValue");
				var labelCell = createCell("fieldLabel", fieldLabel, className);
				var valueCell = createCell("fieldValue", fieldValue, className);
				labelCell.html(fieldLabel.contents());
				valueCell.html(fieldValue.contents());
				var valueColSpan = fieldValue.data("colspan");
				if (valueColSpan) {
					// retain colspan attribute
					valueCell.attr("data-colspan", valueColSpan);
				}
				cells.push(labelCell);
				cells.push(valueCell);
			} catch(ex) {
				console.error(ex);
			}
		});
		return cells;
	};

	var reWrapTableRows = function(cells, fieldsPerRow) {
		var table = $("<table></table>");
		var row = $("<tr></tr>");
		fieldsPerRow = fieldsPerRow || 3;
		var cellsPerRow = fieldsPerRow * 2;
		var index = 0;
		$(cells).each(function() {

			var cell = $(this);

			var isRowStart = function() {
				return index % cellsPerRow == 0;
			};

			var startNewRowIfNeeded = function() {
				if (row.contents().size() > 0 && isRowStart()) {
					table.append(row);
					row = $("<tr></tr>");
				}
			};

			var insertLineBreak = function() {
				var dummyCount = cellsPerRow - (index % cellsPerRow);
				for (var i = 0; i < dummyCount; i++) {
					row.append($("<td class='dummy'></td>"));
				}
				index += dummyCount;
				startNewRowIfNeeded();
			};

			// handle line breaks
			if (!isRowStart() && cell.hasClass("breakRow") && index % 2 == 0) {
				insertLineBreak();
			}

			// handle colspans
			if (cell.data("colspan") > 1) {
				var remainingSpace = (cellsPerRow - ((index + 1) % cellsPerRow)) % cellsPerRow;
				var moreSpaceNeeded = 2 * (cell.data("colspan") - 1);
				var cp = moreSpaceNeeded + 1;
				cell.attr("colspan", cp);
				if (remainingSpace < moreSpaceNeeded) {
					var labelCell = row.find("td").last().detach();
					--index;
					insertLineBreak();
					row.append(labelCell);
					++index;
				}
				index += moreSpaceNeeded;
			} else {
				cell.attr("colspan", "");
			}
			startNewRowIfNeeded();

			row.append(cell);
			++index;
		});
		if (row.contents().size() > 0) {
			table.append(row);
		}

		// need to add a <colgroup> section to set a fixed width for specific columns
		var colGroup = $("<colgroup></colgroup>");
		for (var i = 0; i < cellsPerRow; i++) {
			var col = $("<col>");
			col.addClass((i % 2 == 0) ? "fieldLabel" : "fieldValue").appendTo(colGroup);
		}
		table.prepend(colGroup);

		return table;
	};

	var convertLayoutToTabular = function(fieldsPerRow) {
		var cells = convertInitialStateToCells();
		return reWrapTableRows(cells, fieldsPerRow);
	};

	var initLayoutMode = function(layout, filter) {
		var isEmbedded = false;
		<c:if test="${param.embeddedView == 'true'}">
			layout = "straightDown";
			filter = "*";
			isEmbedded = true;
		</c:if>

		var CELL_SELECTOR = "td.fieldLabel,td.fieldValue";

		var fieldsPerRow = layout == "straightDown" ? 1 : 3;
		var container = $(".dynamicLayout");

		var fieldsTable = $(".fieldsTable");
		var initializing = fieldsTable.hasClass("initializing");
		var table;
		if (initializing) {
			table = convertLayoutToTabular(fieldsPerRow);
			fieldsTable.removeClass("initializing");
		} else {
			var cells = container.find(CELL_SELECTOR).not(".dummy");
			table = reWrapTableRows(cells, fieldsPerRow);
		}

		table.addClass("dynamicLayout " + layout + (isEmbedded ? " fullWidth" : ""));
		table.find(CELL_SELECTOR).each(function() {
			var cell = $(this);
			var show = cell.is(filter);
			cell.toggle(show);
		});
		container.replaceWith(table);

		var separatorOfSections = $(".staticLayout .blockSeparator").first();
		separatorOfSections.toggle(isAnyDynamicFieldVisible());
	};

	var getSelectedLayoutMode = function() {
		var selectedLayoutMode = $(".layoutControl a.active").data("layout-mode");
		return selectedLayoutMode || "${param.layoutMode}" || $.cookie("codebeamer.issueEditor.selectedLayout") || "all";
	};

	var storeSelectedLayoutMode = function(layout) {
		$.cookie("codebeamer.issueEditor.selectedLayout", layout, { path: '${pageContext.request.contextPath}', expires: 90, secure: (location.protocol === 'https:')});
		$(".container input[name=mode]").val(layout);
	};

	var isAnyDynamicFieldVisible = function() {
		return !!$(".dynamicLayout td.fieldLabel:visible").length;
	};

	/**
	 * IE8 does not tolerate nested <form> tags so we have to rearrange a DOM a bit if it is needed.
	 */
	var fixReferenceBoxes = function() {
		var box = $(".chooseReferences .yui-ac-container").detach();
		$("<div class='yui-multibox'></div>").html(box).appendTo("body");
	};

	var activateLayout = function(layout) {
		$(".layoutControl a[data-layout-mode=" + layout + "]").click();
	};

	jQuery(function($) {

		var container = $(".layoutControl");

		container.find("a").click(function() {
			container.find("a").removeClass("active");
			$(this).addClass("active");
			var method = $(this).data("layout-mode");
			var filter = "*";
			switch (method) {
				case "mandatory": filter = ".mandatory"; break;
				case "editable": filter = ".editable"; break;
			}
			initLayoutMode((method == "all") ? 'tabular' : 'straightDown', filter);

			// Show the whole table only after layout initialization to avoid flasing scrollbars
			$(".fieldsTable").css("display", "block");

			storeSelectedLayoutMode(method);
			$('body').trigger('cbRefreshEditorPositions');
			return false;
		});


		if (container.closest("form").closest("form").length > 0) {
			fixReferenceBoxes();
		}

		activateLayout(getSelectedLayoutMode());

		setTimeout(function() {
		    $('#summary').focus();
		}, window.parent != window ? 800 : 1);

		(function switchLayoutModeOnValidationError() {
			container.closest("form").submit(function() {
				var that = this;
				setTimeout(function() {
					if ($(that).find(".notEmptyAutocompleteInput").length > 0) {
						activateLayout("editable");
					}
				}, 100);
				return true;
			});
		})();

		if (typeof addUpdateTask != "undefined") {
			var wikiFieldSizes = ${empty wikiFieldSizes ? "null" : wikiFieldSizes};
			addUpdateTask.makeWikiFieldsRememberTheirSizes("${tracker_id}", wikiFieldSizes);
		}

		codebeamer.NavigationAwayProtection.init();
	});

</script>

<c:if test="${!empty task_id and canAddComment and !param.noComment == 'true'}">
	<script type="text/javascript" src="<ui:urlversioned value='/bugs/includes/commentVisibility.js'/>"></script>

	<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/multiselect.less" />" type="text/css" media="all" />

	<script type="text/javascript">
	    jQuery(function($) {
	        $('#visibilityContainer').commentVisibilityControl(${tracker.id}, "${defaultVisibility}", {
	            memberFields        : [<c:forEach items="${memberFields}" var="field" varStatus="loop">{ id : ${field.id}, name : "<spring:message code='tracker.field.${field.label}.label' text='${field.label}' javaScriptEscape='true'/>" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
	            roles               : [<c:forEach items="${roles}"        var="role"  varStatus="loop">{ id : ${role.id}, name : "${ui:escapeJavaScript(role.name)}" }<c:if test="${!loop.last}">, </c:if></c:forEach>],
	            visibilityTitle     : '<spring:message code="comment.visibility.tooltip" text="Limit visibility of this comment" javaScriptEscape="true" />',
	            everybodyLabel      : '<spring:message code="comment.visibility.everybody.label" text="Everybody" javaScriptEscape="true" />',
	            everybodyTitle      : '<spring:message code="comment.visibility.everybody.tooltip" text="Everybody who normally can see the issue, will see this comment too" javaScriptEscape="true" />',
	            memberFieldsLabel   : '<spring:message code="tracker.fieldAccess.memberFields.label" text="Participants" javaScriptEscape="true"/>',
	            rolesLabel          : '<spring:message code="tracker.fieldAccess.roles.label" text="Roles" javaScriptEscape="true"/>',
	            checkAllText        : '<spring:message code="tracker.field.value.choose.all" text="Check all" javaScriptEscape="true"/>',
	            uncheckAllText      : '<spring:message code="tracker.field.value.choose.none" text="Uncheck all" javaScriptEscape="true"/>',
	            defaultVisibility   : '${defaultVisibility}'
	        });

	        (function rePositionRoleSelectorOnWindowResize() {
	            $(window).resize(function() {
	                $(".ui-widget.ui-multiselect-menu").position({
	                    of: $("#visibilityContainer"),
	                    my: "left top",
	                    at: "left bottom"
	                });
	            });
	        })();
	    });
	</script>
</c:if>
<wysiwyg:editorInline />