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
<meta name="module" content="labels"/>
<meta name="bodyCSSClass" content="newskin"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<ui:actionMenuBar>
	<ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span>
		<ui:pageTitle><spring:message code="tags.label" text="Tags"/></ui:pageTitle>
	</ui:breadcrumbs>
</ui:actionMenuBar>

<script type="text/javascript">
	function addLabel(labelName) {
		var oldLabelNames = document.forms[0].entityLabels.value;
		if (oldLabelNames.length == 0) {
			document.forms[0].entityLabels.value = labelName;
		} else {
			found = false;
			var oldLabelNameList = oldLabelNames.split(";");
			for (i = 0; i < oldLabelNameList.length; i++) {
				var oldNameTrimmed = oldLabelNameList[i].replace(/^\s+/g, '').replace(/\s+$/g, '');
				if (oldNameTrimmed == labelName) {
					found = true;
					break;
				}
			}

			if (!found) {
				document.forms[0].entityLabels.value += "; " + labelName;
			} else {
				alert("Tag \"" + labelName + "\" is already assigned to this entity.");
			}
		}
	}

	function cancelAction() {
		window.close();
	}
</script>

<html:form action="/proj/label/updateEntityLabel" focus="entityLabels">

	<html:hidden property="entityTypeId"/>
	<html:hidden property="entityId"/>
	<html:hidden property="forwardUrl"/>
	<html:hidden property="itemIds"/>
	<html:hidden property="branchId"/>

	<ui:actionBar>
		&nbsp;&nbsp;
		<html:submit styleClass="button" property="SAVE">
			<spring:message code="button.save" text="Save"/>
		</html:submit>

		&nbsp;&nbsp;
		<html:cancel styleClass="cancelButton" onclick="closePopupInline(); return false;">
			<spring:message code="button.cancel" text="Cancel"/>
		</html:cancel>
	</ui:actionBar>

	<ui:showErrors/>

	<c:if test="${numberOfParents > 0}">
		<div class="selected-element-tagging">
			<b><spring:message code="tags.selected.items.and.children" arguments="${numberOfParents}"/></b>
	    </div>
    </c:if>
	
	<c:if test="${numberOfParents <= 0 && numberOfItems > 0}">
		<div class="selected-element-tagging">
			<b><spring:message code="tags.selected.items.label" arguments="${numberOfItems}"/></b>
	    </div>
    </c:if>
    
    <c:if test="${numberOfParents <= 0 && numberOfItems <= 0 && not empty entityName}">
    	<div class="selected-element-tagging">
			<b><spring:message code="tags.selected.tracker.label" arguments="${entityName}"/></b>
    	</div>
    </c:if>
	
	<table border="0" class="formTableWithSpacing" cellpadding="2">
		
		<tr>
			
			<td rowspan="7"><spring:message code="tags.label" text="Tags"/>:</td>
			
			<td class="expandText">
				<div>
					<html:text styleId="labelInput" styleClass="expandText" size="90" property="entityLabels"/>
					<div id="labelSuggestionsContainer" class="yui-ac-container"></div>
				</div>

				<script type="text/javascript">
					$(function() {
						var $input = $('#labelInput');
						
						initEntityLabelAutocomplete($input);
						setTimeout(function() { $input.focus(); }, 200);
					});
				</script>
			</td>
		</tr>

	</table>

	<div class="contentWithMargins">

        <span class="subtext">
            <spring:message code="tag.edit.hint"/>
        </span>

		<spring:message var="title" code="tags.recent.label" text="Most recent tags" scope="request"/>
		<c:set var="labels" value="${mostRecentLabels}" scope="request"/>
		<jsp:include page="includes/entityLabelPopupList.jsp"/>

		<spring:message var="title" code="tags.popular.label" text="Most popular tags" scope="request"/>
		<c:set var="labels" value="${mostPopularLabels}" scope="request"/>
		<jsp:include page="includes/entityLabelPopupList.jsp"/>

		<spring:message var="title" code="tags.public.label" text="All public tags" scope="request"/>
		<c:set var="labels" value="${publicLabels}" scope="request"/>
		<jsp:include page="includes/entityLabelPopupList.jsp"/>

	</div>

</html:form>

<script type="text/javascript">
	jQuery(function() {
		var $ = jQuery;
		$(".toggleMoreLink").click(function() {
			var moreContainer = $(this).hide().next();
			moreContainer.show();
			return false;
		});
		$(".toggleLessLink").click(function() {
			var moreContainer = $(this).parent();
			moreContainer.hide().prev(".toggleMoreLink").show();
			return false;
		});
	});
</script>
