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
<meta name="decorator" content="popup"/>
<meta name="module" content="cmdb"/>
<meta name="moduleCSSClass" content="newskin CMDBModule"/>

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>

<style type="text/css">
	#presetTable .name {
		font-weight: bold;
		padding: 0.3em;
		border-bottom: 1px solid #a9a9a9;
	}
	#presetTable .name a {
		font-size: 14px;
	}
	#presetTable .selection ul {
		list-style-type: none;
		padding: 0;
		margin: 0;
	}
	#presetTable .selection ul li {
		display: inline-block;
		padding: 0 1em 0 0;
	}
	#presetTable .selection ul li .icon {
		position: relative;
    	top: 2px;
    	display: inline-block;
    	height: 16px;
	}
	#presetTable .deletePreset {
		float: right;
		display: block;
		width: 12px;
		height: 12px;
		cursor: pointer;
		background: url("${contextPath}/images/newskin/action/delete-grey-12x12.png") no-repeat center center;
	}
	#presetTable .arrow {
		display: inline-block;
		color: #a9a9a9;
		font-size: 16px;
		padding: 0 0.3em;
		position: relative;
		top: -3px;
		font-family: monospace;
	}
	.presetAttrs {
		margin-top: 0.5em;
	}
	.presetAttrs td {
		padding: 0.3em !important;
	}
	.presetAttrs td.label {
		font-weight: bold;
		padding: 0.5em !important;
		width: 150px;
	}
</style>

<ui:actionMenuBar>
	<spring:message code="tracker.traceability.browser.manage.presets.title" text="Load/Manage Traceability Browser presets"/>
</ui:actionMenuBar>

<div class="contentWithMargins">
	<c:choose>
		<c:when test="${empty settings}">
			<spring:message code="tracker.traceability.browser.no.preset" text="No presets saved yet."/>
		</c:when>
		<c:otherwise>
			<table id="presetTable" class="displaytag">
				<c:forEach var="setting" items="${settings}">
					<tr class="odd">
						<td class="textDataWrap">
							<div class="name"><a class="loadPreset" href="#" data-url="${setting.urlParams}"><c:out value='${setting.name}'/></a><span class="deletePreset" data-name="<c:out value='${setting.name}'/>"></span></div>
							<div class="selection">
								<table class="presetAttrs">
									<tr>
										<td class="label">
											<c:choose>
												<c:when test="${not empty setting.initialCbQL}">
													<spring:message code="tracker.traceability.browser.initial.filter"/>
												</c:when>
												<c:otherwise>
													<spring:message code="tracker.traceability.browser.initial.trackers"/>
												</c:otherwise>
											</c:choose>
										</td>
										<td>
											<c:choose>
												<c:when test="${not empty setting.initialCbQL}">
													${setting.decodedInitialCbQL}
												</c:when>
												<c:otherwise>
													<ul class="paramList">
														<c:forEach items="${setting.initialTrackerParams}" var="initialParam">
															<li>
																<span class="icon"><img src="${contextPath}${initialParam.iconUrl}" style="background-color: #5f5f5f"></span>
																<span class="paramName">${initialParam.label}</span>
															</li>
														</c:forEach>
													</ul>
												</c:otherwise>
											</c:choose>
										</td>
									</tr>
									<c:set var="level" value="1"/>
									<c:forEach items="${setting.trackerParams}" var="levelEntities">
										<tr>
											<td class="label"><spring:message code="tracker.traceability.browser.level" /> ${level}</td>
											<td>
												<ul class="paramList">
													<c:forEach items="${levelEntities}" var="trackerParam">
														<li>
															<span class="icon"><c:if test="${!trackerParam.isAll()}"><img src="${contextPath}${trackerParam.iconUrl}" style="background-color: #5f5f5f"></c:if></span>
															<span class="paramName">${trackerParam.label}</span>
														</li>
													</c:forEach>
												</ul>
											</td>
										</tr>
										<c:set var="level" value="${level + 1}" />
									</c:forEach>
								</table>
							</div>
						</td>
					</tr>
				</c:forEach>
			</table>
		</c:otherwise>
	</c:choose>
</div>

<c:if test="${not empty settings}">
	<script type="text/javascript">
		$(function() {
			$('#presetTable').on("click", ".loadPreset", function(e) {
				e.preventDefault();
				var urlParams = $(this).data("url");
				var revision = '';
				<c:if test="${not empty revisionId}">
					revision = "&revision=${revisionId}";
				</c:if>
				window.top.location.href = '${browserUrl}' + urlParams + revision;
			});

			$('#presetTable').on("click", ".deletePreset", function(e) {
				e.preventDefault();
				var name = $(this).data("name");
				showFancyConfirmDialogWithCallbacks(i18n.message("tracker.traceability.browser.delete.preset.confirm"), function() {
					var busyDialog = ajaxBusyIndicator.showBusyPage();
					$.ajax('${deletePresetUrl}', {
						type: 'POST',
						data: {
							"proj_id" : ${projectId},
							"name" : name
						}
					}).success(function (data) {
						var dataJson = $.parseJSON(data);
						if (dataJson.hasOwnProperty("success") && dataJson.success) {
							window.location.reload();
						} else {
							showFancyAlertDialog(i18n.message("tracker.traceability.browser.cannot.delete.preset"));
							ajaxBusyIndicator.close(busyDialog);
						}
					}).fail(function (o) {
						showFancyAlertDialog(i18n.message("tracker.traceability.browser.cannot.delete.preset"));
						ajaxBusyIndicator.close(busyDialog);
					});
				});
			});
		});
	</script>
</c:if>


