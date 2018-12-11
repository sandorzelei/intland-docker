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

<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
	.system-monitoring-chart-synchronizer {
		height: 100%;
		width: 100%;
		display: flex;
		flex-wrap: wrap;
		justify-content: space-between;
	}

	.system-monitoring-chart {
		flex: 0 50%;
	}

	.system-monitoring-chart-synchronizer-control {
		display: flex;
		align-items: center;
		margin-top: 10px;
	}

	.system-monitoring-chart-synchronizer-control label {
		height: 16px;
	}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		$(".system-monitoring-chart").on("selection:change", function(event, min, max) {
			if ($("input[name=synchronize]").is(":checked")) {
				$(".system-monitoring-chart-synchronizer").css({
					"cursor":  "wait"
				});

				// Break from the callback to properly display cursor
				setTimeout(function() {
					$(".system-monitoring-chart").each(function(index, element) {
						var $element = $(element);


						if (event.currentTarget !== element) {
							$(element).trigger("selection:update", [min, max]);
						}

					});

					$(".system-monitoring-chart-synchronizer").css({
						"cursor":  "auto"
					});

				}, 10);
			}
		});
	});
</script>

<div class="system-monitoring-chart-synchronizer-control">
	<input type="checkbox" id="synchronize" name="synchronize" checked />
	<label for="synchronize"><spring:message code="sysadmin.dashboard.monitoring.chart.synchronize"></spring:message></label>
</div>


<div class="system-monitoring-chart-synchronizer">
	<jsp:doBody></jsp:doBody>
</div>