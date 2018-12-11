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
 * $Revision: 23955:cdecf078ce1f $ $Date: 2009-11-27 19:54 +0100 $
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="com.intland.codebeamer.ui.view.actionmenubuilder.ArtifactActionMenuBuilder" %>

<meta name="decorator" content="popup" />
<meta name="module" content="tracker" />

<style>
	.column-centered {
		text-align: center;
	}
</style>

<%-- include the JS and hidden field for deleting one/multiple documents --%>
<jsp:include page="../../docs/includes/deleteArtifacts.jsp">
	<jsp:param name="confirmMessageKey"
		value="docs.delete.baseline.confirm" />
	<jsp:param name="confirmOneMessageKey"
		value="docs.delete.oneBaseline.confirm" />
	<jsp:param name="confirmOneDirMessageKey"
		value="docs.delete.oneBaseline.confirm" />
</jsp:include>

<c:url var="compareBaselinesUrl" value="/proj/baselines.spr">
	<c:param name="proj_id" value="${tracker.project.id}" />
	<c:param name="tracker_id" value="${tracker.id}" />
</c:url>

<c:if test="${empty param.hideActionMenuBar }">
	<spring:message var="baselinesTitle" code="Baselines" text="Baselines"
		htmlEscape="true" />
	<ui:actionMenuBar>
		<ui:pageTitle prefixWithIdentifiableName="false">
				${trackerName} ${baselinesTitle}
			</ui:pageTitle>
	</ui:actionMenuBar>
</c:if>

<spring:message var="trackerName" code="tracker.${tracker.name}.label" text="${tracker.name}" htmlEscape="true" />

