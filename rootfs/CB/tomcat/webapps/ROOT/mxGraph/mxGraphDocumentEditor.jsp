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

<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="tag" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=5,IE=9" ><![endif]-->
<!DOCTYPE html>
<html>
<head>
    <title>Grapheditor</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" type="text/css" href="styles/grapheditor.css">
    <link rel="stylesheet" href="<ui:urlversioned value='/wro/newskin.css' />" type="text/css" media="all" />


    <script type="text/javascript" src="<ui:urlversioned value='/js/jquery/jquery.js'/>"></script>
	<script type="text/javascript">
		// Parses URL parameters. Supported parameters are:
		// - lang=xy: Specifies the language of the user interface.
		// - touch=1: Enables a touch-style user interface.
		// - storage=local: Enables HTML5 local storage.
		// - chrome=0: Chromeless mode.
		mxBasePath = 'src';
		var urlParams = (function(url)
		{
			var result = new Object();
			var idx = url.lastIndexOf('?');

			if (idx > 0)
			{
				var params = url.substring(idx + 1).split('&');

				for (var i = 0; i < params.length; i++)
				{
					idx = params[i].indexOf('=');

					if (idx > 0)
					{
						result[params[i].substring(0, idx)] = params[i].substring(idx + 1);
					}
				}
			}

			return result;
		})(window.location.href);

		// Default resources are included in grapheditor resources
		mxLoadResources = false;
	</script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/src/js/mxClient.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Init.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/jscolor/jscolor.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/sanitizer/sanitizer.min.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/src/js/mxClient.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/EditorUi.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Editor.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Sidebar.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Graph.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Shapes.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Actions.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Menus.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Format.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Toolbar.js'/>"></script>
	<script type="text/javascript" src="<ui:urlversioned value='/mxGraph/js/Dialogs.js'/>"></script>
	<style type="text/css">
		body {
			overflow:hidden;
		}

		#customGeEditor {
			position:relative;
			top:0px;
			left:0px;
			width:100%;
			overflow: hidden;
		}

		.actionMenuBar {
			margin-left: 0px;
			margin-right: 0px;
			margin-bottom: 0px;
		}

		.actionBar {
			margin: 0 0 10px 0;
			padding: 5px 10px;
		}

		.infoMessages.invisible {
			display: none;
		}

		.actionMenuBar .actionMenuBarIcon,  .newskin .actionMenuBar .actionMenuBarIcon {
		float: left;
			width: 34px;
			height: 32px;
			padding: 0;
			margin-right: 12px;
			background-repeat: no-repeat;
			background-position: center center;
			background-image: url(../stylesheet/../images/newskin/header/mxgraph-l.png);
		}
	</style>
