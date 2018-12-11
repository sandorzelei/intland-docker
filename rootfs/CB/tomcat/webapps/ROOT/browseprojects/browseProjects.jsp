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
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<meta name="decorator" content="main"/>
<meta name="module" content="project_browser"/>
<meta name="moduleCSSClass" content="newskin workspaceModule"/>

<link rel="stylesheet" href="<ui:urlversioned value='/browseprojects/browseProjects.less' />" type="text/css" media="all" />
<link rel="stylesheet" href="<ui:urlversioned value='/bugs/tracker/versionsview/versionStats.css' />" type="text/css" media="all" />

<script type="text/javascript" src="<ui:urlversioned value='/js/isotope/isotope.pkgd.min.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/js/isotope/packery-mode.pkgd.js'/>"></script>
<script src="<ui:urlversioned value='/js/sortableHelpers.js'/>"></script>
<script type="text/javascript" src="<ui:urlversioned value='/browseprojects/browseProjects.js'/>"></script>

<ui:UserSetting var="alwaysDisplayContextMenuIcons" setting="ALWAYS_DISPLAY_CONTEXT_MENU_ICONS" defaultValue="true" />

<ui:actionMenuBar>
	<ui:pageTitle><spring:message code="project.browser.page.title" text="Project Browser"/></ui:pageTitle>
</ui:actionMenuBar>

<c:set var="noProjectsMessage"><spring:message code="project.selector.empty" text="No project available" htmlEscape="true" />.</c:set>

