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
<meta name="module" content="baselines"/>
<meta name="moduleCSSClass" content="newskin documentsModule baselinesModule"/>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="callTag" prefix="ct" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>

<c:if test="${not empty selectionSide}">
	<c:set var="selectionSide"><spring:escapeBody htmlEscape="true" javaScriptEscape="true">${selectionSide}</spring:escapeBody></c:set>
</c:if>

<ui:actionMenuBar>
	<ui:pageTitle prefixWithIdentifiableName="false"><spring:message code="project.baselines.title" text="Baselines" /></ui:pageTitle>
</ui:actionMenuBar>

<ui:actionBar>
	<span class="light"><spring:message code="baseline.change.hint" text="Click a baseline to make it selected." /></span>
	<input class="filterBox" type="text" placeholder="Type here to filter" autofocus="autofocus" value="">
</ui:actionBar>

<c:choose>
	<c:when test="${not empty baselines}">
		<ol class="baselineList">
			<c:forEach items="${baselines}" var="baseline">
				<tag:formatDate value="${baseline.createdAt}" var="formattedCreateDate" />
				<li class="${empty baseline.id ? 'headBaseline' : ''}">
					<span class="baselineHeader">
						<ct:call object="${baselineRenderer}" method="renderUrlLink" param1="${baseline}" param2="${baselineDecorator}" return="itemUrlLink"/>

						<a href="#" data-default-baseline-target="<c:out value="${itemUrlLink}" />" class="baselineName" data-baseline-id="${baseline.id}"><c:out value="${baseline.name}" /></a>
						<span class="baselineMeta">
							<spring:message code="baseline.createdBy.label" text="Created by"/>: <c:out value="${baseline.owner.name}"/><br>
							${formattedCreateDate}
						</span>
					</span>
					<div class="baselineDescription">
						<ct:call object="${baselineRenderer}" method="renderSource" print="true" param1="${baseline}" param2="${user}" param3="${locale}"/>
					</div>
					<ct:call object="${baselineRenderer}" method="renderDescription" return="description" param1="${baseline}" param2="${baselineDecorator}" param3="baselineDescription"/>
					${description}
					<c:if test="${not empty selectionSide}">
						<ct:call object="${baselineRenderer}" method="renderUrlLink" param1="${baseline}" param2="${baselineDecorator}" return="itemUrlLink"/>

						<span class="metaData" style="display: none;"
							  data-baseline-id="${baseline.id}"
							  data-baseline-created-timestamp="${baseline.createdAt.time}"
							  data-baseline-created-date="<c:out value="${formattedCreateDate}" />"
							  data-baseline-name="<c:out value="${baseline.name}" />"
							  data-baseline-url="<c:out value="${itemUrlLink}" />"
							  data-baseline-description="<c:out value="${description}" />"
							  <c:if test="${baseline.parent != null}">
							  	  <ct:call object="${baselineRenderer}" method="getParent" return="parent" param1="${baseline}" param2="${user}"/>
							  	  data-baseline-parent="<c:out value="${parent.typeId}" />"
							  	  <ct:call object="${baselineRenderer}" method="renderSource" return="source" param1="${baseline}" param2="${user}" param3="${locale}"/>
							  	  data-baseline-source="<c:out value="${source}" />"
							  </c:if>
						></span>
					</c:if>
				</li>
			</c:forEach>
		</ol>
	</c:when>
	<c:otherwise>
		<p class="noBaselineFound">
			<spring:message code="baseline.notFoundAny.hint" text="No baselines found. <a href='#'>Click here</a> to create your first baseline." />
		</p>
	</c:otherwise>
</c:choose>

<script src="<ui:urlversioned value='/js/baselineList.js'/>"></script>

<script>
	jQuery(function($) {

		var list = $(".baselineList");
		var items = list.find("li");

		function filter() {
			var value = $.trim($(this).val()).toLowerCase();
			if (value.length >= 2) {
				items.each(function() {
					var item = $(this);
					var name = item.find(".baselineName").text();
					item.toggle(name.toLowerCase().indexOf(value) != -1);
				});
			} else {
				items.show();
			}
		}

		$("a.baselineName").click(function() {
			<c:choose>
				<c:when test="${not empty selectionSide}">
					if (codebeamer.BaselineList.addBaselineFromPopup(parent,  $(this).closest('li').clone(), "${selectionSide}")) {
						// Note: firstly just hide the inline popup dialog to be able to display flashing
						parent.$('.ui-dialog').hide();
						parent.$('.ui-widget-overlay').hide();
						setTimeout(function() {
							closePopupInline();
						}, 1500);
					}

				</c:when>
				<c:otherwise>
					var link = $(this);

					$.post(contextPath + "/proj/ajax/default/baseline.spr", {baseline_id: link.data("baseline-id")}).always(function() {
						// If baseline parameter name is provided, reload page with that updated, otherwise go to default baseline target page
						parent.window.location.href = ${not empty baselineParamName} ?
								UrlUtils.addOrReplaceParameter(parent.window.location.href, "${baselineParamName}".split(","), link.data("baseline-id")) :
								link.data("default-baseline-target");
						closePopupInline();
					});
				</c:otherwise>
			</c:choose>
			return false;
		});

		$(".noBaselineFound").click(function() {
			codebeamer.Baselines.createNewBaseline(${project.id});
			return false;
		});

		$(".filterBox").keydown(function() {
			filter.apply(this);
		});

		$(".filterBox").on("blur", function() {
			filter.apply(this);
		});

		codebeamer.BaselineList.initBaselineDescriptions();
	});
</script>
