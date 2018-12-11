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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<script type="text/javascript" src="<ui:urlversioned value='/docs/includes/artifactManagement.js'/>"></script>
<script type="text/javascript">

    var artifactDefaults = {
    	nameLabel 		 : '<spring:message code="document.name.label"        text="Name"        javaScriptEscape="true" />',
    	descriptionLabel : '<spring:message code="document.description.label" text="Description" javaScriptEscape="true" />',
    	signatureLabel	 : '<spring:message code="baseline.signature.label"   text="Signature"   javaScriptEscape="true" />',
    	signatureTitle	 : '<spring:message code="baseline.signature.hint"    text="You can optionally sign this baseline by entering your password here" javaScriptEscape="true"/>'
    };

    var dialogDefaults = {
		submitUrl		: '<c:url value="/proj/doc/create.spr?proj_id="/>',
	    submitText    	: '<spring:message code="button.ok" 	text="OK" 		javaScriptEscape="true"/>',
	    cancelText   	: '<spring:message code="button.cancel" text="Cancel" 	javaScriptEscape="true"/>'
	};


	function createNewDirectory(menuItem, project, parent) {
		$(menuItem).showCreateArtifactDialog({
			typeId : 2,
			parent : parent
		}, artifactDefaults, $.extend( {}, dialogDefaults, {
			title     : '<spring:message code="document.type.directory.create.title" text="Create New Directory" javaScriptEscape="true" />',
			submitUrl : dialogDefaults.submitUrl + project
		}), function(directory) {
			document.location.href = '<c:url value="/dir/"/>' + directory.id;
		});

		return false;
	}

	function createNewBaseline(menuItem, project, parent, reloadAfterXhr, ignoreDeletedFlag, isBaselineCreationRunning) {
		var ignoreDeletedFlagParam = ignoreDeletedFlag ? '&ignoreDeletedFlag=true' : '';
		$(menuItem).showCreateArtifactDialog({
					typeId: 12,
					parent: parent
				},
				$.extend({}, artifactDefaults, {
					descriptionSizeLimit: 100,
					displayWarning: isBaselineCreationRunning ? 'baseline.creation.veto' : null,
					displayHint: 'baseline.creation.hint'
				}),
				$.extend({}, dialogDefaults, {
					title: '<spring:message code="baseline.create.title" text="Create a new Baseline" javaScriptEscape="true" />',
					submitUrl: dialogDefaults.submitUrl + project + ignoreDeletedFlagParam
				}),
				function(baseline) {
					if (window.location.href.indexOf("create_new_baseline=true") != -1) {
						window.location.href = window.location.href.replace("create_new_baseline=true", "create_new_baseline=false"); // avoid popping form up again
					} else {
						if (reloadAfterXhr) {
							window.location.reload();
						} else {
							setTimeout(function() {
								var msg = i18n.message('baseline.create.successful');

								$("body").trigger("inProgressDialog", false);
								showFancyAlertDialog(msg, 'notification');
							}, 1000);
						}
					}
				},
				function(jqXHR) {
					$("body").trigger("inProgressDialog", false);
				},
				function() {
					$("body").trigger("inProgressDialog");
				}
		);

		return false;
	}

</script>

<ui:inProgressDialog imageUrl="${pageContext.request.contextPath}/images/newskin/baseline_create_in_progress.gif" height="235" attachTo="body" triggerOnClick="false" />