<ui:splitTwoColumnLayoutJQuery cssClass="layoutfullPage autoAdjustPanesHeight" rightMinWidth="335">
	<jsp:body>
		<div id="left-content" class="accordion">
			<spring:message code="project.browser.select.all.title" text="All" var="selectAllTitle"/>
			<div class="actionBar">
				<ui:actionLink builder="projectListPageActionMenuBuilder" keys="exportToExcel,createNewProject" ></ui:actionLink>
				<spring:message code="association.search.as.you.type.label" var="filterLabel" text="Type to filter"/>
				<input id="project-filter" class="treeFilterBox filter-text" type="text" title="${filterLabel}" value="${param.filter }" data-filter="${param.filter }"/>
			</div>
			<div id="accordion-container">
				<h4 class="accordion-header"><spring:message code="project.browser.status.filter.label" text="Status filtering"/></h4>
				<div class="project-status-list accordion-content">
					<div class="subtext" style="margin-left: 10px;"><spring:message code="project.browser.coloring.label" text="Coloring"/></div>
					<div class="switch">
						<a data-property="statuscolor" class="${activeColoring == 'statuscolor' ? 'active' : '' }"><spring:message code="project.browser.project.status.label" text="Project Status"/></a><!--
						--><a data-property="color" class="${activeColoring == 'color' ? 'active' : '' }"><spring:message code="project.browser.my.colors.label" text="My Colors"/></a>
					</div>
					<div class="color-filter ${activeColoring == 'statuscolor' ? 'selected' : ''}" data-property="statuscolor" style="${activeColoring == 'color' ? 'display: none;' : '' }">
						<c:forEach items="${statusOptions}" var="option" varStatus="loopStatus">
							<div class="project-status-option ${loopStatus.last ? 'last' : '' }">
								<a class="project-status ${option.key} color-box"></a>
								<label for="option-${option.key}"><spring:message code="project.status.${option.key}.label" text="${option.key}"/></label>
								<input type="checkbox" checked="checked" onclick="codebeamer.projects.filterByColor();" data-name="${option.key}" id="option-${option.key}"
									data-color="${option.value}"/>
							</div>
						</c:forEach>
					</div>
					<div class="subtext" style="margin-left: 15px; margin-top: 15px;"><spring:message code="project.browser.color.filter.hint" text="Click on the boxes to filter by color"/></div>
					<div class="color-filter property-color ${activeColoring == 'color' ? 'selected' : ''}" data-property="color" style="${activeColoring == 'statuscolor' ? 'display: none;' : '' }">
						<c:forEach items="${defaultColors}" var="option" varStatus="loopStatus">
							<a class="project-status color-box big state-checked" style="background-color: ${option};" data-name="${option}"></a>
							<input type="checkbox" checked="checked" onclick="codebeamer.projects.filterByColor();" data-name="${option}" id="option-${option}"
								data-color="${option}" style="display: none;"/>
						</c:forEach>
					</div>
				</div>

				<h4 class="accordion-header"><spring:message code="project.categories.label" text="Categories"/></h4>
				<div class="accordion-content">
					<div class="category-list" id="category-togglers">
						<div class="category-label toggler" title="${selectAllTitle}">
							<label for="show-all-categories">${selectAllTitle}</label>
							<input type="checkbox" checked="checked" onclick="return codebeamer.projects.toggleCheckboxes(this);" id="show-all-categories" checked="checked"/>
							<span class="storyPointsLabel">${fn:length(activeProjects)}</span>
						</div>
						<c:forEach items="${categories}" var="category">
							<c:set var="categoryIdValue" value="${category.key.id}" />
							<c:set var="categoryName" value="${category.key.name}"/>
							<c:if test="${categoryName == 'Uncategorized' || categoryName == 'Recent'}">
								<spring:message code="project.browser.category.${category.key.name}.title" var="categoryName" text="${category.key.name}"/>
							</c:if>

							<div class="category-label" title="${categoryName}">
								<c:if test="${not anonymous }">
									<div class="knob"></div>
								</c:if>
								<label for="category-${category.key.id}"><c:out value="${categoryName}"/></label>
								<input class="category-box" type="checkbox" checked="checked" data-name="<c:out value="${category.key.name}" />"
									data-id="${categoryIdValue}"
									id="category-${categoryIdValue}"/>
								<span class="set-count storyPointsLabel open">${fn:length(category.value)}</span>
							</div>
						</c:forEach>
					</div>
					<div class="category-list" id="workingSet-togglers">
						<div class="category-label toggler" title="${selectAllTitle}">
							<label for="show-all-workingSets">${selectAllTitle}</label>
							<input type="checkbox" checked="checked" onclick="return codebeamer.projects.toggleCheckboxes(this);" id="show-all-workingSets" checked="checked"/>
							<span class="storyPointsLabel">${fn:length(workingSets)}</span>
						</div>
						<c:forEach items="${workingSets}" var="workingSet">
							<div class="category-label" title="${workingSet.key.name}">
								<c:if test="${not anonymous}">
									<div class="knob"></div>
								</c:if>
								<label for="category-${workingSet.key.id}">${workingSet.key.name}</label>
								<input type="checkbox" class="category-box" checked="checked"
									data-name="${workingSet.key.id}" id="category-${workingSet.key.id}" data-id="${workingSet.key.id}"/>
								<span class="set-count storyPointsLabel open">${fn:length(workingSet.value)}</span>
							</div>
						</c:forEach>
					</div>
				</div>
			</div>
		</div>

		<c:set var="defaultTabLink">
			<a href="#" onclick="codebeamer.projects.setDefaultTab()"
				class="make-default-link" style="display:none;" title='<spring:message code="project.browser.set.default.tab.title" text="Make default"/>'>
				<spring:message code="project.browser.set.default.tab.label" text="Sets this tab as the default"/>
			</a>
		</c:set>

		<c:url var="menuArrow" value="/images/space.gif"/>
		<tab:tabContainer id="project-browser-tabs" skin="cb-box" jsTabListener="codebeamer.projects.tabChangeListener"
			selectedTabPaneId="${defaultTab}" afterTabsFragment="${defaultTabLink}">
			<spring:message code="project.browser.categories.tab.title" text="Projects" var="categoriesTabTitle"/>
			<tab:tabPane id="project-categories" tabTitle="${categoriesTabTitle}">
				<c:choose>
					<c:when test="${empty activeProjects }">
						<jsp:include page="createFirstProject.jsp"/>
					</c:when>
					<c:otherwise>
						<c:choose>
							<c:when test="${empty categories}">
								<p>${noProjectsMessage}</p>
							</c:when>
							<c:otherwise>
								<div class="categories">
									<c:forEach items="${categories}" var="category">
										<div class="set" data-name="<c:out value="${category.key.name}" />"
												data-id="<c:out value="${category.key.id}" />">
											<div class="set-header">
												<c:set var="categoryName" value="${category.key.name}"/>
												<c:if test="${categoryName == 'Uncategorized' || categoryName == 'Recent'}">
													<spring:message code="project.browser.category.${category.key.name}.title" var="categoryName" text="${category.key.name}"/>
												</c:if>
												<c:out value="${categoryName}" />
											</div>
											<div class="set-container" data-workingsetid="<c:out value="${category.key.id}" />" data-type="category">
												<c:forEach items="${category.value}" var="properties">
													<c:url var="projectUrl" value="${properties.project.urlLink}"/>
													<c:set var="editable" value="false"/>
													<c:if test="${not empty editableProjects[properties.project.id] }">
														<c:set var="editable" value="true"/>
													</c:if>

													<c:set var="statusColor" value="${statusOptions[properties.status] }"/>
													<a class="project-card size-${properties.size}" style="background-color: ${activeColoring ==  'color' ? properties.color : statusColor};" id="${category.key.id}-${properties.project.id}"
													data-size="${properties.size}" data-color="${properties.color}" data-projectid="${properties.project.id}" data-name="${properties.project.name}"
													data-editable="${editable }" data-status="${properties.status}" data-statuscolor="${statusOptions[properties.status] }"
													data-url="${projectUrl}" href="${projectUrl}">
														<span class="yuimenubaritemlabel yuimenubaritemlabel-hassubmenu">
															<img class="menuArrowDown${alwaysDisplayContextMenuIcons eq 'true' ? ' always-display-context-menu' : ''}" src="${menuArrow }"/>
														</span>
														<c:if test="${not anonymous}">
															<div class="knob"></div>
														</c:if>
														<c:url var="projectIconUrl" value="${properties.iconUrl}"/>
														<span class="project-icon">
															<img src="${projectIconUrl}"/>
														</span>
														<span class="details-arrow" title="${properties.project.name}"></span>
														<span class="project-name" title="${properties.project.name}">${properties.project.name}</span>
													</a>
												</c:forEach>
											</div>
										</div>
									</c:forEach>
								</div>
							</c:otherwise>
						</c:choose>
					</c:otherwise>
				</c:choose>
			</tab:tabPane>

			<spring:message code="project.browser.project.join.tab.title" text="Open to Join" var="openToJoinTitle"/>
			<tab:tabPane id="project-join" tabTitle="${openToJoinTitle}">
			</tab:tabPane>

			<spring:message code="project.browser.project.list.tab.title" text="Compact List" var="projectListTitle"/>
			<tab:tabPane id="project-list" tabTitle="${projectListTitle}">
				<c:choose>
					<c:when test="${empty activeProjects }">
						<jsp:include page="createFirstProject.jsp"/>
					</c:when>
					<c:otherwise>
						<ul id="project-list" class="project-list filterable">
							<c:choose>
								<c:when test="${empty activeProjects}">
									<spring:message code="project.selector.empty" text="No project available"/>.
								</c:when>

								<c:otherwise>
									<c:forEach items="${activeProjects}" var="project">
										<c:url var="projectUrl" value="${project.urlLink}"/>

										<li>
											<ui:ajaxTagging entity="${project}" favourite="true"/>
											<a href="${projectUrl}"><c:out value="${project.name}" /></a>
										</li>
									</c:forEach>
								</c:otherwise>
							</c:choose>
						</ul>
						<div style="clear: both;"></div>
					</c:otherwise>
				</c:choose>
			</tab:tabPane>

			<c:if test="${not anonymous}">
				<spring:message code="project.browser.add.set.title" text="Click to add new working set" var="addWorkingSetTitle"/>
				<spring:message code="project.browser.mySets.tab.title" text="Working Sets" var="mySetsTabTitle"/>
				<tab:tabPane id="project-mySets" tabTitle="${mySetsTabTitle}">
					<div class="categories workingSets">
						<div class="new-set-placeholder first" title="${addWorkingSetTitle}"></div>
						<c:forEach items="${workingSets}" var="entry">
							<div class="set" data-name="${entry.key.id}" data-id="${entry.key.id}">
								<div class="set-header">
									<span class="working-set-name" data-unescaped="${entry.key.name}">${entry.key.name}</span><!--
									--><span class="remove-set-icon" title="<spring:message code="project.browser.action.remove.set.tooltip"
											text="Remove this working set" htmlEscape="true" />"></span><!--
									--><span class="add-project-icon" title="<spring:message code="project.browser.action.add.existing.project.to.set.tooltip"
											text="Add an existing project to this working set" htmlEscape="true" />"></span>
								</div>
								<div class="set-container" data-workingsetid="${entry.key.id}" data-type="set">
									<c:forEach items="${entry.value}" var="properties">
										<c:url var="projectUrl" value="${properties.project.urlLink}"/>
										<c:set var="editable" value="false"/>
										<c:if test="${not empty editableProjects[properties.project.id] }">
											<c:set var="editable" value="true"/>
										</c:if>
										<c:set var="statusColor" value="${statusOptions[properties.status] }"/>
										<a class="project-card size-${properties.size}" style="background-color: ${activeColoring ==  'color' ? properties.color : statusColor};" id="${category.key.id}-${properties.project.id}"
										data-size="${properties.size}" data-color="${properties.color}" data-projectid="${properties.project.id}" data-name="${properties.project.name}"
										data-editable="${editable}" data-status="${properties.status}" data-statuscolor="${statusOptions[properties.status]}"
										data-url="${projectUrl}" href="${projectUrl}">
											<span class="yuimenubaritemlabel yuimenubaritemlabel-hassubmenu">
												<img class="menuArrowDown${alwaysDisplayContextMenuIcons eq 'true' ? ' always-display-context-menu' : ''}" src="${menuArrow }"/>
											</span>
											<c:if test="${not anonymous}">
												<div class="knob"></div>
											</c:if>
											<c:url var="projectIconUrl" value="${properties.iconUrl}"/>
											<span class="project-icon">
												<img src="${projectIconUrl}"/>
											</span>
											<span class="details-arrow" title="${properties.project.name}"></span>
											<span class="project-name" title="${properties.project.name}">${properties.project.name}</span>
										</a>
									</c:forEach>
								</div>
							</div>
							<div class="new-set-placeholder" title="${addWorkingSetTitle}">
								<span class="insert-here-hint"><spring:message code="project.browser.insert.set.hint" /></span>
							</div>
						</c:forEach>
					</div>
				</tab:tabPane>
			</c:if>

			<spring:message code="project.browser.project.list.tab.title" text="Project List" var="projectListTitle"/>
			<tab:tabPane id="project-list" tabTitle="${projectListTitle}">
				<c:choose>
					<c:when test="${empty activeProjects}">
						<p>${noProjectsMessage}</p>
					</c:when>

					<c:otherwise>
						<ul id="project-list" class="project-list">
							<c:forEach items="${activeProjects}" var="project">
								<c:url var="projectUrl" value="${project.urlLink}"/>

								<li>
									<a href="${projectUrl}"><c:out value="${project.name}" /></a>
								</li>
							</c:forEach>
						</ul>
						<div style="clear: both;"></div>
					</c:otherwise>
				</c:choose>
			</tab:tabPane>

			<c:if test="${not empty deletedProjects}">
				<spring:message code="project.deleted.label" text="Deleted" var="deletedProjectsTitle"/>
				<tab:tabPane id="project-deleted" tabTitle="${deletedProjectsTitle}">
					<c:choose>
						<c:when test="${empty deletedProjects}">
							<p>${noProjectsMessage}</p>
						</c:when>

						<c:otherwise>
							<ul id="deleted-projects" class="project-list filterable">
								<c:forEach items="${deletedProjects}" var="project">
									<c:url var="projectUrl" value="/proj/admin.spr">
										<c:param name="proj_id" value="${project.id}"/>
										<c:param name="options" value="IgnoreDeletedFlag"/>
									</c:url>

									<li>
										<ui:ajaxTagging entity="${project}" favourite="true"/>
										<a href="${projectUrl}"><c:out value="${project.name}" /></a>
									</li>
								</c:forEach>
							</ul>
							<div style="clear: both;"></div>
						</c:otherwise>
					</c:choose>
				</tab:tabPane>
			</c:if>
		</tab:tabContainer>
	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>

