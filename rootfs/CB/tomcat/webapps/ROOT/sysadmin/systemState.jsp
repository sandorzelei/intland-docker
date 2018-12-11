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
<meta name="decorator" content="main" />
<meta name="module" content="sysadmin" />
<meta name="moduleCSSClass" content="sysadminModule newskin" />

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="uitaglib" prefix="ui"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<script src="<ui:urlversioned value='/js/highcharts/modules/solid-gauge.js'/>"></script>

<style type="text/css">
	.sysinfo-container{
		margin: 10px;
	}

	.versionHeader {
		font-size: 14px;
	}

	.second-column {
		padding-left: 10px;
	}

	.filesTable {
		width: 90% !important;
	}

	.filesTable th {
		text-align: left;
	}

	.logsTable {
		width: auto !important;
	}

	.logsTable th {
		text-align: left;
	}

	.number-column {
		text-align: right !important;
		padding-right: 0px !important;
	}

	#fileList td, .logsTable td {
		padding: 0 20px 0 0 !important;
		white-space: nowrap;
		font-family: monospace;
		font-size: 12px !important;
	}

	.codebeamerStatistics .summary {
		margin-top: 10px;
	}

	.loaderImage {
		width: 13px;
	}
</style>

<ui:actionMenuBar>
	<ui:pageTitle>
		<spring:message code="sysadmin.state" text="System State" />
	</ui:pageTitle>
</ui:actionMenuBar>

<ui:actionBar>

	<c:url var="cancelUrl" value="/sysadmin.do" />
	<c:url var="exportUrl" value="/sysadmin/download/cb-info.spr" />


	<spring:message var="exportButton" code="project.export.menu.label" text="Export" />
	<input type="button" class="button"	onclick="location.href = '${exportUrl}'" value="${exportButton}">

	<spring:message code="button.cancel" text="Cancel" var="cancelLabel" />
	<input type="button" class="button cancelButton" value="${cancelLabel}"	onclick="location.href = '${cancelUrl}';" />

</ui:actionBar>

<div class="sysinfo-container">

	<spring:message code="sysadmin.dashboard.monitoring" text="System Monitoring" var="systemMonitoringDashboardLabel" />
	<ui:collapsingBorder id="systemMonitoringPart" label="${systemMonitoringDashboardLabel}" open="true" cssClass="scrollable separatorLikeCollapsingBorder">
		<ui:systemMonitoringChartSynchronizer>
			<c:forEach var="systemMonitoringChartDto" items="${systemMonitoringChartDtos}" varStatus="loop">
				<ui:systemMonitoringChart containerId="system-monitoring-chart-${loop.index }" title="${systemMonitoringChartDto.title}"
					values="${systemMonitoringChartDto.data}" systemStartupTimestamps="${systemStartupTimestamps}"></ui:systemMonitoringChart>
			</c:forEach>
		</ui:systemMonitoringChartSynchronizer>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.codebeamer.entities" text="Codebeamer Statistics" var="codebeamerStatisticsPartLabel" />
	<ui:collapsingBorder id="codebeamerStatisticsPart" label="${codebeamerStatisticsPartLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder" onChange="onCodebeamerStatisticsToggle">
		<div class="codebeamerStatistics">
			<img class="loaderImage" src="<ui:urlversioned value='/js/yui/assets/skins/sam/ajax-loader.gif'/>"}" />
		</div>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.info" text="System Informations" var="systemInfoLabel" />
	<ui:collapsingBorder id="systemInformationPart" label="${systemInfoLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder">
		<h4 class="versionHeader">codeBeamer <c:out value="${versionName}"></c:out></h4>

		<table class="summary">
			<c:forEach items="${systemInformation}" var="entry">
				<c:if test="${not empty entry.value}">
					<tr>
						<td><b><spring:message code="${entry.key}"/>:</b></td>
						<td class="second-column">${entry.value}</td>
					</tr>
				</c:if>
			</c:forEach>
		</table>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.java.memory" text="Java Memory Dashboard" var="javaMemoryLabel" />
	<ui:collapsingBorder id="javaMemoryChartPart" label="${javaMemoryLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder">
		<c:forEach var="javamemoryModel" items="${javamemoryModels}" varStatus="loop">
			<div id="container-jvm-${loop.index}" style="width: 300px; height: 200px; float: left"></div>
		</c:forEach>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.cmd.args" text="JVM Command Line Arguments" var="commandLineArgsLabel" />
	<ui:collapsingBorder id="commandLineArgstPart" label="${commandLineArgsLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder">
		<pre class="wiki"><c:out value="${jvmArguments}"></c:out></pre>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.system.props" text="JVM system properties" var="jvmPropertiesLabel" />
	<ui:collapsingBorder id="systemPropsPart" label="${jvmPropertiesLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder">
		<table class="summary">
			<c:forEach items="${systemProperties}" var="entry">
				<c:if test="${not empty entry.value}">
					<tr>
						<td><b><spring:message code="${entry.key}"/>:</b></td>
						<td class="second-column">${entry.value}</td>
					</tr>
				</c:if>
			</c:forEach>
		</table>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.log.list" text="Log List" var="logListLabel" />
	<ui:collapsingBorder id="logListLabel" label="${logListLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder">
		<table class="displaytag logsTable">
			<thead>
				<tr>
					<th class="columnSeparator"><spring:message code="sysadmin.dashboard.file.name" text="File Name"/></th>
					<th class="columnSeparator"><spring:message code="sysadmin.dashboard.file.modified" text="Last Modifiede"/></th>
					<th class="columnSeparator number-column"><spring:message code="document.fileSize.label" text="Size"/></th>
				</tr>
			</thead>
			<tbody>
				<c:forEach items="${logFiles}" var="entry" varStatus="loop">
					<c:if test="${loop.index < 10}">
						<tr>
							<td>${entry.name}</td>
							<td>${entry.lastModified}</td>
							<td class="number-column">${entry.sizeFormatted}</td>
						</tr>
					</c:if>
					<c:if test="${loop.index == 10}">
						<tr>
							<td><spring:message code="paging.items.banner" text="{1} found, displaying {2} to {3}." arguments="0,${fn:length(logFiles)},1,10" argumentSeparator=","/></td>
						</tr>
					</c:if>
				</c:forEach>
			</tbody>
		</table>
	</ui:collapsingBorder>

	<spring:message code="sysadmin.dashboard.file.list" text="File List" var="fileListLabel" />
	<ui:collapsingBorder id="fileSystem" label="${fileListLabel}" open="false" cssClass="scrollable separatorLikeCollapsingBorder " onChange="onFilesListToggle">
		<table class="displaytag filesTable">
			<thead>
				<tr>
					<th class="columnSeparator"><spring:message code="sysadmin.dashboard.file.name" text="File Name"/></th>
					<th class="columnSeparator"><spring:message code="sysadmin.dashboard.file.modified" text="Last Modifiede"/></th>
					<th class="columnSeparator number-column"><spring:message code="sysadmin.dashboard.file.size" text="Size (bytes)"/></th>
					<th class="columnSeparator"><spring:message code="sysadmin.dashboard.file.hash" text="MD5 hash"/></th>
				</tr>
			</thead>
			<tbody id="fileList">
				<tr><td><spring:message code="ajax.loading" text="Loading..."/></td></tr>
			</tbody>
		</table>
	</ui:collapsingBorder>

