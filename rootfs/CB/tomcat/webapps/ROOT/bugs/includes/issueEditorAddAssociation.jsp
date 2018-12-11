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
 *
 * $Revision$ $Date$
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<%--
	JSP fragment handles the add-association during issue add
--%>
<style type="text/css">
	#associationBlock select {
 		border: solid 1px silver;
 	}

 	.associationSelectContainer {
 		/* absolute positioning takes it out of the 'page-flow' so it won't push the tables wider */
 		position: absolute;
 		width: auto;
 		display: inline-block;
 	}

 	#associationBlock .refresh-button {
		border: none;
		width: auto;
 	}

</style>

<tag:history var="history" command="list" />
<c:set var="history_size" value="20" />

<spring:message var="assocCreateTitle" code="association.creation.tooltip" text="Click to add an association to some of the previous items..."/>
<div id="addAssociationLink" style="padding:5px;">
	<a href="#?" onclick='onAssociationChange(true)' title="${assocCreateTitle}"><spring:message code="association.creation.label" text="Add association..."/></a>
</div>
<span id="associationBlock" style="display:none;">
	<form:select path="associationType" cssStyle="width: auto;">
		<c:forEach items="${addUpdateTaskForm.associationTypes}" var="assocType">
			<form:option value="${assocType.value}">
				<spring:message code="association.typeId.${assocType.label}" text="${assocType.label}"/>
			</form:option>
		</c:forEach>
	</form:select>

	<%--
	<html:select property="associationType" style="width: auto;">
		<c:forEach items="${addUpdateTaskForm.associationTypes}" var="assocType">
			<html:option value="${assocType.value}">
				<spring:message code="association.typeId.${assocType.label}" text="${assocType.label}"/>
			</html:option>
		</c:forEach>
	</html:select>
	--%>

	<div class="associationSelectContainer">
		<form:select path="association" cssClass="dynamicSelectWidth" id="associationSelect" onchange="onAssociationChange();">
			<form:option value="">
				<spring:message code="tracker.template.choose.none" text="None"/>
			</form:option>
			<c:forEach items="${history}" var="hist_entry" end="${history_size - 1}">
				<form:option value="${hist_entry.typeId}-${hist_entry.id}">
					[<tag:issueKeyAndId dto="${hist_entry}"></tag:issueKeyAndId>]&nbsp;<c:out value="${hist_entry.shortDescription}" />
				</form:option>
			</c:forEach>
		</form:select>

		<spring:message var="assocListRefreshLabel" code="association.refresh" text="Refresh"/>
		<input type="submit" class="linkButton refresh-button" onclick="reloadAssociations(); return false;" value="${assocListRefreshLabel}">
	</div>
<%--
	<html:select property="association" styleClass="dynamicSelectWidth" styleId="associationSelect" onchange="onAssociationChange();">
		<html:option value="">
			<spring:message code="tracker.template.choose.none" text="None"/>
		</html:option>
		<c:forEach items="${history}" var="hist_entry" end="${history_size - 1}">
			<html:option value="${hist_entry.typeId}-${hist_entry.id}">
				<c:out value="${hist_entry.interwikiLink} ${hist_entry.shortDescription}" />
			</html:option>
		</c:forEach>
	</html:select>
--%>
	<br/>

	<spring:message var="assocCommentTitle" code="association.description.tooltip" text="Add your comment about the association"/>
	<form:textarea path="associationComment" rows="2" cols="80" cssClass="expandTextArea" id="associationComment"
			cssStyle="display:none; margin-top:4px;" title="${assocCommentTitle}"
	/>

<%--
	<html:textarea property="associationComment" rows="2" cols="80" styleClass="expandTextArea" styleId="associationComment"
			style="display:none; margin-top:4px;" title="${assocCommentTitle}"
	/>
--%>
</span>

<ui:delayedScript>
<SCRIPT type="text/javascript" language="JavaScript">

function reloadAssociations(){
	$.ajax({
	    url: contextPath + '/ajax/history.spr?size=20',
	    type: 'GET',
	    dataType: "json",
	    success: function(data) {
			if (data && data.length > 0){
				var $assocSelect = $("#associationSelect");
				$assocSelect.empty();
				$assocSelect.append($('<option>', { value: "" }).text(i18n.message('tracker.template.choose.none')));

				$.each(data, function(key, value) {
					$assocSelect.append($('<option>', { value: value.typeId + "-" + value.id }).text(value.interwikiLink + " " + value.shortDescription ));
				});
			}
	    }
	});
}

/**
 * Called when the some issue is selected/unselected in the select box for association change
 * @param showBlock If the association block should be revealed
 */
function onAssociationChange(showBlock) {
	var selectControl = document.getElementById("associationSelect");
	var associationTargetSelected = (selectControl.selectedIndex != 0);
	var associationComment = document.getElementById("associationComment");
	var addAssociationLink = document.getElementById("addAssociationLink");
	var associationBlock = document.getElementById("associationBlock");
	// show/hide the association comment depending on if the association target is selected or not.
	if (associationTargetSelected) {
		associationComment.style.display = "";
	} else {
		associationComment.style.display = "none";
	}
	showBlock = showBlock || associationTargetSelected;
	if (showBlock) {
		associationBlock.style.display = "";
		addAssociationLink.style.display = "none";
	} else {
		associationBlock.style.display = "none";
		addAssociationLink.style.display = "";
	}
}

//when page loads show/hide the association comments depending on if the target is selected
$(onAssociationChange);
</SCRIPT>
</ui:delayedScript>