<script type="text/javascript">
	jQuery(function($) {
		codebeamer.projects.init(${not anonymous});
		codebeamer.projects.defaultTab = "${defaultTab}";

		$("#create-project-link.project-limit-exceeded").attr("href", "#").click(function(e) {
			var buttonOrMessage = ${canVisitWebshop ? 'true' : 'false'} ?
					'<button class="visit-shop-button button">' + i18n.message("project.browser.projectLimitExceeded.shopButtonTitle") + '</button>' :
					'<span class="visit-shop-message">' + i18n.message("project.browser.projectLimitExceeded.shopMessage") + '</span>'; // TODO
			var div = $("<div>").append("${projectLimitExceededWindowContent}").append(buttonOrMessage);
			$(div).dialog({
				"modal": true,
				"draggable": false,
				"resizable": false,
				"position": "center",
				"dialogClass": "project-limit-exceeded-dialog",
				"height": 480,
				"width": 600,
				"close": function () {},
				"open": function () {}
			});
			$("button.visit-shop-button").click(function() {
				window.location.href = "${webshopUrl}";
				return false;
			});
			return false;
		});

		$("#project-join").on("click", ".pagelinks a", function (event) {
			debugger;
			var $link = $(this);
			var href = $link.attr("href");

			if (href) {
				codebeamer.projects.goToPage(href);
				event.preventDefault();
			}
		});

		codebeamer.projects.filterByColor();
	});
</script>

<div style="display: none;" id="category-label-template">
	<div class="category-label" title="$name">
		<c:if test="${not anonymous}">
			<div class="knob"></div>
		</c:if>
		<label for="category-$id">$name</label>
		<input type="checkbox" class="category-box" checked="checked" data-name="$id" id="category-$id"/>
		<span class="set-count storyPointsLabel open">0</span>
	</div>
</div>
