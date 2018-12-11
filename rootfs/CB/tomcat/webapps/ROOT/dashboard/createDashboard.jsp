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
--%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ taglib uri="wysiwyg" prefix="wysiwyg" %>

<meta name="decorator" content="${param.overlay ? 'popup' : 'main' }"/>
<meta name="moduleCSSClass" content="newskin"/>

<style type="text/css">
    .name-container input {
        width: calc(100% - 10px);
    }
	.mandatory.form-label, .optional.form-label {
		text-align: left !important;
		padding-left: 0px;
	}

	.form-label.content-form-label {
		margin-top: 15px;
	}
</style>



<form:form commandName="addDashboardCommand" class="dirty-form-check">
	<form:hidden path="projectId"/>
	<form:hidden path="parent_id"/>

    <div class="ui-layout-north">
		<ui:actionMenuBar>
		    <ui:breadcrumbs showProjects="false"><span class='breadcrumbs-separator'>&raquo;</span><span class="page-title">
		        <spring:message code="dashboard.create.label" text="Create Dashboard"/>
		    </span>
		        <ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
		            <spring:message code="dashboard.create.label" text="Create Dashboard"/>
		        </ui:pageTitle>
		    </ui:breadcrumbs>
		</ui:actionMenuBar>

		<ui:actionBar>
			<button type="submit" class="button"><spring:message code="button.add" text="Add"/></button>
			<spring:message var="cancelButton" code="button.cancel" />
			<button type="button" class="cancelButton" onclick="closePopupInline(); return true;"><spring:message code="button.cancel" /></button>
		</ui:actionBar>
	</div>
	<div class="ui-layout-center contentWithMargins">
		<div class="name-container">
			<div class="mandatory labelcell form-label" style="vertical-align: middle;"><spring:message code="dashboard.name.label" text="Name"/>:</div>
			<form:input id="name" path="name" size="80" maxlength="200" />
		</div>
		<div class="optional labelcell form-label content-form-label" style="vertical-align: middle;"><spring:message code="dashboard.description.label" text="Description"/>:</div>
		<wysiwyg:froalaConfig />
		<wysiwyg:editor editorId="editor" resizeEditorToFillParent="true" useAutoResize="false" hideQuickInsert="true">
		    <form:textarea path="description" id="editor" rows="12" cols="80" autocomplete="off" />
		</wysiwyg:editor>
	</div>

</form:form>

<script type="text/javascript">
	setTimeout(function() {
	    $('#name').focus();
	}, window.parent != window ? 800 : 1);

	codebeamer.NavigationAwayProtection.init(${param.overlay ? 'true': ''});
</script>