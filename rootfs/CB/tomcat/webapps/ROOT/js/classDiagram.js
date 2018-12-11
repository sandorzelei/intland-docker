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

var codebeamer = codebeamer || {};
codebeamer.ClassDiagram = codebeamer.ClassDiagram || (function($) {

	mxBasePath = contextPath + "/mxGraph/src";
	mxLoadResources = false;
	if (typeof globalVariables === 'undefined' || globalVariables === null) {
		globalVariables = new Object();
	}

	/*var graph;
	var layout = new mxHierarchicalLayout(graph, null);
	var graphCels;
	var graphEdges
	var highlight;
	var previousCell;*/

	function executeLayout(mxGraphId) {
		globalVariables[mxGraphId].graph.getModel().beginUpdate();
		globalVariables[mxGraphId].layout = new mxHierarchicalLayout(globalVariables[mxGraphId].graph, mxConstants.DIRECTION_WEST, true);

		globalVariables[mxGraphId].layout.forceConstant = 300;
		globalVariables[mxGraphId].layout.execute(globalVariables[mxGraphId].graph.getDefaultParent());

		globalVariables[mxGraphId].graph.getModel().endUpdate();

		if (globalVariables[mxGraphId].highlight == null) {
			globalVariables[mxGraphId].highlight = new mxCellHighlight(globalVariables[mxGraphId].graph, '#ff0000', 2);
			globalVariables[mxGraphId].highlight.spacing = 8;
		}
	}

	function getAttributeByName(name, styleString) {
		name = name.replace(/[\[\]]/g, "\\$;");
		var regex = new RegExp(name + "(=([^;]*)|;|$)"),
			results = regex.exec(styleString);
		if (!results) return null;
		if (!results[2]) return '';
		return results[2];
	}

	function main(container, mxGraphId, exportMode, host) {
		// Checks if browser is supported
		if (!mxClient.isBrowserSupported()) {
			// Displays an error message if the browser is
			// not supported.
			mxUtils.error('Browser is not supported!', 200, false);
		}
		else {
			mxClient.NO_FO = mxClient.NO_FO || mxClient.IS_SF || mxClient.IS_GC;
			globalVariables[mxGraphId].graph = new mxGraph(container);
			var graph = globalVariables[mxGraphId].graph;
			var style = globalVariables[mxGraphId].graph.getStylesheet().getDefaultVertexStyle();
			style[mxConstants.STYLE_SHAPE] = mxConstants.SHAPE_RECTANGLE;
			style[mxConstants.STYLE_ROUNDED] = true;
			style[mxConstants.STYLE_PERIMETER] = mxPerimeter.RectanglePerimeter;
			style[mxConstants.STYLE_FONTSIZE] = '16';
			style[mxConstants.STYLE_FONTFAMILY] = 'Arial Unicode MS';
			style[mxConstants.STYLE_SHADOW] = '1';
			style[mxConstants.STYLE_ROUNDED] = '1';
			style[mxConstants.STYLE_GLASS] = '1';
			style[mxConstants.STYLE_SHAPE] = 'label';

			style[mxConstants.STYLE_VERTICAL_ALIGN] = mxConstants.ALIGN_MIDDLE;
			style[mxConstants.STYLE_ALIGN] = mxConstants.ALIGN_LEFT;
			style[mxConstants.STYLE_SPACING_LEFT] = 17;

			style[mxConstants.STYLE_IMAGE_WIDTH] = '13';
			style[mxConstants.STYLE_IMAGE_HEIGHT] = '13';
			style[mxConstants.STYLE_SPACING] = 5;

			style = globalVariables[mxGraphId].graph.getStylesheet().getDefaultEdgeStyle();
			style[mxConstants.STYLE_CURVED] = '1';
			style[mxConstants.STYLE_EDGE] = mxConstants.SegmentConnector;

			graph.setResizeContainer(false);
			//graph.setHtmlLabels(true);

			graph.gridSize = 20;

			graph.setCellsMovable(true);
			graph.setAutoSizeCells(true);
			graph.centerZoom = true;
			graph.panningHandler.useLeftButtonForPanning = true;
			graph.panningHandler.ignoreCell = false;
			graph.panningHandler.panningEnabled = true;
			graph.setPanning(true);

			mxPanningHandler.prototype.isForcePanningEvent = function(me) {
				if (me.isConsumed() || (me.getCell() != null && !me.getCell().vertex)) {
					return true;
				} else {
					return false;
				}
			}

			graph.getModel().beginUpdate();
			var doc = mxUtils.parseXml(globalVariables[mxGraphId].xml);
			var codec = new mxCodec(doc);
			codec.decode(doc.documentElement, graph.model);

			var parent = graph.getDefaultParent();

			var allCells = graph.model.getChildCells(graph.getDefaultParent(), true, true);
			processValue(graph, allCells, mxGraphId);

			globalVariables[mxGraphId].graphCells = graph.model.getChildCells(parent, true, false);
			//globalVariables[mxGraphId].graphCells = graph.model.getChildCells(parent, false, true);

			var graphCells = globalVariables[mxGraphId].graphCells;
			var cells = globalVariables[mxGraphId].cells;

			graph.getModel().endUpdate();

			var timeOut = 300;
			if (exportMode) {
				timeOut = 0;
			}

			setTimeout(function() {
				try {
					graph.getModel().beginUpdate();
					for (var i = 0; i < graphCells.length; ++i) {
						graph.updateCellSize(graphCells[i], false);
					}
				} finally {
					graph.getModel().endUpdate();
				}
				executeLayout(mxGraphId);
				var overlays = [];
				for (var i = 0; i < graphCells.length; ++i) {
					var imgUrl = '';
					if (exportMode) {
						imgUrl = host + cells[graphCells[i].id].darkImage;
					} else {
						imgUrl = cells[graphCells[i].id].darkImage;
					}
					var img = new mxImage(imgUrl, 16, 16);
					var overlay = new mxCellOverlay(img, "", "left", "middle");
					overlay['url'] = cells[graphCells[i].id].url;
					overlay.defaultOverlap = 0.0;
					overlay.offset = new mxPoint(7,-7);
					overlay.cursor = 'pointer';
					graph.addCellOverlay(graphCells[i], overlay);
					overlay.addListener(mxEvent.CLICK, function(sender, evt) {
						window.open(sender.url,'_blank');
					});

					// set the font color for branch nodes
					var color = cells[graphCells[i].id].color;
					if (color) {
						var model = globalVariables[mxGraphId].graph.model;
						var style = model.getStyle(graphCells[i]);
						style = mxUtils.setStyle(style, mxConstants.STYLE_FONTCOLOR, color);

						model.setStyle(graphCells[i], style);
					}
				}

				if (exportMode) {
					setTimeout(function() {
						graph.fit();
						graph.view.rendering = true;
						graph.refresh();
					}, 0);
				}

			}, timeOut);

			graph.setEnabled(false);

			graph.addMouseListener({
				currentState: null,
				previousStyle: null,
				mouseDown: function(sender, me) {},
				mouseMove: function(sender, me) {
					if (me != null && me.getCell() != null && me.getCell().vertex) {
						graph.container.style.cursor = 'pointer';
					} else  if (graph.container.style.cursor != '' && graph.container.style.cursor != 'wait') {
						graph.container.style.cursor = '';
					}
				},
				mouseUp: function(sender, me) { },
				dragEnter: function(evt, state) {},
				dragLeave: function(evt, state) {}
			});

			var previousCellColors;
			graph.addListener(mxEvent.CLICK, function(sender, evt)
				{

					try {
					graph.getModel().beginUpdate();
					var selectedCell = evt.getProperty('cell');
					if (selectedCell != null && selectedCell.vertex) {
						graph.container.style.cursor = 'wait';
						setTimeout(function() {
						var tmpPreviousCell = globalVariables[mxGraphId].previousCell;

							var allVisibleCells = obtainVisibleChildCells(graph.model, graph.getDefaultParent(), true, true, false);
							var previousCell = globalVariables[mxGraphId].previousCell;

							if (previousCell != null) {
								if (cell != null && cell.vertex && cell != tmpPreviousCell) {
								} else {
									updateCellStyles(allVisibleCells, graph.model, false);
								}
								globalVariables[mxGraphId].highlight.hide();
								globalVariables[mxGraphId].previousCell = null;
								previousCell = null;
							}

							var cell = evt.getProperty('cell');
							if (cell != null && cell.vertex && cell != tmpPreviousCell) {
								globalVariables[mxGraphId].previousCell = cell;
								previousCell = cell;
								globalVariables[mxGraphId].highlight.highlight(graph.view.getState(cell));

								updateCellStyles(allVisibleCells, graph.model, true);

								var selectedCells = [];

								var edges = graph.getOutgoingEdges(previousCell);

								/*graph.setCellStyles(mxConstants.STYLE_OPACITY, "100", [cell]);
								graph.setCellStyles(mxConstants.STYLE_FILL_OPACITY, "100", [cell]);
								graph.setCellStyles(mxConstants.STYLE_STROKE_OPACITY, "100", [cell]);
								graph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY, "100", [cell]);*/
								updateCellStyles([cell], graph.model, false);

								for (var i = 0; i < edges.length; ++i) {
									/*graph.setCellStyles(mxConstants.STYLE_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_FILL_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_STROKE_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY, "100", [edges[i]]);*/

									updateCellStyles([edges[i]], graph.model, false);

									/*graph.setCellStyles(mxConstants.STYLE_OPACITY, "100", [edges[i].target]);
									graph.setCellStyles(mxConstants.STYLE_FILL_OPACITY, "100", [edges[i].target]);
									graph.setCellStyles(mxConstants.STYLE_STROKE_OPACITY, "100", [edges[i].target]);
									graph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY, "100", [edges[i].target]);*/

									updateCellStyles([edges[i].target], graph.model, false);

								}
								edges = graph.getIncomingEdges(previousCell);
								for (var i = 0; i < edges.length; ++i) {
									updateCellStyles([edges[i]], graph.model, false);
									/*graph.setCellStyles(mxConstants.STYLE_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_FILL_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_STROKE_OPACITY, "100", [edges[i]]);
									graph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY, "100", [edges[i]]);*/

									updateCellStyles([edges[i].source], graph.model, false);
									/*graph.setCellStyles(mxConstants.STYLE_OPACITY, "100", [edges[i].source]);
									graph.setCellStyles(mxConstants.STYLE_FILL_OPACITY, "100", [edges[i].source]);
									graph.setCellStyles(mxConstants.STYLE_STROKE_OPACITY, "100", [edges[i].source]);
									graph.setCellStyles(mxConstants.STYLE_TEXT_OPACITY, "100", [edges[i].source]);*/

								}
								graph.container.style.cursor = '';
							}
						}, 0);
					}
					} finally {
						graph.getModel().endUpdate();
						graph.container.style.cursor = '';
					}
				}
			);

			new mxRubberband(graph);

			mxRubberband.prototype.mouseUp = function(sender, me) {

				var execute = this.div != null;
				this.reset();

				if (execute) {
					var rect = new mxRectangle(this.x, this.y, this.width, this.height);
					var graph = this.graph;

					graph.zoomToRect(rect);
					me.consume();
				}
			};

			$("#treePanePopup").bind("changed.jstree", function(event, data) {
				setTimeout(function() {
					var trackerIds = refreshDiagram(mxGraphId);
					if (!(!globalVariables[mxGraphId].projectId || 0 === globalVariables[mxGraphId].projectId.length)) {
						var selectedTrackers = "-1";
						if (trackerIds.length > 0) {
							selectedTrackers = trackerIds.join(",");
						}
						codebeamer.TrackerHomePage.callSaveTrackers($("#treePanePopup"), selectedTrackers);
					}
				}, 300);
			});

			if ($("#treePanePopup").length == 0) {
				setTimeout(function() {
					if (globalVariables[mxGraphId].outln == null) {
						var outline = document.getElementById('outlineContainer' + mxGraphId);
						if (mxClient.IS_QUIRKS)
						{
							document.body.style.overflow = 'hidden';
							new mxDivResizer(container);
							new mxDivResizer(outline);
						}

						globalVariables[mxGraphId].outln = new mxOutline(graph, outline);
					}

				}, 300);
			}

			var parent = $("#container" + mxGraphId).parent('div');

			if (parent.length > 0 && parent.parent('div').length > 0 && parent.parent('div').hasClass('pinned-content')) {
				parent.css('width', '100%');
			}
		}
	};



	function obtainVisibleChildCells(model, parent, vertices, edges, visible)
	{
		vertices = (vertices != null) ? vertices : false;
		edges = (edges != null) ? edges : false;

		var childCount = model.getChildCount(parent);
		var result = [];

		for (var i = 0; i < childCount; i++)
		{
			var child = model.getChildAt(parent, i);

			var showChild = child.isVisible() || visible;

			if ((!edges && !vertices) || (edges && model.isEdge(child) && ((showChild && model.isVertex(child)) || child.source.isVisible() && child.target.isVisible())) ||
				(vertices && model.isVertex(child) && showChild))
			{
				result.push(child);
			}
		}

		return result;
	};

	function updateCellStyles(cells, model, transparent) {
		for (var i = 0; i < cells.length; ++i) {
			model.setStyle(cells[i], createStyleFromCell(cells[i], model, transparent));
		}
	}

	function createStyleFromCell(cell, model, transparent) {
		var opacity = "100";
		if (transparent) {
			opacity = "20;"
		}
		var style = model.getStyle(cell);
		style = mxUtils.setStyle(style, mxConstants.STYLE_OPACITY, opacity);
		style = mxUtils.setStyle(style, mxConstants.STYLE_FILL_OPACITY, opacity);
		style = mxUtils.setStyle(style, mxConstants.STYLE_STROKE_OPACITY, opacity);
		style = mxUtils.setStyle(style, mxConstants.STYLE_TEXT_OPACITY, opacity);
		return style;
	}

	function processValue(graph, allCells, mxGraphId) {
		try {
			graph.getModel().beginUpdate();
			for (var i = 0; i < allCells.length; ++i) {
				// store urls
				var urlAttribute = getAttribute('url', allCells[i].value);
				var nameAttribute = getAttribute('name', allCells[i].value);
				var darkImageAttribute = getAttribute('darkImage', allCells[i].value);
				var lightImageAttribute = getAttribute('lightImage', allCells[i].value);
				var projectName = getAttribute('projectName', allCells[i].value);
				var isBranch = getAttribute('isBranch', allCells[i].value);
				var color = getAttribute('color', allCells[i].value);
				globalVariables[mxGraphId].cells[allCells[i].id] = { 'url': urlAttribute,
						'nameUrl': nameAttribute,
						'darkImage': darkImageAttribute,
						'lightImage': lightImageAttribute,
						'isBranch': isBranch,
						'color': color
					};
				// set label
				var name = getAttribute('name', allCells[i].value);
				var label = '';
				if (projectName != null && projectName != '') {
					label = projectName + ' - ';
				}
				if (name != null) {
					label += name;
				}
				allCells[i].value = label;
				graph.getView().clear(allCells[i], false, false);
				graph.getView().validate();
				if (allCells[i].children && allCells[i].children.length && allCells[i].children.length > 0) {
					processValue(graph, allCells[i].children, mxGraphId);
				}
			}
		} finally {
			graph.getModel().endUpdate();
		}
	}

	function getAttribute(name, values) {
		var start = values.indexOf('<' + name + '>=');
		if (start == -1) {
			return null;
		} else {
			start += name.length + 3;
		}
		var end = values.indexOf('</>', start);
		return values.substring(start, end);
	}

	function refreshDiagram(mxGraphId) {
		var tree = $.jstree.reference($("#treePanePopup"));
		var selectedNodes = tree.get_selected(true);
		var trackerIds = [];
		for (var i = 0; i < selectedNodes.length; i++) {
			var node = selectedNodes[i];
			if (node.li_attr.hasOwnProperty("data-trackerId")) {
				trackerIds.push(node.li_attr["data-trackerId"]);
			}
		}

		if (globalVariables[mxGraphId] === undefined || globalVariables[mxGraphId] == null || globalVariables[mxGraphId].graph === undefined || globalVariables[mxGraphId].graph == null) {
			return;
		}
		globalVariables[mxGraphId].graph.getModel().beginUpdate();

		for (var i = 0; i < globalVariables[mxGraphId].graphCells.length; ++i) {
			if (trackerIds.indexOf(globalVariables[mxGraphId].graphCells[i].id) != -1) {
				globalVariables[mxGraphId].graph.getModel().setVisible(globalVariables[mxGraphId].graphCells[i], true);
			} else {
				globalVariables[mxGraphId].graph.getModel().setVisible(globalVariables[mxGraphId].graphCells[i], false);
			}
		}
		globalVariables[mxGraphId].highlight.hide();
		globalVariables[mxGraphId].previousCell = null;
		var allVisibleCells = obtainVisibleChildCells(globalVariables[mxGraphId].graph.model, globalVariables[mxGraphId].graph.getDefaultParent(), true, true, false);
		updateCellStyles(allVisibleCells, globalVariables[mxGraphId].graph.model, false);
		globalVariables[mxGraphId].graph.getModel().endUpdate();

		executeLayout(mxGraphId);
		setTimeout(function() {
			$("#rightPane").show();

			if (globalVariables[mxGraphId].outln == null) {
				var outline = document.getElementById('outlineContainer' + mxGraphId);
				if (mxClient.IS_QUIRKS)
				{
					document.body.style.overflow = 'hidden';
					new mxDivResizer(container);
					new mxDivResizer(outline);
				}

				globalVariables[mxGraphId].outln = new mxOutline(globalVariables[mxGraphId].graph, outline);
			}

		}, 300);

		return trackerIds;
	}

	var update = function(previewPic, url){
		var image = url.substring(1, url.length-1);
		previewPic.style.backgroundImage = "url('" + contextPath + "/mxGraph/custom/images/trackerType/" + image + "')";
	};

	var init = function(mxGraphId, providedPojectId, providedXml, disableZoom, exportMode, contextpath) {
		globalVariables[mxGraphId] = {
			'graph': null,
			'layout': null,
			'highlight': null,
			'previousCell': null,
			'projectId': providedPojectId,
			'xml': providedXml,
			'cells': new Object(),
			'outln' : null
		};
		main(document.getElementById('graphContainer' + mxGraphId), mxGraphId, exportMode, contextpath);

		$("#zoomInButton" + mxGraphId).click(function() {
			globalVariables[mxGraphId].graph.zoomIn();
		});

		$("#zoomOutButton" + mxGraphId).click(function() {
			globalVariables[mxGraphId].graph.zoomOut();
		});

		if (disableZoom == null || disableZoom == false) {
			mxEvent.addMouseWheelListener(function (evt, up)
		    {
			    var target = $(evt.target);
			    if (target.closest("#treePanePopup").length == 0) {
					if (!mxEvent.isConsumed(evt)) {
						if (up) {
							globalVariables[mxGraphId].graph.zoomIn();
						} else {
							globalVariables[mxGraphId].graph.zoomOut();
						}
						mxEvent.consume(evt);
					}
			    }
		    });
		}
	};

	return {
		"init" : init,
		"refreshDiagram" : refreshDiagram,
		"update" : update
	};

})(jQuery);