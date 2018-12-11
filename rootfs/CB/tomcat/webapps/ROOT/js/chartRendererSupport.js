/**
 * Copyright by Intland Software
 *
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Intland Software. ("Confidential Information"). You
 * shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Intland.
 */

/**
 * Supporting class for dynamic chart rendering
 */
var chartRendererSupport = {

	/**
	 * Update the chart via ajax
	 * @param contextPath
	 * @param elId The html element's id to render the chart into
	 * @param url The url renders the chart's html
	 * @param width The width of the expected image
	 * @param height
	 */
	updateChart:function(contextPath, elId, url, width, height) {
		// only update the chart if the url has changed
		var chartEl = document.getElementById(elId);
		if (chartEl.lasturl == url) {
			return;
		}
		chartEl.lasturl = url;

		if (width == null) {
			width = 400;
		}
		if (height == null) {
			height = 300;
		}

		var isIE8 = $("body").hasClass('IE8');
		if (!isIE8){
			var chartImage = $(chartEl).find("img")[0];
			if (chartImage){
				var busy = ajaxBusyIndicator.showBusysign(chartImage, i18n.message("ajax.loading") , false
					, { centered: true, renderTo: document.body }
				);
			}
			else {
				var chartDiv = $(chartEl).find(".highchartbox")[0];
				if (chartDiv) {
					var busy = ajaxBusyIndicator.showBusysign(chartDiv, i18n.message("ajax.loading") , false
						, { centered: true, renderTo: document.body }
					);
				} else {
					var busy = ajaxBusyIndicator.showBusysign(chartEl, i18n.message("ajax.loading") , false
						, { centered: true, renderTo: document.body }
					);
				}
			}
		}

		$(chartEl).css({
			"width": width +"px",
			"height": width +"px"
		});

		var showResult = function(html) {
			$(chartEl).html(html);
			if (!isIE8){
				ajaxBusyIndicator.close(busy);
			}
		};

		$.ajax(url, {
			method: 'GET',
			dataType: "xml",
			success: function(data) {
				var response = $(data).find('html').text();
				showResult(response);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				var retry = "<a href='#' onclick='chartRendererSupport.updateChart(\"" +contextPath +"\", \"" + elId +"\", \"" + url +"\", " + width +"," + height +"); return false;'>Retry</a>";
				var details = "<div class='hd'>Error details</div><div class='bd' style='overflow:auto;'>" + errorThrown +"</div>";
				var html = "<div class='error' style='overflow:auto;height:44px; padding-left:50px;'>Failed to render chart.<br/>" + retry + "<br>" + details +"</div>";
				showResult(html);
			}
		});

	},

	updateTable: function(contextPath, elId, url) {
		var $element, lastUrl;

		$element = $(document.getElementById(elId));

		if ($element.size() > 0) {
			lastUrl = $element.data("lastUrl");

			if (!lastUrl || lastUrl !== url) {
				$element.data("lastUrl", url);

				$.ajax(url, {
					method: 'GET',
					success: function(data) {
						$element.empty();
						$element.append(data);
					},
					error: function(jqXHR, textStatus, errorThrown) {
						var retry = "<a href='#' onclick='chartRendererSupport.updateChart(\"" +contextPath +"\", \"" + elId +"\", \"" + url +"\", " + width +"," + height +"); return false;'>Retry</a>";
						var details = "<div class='hd'>Error details</div><div class='bd' style='overflow:auto;'>" + errorThrown +"</div>";
						var html = "<div class='error' style='overflow:auto;height:44px; padding-left:50px;'>Failed to render chart.<br/>" + retry + "<br>" + details +"</div>";
						showResult(html);
					}
				});

			}
		}
	},

	replaceOrAddParameter: function(url, parameterName, parameterLength, parameterValue) {
		var index = url.indexOf("&" + parameterName);

		if (index >= 0) {
			var nextParameterIndex = url.indexOf("&", index + parameterLength);
			if (nextParameterIndex < 0) {
				nextParameterIndex = url.length;
			}

			url = url.slice(0, index + parameterLength) + "=" + parameterValue + url.slice(nextParameterIndex);
		} else {
			url = url + "&" + parameterName + "=" + parameterValue;
		}

		return url;
	},

	sortTable: function(tableUrl, tableId, contextPath) {
		var $target, $div, sortDirection, columnIndex, sortColumnIndex, sortingDirection;

		$target = $(event.currentTarget);

		$div = $target.find("div");

		sortColumnIndex = $div.data("column-index");

		sortingDirection = "ASC";
		if ($div.hasClass("ASC")) {
			sortingDirection = "DESC";
		}

		tableUrl = this.replaceOrAddParameter(tableUrl, "sortColumnIndex", 16, sortColumnIndex);
		tableUrl = this.replaceOrAddParameter(tableUrl, "sortingDirection", 17, sortingDirection);

		chartRendererSupport.updateTable(contextPath, tableId, tableUrl);
	}

};

