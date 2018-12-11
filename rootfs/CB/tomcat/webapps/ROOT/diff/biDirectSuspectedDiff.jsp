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

<%--
 shows the biDirectional differences in those cases where the two ends of the reference are of different types. in these
 cases there is no merge tab, only two diffs.
--%>
<%@ taglib uri="http://ditchnet.org/jsp-tabs-taglib" prefix="tab" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<spring:message code="diffTool.diff.label" var="diffLabel" text="Diff"/>
<spring:message code="diffTool.downstream.diff.label" var="downstreamDiffLabel" text="Diff"/>

<ui:actionMenuBar>
    <jsp:body>
        <ui:breadcrumbs showProjects="false" projectAware="${copy}"><span class='breadcrumbs-separator'>&raquo;</span>
            <span><spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" /></span>
            <ui:pageTitle prefixWithIdentifiableName="false" printBody="false" >
                <spring:message code="diffTool.pageTitle" text="Differences" arguments="${copy.name},${original.name}" htmlEscape="true" />
            </ui:pageTitle>
        </ui:breadcrumbs>
    </jsp:body>
</ui:actionMenuBar>

<tab:tabContainer id="diff-tabs" skin="cb-box" jsTabListener="tabChangeListener" selectedTabPaneId="diff-tab">
    <tab:tabPane id="diff-tab" tabTitle="${diffLabel }">

        <div id="suspected-diff-container-0" class="initialized">
            <jsp:include page="diff.jsp?noActionMenuBar=true"></jsp:include>
        </div>
    </tab:tabPane>

    <tab:tabPane id="downstream-diff-tab" tabTitle="${downstreamDiffLabel }">

        <div id="suspected-diff-container-1">

        </div>
    </tab:tabPane>

</tab:tabContainer>

<script type="text/javascript">

    function tabChangeListener(event) {
        var $container = $("#suspected-diff-container-" + event._selectedIndex);
        if (event._selectedIndex == 1  && !$container.is('.initialized')) {
            var url = "/ajax/issuediff/diffSuspected.spr";
            var parameters = {
                'association_id': '${associationId}',
                'is_reference': '${isReference}',
                'issue_id': ${associationTaskId},
                'association_task_id': ${taskId},
                'noActionMenuBar': true,
                'showOmittedFields': true,
                'revision': '${revision}'
            };

            var busyPage = ajaxBusyIndicator.showBusyPage();
            $.get(contextPath + url, parameters).done(function (data) {
                $container.html(data);
                $container.addClass('initialized');
            }).always(function () {
                if (busyPage) {
                    busyPage.remove();
                }
            });
        }
    }
</script>