<form action="/proj/tracker/compareBaselines.spr">
	<div class="actionBar">
		<spring:message var="compareButton"
			code="project.baselines.compare.button"
			text="Compare Selected Baselines" />
		<input type="button" class="button"
			onclick="codebeamer.Baselines.compareBaselinesButtonHandler(this.form, '${compareBaselinesUrl}', 'baseline', true); return false;"
			value="${compareButton}" />

		<c:if test="${empty project}">
			<jsp:include page="/docs/includes/createArtifacts.jsp"></jsp:include>
			<ui:actionGenerator builder="trackerListContextActionMenuBuilder" actionListName="actions" subject="${tracker}">
				<ui:actionLink actions="${actions}" keys="newBaselineWithReload" />
			</ui:actionGenerator>
		</c:if>

		<a href="#" class="cancelButton" onclick="inlinePopup.close();">
			<spring:message code="button.cancel" text="Cancel"/>
		</a>

		<input class="baselineFilterBox" type="text" data-type="baseline" placeholder="<spring:message code="Filter"/>" autofocus="autofocus" value="">

	</div>

	<div class="contentWithMargins baselineListWrapper">
		<div class="hint">
			<spring:message code="baseline.list.hint"/>
		</div>
		<c:if test="${empty project}">
			<display:table name="${baselines}" id="baseline"
						   export="false" class="expandTable" cellpadding="0"
						   decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator" defaultsort="4" defaultorder="descending">
				<c:set var="currentBaselineId" value="${empty baseline.baseline ? baseline.id : baseline.baseline.id}"/>
				<display:column media="html">
					<input type="checkbox" name="selectedBaselines" ${currentBaselineId == baselineId ? 'checked' : ''}
						   value="${empty baseline.baseline ? baseline.id : baseline.baseline.id}" />
				</display:column>

				<spring:message var="baselineLabel" code="baseline.label"
								text="Baseline" />
				<display:column title="${baselineLabel}" headerClass="textData"
								class="textData">
					<spring:message var="baselineTooltip"
									code="document.baselines.link.title"
									text="Click here to display this baselined revision" />
					<a href="#" title="${baselineTooltip}" data-baselineId="${not empty baseline.baseline ? baseline.baseline.id : baseline.id}"><c:out value="${baseline.name}" /></a>
					<c:if test="${baseline.dto.parent != null}">
						<div class="subtext">
							<ct:call object="${baselineRenderer}" method="renderSource" print="true" param1="${baseline.dto}" param2="${user}" param3="${locale}"/>
						</div>
					</c:if>
				</display:column>

				<spring:message var="baselineDescription"
								code="baseline.description.label" text="Description" />
				<display:column title="${baselineDescription}" property="baselineDescription"
								headerClass="textData expand"
								class="textDataWrap smallerText columnSeparator" style="padding-left: 10px;"/>

				<spring:message var="baselineCreatedAt"
								code="baseline.createdAt.label" text="Created at" />
				<display:column title="${baselineCreatedAt}" property="createdAt" sortProperty="sortCreatedAt"
								headerClass="dateData" class="dateData columnSeparator" />

				<spring:message var="baselineCreatedBy"
								code="baseline.createdBy.label" text="Created by" />
				<display:column title="${baselineCreatedBy}" property="owner"
								headerClass="textData" class="textData columnSeparator" />

				<spring:message var="baselineSignature" code="baseline.signed.label"
								text="Signed" />
				<display:column title="${baselineSignature}" sortable="false"
								headerClass="textData" class="textData">
					<c:choose>
						<c:when test="${fn:contains(baseline.dto.comment, 'baseline.signed.label')}">
							<img src="<c:url value='/images/choice-yes.gif'/>" />
						</c:when>
						<c:otherwise>
							--
						</c:otherwise>
					</c:choose>
				</display:column>

				<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
					<c:if test="${baseline.dto != null }">
						<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="actions" subject="${baseline}">
							<ui:actionLinkList actions="${actions}" keys="Properties,Delete..." cssClass="baselineActions" />
						</ui:actionGenerator>
					</c:if>
				</display:column>

				<spring:message code="baseline.compare.label" var="compareLabel" text="Compare to Head revision"/>
				<spring:message code="baseline.compare.title" var="compareTitle" text="Click to compare to Head revision"/>
				<display:column title="${compareLabel}" class="column-centered">
					<c:choose>
						<c:when test="${not empty baseline.baseline }">
							<c:url value="/tracker/${tracker.id }?comparedBaselineId=${baseline.baseline.id}" var="compareUrl"></c:url>
							<a href="#" class="baseline-compare-head" title="${compareTitle }" onclick="parent.location.href='${compareUrl }'"></a>
						</c:when>
						<c:when test="${not empty baseline.dto }">
							<c:url value="/tracker/${tracker.id }?comparedBaselineId=${baseline.dto.id}" var="compareUrl"></c:url>
							<a href="#" class="baseline-compare-head" title="${compareTitle }" onclick="parent.location.href='${compareUrl }'"></a>
						</c:when>
						<c:otherwise>
							--
						</c:otherwise>
					</c:choose>
				</display:column>
			</display:table>
		</c:if>
		<c:if test="${not empty project}">
			<display:table name="${projectBaselines}" id="baseline" sort="external"
						   export="false" class="expandTable" cellpadding="0"
						   decorator="com.intland.codebeamer.ui.view.table.DocumentListDecorator">
				<c:set var="currentBaselineId" value="${baseline.id}"/>
				<display:column media="html">
					<input type="checkbox" name="selectedBaselines" ${currentBaselineId == baselineId ? 'checked' : ''}
						   value="${baseline.id}" />
				</display:column>

				<spring:message var="baselineLabel" code="baseline.label"
								text="Baseline" />
				<display:column title="${baselineLabel}" headerClass="textData"
								class="textData">
					<spring:message var="baselineTooltip"
									code="document.baselines.link.title"
									text="Click here to display this baselined revision" />
					<a href="#" title="${baselineTooltip}" data-baselineId="${baseline.id}"><c:out value="${baseline.name}" /></a>
					<c:if test="${baseline.parent != null}">
						<div class="subtext">
							<ct:call object="${baselineRenderer}" method="renderSource" print="true" param1="${baseline}" param2="${user}" param3="${locale}"/>
						</div>
					</c:if>
				</display:column>

				<spring:message var="baselineDescription"
								code="baseline.description.label" text="Description" />
				<display:column title="${baselineDescription}" property="baselineDescription"
								headerClass="textData expand"
								class="textDataWrap smallerText columnSeparator" style="padding-left: 10px;"/>

				<spring:message var="baselineCreatedAt"
								code="baseline.createdAt.label" text="Created at" />
				<display:column title="${baselineCreatedAt}" property="createdAt"
								headerClass="dateData" class="dateData columnSeparator" />

				<spring:message var="baselineCreatedBy"
								code="baseline.createdBy.label" text="Created by" />
				<display:column title="${baselineCreatedBy}" property="owner"
								headerClass="textData" class="textData columnSeparator" />

				<spring:message var="baselineSignature" code="baseline.signed.label"
								text="Signed" />
				<display:column title="${baselineSignature}" sortable="false"
								headerClass="textData" class="textData">
					<c:choose>
						<c:when test="${fn:contains(baseline.comment, 'baseline.signed.label')}">
							<img src="<c:url value='/images/choice-yes.gif'/>" />
						</c:when>
						<c:otherwise>
							--
						</c:otherwise>
					</c:choose>
				</display:column>

				<display:column title="" decorator="com.intland.codebeamer.ui.view.table.TrimmedColumnDecorator" media="html" class="action-column-minwidth columnSeparator">
					<c:if test="${baseline != null }">
						<ui:actionGenerator builder="allArtifactActionsMenuBuilder" actionListName="actions" subject="${baseline}">
							<ui:actionLinkList actions="${actions}" keys="Properties,Delete..." cssClass="baselineActions" />
						</ui:actionGenerator>
					</c:if>
				</display:column>

			</display:table>
		</c:if>
	</div>

</form>

<script src="<ui:urlversioned value='/js/baselineList.js'/>"></script>
<script>
	jQuery(function($) {
		codebeamer.BaselineList.initBaselineDescriptions();
		$('a[data-baselineId]').click(function() {
			var baselineId = $(this).attr('data-baselineId'),
				url = parent.window.location.href;

			if (baselineId.length || url.indexOf('revision') > -1) {
				url = UrlUtils.addOrReplaceParameter(url, 'revision', baselineId);
			}

			parent.window.location.href = url;
			return false;
		});
	});
</script>