/**
 * Supporting class for dynamic ajax plugin rerendering
 */
var ajaxPluginRendererSupport = {

	/**
	 * Update the plugin via ajax
	 * @param contextPath
	 * @param pluginId The id of the plugin
	 * @param url The url renders the chart's html
	 * @param width The width of the expected image
	 * @param height
	 * @param force Force to reload the plugin even the url is same as the last time
	 */
	updatePlugin:function(contextPath, pluginId, url, width, height, force) {
		var elId = "ajaxplugin_" + pluginId;
		// only update the chart if the url has changed
		var pluginEl = document.getElementById(elId);
		if (pluginEl.lasturl == url && force != true) {
			return;
		}
		pluginEl.lasturl = url;

		if (width == null) {
			width = 400;
		}
		if (height == null) {
			height = 300;
		}
		var ALLOW_FADING = false;
		//pluginEl.style.width = width +"px";
		//pluginEl.style.height = height +"px";
		if (ALLOW_FADING) {
			// only show the ajax-loading image if we had no response for a 1 second. typically it won't be shown
			ajaxPluginRendererSupport.indicatorImageTimer = setTimeout(function() { ajaxPluginRendererSupport.showLoadingImage(pluginEl); }, 1000);
		} else {
			// pluginEl.innerHTML = "<img src='" + contextPath +"/images/ajax-loading_16.gif'></img>";
			ajaxPluginRendererSupport.showLoadingImage(pluginEl);
		}

		$.ajax(url, {
			method: 'GET',
			dataType: 'xml',
			success: function(data) {
				if (ajaxPluginRendererSupport.indicatorImageTimer != null) {
					clearTimeout(ajaxPluginRendererSupport.indicatorImageTimer);
					ajaxPluginRendererSupport.indicatorImageTimer =null;
				}

				var response = $(data).find('html').text();
				// cut down xhtml envelope
				var busySign = pluginEl.busySign;
				if (ALLOW_FADING) {
					ajaxPluginRendererSupport.replaceWithFade(pluginEl, response);
				} else {
					$(pluginEl).html(response);
				}
				if (busySign) {
					ajaxBusyIndicator.close(busySign);
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				var retry = "<a href='#' onclick='ajaxPluginRendererSupport.updateChart(\"" +contextPath +"\", \"" + pluginId +"\", \"" + url +"\", " + width +"," + height +"); return false;'>Retry</a>";
				var details = "<div class='hd'>Error details</div><div class='bd' style='overflow:auto;'>" + errorThrown +"</div>";
				var html = "<div class='error' style='overflow:auto;height:44px; padding-left:50px;'>Failed to render chart.<br/>" + retry + "<br>" + details +"</div>";
				pluginEl.innerHTML = html;
			}
		});

	},

	showLoadingImage:function(pluginEl) {
		var busy = ajaxBusyIndicator.showBusysign($(pluginEl)[0], i18n.message("ajax.loading") , false
				, { centered: true, renderTo: document.body }
		);
		pluginEl.busySign = busy;
	},

	// replace the content of an element with fade-out/in
	replaceWithFade: function(el, newContent) {
		var fadetime = 300;
		// Note: the color fading would work, but not visible, because the elements inside cover the color
		var origColor = $(el).css("background-color");
		$(el).animate({
			opacity: 0,
			backgroundColor: "#e06"
		}, fadetime, function() {
			el.innerHTML = newContent;
			$(el).animate({
				opacity: 1,
				backgroundColor: origColor
			}, fadetime, function() {
				$(el).removeClass("ajaxplugin_loading");
			});
		});
	}

};
