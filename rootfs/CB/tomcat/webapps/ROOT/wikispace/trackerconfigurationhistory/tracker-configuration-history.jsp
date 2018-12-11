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
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>

<style>
	.trackerHistoryAuditTrailPlugin .baseline-info {
		font-size: 12px;
		border-bottom: 1px solid #ffd9ab;
		background: #fff7eb url("${pageContext.request.contextPath}/images/newskin/message/info-stripes.png") no-repeat 10px center;
		margin: -20px -20px 15px -20px;
		padding-left: 32px;
		line-height: 32px;
	}
	.trackerHistoryAuditTrailPlugin .baseline-info .baseline-name {
        font-weight: bold;
	}

	.trackerHistoryAuditTrailPlugin .hidden-info,
	.tracker-configuration-history-wrapper .hidden-info {
        color: #666;
	}

    .trackerHistoryAuditTrailPlugin .tracker-history-header.accordion-header,
    .tracker-configuration-history-content .transition-diagram-header.accordion-header {
        font-size: 12px !important;
        padding: 7px 10px !important;
    }

    .tracker-configuration-history-wrapper .accordion-header {
        font-size: 12px !important;
        font-weight: normal;
    }
    .tracker-configuration-history-wrapper .actionBar {
        line-height: 23px;
    }

    .trackerHistoryAuditTrailPlugin .accordion-header:hover,
    .tracker-configuration-history-content .accordion-header:hover {
        background-color: #F5F5F5;
    }

    .trackerHistoryAuditTrailPlugin .accordion-header .modified-by-info,
    .tracker-configuration-history-content .accordion-header .modified-by-info,
    .tracker-configuration-history-wrapper .modified-by-info {
        color: #333;
        font-size: 11px;
        letter-spacing: normal;
        text-transform: none;
    }

    .tracker-configuration-history-wrapper .export-to-word {
        margin-left: 20px !important;
    }

    .tracker-configuration-history-wrapper .export-to-word img {
        position: relative;
        top: 3px;
        margin-right: 3px;
    }

    .tracker-configuration-history-content .ditch-tab-pane-wrap:before {
        background-color: #f5f5f5;
        content: '';
        display: block;
        height: 15px;
        margin-bottom: 15px;
    }

    .tracker-configuration-history-content .tracker-history-action-bar {
        background-color: #f5f5f5;
        border-bottom: 1px solid #ababab;
        margin: -30px -15px 20px -15px;
        padding: 12px 15px;
    }

    .tracker-configuration-history-content .tracker-history-entries {
        margin-bottom: 25px;
        width: 100%;
    }
    .tracker-configuration-history-content .tracker-history-entries thead tr {
        border-bottom: 1px solid #d1d1d1;
    }
    .tracker-configuration-history-content .tracker-history-entries th {
        background-color: transparent !important;
        color: #666 !important;
        text-align: left;
    }
    .tracker-configuration-history-content .tracker-history-entries .user-photo {
        margin-right: 5px;
    }
    .tracker-configuration-history-content .tracker-history-entries td.user-photo-cell {
        min-width: 150px;
        padding-left: 0 !important;
        vertical-align: top;
    }
    .tracker-configuration-history-content .tracker-history-entries td.user-photo-cell > * {
        float: left;
    }
    .tracker-configuration-history-content .tracker-history-entries .baseline-label-wrapper {
        line-height: 32px;
        margin-left: 20px;
    }
    .tracker-configuration-history-content .tracker-history-entries td.revert {
        padding-left: 0 !important;
        vertical-align: top;
        text-align: center;
    }
    .tracker-configuration-history-content .tracker-history-entries td {
        padding: 10px 5px !important;
    }
    .tracker-configuration-history-content .tracker-history-entries tr:not(:first-child) {
        border-top: 1px solid #f5f5f5;
    }
    .tracker-configuration-history-content .tracker-history-entries .baseline-row {
        background: #fff7eb;
    }
    .tracker-configuration-history-content .tracker-history-entries .info-image {
		margin-right: 5px;
		position: relative;
		top: 4px;
    }
    .tracker-configuration-history-content .tracker-history-entries .list {
        line-height: 20px;
    }
    .tracker-configuration-history-content .tracker-history-entries .inherited-change {
        color: #666;
        text-transform: uppercase;
    }

    #tracker-customize-history .warning, #tracker-customize-history .information {
        margin-top: 10px;
        padding-bottom: 5px;
        padding-top: 15px;
    }