</div>


<script type="text/javascript">

function onFilesListToggle() {

	if ($( "#fileList tr" ).length === 1){

		$.get( contextPath + "/sysadmin/fileInfos.spr", function( data ) {
			$( "#fileList" ).empty();
			var $html = $("<div>");
			$.each(data, function( index, value ) {
				var modified = new Date(value.lastModified);
				$html.append($('<tr>')
					.append($('<td>')
		                .text(value.name)
		            )
		            .append($('<td>')
		                .text($.datepicker.formatDate("MM dd, yy. ", modified) + pad(modified.getHours(),2)+":"+pad(modified.getMinutes(),2))
		            )
		            .append($('<td>')
		                .text(value.size).addClass("number-column")
		            )
		            .append($('<td>')
		                .text(value.md5)
		            )
				);
			});
			$( "#fileList" ).append($html.html());
		});
	}

}

function onCodebeamerStatisticsToggle() {
	if ($( ".codebeamerStatistics .loaderImage" ).length > 0){
		$.get(contextPath + "/sysadmin/codebeamerStatistics.spr", function(data) {
			$(".codebeamerStatistics").html(data);
		});
	}
}

function pad(n, width) {
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(0) + n;
}

$(function () {
	var gaugeOptions = {

        chart: {
            type: 'solidgauge'
        },

        credits: {
            enabled: false
        },

        title: null,

        pane: {
            center: ['50%', '85%'],
            size: '140%',
            startAngle: -90,
            endAngle: 90,
            background: {
                backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || '#EEE',
                innerRadius: '60%',
                outerRadius: '100%',
                shape: 'arc'
            }
        },

        tooltip: {
            enabled: false
        },

        // the value axis
        yAxis: {
            stops: [
                [0.1, '#3D998D'], // green
                [0.2, '#27C27C'], // green
                [0.5, '#FFAB46'], // yellow
                [0.9, '#CC3F44'] // red
            ],
            lineWidth: 0,
            minorTickInterval: null,
            tickPixelInterval: 400,
            tickWidth: 0,
            title: {
                y: -70
            },
            endOnTick:false,
            labels: {
                y: 16,
                format: "{value:,f}"
            }
        },

        plotOptions: {
            solidgauge: {
                dataLabels: {
                    y: 5,
                    borderWidth: 0,
                    useHTML: true
                }
            }
        }
    };

	<c:forEach var="javamemoryModel" items="${javamemoryModels}" varStatus="loop">
		// The gauge
	    $('#container-jvm-${loop.index}').highcharts(Highcharts.merge(gaugeOptions, {
	        yAxis: {
	            min: 0,
	            max: ${javamemoryModel.max},
	            tickPositions: [0, ${javamemoryModel.max}],
	            title: {
	                text: '${javamemoryModel.label}'
	            }
	        },

	        series: [{
	            name: '${javamemoryModel.unit}',
	            data: [${javamemoryModel.used}],
	            dataLabels: {
	                format: '<div style="text-align:center"><span style="font-size:25px;color:' +
	                    ((Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black') + '">{y}</span><br/>' +
	                       '<span style="font-size:12px;color:silver">${javamemoryModel.unit}</span></div>'
	            },
	            tooltip: {
	                valueSuffix: ' revolutions/min'
	            }
	        }]

	    }));
	</c:forEach>

});
</script>