</head>
<body class="popupBody newskin" style="margin: 0px;">
	<spring:message var="graphEditorTitleLabel" code="wysiwyg.wiki.markup.plugin.mxGraph.title" />
	<ui:actionMenuBar><b>${graphEditorTitleLabel}</b></ui:actionMenuBar>
	<spring:message var="graphEditorSaveButtonLabel" code="wysiwyg.wiki.markup.plugin.save.button.label" />
	<spring:message var="graphEditorCancelButtonLabel" code="wysiwyg.wiki.markup.plugin.cancel.button.label" />
	<ui:actionBar>
		&nbsp;&nbsp;<input type="button" class="button" name="insertMarkupButton" value="${graphEditorSaveButtonLabel}" onclick="EditorUi.prototype.saveFile(true)"/>
		<input type="button" class="button cancelButton" value="${graphEditorCancelButtonLabel}" onclick="closeEditor()"/>
	</ui:actionBar>
	<div id="customGeEditor"></div>
	<script type="text/javascript">

	</script>
	<script type="text/javascript">
		$( document ).ready(function() {
			var parentWindowHeight = $(parent.document).height();
			var height = parentWindowHeight - 92;
			$("#customGeEditor").height(height);
		});

		var contextPath = '${pageContext.request.contextPath}';

		var exportUrl = '<c:url value="/mxGraph/export.spr" />';
		var saveUrl = '<c:url value="/mxGraph/saveArtifact.spr" />';
		var artifactCreateUrl = '<c:url value="/mxGraph/createArtifact.spr" />';
		// Extends EditorUi to update I/O action states based on availability of backend
		function getContainerPluginSourceBlock(selectedNode) {
		    return $(selectedNode).closest('.pluginSource');
		}

		function hash(str) {
			var i, l,
			hval = 0x811c9dc5;

			for (i = 0, l = str.length; i < l; i++) {
				hval ^= str.charCodeAt(i);
				hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
			}
			return hval >>> 0;
		}

		function closeEditor() {
			window.parent.inlinePopup.close();
		}

		(function()
		{
			var editorUiInit = EditorUi.prototype.init;

			Menus.prototype.init = function()
			{
				var graph = this.editorUi.editor.graph;
				editorInstance = this.editor;
				var isGraphEnabled = mxUtils.bind(graph, graph.isEnabled);

				this.customFonts = [];
				this.customFontSizes = [];

				this.put('fontFamily', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					var addItem = mxUtils.bind(this, function(fontname)
					{
						var tr = this.styleChange(menu, fontname, [mxConstants.STYLE_FONTFAMILY], [fontname], null, parent, function()
						{
							document.execCommand('fontname', false, fontname);
						});
						tr.firstChild.nextSibling.style.fontFamily = fontname;
					});

					for (var i = 0; i < this.defaultFonts.length; i++)
					{
						addItem(this.defaultFonts[i]);
					}

					menu.addSeparator(parent);

					if (this.customFonts.length > 0)
					{
						for (var i = 0; i < this.customFonts.length; i++)
						{
							addItem(this.customFonts[i]);
						}

						menu.addSeparator(parent);

						menu.addItem(mxResources.get('reset'), null, mxUtils.bind(this, function()
						{
							this.customFonts = [];
						}), parent);

						menu.addSeparator(parent);
					}

					this.promptChange(menu, mxResources.get('custom') + '...', '', mxConstants.DEFAULT_FONTFAMILY, mxConstants.STYLE_FONTFAMILY, parent, true, mxUtils.bind(this, function(newValue)
					{
						this.customFonts.push(newValue);
					}));
				})));
				this.put('formatBlock', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					function addItem(label, tag)
					{
						return menu.addItem(label, null, mxUtils.bind(this, function()
						{
							// TODO: Check if visible
							graph.cellEditor.textarea.focus();
				      		document.execCommand('formatBlock', false, '<' + tag + '>');
						}), parent);
					};

					addItem(mxResources.get('normal'), 'p');

					addItem('', 'h1').firstChild.nextSibling.innerHTML = '<h1 style="margin:0px;">' + mxResources.get('heading') + ' 1</h1>';
					addItem('', 'h2').firstChild.nextSibling.innerHTML = '<h2 style="margin:0px;">' + mxResources.get('heading') + ' 2</h2>';
					addItem('', 'h3').firstChild.nextSibling.innerHTML = '<h3 style="margin:0px;">' + mxResources.get('heading') + ' 3</h3>';
					addItem('', 'h4').firstChild.nextSibling.innerHTML = '<h4 style="margin:0px;">' + mxResources.get('heading') + ' 4</h4>';
					addItem('', 'h5').firstChild.nextSibling.innerHTML = '<h5 style="margin:0px;">' + mxResources.get('heading') + ' 5</h5>';
					addItem('', 'h6').firstChild.nextSibling.innerHTML = '<h6 style="margin:0px;">' + mxResources.get('heading') + ' 6</h6>';

					addItem('', 'pre').firstChild.nextSibling.innerHTML = '<pre style="margin:0px;">' + mxResources.get('formatted') + '</pre>';
					addItem('', 'blockquote').firstChild.nextSibling.innerHTML = '<blockquote style="margin-top:0px;margin-bottom:0px;">' + mxResources.get('blockquote') + '</blockquote>';
				})));
				this.put('fontSize', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					var sizes = [6, 8, 9, 10, 11, 12, 14, 18, 24, 36, 48, 72];

					var addItem = mxUtils.bind(this, function(fontsize)
					{
						this.styleChange(menu, fontsize, [mxConstants.STYLE_FONTSIZE], [fontsize], null, parent, function()
						{
							// Creates an element with arbitrary size 3
							document.execCommand('fontSize', false, '3');

							// Changes the css font size of the first font element inside the in-place editor with size 3
							// hopefully the above element that we've just created. LATER: Check for new element using
							// previous result of getElementsByTagName (see other actions)
							var elts = graph.cellEditor.textarea.getElementsByTagName('font');

							for (var i = 0; i < elts.length; i++)
							{
								if (elts[i].getAttribute('size') == '3')
								{
									elts[i].removeAttribute('size');
									elts[i].style.fontSize = fontsize + 'px';

									break;
								}
							}
						});
					});

					for (var i = 0; i < sizes.length; i++)
					{
						addItem(sizes[i]);
					}

					menu.addSeparator(parent);

					if (this.customFontSizes.length > 0)
					{
						for (var i = 0; i < this.customFontSizes.length; i++)
						{
							addItem(this.customFontSizes[i]);
						}

						menu.addSeparator(parent);

						menu.addItem(mxResources.get('reset'), null, mxUtils.bind(this, function()
						{
							this.customFontSizes = [];
						}), parent);

						menu.addSeparator(parent);
					}

					this.promptChange(menu, mxResources.get('custom') + '...', '(pt)', '12', mxConstants.STYLE_FONTSIZE, parent, true, mxUtils.bind(this, function(newValue)
					{
						this.customFontSizes.push(newValue);
					}));
				})));
				this.put('direction', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					menu.addItem(mxResources.get('flipH'), null, function() { graph.toggleCellStyles(mxConstants.STYLE_FLIPH, false); }, parent);
					menu.addItem(mxResources.get('flipV'), null, function() { graph.toggleCellStyles(mxConstants.STYLE_FLIPV, false); }, parent);
					this.addMenuItems(menu, ['-', 'rotation'], parent);
				})));
				this.put('align', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					menu.addItem(mxResources.get('leftAlign'), null, function() { graph.alignCells(mxConstants.ALIGN_LEFT); }, parent);
					menu.addItem(mxResources.get('center'), null, function() { graph.alignCells(mxConstants.ALIGN_CENTER); }, parent);
					menu.addItem(mxResources.get('rightAlign'), null, function() { graph.alignCells(mxConstants.ALIGN_RIGHT); }, parent);
					menu.addSeparator(parent);
					menu.addItem(mxResources.get('topAlign'), null, function() { graph.alignCells(mxConstants.ALIGN_TOP); }, parent);
					menu.addItem(mxResources.get('middle'), null, function() { graph.alignCells(mxConstants.ALIGN_MIDDLE); }, parent);
					menu.addItem(mxResources.get('bottomAlign'), null, function() { graph.alignCells(mxConstants.ALIGN_BOTTOM); }, parent);
				})));
				this.put('distribute', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					menu.addItem(mxResources.get('horizontal'), null, function() { graph.distributeCells(true); }, parent);
					menu.addItem(mxResources.get('vertical'), null, function() { graph.distributeCells(false); }, parent);
				})));
				this.put('layout', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					menu.addItem(mxResources.get('horizontalFlow'), null, mxUtils.bind(this, function()
					{
						var layout = new mxHierarchicalLayout(graph, mxConstants.DIRECTION_WEST);
			    		this.editorUi.executeLayout(function()
			    		{
			    			var selectionCells = graph.getSelectionCells();
			    			layout.execute(graph.getDefaultParent(), selectionCells.length == 0 ? null : selectionCells);
			    		}, true);
					}), parent);
					menu.addItem(mxResources.get('verticalFlow'), null, mxUtils.bind(this, function()
					{
						var layout = new mxHierarchicalLayout(graph, mxConstants.DIRECTION_NORTH);
			    		this.editorUi.executeLayout(function()
			    		{
			    			var selectionCells = graph.getSelectionCells();
			    			layout.execute(graph.getDefaultParent(), selectionCells.length == 0 ? null : selectionCells);
			    		}, true);
					}), parent);
					menu.addSeparator(parent);
					menu.addItem(mxResources.get('horizontalTree'), null, mxUtils.bind(this, function()
					{
						var tmp = graph.getSelectionCell();
						var roots = null;

						if (tmp == null || graph.getModel().getChildCount(tmp) == 0)
						{
							if (graph.getModel().getEdgeCount(tmp) == 0)
							{
								roots = graph.findTreeRoots(graph.getDefaultParent());
							}
						}
						else
						{
							roots = graph.findTreeRoots(tmp);
						}

						if (roots != null && roots.length > 0)
						{
							tmp = roots[0];
						}

						if (tmp != null)
						{
							var layout = new mxCompactTreeLayout(graph, true);
							layout.edgeRouting = false;
							layout.levelDistance = 30;

							this.editorUi.executeLayout(function()
				    		{
								layout.execute(graph.getDefaultParent(), tmp);
				    		}, true);
						}
					}), parent);
					menu.addItem(mxResources.get('verticalTree'), null, mxUtils.bind(this, function()
					{
						var tmp = graph.getSelectionCell();
						var roots = null;

						if (tmp == null || graph.getModel().getChildCount(tmp) == 0)
						{
							if (graph.getModel().getEdgeCount(tmp) == 0)
							{
								roots = graph.findTreeRoots(graph.getDefaultParent());
							}
						}
						else
						{
							roots = graph.findTreeRoots(tmp);
						}

						if (roots != null && roots.length > 0)
						{
							tmp = roots[0];
						}

						if (tmp != null)
						{

							var layout = new mxCompactTreeLayout(graph, false);
							layout.edgeRouting = false;
							layout.levelDistance = 30;

							this.editorUi.executeLayout(function()
				    		{
								layout.execute(graph.getDefaultParent(), tmp);
				    		}, true);
						}
					}), parent);
					menu.addItem(mxResources.get('radialTree'), null, mxUtils.bind(this, function()
					{
						var tmp = graph.getSelectionCell();
						var roots = null;

						if (tmp == null || graph.getModel().getChildCount(tmp) == 0)
						{
							if (graph.getModel().getEdgeCount(tmp) == 0)
							{
								roots = graph.findTreeRoots(graph.getDefaultParent());
							}
						}
						else
						{
							roots = graph.findTreeRoots(tmp);
						}

						if (roots != null && roots.length > 0)
						{
							tmp = roots[0];
						}

						if (tmp != null)
						{
							var layout = new mxRadialTreeLayout(graph, false);
							layout.levelDistance = 60;
							layout.autoRadius = true;

				    		this.editorUi.executeLayout(function()
				    		{
				    			layout.execute(graph.getDefaultParent(), tmp);

				    			if (!graph.isSelectionEmpty())
				    			{
					    			tmp = graph.getModel().getParent(tmp);

					    			if (graph.getModel().isVertex(tmp))
					    			{
					    				graph.updateGroupBounds([tmp], graph.gridSize * 2, true);
					    			}
				    			}
				    		}, true);
						}
					}), parent);
					menu.addSeparator(parent);
					menu.addItem(mxResources.get('organic'), null, mxUtils.bind(this, function()
					{
						var layout = new mxFastOrganicLayout(graph);

			    		this.editorUi.executeLayout(function()
			    		{
			    			var tmp = graph.getSelectionCell();

			    			if (tmp == null || graph.getModel().getChildCount(tmp) == 0)
			    			{
			    				tmp = graph.getDefaultParent();
			    			}

			    			layout.execute(tmp);

			    			if (graph.getModel().isVertex(tmp))
			    			{
			    				graph.updateGroupBounds([tmp], graph.gridSize * 2, true);
			    			}
			    		}, true);
					}), parent);
					menu.addItem(mxResources.get('circle'), null, mxUtils.bind(this, function()
					{
						var layout = new mxCircleLayout(graph);
			    		this.editorUi.executeLayout(function()
			    		{
			    			var tmp = graph.getSelectionCell();

			    			if (tmp == null || graph.getModel().getChildCount(tmp) == 0)
			    			{
			    				tmp = graph.getDefaultParent();
			    			}

			    			layout.execute(tmp);

			    			if (graph.getModel().isVertex(tmp))
			    			{
			    				graph.updateGroupBounds([tmp], graph.gridSize * 2, true);
			    			}
			    		}, true);
					}), parent);
				})));
				this.put('navigation', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['home', '-', 'exitGroup', 'enterGroup', '-', 'expand', 'collapse', '-', 'collapsible'], parent);
				})));
				this.put('arrange', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['toFront', 'toBack', '-'], parent);
					this.addSubmenu('direction', menu, parent);
					this.addMenuItems(menu, ['turn', '-'], parent);
					this.addSubmenu('align', menu, parent);
					this.addSubmenu('distribute', menu, parent);
					menu.addSeparator(parent);
					this.addSubmenu('navigation', menu, parent);
					this.addSubmenu('insert', menu, parent);
					this.addSubmenu('layout', menu, parent);
					this.addMenuItems(menu, ['-', 'group', 'ungroup', 'removeFromGroup', '-', 'clearWaypoints', 'autosize'], parent);
				}))).isEnabled = isGraphEnabled;
				this.put('insert', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['insertLink', 'insertImage'], parent);
				})));
				this.put('view', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ((this.editorUi.format != null) ? ['formatPanel'] : []).
						concat(['outline', 'layers', '-', 'pageView', 'pageScale', '-', 'scrollbars', 'tooltips', '-',
						        'grid', 'guides', '-', 'connectionArrows', 'connectionPoints', '-',
						        'resetView', 'zoomIn', 'zoomOut'], parent));
				})));
				// Two special dropdowns that are only used in the toolbar
				this.put('viewPanels', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					if (this.editorUi.format != null)
					{
						this.addMenuItems(menu, ['formatPanel'], parent);
					}

					this.addMenuItems(menu, ['outline', 'layers'], parent);
				})));
				this.put('viewZoom', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['resetView', '-'], parent);
					var scales = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4];

					for (var i = 0; i < scales.length; i++)
					{
						(function(scale)
						{
							menu.addItem((scale * 100) + '%', null, function()
							{
								graph.zoomTo(scale);
							}, parent);
						})(scales[i]);
					}

					this.addMenuItems(menu, ['-', 'fitWindow', 'fitPageWidth', 'fitPage', 'fitTwoPages', '-', 'customZoom'], parent);
				})));
				this.put('file', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['pageSetup', 'print'], parent);
				})));
				this.put('edit', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['undo', 'redo', '-', 'cut', 'copy', 'paste', 'delete', '-', 'duplicate', '-',
					                         'editData', 'editTooltip', 'editStyle', '-', 'editLink', 'openLink', '-', 'selectVertices',
					                         'selectEdges', 'selectAll', 'selectNone', '-', 'lockUnlock']);
				})));
				this.put('extras', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['copyConnect', 'collapseExpand', '-', 'editDiagram']);
				})));
				this.put('help', new Menu(mxUtils.bind(this, function(menu, parent)
				{
					this.addMenuItems(menu, ['about']);
				})));
			};

			var artifactId = "";
			var editorUi;
			var garphEditorInstance;


			EditorUi.prototype.init = function() {

				editorUiInit.apply(this, arguments);
				//this.actions.get('export').setEnabled(false);

				var enabled = true;
				this.actions.get('open').setEnabled(enabled || Graph.fileSupport);
				this.actions.get('import').setEnabled(enabled || Graph.fileSupport);
				this.actions.get('save').setEnabled(enabled);
				this.actions.get('saveAs').setEnabled(enabled);
				this.actions.get('export').setEnabled(enabled);
				editorUi = this;
				var graphEditorInstance = this.editor;

				var artifactUrl = '<c:url value="/mxGraph/modelById.spr" />'

				var docId = '${docId}';
				var xml = "";
				if (docId && docId.length > 0) {
					$.post(artifactUrl, { artifactId: docId }).done(function( data ) {
						xml = data.substring(data.indexOf("<model>") + 7, data.indexOf("</model>"));
						var doc = mxUtils.parseXml(xml);
						var node = doc.documentElement;
						graphEditorInstance.setGraphXml(node);
						graphEditorInstance.setModified(false);
						graphEditorInstance.undoManager.clear();
					});
				}

				EditorUi.prototype.saveFile = function(forceDialog)
				{
					if ((docId && docId.length > 0) || !forceDialog && editorUi.editor.filename != null)
					{
						editorUi.save(editorUi.editor.getOrCreateFilename());
					}
					else
					{
						var dlg = new FilenameDialog(editorUi, 'diagram.cbmxml', mxResources.get('save'), mxUtils.bind(editorUi, function(name)
						{
							editorUi.save(name);
						}), null, mxUtils.bind(editorUi, function(name)
						{
							if (name != null && name.length > 0)
							{
								return true;
							}

							mxUtils.confirm(mxResources.get('invalidName'));

							return false;
						}));
						editorUi.showDialog(dlg.container, 300, 100, true, true);
						dlg.init();
					}
				};

				EditorUi.prototype.save = function(name)
				{
					var self = this;

					//if (name != null)
					{
						if (this.editor.graph.isEditing())
						{
							this.editor.graph.stopEditing();
						}

						var xml = mxUtils.getXml(this.editor.getGraphXml());

						graphEditorInstance.graph.minFitScale = null;

						var xmlDoc = mxUtils.createXmlDocument();
						var root = xmlDoc.createElement('output');
						xmlDoc.appendChild(root);

						var xmlCanvas = new mxXmlCanvas2D(root);
						var scale = graphEditorInstance.graph.view.scale;
						var bounds = graphEditorInstance.graph.getGraphBounds();
						var vs = graphEditorInstance.graph.view.scale;
						xmlCanvas.translate(Math.floor((1 / scale - bounds.x) / vs), Math.floor((1 / scale - bounds.y) / vs));
						xmlCanvas.scale(scale / vs);
						var imgExport = new mxImageExport();
						imgExport.drawState(graphEditorInstance.graph.getView().getState(graphEditorInstance.graph.model.root), xmlCanvas);

						var bounds = graphEditorInstance.graph.getGraphBounds();
						var w =  Math.ceil(bounds.width / vs + 2 * 1);
						var h =  Math.ceil(bounds.height / vs + 2 * 1);

						var xml2 = mxUtils.getXml(root);

						var cbXml = "<root><model>" + xml + "</model><state><infoAttributes><graphWidth>" + w + "</graphWidth><graphHeight>" + h + "</graphHeight></infoAttributes>" + xml2 + "</state></root>";
						try
						{
							if (xml.length < MAX_REQUEST_SIZE)
							{
								if (docId && docId.length > 0) {
									$.post(saveUrl, { artifactId: docId, cbXml: cbXml}).done(function( data ) {
										self.editor.modified = false;
										window.parent.location.reload();
										window.parent.inlinePopup.close();
									});

								} else {
									var extension = '.cbmxml';

									if (!(name.length >= extension.length && name.substr(name.length - extension.length) == extension)) {
										name += '.cbmxml';
									}
									$.post(artifactCreateUrl, { fileName: name, cbXml: cbXml, dirId: '${dirId}', projId: '${projId}' }).done(function( data ) {
										self.editor.modified = false;
										window.parent.location.reload();
										window.parent.inlinePopup.close();
									});
								}
								/*new mxXmlRequest(SAVE_URL, 'filename=' + encodeURIComponent(name) +
									'&xml=' + encodeURIComponent(xml)).simulate(document, '_blank');*/
							}
							else
							{
								mxUtils.alert(mxResources.get('drawingTooLarge'));
								mxUtils.popup(xml);

								return;
							}


						}
						catch (e)
						{
							this.editor.setStatus('Error saving file');
						}
					}
				};
			};

			// Adds required resources (disables loading of fallback properties, this can only
			// be used if we know that all keys are defined in the language specific file)
			mxResources.loadDefaultBundle = false;
			var bundle = mxResources.getDefaultBundle(RESOURCE_BASE, mxLanguage) ||
				mxResources.getSpecialBundle(RESOURCE_BASE, mxLanguage);

			// Fixes possible asynchronous requests
			mxUtils.getAll([bundle, STYLE_PATH + '/default.xml'], function(xhr)
			{
				// Adds bundle text to resources
				mxResources.parse(xhr[0].getText());

				// Configures the default graph theme
				var themes = new Object();
				themes[Graph.prototype.defaultThemeName] = xhr[1].getDocumentElement();

				// Main
				new EditorUi(new Editor(urlParams['chrome'] == '0', themes), document.getElementById("customGeEditor"));
			}, function()
			{
				document.body.innerHTML = '<center style="margin-top:10%;">Error loading resource files. Please check browser console.</center>';
			});
		})();
	</script>
</body>
</html>
