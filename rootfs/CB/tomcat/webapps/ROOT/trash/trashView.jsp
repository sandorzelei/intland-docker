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

<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab"%>

<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="acltaglib" prefix="acl"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="callTag" prefix="ct"%>

<meta name="decorator" content="main" />
<meta name="module" content="trash" />
<meta name="moduleCSSClass" content="documentsModule newskin" />

<spring:message var="emptyHint" code="trash.remove.all"/>
<spring:message var="emptyTrashLabel" code="project.emptyTrash.title" text="Empty trash"/>

<style type="text/css">
.trash-tab-container {
	margin: 15px;
}

.empty-trash-div{
	padding: 8px 15px;
  	font-weight: bold;
  	padding-bottom: 9px;
  	margin-bottom: -1px;
  	outline: none;
  	position: relative;
    float: left;
    text-align: center;
}

</style>

<c:if test="${!(emptyTrash or empty clearTrashURL)}">

<c:url var="deleteArtifactsURL" value="/trash/deleteArtifacts.spr">
	<c:param name="projectId" value="${projectId}"/>
</c:url>

<c:url var="restoreArtifactsURL" value="/trash/restoreArtifacts.spr">
	<c:param name="projectId" value="${projectId}"/>
</c:url>

<script type="text/javascript">

	var deleteArtifacts = {
		confirm : '<spring:message code="documents.deleteTrash.confirm" text="Do you really want to irreversibly delete the selected documents ?"/>',
		url     : "${deleteArtifactsURL}"
	};

	var restoreArtifacts = {
		url     : "${restoreArtifactsURL}"
	};

	function submitArtifacts(link, config) {
		var style = link.css(['color', 'cursor']);
		if (style.cursor != 'progress') {
			var selectedArtifactIds = [];

			$('#task-details').find('input:checkbox[name="selectedArtifactIds-' + config.tab + '"]:checked').each(function() {
				selectedArtifactIds.push($(this).val());
			});

			if (selectedArtifactIds.length > 0 && (!config.action.confirm || confirm(config.action.confirm))) {
				var busy = ajaxBusyIndicator.showBusyPage();

				$('#task-details').find('a.actionLink').css({
					color  : 'lightGray',
					cursor : 'progress'
				});

				$.ajax(config.action.url, {
					type        : 'POST',
					data		: JSON.stringify(selectedArtifactIds),
					contentType : 'application/json',
					dataType    : 'json'
				}).done(function(result) {
					if ($.isFunction(config.success)) {
						config.success();
					}
		    	}).fail(function(jqXHR, textStatus, errorThrown) {
		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
		    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		    	}).always(function() {
					ajaxBusyIndicator.close(busy);
		    		$('#task-details').find('a.actionLink').css(style);
		    	});
			}
		}

		return false;
	}

	function emptyTrash(link) {
		var style = link.css(['color', 'cursor']);

		if (style.cursor != 'progress' && confirm('<spring:message code="project.emptyTrash.confirm" text="Are you sure you want to empty the trash?"/>')) {
			var busy = ajaxBusyIndicator.showBusyPage();

			$('#task-details').find('a.actionLink').css({
				color  : 'lightGray',
				cursor : 'progress'
			});

			$.ajax("${clearTrashURL}", {
				type 	 : 'GET',
				dataType : 'json'
			}).done(function(result) {
				window.location.reload();
	    	}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
	    			console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	    	}).always(function() {
				ajaxBusyIndicator.close(busy);

	    		$('#task-details').find('a.actionLink').css(style);
	    	});
		}

		return false;
	}

	// insert empty trash after the tabs
   jQuery(function($) { $('<div class="empty-trash-div"><a href="#" title="${emptyHint}" class="actionLink empty-trash-link" onclick="return emptyTrash($(this));">${emptyTrashLabel}</a></div>')
	         .insertBefore(".ditch-clear")
   });
</script>
</c:if>

<ui:pageTitle printBody="false"><spring:message code="documents.trash.title" /></ui:pageTitle>

<ui:actionMenuBar>
		<ui:breadcrumbs showProjects="false" strongBody="true">
			<ui:pageTitle><spring:message code="documents.trash.title" text="Trash"/></ui:pageTitle>
		</ui:breadcrumbs>
</ui:actionMenuBar>

<c:if test="${emptyTrash}">
	<div class="trash-tab-container">
		<spring:message code="documents.emptyTrash.message" />
	</div>
</c:if>

<c:if test="${not emptyTrash}">

	<tab:tabContainer id="task-details" skin="cb-box trash-tab-container" selectedTabPaneId="${openTabId}">

		<%-- Trackers tab --%>
		<c:if test="${trackerTrashCount > 0 or openTabId == 'trackerTrash'}">
			<spring:message var="label" code="Trackers" />
			<tab:tabPane id="trackerTrash" tabTitle="${label} (${trackerTrashCount})">
				<c:set var="content" value="${trackerTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="trackerTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- Work items --%>
		<c:if test="${workItemTrashCount > 0 or openTabId == 'workItemTrash'}">
			<spring:message var="label" code="tracker.list.label" />
			<tab:tabPane id="workItemTrash" tabTitle="${label} (${workItemTrashCount})">
				<c:set var="content" value="${workItemTrashList}" scope="request" />
				<jsp:include page="/trash/workItemTrash.jsp" flush="true" >
					<jsp:param name="tab" value="workItemTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- Wiki tab --%>
		<c:if test="${wikiTrashCount > 0 or openTabId == 'wikiTrash'}">
			<spring:message var="label" code="documents.trash.wiki.dashboard" />
			<tab:tabPane id="wikiTrash" tabTitle="${label} (${wikiTrashCount})">
				<c:set var="content" value="${wikiTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="wikiTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- Documents tab --%>
		<c:if test="${filesTrashCount > 0 or openTabId == 'filesTrash'}">
			<spring:message var="label" code="Documents" />
			<tab:tabPane id="filesTrash" tabTitle="${label} (${filesTrashCount})">
				<c:set var="content" value="${filesTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="filesTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- Baselines tab --%>
		<c:if test="${baselinesTrashCount > 0 or openTabId == 'baselinesTrash'}">
			<spring:message var="label" code="Baselines" />
			<tab:tabPane id="baselinesTrash" tabTitle="${label} (${baselinesTrashCount})">
				<c:set var="content" value="${baselinesTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="baselinesTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- SCM repositories tab --%>
		<c:if test="${scmTrashCount > 0 or openTabId == 'scmTrash'}">
			<spring:message var="label" code="scm.repositories.page.title" />
			<tab:tabPane id="scmTrash" tabTitle="${label} (${scmTrashCount})">
				<c:set var="content" value="${scmTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="scmTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

		<%-- Reports --%>
		<c:if test="${reportTrashCount > 0 or openTabId == 'reportTrash'}">
			<spring:message var="label" code="Reports" />
			<tab:tabPane id="reportTrash" tabTitle="${label} (${reportTrashCount})">
				<c:set var="content" value="${reportTrashList}" scope="request" />
				<jsp:include page="/trash/artifactTrash.jsp" flush="true" >
					<jsp:param name="tab" value="reportTrash" />
					<jsp:param name="title" value="${label}" />
				</jsp:include>
			</tab:tabPane>
		</c:if>

	</tab:tabContainer>
</c:if>