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
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="taglib" prefix="tag" %>

<c:url var="selectedTickUrl" value="/images/blackTick.png"/>

<style type="text/css">
	.paletteContainer {
		display: block;
		width: 100%;
	}

	.paletteContainer .color {
		display: inline-block;
		width: 18px;
		height: 18px;
		margin-left: 2px;
		cursor: pointer;
	}

	.paletteContainer .color.selected {
		background-image: url("${selectedTickUrl}");
		background-repeat: no-repeat;
		background-position: center;
	}

	.riskMatrixColorConfig {
		width: 100%;
	}

	.riskMatrixColorConfig .colorSelector {
		width: 300px;
		vertical-align: top;
		padding-right: 2em;
	}

	.stepLabel {
		padding: 1em 0;
	}

	<c:if test="${canAdminTracker}">
	#riskMatrixDiagram table .field {
		cursor: pointer;
	}
	</c:if>

	.riskMatrixParameters a {
		display: inline-block;
		margin-right: 1em;
		margin-bottom: 1em;
	}

	#riskMatrixResetToDefault {
		margin-top: 1em;
		display: inline-block;
	}

</style>

<form id="riskMatrixConfigForm" action="${configurationUrl}" method="post">
	<ui:actionBar>
		<c:if test="${canAdminTracker}">
			<spring:message var="saveButton" code="button.save" text="Save"/>
			<input type="button" class="button" name="save" value="${saveButton}"/>
		</c:if>

		<spring:message var="cancelButton" code="button.cancel" text="Cancel"/>
		<input type="submit" class="cancelButton" name="_cancel" value="${cancelButton}"/>

		<div class="rightAlignedDescription">
			<spring:message code="tracker.riskManagement.config.tooltip" text="You can configure Risk management related settings." />
		</div>
	</ui:actionBar>

	<h2><spring:message code="tracker.riskManagement.config.risk.matrix.parameters" text="Risk Matrix Diagram parameters"/></h2>

	<div class="riskMatrixParameters">
		<a href="#" id="riskMatrixLikelihoodConfig"><spring:message code="tracker.field.${likelihoodLabel}.label" text="${likelihoodLabel}" htmlEscape="true"/></a>
		<a href="#" id="riskMatrixSeverityConfig"><spring:message code="tracker.field.${severityLabel}.label" text="${severityLabel}" htmlEscape="true"/></a>
	</div>

	<input type="checkbox" id="reverseAxis"<c:if test="${reverseAxis}"> checked="checked"</c:if>/><label for="reverseAxis"><spring:message code="tracker.riskManagement.config.reverse.axis"/></label>

	<h2><spring:message code="tracker.riskManagement.config.risk.matrix.colors" text="Risk Matrix Diagram colors" /></h2>

	<table class="riskMatrixColorConfig">
		<tr>
			<c:if test="${canAdminTracker}">
			<td class="colorSelector">
				<div class="stepLabel">
					<spring:message code="tracker.riskManagement.config.risk.matrix.colors.step1" />
				</div>
				<div class="paletteContainer">
					<c:forEach items="${palette}" var="color">
						<div class="color" data-bg-color="${color.key}" data-fg-color="${color.value}" style="background-color: ${color.key}"></div>
					</c:forEach>
				</div>
				<a id="riskMatrixResetToDefault" href="#"><spring:message code="tracker.riskManagement.config.reset.to.default" text="Reset colors to default"/></a>
			</td>
			</c:if>
			<td class="riskMatrixDiagramContainer">
				<div id="riskMatrixDiagram">
					<c:if test="${canAdminTracker}">
					<div class="stepLabel">
						<spring:message code="tracker.riskManagement.config.risk.matrix.colors.step2" />
					</div>
					</c:if>
					<tag:transformText value="${riskMatrixMarkup}" format="W"/>
				</div>
			</td>
		</tr>
	</table>

</form>

<script type="text/javascript">
	(function($) {

		$(function () {

			<c:if test="${canAdminTracker}">

			var currentBgColor = null;
			var currentFgColor = null;

			var collectColorData = function(diagram) {
				var colorData = [];
				diagram.find(".field").each(function() {
					var field = $(this);
					var bgColor = field.attr("data-bg-color");
					if (field.attr("data-bg-color-by-default") != bgColor) {
						colorData.push({
							"likelihood" : field.attr('data-likelihood-value'),
							"severity": field.attr('data-severity-value'),
							"backgroundColor": bgColor,
							"color": field.attr("data-fg-color")
						});
					}
				});
				return colorData;
			};

			var submitColorData = function(colorData, successCallback) {
				var busy = ajaxBusyIndicator.showBusyPage();
				var isReverseAxis = $("#reverseAxis").is(":checked") ? "true" : "false";
				$.ajax("<c:url value="${riskMatrixConfigSubmitUrl}" />&reverse_axis=" + isReverseAxis, {
					type: "POST",
					data: JSON.stringify(colorData),
					contentType : 'application/json',
					dataType 	: 'json'
				}).done(function() {
					ajaxBusyIndicator.close(busy);
					showOverlayMessage(i18n.message("ajax.changes.successfully.saved"));
					successCallback();
					// reload page
					$("#saveTrackerFieldsSubmitButton").click();
				}).fail(function(jqXHR, textStatus, errorThrown) {
					ajaxBusyIndicator.close(busy);
					try {
						var exception = eval('(' + jqXHR.responseText + ')');
						alert(exception.message);
					} catch(err) {
						alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					}
				});
			};

			var paletteCont = $(".paletteContainer");
			var colorDivs = paletteCont.find(".color");
			paletteCont.on("click", ".color", function() {
				colorDivs.removeClass("selected");
				$(this).addClass("selected");
				currentBgColor = $(this).attr("data-bg-color");
				currentFgColor = $(this).attr("data-fg-color");
			});
			colorDivs.first().click();

			var diagram = $('#riskMatrixDiagram');
			diagram.find("table").on("click", ".field", function() {
				var fieldBgColor = $(this).attr("data-bg-color");
				if (fieldBgColor != currentBgColor) {
					$(this).css("background-color", currentBgColor);
					$(this).attr("data-bg-color", currentBgColor);
					$(this).css("color", currentFgColor);
					$(this).attr("data-fg-color", currentFgColor);
				}
			});

			var form = $('#riskMatrixConfigForm');
			form.find('input[name="save"]').click(function(e) {
				e.preventDefault();
				submitColorData(collectColorData(diagram), function() {});
			});
			$('#riskMatrixResetToDefault').click(function(e) {
				e.preventDefault();
				showFancyConfirmDialogWithCallbacks(i18n.message("tracker.riskManagement.config.reset.to.default.confirm"), function() {
					submitColorData([], function() {
						diagram.find(".field").each(function() {
							var originalBgColor = $(this).attr("data-bg-color-by-default");
							var originalFgColor = "black";
							$(this).css("background-color", originalBgColor);
							$(this).attr("data-bg-color", originalBgColor);
							$(this).css("color", originalFgColor);
							$(this).attr("data-fg-color", originalFgColor);
						});
					});
				});
			});

			</c:if>

			var triggerFieldSettings = function(fieldId) {
				$("#field_" + fieldId).find("> tr > td.layoutAndContent.textData > a").trigger("clickWithAutoSave");
			};

			$("#riskMatrixLikelihoodConfig").click(function(e) {
				e.preventDefault();
				triggerFieldSettings(${likelihoodFieldId});
			});
			$("#riskMatrixSeverityConfig").click(function(e) {
				e.preventDefault();
				triggerFieldSettings(${severityFieldId});
			});

		});
	})(jQuery);
</script>
