<%@ tag language="java" pageEncoding="ISO-8859-1"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%@ attribute name="containerId" required="true" rtexprvalue="true" description="Html element id, chart will appear there."%>
<%@ attribute name="values" required="true" rtexprvalue="true" description="Dtos to render as JSON."%>
<%@ attribute name="title" required="true" rtexprvalue="true" description="Chart title."%>
<%@ attribute name="systemStartupTimestamps" required="false" rtexprvalue="true" description="List of timestamps represeting the codebeamer startup events."%>
<%@ attribute name="cssClass" required="false" rtexprvalue="true" description="Additional css class added to the container element."%>
<%@ attribute name="widthModifier" required="false" rtexprvalue="true" description="Set the width of the chart; this variable is used to define the chart size through parent width / widthModifier calculation."%>

<link rel="stylesheet" href="<ui:urlversioned value="/stylesheet/systemMonitoringChart.css" />" type="text/css" media="all" />

<div id="${containerId}" class="system-monitoring-chart ${cssClass}" style="height: 400px;">
	<div data-purpose="detail-container"></div>
	<div data-purpose="master-container"></div>
</div>
<script type="text/javascript">

$(function () {
	const threeHoursInMillis = 3 * 3600000;

	var detailChart, series, systemStartupTimestamps, width, range, widthModifier, systemStartupPlotLines, $container, chart;

	systemStartupTimestamps = JSON.parse("${systemStartupTimestamps}");

	series = JSON.parse("${values}");

	widthModifier = ${empty widthModifier ? 2 : widthModifier};

	if (widthModifier > 0) {
		width = $("#${containerId}").parent().width() / widthModifier;
	} else {
		width = null;
	}

	range = series[0].data[series[0].data.length - 1].x - series[0].data[0].x;

	systemStartupPlotLines = [];
	if (systemStartupTimestamps && $.isArray(systemStartupTimestamps)) {
		$.each(systemStartupTimestamps, function(index, value) {
			if (value) {
				systemStartupPlotLines.push({
					id: "system-startup-plotline-" + index,
					width: 3,
					dashStyle: "dash",
					value: value,
					color: Highcharts.getOptions().colors[3],
					events: {
						mouseover: function (e) {
							var chart;

							chart = this.axis.chart;

							if (!chart.lbl) {
								chart.lbl = chart.renderer.label(i18n.message("sysadmin.dashboard.monitoring.chart.system.startup"), 50, 0)
									.attr({
										padding: 10,
										r: 10,
										fill: Highcharts.getOptions().colors[3],
									}).css({
										color: "#FFFFFF",
										"font-weight": "bold"
									}).add();
							}

							chart.lbl .show();

						},
						mouseout: function (e) {
							if (this.axis.chart.lbl) {
								this.axis.chart.lbl.hide();
							}
						}
					}
				});
			}
		});
	}

	function handleSelectionEvent(min, max, animate) {
		var detailData, xAxis;

		detailData = [],
		xAxis = this.xAxis[0];

		$.each(series, function(index, value) {
			detailData = [];

			// reverse engineer the last part of the data
			$.each(value.data, function () {
				if (this.x > min && this.x < max) {
					detailData.push({
						x: this.x,
						y: this.y,
						payload: this.payload,
						className: this.payload ? "pointer" : ""
					});
				}
			});

			// move the plot bands to reflect the new detail span
			xAxis.removePlotBand("mask-before");
			xAxis.addPlotBand({
				id: "mask-before",
				from: series[0].data[0].x,
				to: min,
				color: "rgba(239, 239, 239, 0.9)"
			});

			xAxis.removePlotBand("mask-after");
			xAxis.addPlotBand({
				id: "mask-after",
				from: max,
				to: series[0].data[series[0].data.length - 1].x,
				color: "rgba(239, 239, 239, 0.9)"
			});

			$.each(systemStartupPlotLines, function(index, value) {
				detailChart.xAxis[0].removePlotLine(value.id);
			});

			$.each(systemStartupPlotLines, function(index, value) {
				if (value.value > min) {
					detailChart.xAxis[0].addPlotLine(value);
				}
			});

			detailChart.series[index].setData(detailData, false);

		});

		detailChart.redraw(animate !== null && animate !== undefined ? animate : true);

		return false;
	}

	function gcTooltipFormatter() {
		var point, result;

		point = this;
		result = "";

		$.each(this.options.payload, function () {
			result += "<br/><span style='color:" + point.color + "'>\u25CF</span> " + point.series.name
				+ " (" + this.name + "): <b>" + this.value + "</b>";
		});

		return result;
	}

	// create the detail chart
	function createDetail(masterChart) {
		var detailSeries, detailPlotLines, enablePointerCursor, tooltip;

		// prepare the detail chart
		detailSeries = [];
		enablePointerCursor = false;

		$.each(series, function(index, value) {
			detailData = [];
			detailStart = series[0].data[0].x;

			// If range is greater than 4 hours, then only show the last 4 hours
			if (range > threeHoursInMillis) {
				detailStart = series[0].data[series[0].data.length - 1].x - threeHoursInMillis;
			}

			$.each(value.data, function () {
				var dataPoint;

				if (this.x >= detailStart) {
					dataPoint = {
						x: this.x,
						y: this.y,
						payload: this.payload
					};

					if (dataPoint.hasOwnProperty("payload") && dataPoint.payload && dataPoint.payload.hasOwnProperty("requestId") && dataPoint.payload.requestId) {
						enablePointerCursor = true;
					}

					detailData.push(dataPoint);
				}
			});

			if (value.hasOwnProperty("tooltip")) {
				tooltip = value.tooltip;
				if (tooltip.hasOwnProperty("formatter") && tooltip.formatter === "gcTooltipFormatter") {
					tooltip.pointFormatter = gcTooltipFormatter;
				}
				detailSeries.push({
					name: value.name,
					data: detailData,
					tooltip: tooltip
				});
			} else {
				detailSeries.push({
					name: value.name,
					data: detailData
				});
			}
		});

		if (enablePointerCursor) {
			$.each(detailSeries, function(index, series) {
				series.className = "pointer";
			});
		}

		detailPlotLines = [];
		$.each(systemStartupPlotLines, function(index, value) {
			if (value.value > detailStart) {
				detailPlotLines.push(value);
			}
		});

		// create a detail chart referenced by a global variable
		detailChart = Highcharts.chart($("#${containerId} div[data-purpose=detail-container]")[0], {
			chart: {
				marginBottom: 120,
				reflow: false,
				marginLeft: 80,
				marginRight: 20,
				width: width,
				style: {
					position: "relative"
				}
			},
			credits: {
				enabled: false
			},
			title: {
				text: "${title}"
			},
			subtitle: {
				text: i18n.message("sysadmin.dashboard.monitoring.chart.hint")
			},
			xAxis: {
				type: "datetime",
				plotLines: detailPlotLines
			},
			yAxis: {
				title: {
					text: null
				},
				maxZoom: 0.1,
				minTickInterval: 1
			},
			tooltip: {
				shared: true
			},
			legend: {
				enabled: false
			},
			plotOptions: {
				series: {
					marker: {
						enabled: false,
						states: {
							hover: {
								enabled: true,
								radius: 3
							}
						}
					},
					pointStart: detailStart,
					pointInterval: 24 * 3600 * 1000,
					point: {
						events: {
							click: function (event) {
								var point, index;

								point = event.point;

								if (point.hasOwnProperty("payload") && point.payload && point.payload.hasOwnProperty("requestId") && point.payload.requestId) {
									location.href = contextPath + "/sysadmin/download/requestlog.spr?requestId=" + point.payload.requestId + "&timestamp=" + point.x;
								} else {
									index = point.series.data.indexOf(point);
									if (index != null && index != undefined) {
										detailSeries.forEach(function (series) {
											point = series.data[index];
											if (point.hasOwnProperty("payload") && point.payload && point.payload.hasOwnProperty("requestId") && point.payload.requestId) {
												location.href = contextPath + "/sysadmin/download/requestlog.spr?requestId=" + point.payload.requestId + "&timestamp=" + point.x;
											}
										});
									}
								}
							}
						}
					}
				}
			},
			series: detailSeries,

			exporting: {
				enabled: false
			}

		}); // return chart
	}

	// create the master chart
	function createMaster() {
		var masterSeries, masterPlotLines;

		masterSeries = [];

		$.each(series, function(index, value) {
			masterSeries.push({
				name: value.name,
				pointStart: series[0].data[0].x,
				data: value.data
			});
		});

		masterPlotLines = [];
		$.each(systemStartupPlotLines, function(index, value) {
			masterPlotLines.push({
				id: "master-" + value.id,
				value: value.value,
				color: value.color,
				width: 1,
				dashStyle: value.dashStyle,
				zIndex: 10
			});
		});


		return Highcharts.chart($("#${containerId} div[data-purpose=master-container]")[0], {
			chart: {
				reflow: false,
				borderWidth: 0,
				backgroundColor: null,
				marginLeft: 80,
				marginRight: 20,
				width: width,
				zoomType: "x",
				events: {
					// listen to the selection event on the master chart to update the
					// extremes of the detail chart
					selection: function (event) {
						var extremesObject = event.xAxis[0],
							min = extremesObject.min,
							max = extremesObject.max,
							result;

						result =  handleSelectionEvent.call(this, min, max);

						$container.trigger("selection:change", [min, max]);

						return result;
					}
				}
			},
			title: {
				text: null
			},
			xAxis: {
				type: "datetime",
				showLastTickLabel: true,
				maxZoom: series[0].data[series[0].data.length - 1].x - series[0].data[0].x,
				plotBands: [{
					id: "mask-before",
					from: series[0].data[0].x,
					to: (range > threeHoursInMillis) ? (series[0].data[series[0].data.length - 1].x - threeHoursInMillis) : series[0].data[series[0].data.length - 1].x,
					color: "rgba(239, 239, 239, 0.9)"
				}],
				plotLines: masterPlotLines,
				title: {
					text: null
				}
			},
			yAxis: {
				gridLineWidth: 0,
				labels: {
					enabled: false
				},
				title: {
					text: null
				},
				min: 0.6,
				showFirstLabel: false
			},
			tooltip: {
				formatter: function () {
					return false;
				}
			},
			legend: {
				enabled: false
			},
			credits: {
				enabled: false
			},
			plotOptions: {
				series: {
					lineWidth: 2,
					marker: {
						enabled: false
					},
					shadow: false,
					states: {
						hover: {
							lineWidth: 1
						}
					},
					turboThreshold: 0,
					enableMouseTracking: false,
					pointInterval: 24 * 3600 * 1000
				}
			},

			series: masterSeries,

			exporting: {
				enabled: false
			}

		}, function (masterChart) {
			createDetail(masterChart);
		}); // return chart instance
	}

	// make the container smaller and add a second container for the master chart
	$container = $("#${containerId}").css("position", "relative");

	$("#${containerId} div[data-purpose=master-container]").css({
			position: "relative",
			top: -100,
			height: 100,
			width: "100%"
		}).appendTo($container);

	// create master and in its callback, create the detail chart
	chart = createMaster();

	$("#${containerId}").on("selection:update", function(event, min, max, index) {
		handleSelectionEvent.call(chart, min, max, false);
	});

});

</script>