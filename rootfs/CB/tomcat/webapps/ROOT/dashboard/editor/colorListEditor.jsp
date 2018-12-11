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

<link rel="stylesheet" href="<ui:urlversioned value='/dashboard/editor/colorListEditor.css' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/dashboard/colorListEditor.js'/>"></script>

<div class="form-field">
	<label for="${selectorId}" <c:if test="${isMandatory}">class="mandatory"</c:if>>${fieldLabel}</label>

	<div id="${selectorId}" class="color-editor-container">
		<div class="color-container">
			<spring:message code="widget.editor.field.label.seriesPaint.title" text="Click to delete this color." var="deleteTitle"/>
			<c:forEach items="${value}" var="color" varStatus="loop">
				<c:if test="${not empty color }">
					<div class="color-badge" style="background-color: ${color};" data-color="${color}">
						<span class="color-name"><spring:message code="widget.editor.field.label.seriesPaint.text" text="Color"/> ${loop.count}</span>
						<span title="${deleteTitle}" class="delete"></span>
					</div>
				</c:if>
			</c:forEach>
		</div>

		<input type="hidden" id="${selectorId}_selected_colors"  name="params[${fieldName}]" value="${valueAsList}"/>
		<input type="hidden" id="${selectorId}_color_code"/>

		<span class="color-picker-link-container">
			<a href="#" id="${selectorId}_color_picker_link"><spring:message code="widget.editor.field.label.seriesPaint.colorPickerLink" text="Click to add new color"/></a>
			<ui:colorPicker fieldId="${selectorId}_color_code" showClear="${false}"/>
		</span>
	</div>

	<script type="text/javascript">
		$(document).ready(function() {
			codebeamer.dashboard.colorListEditor.init("${selectorId}");
		});
	</script>

</div>