</style>

<c:if test="${isExportMode}">
    <c:set var="baselineRowStyle" value=' style="background-color: #fff7eb;"' scope="request" />
    <c:set var="displayNoneStyle" value=' style="display: none;"' scope="request" />
    <c:set var="tableStyle" value=' cellpadding="5" border="1" style="border-collapse: collapse; border: 1px solid #ccc; width: 100%"' scope="request" />
</c:if>

<jsp:include page="audit-baseline-info.jsp"></jsp:include>

<c:if test="${not empty permissionIsMissingMessage}">
    <div class="warning">${ui:sanitizeHtml(permissionIsMissingMessage)}</div>
</c:if>

<c:if test="${empty permissionIsMissingMessage and empty data}">
    <div class="information"><spring:message code="table.nothing.found" text="No data to display." /></div>
</c:if>

<c:if test="${not empty data}">
	<div class="${param.isTrackerConfigurationPage eq 'true' ? 'tracker-configuration-history-wrapper' : 'accordion'} plugin-${pluginId}">
		<c:forEach var="mapEntry" items="${data}">
		    <c:set var="mapEntry" value="${mapEntry}" scope="request" />

		    <c:if test="${not isExportMode}">
		        <h3 class="tracker-history-header accordion-header${param.isTrackerConfigurationPage eq 'true' ? ' actionBar' : ''}">
					<spring:escapeBody><c:out value="${mapEntry.key.name}" escapeXml="true" /></spring:escapeBody> <spring:message code="tracker.label" text="Tracker"/>
			        <c:if test="${not mapEntry.key.visible}"><span class="hidden-info" title="Tracker is currently hidden">(Hidden)</span></c:if>
			        <span class="modified-by-info"><spring:message code="tracker.configuration.history.plugin.modified.by.label" text="modified by" /> ${mapEntry.value.latestChange.user.name} at <b><tag:formatDate value="${mapEntry.value.latestChange.date}" /></b></span>
	                <c:if test="${param.isTrackerConfigurationPage eq 'true'}">
	                    <c:url var="exportUrl" value="/proj/tracker/exportHistoryToWord.spr">
	                        <c:param name="trackerId">${mapEntry.key.id}</c:param>
	                        <c:if test="${not empty param.revision}">
	                            <c:param name="revision">${param.revision}</c:param>
	                        </c:if>
	                    </c:url>
	                    <a class="export-to-word" href="${exportUrl}"><img src="${pageContext.request.contextPath}/images/newskin/action/icon_word.png" /><spring:message code="wiki.export.to.word.label" /></a>
	                </c:if>
			    </h3>
			    <div class="accordion-content tracker-configuration-history-content">
					<tab:tabContainer id="tracker-configuration-history-${mapEntry.key.id}" skin="cb-box" selectedTabPaneId="tracker-changes-${mapEntry.key.id}" jsTabListener="codebeamer.trackerConfigurationHistoryView.trackerConfigurationTabChanged">
					    <spring:message var="trackerChangesLabel" code="tracker.configuration.history.plugin.tracker.changes.label" text="Tracker changes"/>
					    <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(trackerChangesLabel, fn:length(mapEntry.value.trackerChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
					    <tab:tabPane id="tracker-changes-${mapEntry.key.id}" tabTitle="${tabTitle}">
	                        <jsp:include page="general-changes-tab.jsp"></jsp:include>
					    </tab:tabPane>

					    <c:if test="${fn:length(mapEntry.value.fieldChanges) gt 0}">
					        <spring:message var="fieldChangesLabel" code="tracker.configuration.history.plugin.field.changes.label" text="Field changes"/>
					        <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(fieldChangesLabel, fn:length(mapEntry.value.fieldChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
				            <tab:tabPane id="field-changes-${mapEntry.key.id}" tabTitle="${tabTitle}">
		                        <jsp:include page="field-changes-tab.jsp"></jsp:include>
				            </tab:tabPane>
					    </c:if>
					    <c:if test="${fn:length(mapEntry.value.workflowChanges) gt 0}">
				            <spring:message var="workflowChangesLabel" code="tracker.configuration.history.plugin.workflow.changes.label" text="Workflow changes"/>
					        <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(workflowChangesLabel, fn:length(mapEntry.value.workflowChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
				            <tab:tabPane id="workflow-changes-${mapEntry.key.id}" tabTitle="${tabTitle}">
		                        <jsp:include page="workflow-changes-tab.jsp"></jsp:include>
				            </tab:tabPane>
				        </c:if>
						<c:if test="${fn:length(mapEntry.value.transitionDiagramsData) gt 0}">
						    <c:set var="trackerId" value="${mapEntry.key.id}" scope="request"/>
						    <c:set var="diagramEntries" value="${mapEntry.value.transitionDiagramsData}" scope="request"/>

						    <spring:message var="transitionDiagramsLabel" code="tracker.configuration.history.plugin.transition.diagrams.label" text="Transition diagrams"/>
						    <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(transitionDiagramsLabel, fn:length(mapEntry.value.transitionDiagramsData))}</c:set>

						    <tab:tabPane id="transition-diagrams-${mapEntry.key.id}" tabTitle="${tabTitle}" >
								<jsp:include page="transition-diagrams-tab.jsp"></jsp:include>
						    </tab:tabPane>
						</c:if>
						<c:if test="${fn:length(mapEntry.value.events) gt 0}">
							<spring:message var="tabLabel" code="tracker.configuration.history.plugin.tracker.related.changes.label" text="General Audit Trail" />
							<tab:tabPane id="tracker-related-${mapEntry.key.id}" tabTitle="${tabLabel}">
								<jsp:include page="tracker-related-changes-tab.jsp"></jsp:include>
							</tab:tabPane>
						</c:if>
						<c:if test="${fn:length(mapEntry.value.permissions) gt 0}">
		                    <spring:message var="tabLabel" code="permissions.label" text="Permissions" />
		                    <tab:tabPane id="permissions-${mapEntry.key.id}" tabTitle="${tabLabel}">
		                        <jsp:include page="permissions-tab.jsp"></jsp:include>
		                    </tab:tabPane>
		                </c:if>

						<c:set var="showPermissionChanges" value="${param.isTrackerConfigurationPage == 'true' and not isExportMode and not empty mapEntry.value.permissionEntries}"/>
						<c:if test="${showPermissionChanges }">
			                <spring:message var="tabLabel" code="tracker.configuration.history.plugin.permission.changes.label" text="Permission changes" />
		                    <tab:tabPane id="permission-changes-${mapEntry.key.id}" tabTitle="${tabLabel}">
		                        <jsp:include page="permission-changes-tab.jsp"></jsp:include>
		                    </tab:tabPane>
	                    </c:if>

					</tab:tabContainer>
				</div>
		    </c:if>
		    <c:if test="${isExportMode}">
		        <h3>
		            ${mapEntry.key.name} <spring:message code="tracker.label" text="Tracker"/>
		            <c:if test="${not mapEntry.key.visible}"><span title="Tracker is currently hidden">(Hidden)</span></c:if>
		            <span><spring:message code="tracker.configuration.history.plugin.modified.by.label" text="modified by" /> ${mapEntry.value.latestChange.user.name} at <b><tag:formatDate value="${mapEntry.value.latestChange.date}" /></b></span>
		        </h3>

		        <spring:message var="trackerChangesLabel" code="tracker.configuration.history.plugin.tracker.changes.label" text="Tracker changes"/>
		        <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(trackerChangesLabel, fn:length(mapEntry.value.trackerChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
		        <jsp:include page="general-changes-tab.jsp"></jsp:include>

		        <c:if test="${fn:length(mapEntry.value.fieldChanges) gt 0}">
		            <spring:message var="fieldChangesLabel" code="tracker.configuration.history.plugin.field.changes.label" text="Field changes"/>
		            <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(fieldChangesLabel, fn:length(mapEntry.value.fieldChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
		            <jsp:include page="field-changes-tab.jsp"></jsp:include>
		        </c:if>
		        <c:if test="${fn:length(mapEntry.value.workflowChanges) gt 0}">
		            <spring:message var="workflowChangesLabel" code="tracker.configuration.history.plugin.workflow.changes.label" text="Workflow changes"/>
		            <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(workflowChangesLabel, fn:length(mapEntry.value.workflowChanges) - fn:length(mapEntry.value.baselineEntries))}</c:set>
		            <jsp:include page="workflow-changes-tab.jsp"></jsp:include>
		        </c:if>
		        <c:if test="${fn:length(mapEntry.value.transitionDiagramsData) gt 0}">
		            <c:set var="trackerId" value="${mapEntry.key.id}" scope="request"/>
		            <c:set var="diagramEntries" value="${mapEntry.value.transitionDiagramsData}" scope="request"/>

		            <spring:message var="transitionDiagramsLabel" code="tracker.configuration.history.plugin.transition.diagrams.label" text="Transition diagrams"/>
		            <c:set var="tabTitle" scope="request">${ui:getTabLabelWithCount(transitionDiagramsLabel, fn:length(mapEntry.value.transitionDiagramsData))}</c:set>

		            <jsp:include page="transition-diagrams-tab.jsp"></jsp:include>
		        </c:if>
				<c:if test="${fn:length(mapEntry.value.events) gt 0}">
					<c:set var="tabTitle" scope="request"><spring:message code="tracker.configuration.history.plugin.tracker.related.changes.label" text="General Audit Trail" /></c:set>
					<jsp:include page="tracker-related-changes-tab.jsp"></jsp:include>
				</c:if>
		        <c:if test="${fn:length(mapEntry.value.permissions) gt 0}">
		            <c:set var="tabTitle" scope="request"><spring:message code="permissions.label" text="Permissions" /></c:set>
		            <jsp:include page="permissions-tab.jsp"></jsp:include>
		        </c:if>
		    </c:if>
		</c:forEach>
	</div>
	<c:if test="${not isExportMode}">
		<script type="text/javascript">
	    	var codebeamer = codebeamer || {};

	    	codebeamer.trackerConfigurationHistoryView = (function($) {
		        function trackerConfigurationTabChanged(evt) {
		        	if (evt.getTab().id.startsWith('transition-diagrams')) {
		        		var $firstDiagramHeader = $(evt.getTabPane()).find('.accordion-header.transition-diagram-header').first(),
		        		    $diagramsAccordion = $(evt.getTabPane()).find('.accordion');
		        		// if there aren't any opened transition diagrams then open the first
		        		if (!$diagramsAccordion.cbMultiAccordion('hasOpened')) {
		        		    $firstDiagramHeader.click();
		        		}
		        	}
		        }

		        function transitionDiagramOpened($header) {
		            setTimeout(function() {
		                // just to make sure the accordion is opened when this click handler executes...
		                if ($header.hasClass('opened') && !$header.hasClass('loaded')) {
		                    var busy = ajaxBusyIndicator.showProcessingPage();
		                    $.ajax(contextPath + '/ajax/mxGraph/renderGraph.spr', {
		                        type: 'GET',
		                        data: {
		                            trackerId: $header.attr('data-tracker-id'),
		                            revision: $header.attr('data-revision')
		                        }
		                    }).done(function(result) {
		                        $header.next().append(result);
		                        $header.addClass('loaded');
		                    }).always(function() {
		                        ajaxBusyIndicator.close(busy);
		                    });
		                }
		            })
		        }

			    $(function() {
			        $('.trackerHistoryAuditTrailPlugin > .accordion.plugin-${pluginId}').cbMultiAccordion();
			        $('.plugin-${pluginId} .transition-diagrams-accordion').cbMultiAccordion({
			            active: -1
			        });

			        $('.plugin-${pluginId} .transition-diagram-header').on('click', function() {
			        	transitionDiagramOpened($(this));
			        });
			    });

			    return {
			    	trackerConfigurationTabChanged: trackerConfigurationTabChanged
			    }
	    	}(jQuery));
		</script>
	</c:if>
</c:if>