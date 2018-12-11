/*
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
function mxCustomEdgeLabelLayout(graph, radius)
{
	mxGraphLayout.call(this, graph);
};

/**
 * Extends mxGraphLayout.
 */
mxCustomEdgeLabelLayout.prototype = new mxGraphLayout();
mxCustomEdgeLabelLayout.prototype.constructor = mxCustomEdgeLabelLayout;

/**
 * Function: execute
 * 
 * Implements <mxGraphLayout.execute>.
 */
mxCustomEdgeLabelLayout.prototype.execute = function(edgesArray, cellsArray)
{
	var view = this.graph.view;
	var model = this.graph.getModel();
	
	// Gets all vertices and edges
	var edges = [];
	var vertices = [];
	
	var edges = [];
	var vertices = [];
	
	for (var i = 0; i < edgesArray.length; i++)
	{
		
		var state = view.getState(edgesArray[i]);
		
		if (state != null)
		{
			if (!this.isEdgeIgnored(edgesArray[i]))
			{
				edges.push(state);
			}
		}
	}
	
	for (var i = 0; i < cellsArray.length; i++)
	{
		
		var state = view.getState(cellsArray[i]);
		
		if (state != null)
		{
			if (!this.isVertexIgnored(cellsArray[i]))
			{
				vertices.push(state);
			}
		}
	}
	
	this.placeLabels(vertices, edges);
};


mxCustomEdgeLabelLayout.prototype.initContainer = function(v, e) {
	var graphContainer = [];
	
	for (var i = 0; i < e.length; i++) {
		var edge = e[i];
		if (edge != null && 
			edge.text != null &&
			edge.text.boundingBox != null) {
			var x1 = edge.text.boundingBox.x;
			var y1 = edge.text.boundingBox.y;
			var x2 = x1 + edge.text.boundingBox.width;
			var y2 = y1 + edge.text.boundingBox.height;
			graphContainer.push({
				x1: x1,
				y1: y1,
				x2: x2,
				y2: y2,
				movable: true,
				node: edge
			});
		}
	}
	
	for (var i = 0; i < v.length; i++) {
		var vertex = v[i];
		if (vertex != null) {
			var x1 = vertex.x;
			var y1 = vertex.y;
			var x2 = x1 + vertex.width;
			var y2 = y1 + vertex.height;
			
			graphContainer.push({
				x1: x1,
				y1: y1,
				x2: x2,
				y2: y2,
				movable: false,
				node: vertex
			});
		}
	}
	
	return graphContainer;
}

mxCustomEdgeLabelLayout.prototype.placeLabels = function(v, e)
{
	var graphContainer = this.initContainer(v, e);
	
	// Moves the vertices to build a circle. Makes sure the
	// radius is large enough for the vertices to not
	// overlap
	this.layout(graphContainer);
	
};

mxCustomEdgeLabelLayout.prototype.moveNode = function(node1, node2, graphContainer, model)
{
	var move = 0;
	var labRect = node1.node.text.boundingBox;
	var vertex = null;
	if (node2.movable) {
		vertex = node2.node.text.boundingBox;
	} else {
		vertex = node2.node;
	}
	
	if (mxUtils.intersects(labRect, vertex))
	{
		var dy1 = -labRect.y - labRect.height + vertex.y;
		var dy2 = -labRect.y + vertex.y + vertex.height;
		
		var dy = (Math.abs(dy1) < Math.abs(dy2)) ? dy1 : dy2;
		
		var dx1 = -labRect.x - labRect.width + vertex.x;
		var dx2 = -labRect.x + vertex.x + vertex.width;
	
		var dx = (Math.abs(dx1) < Math.abs(dx2)) ? dx1 : dx2;
		
		if (Math.abs(dx) < Math.abs(dy))
		{
			dy = 0;
		}
		else
		{
			dx = 0;
		}
		
		var g = model.getGeometry(node1.node.cell);
		
		if (g != null)
		{
			g = g.clone();
			
			if (g.offset != null)
			{
				g.offset.x += dx;
				g.offset.y += dy;
			}
			else
			{
				g.offset = new mxPoint(dx, dy);
			}
			
			node1.x1 += dx;
			node1.x2 += dx;
			node1.y1 += dy;
			node1.y2 += dy;
			model.setGeometry(node1.node.cell, g);
			move = dx + dy;
		}
	}
	return move;
};

mxCustomEdgeLabelLayout.prototype.layout = function(graphContainer) {
	var move = 1;
	var threshold = 10;
	var iteration = 0;
	while(move > 0 && iteration < threshold) {
		++iteration;
		move = 0;
		var model = this.graph.getModel();
		
		

			for (var i = 0; i < graphContainer.length; ++i) {
				var node1 = graphContainer[i];
				for (var j = 0; j < graphContainer.length; ++j) {
					model.beginUpdate();
					try {
						var node2 = graphContainer[j];
	
						if (node1.node.cell != null && node2.node.cell != null && node1.node.cell.id != node2.node.cell.id) {
							var rect1 = null;
							var rect2 = null;
							if (node1.movable) {
								rect1 = node1.node.text.boundingBox;
							} else {
								rect1 = node1.node;
							}
							if (node2.movable) {
								rect2 = node2.node.text.boundingBox;
							} else {
								rect2 = node2.node;
							}
							if (mxUtils.intersects(rect1, rect2)) {
								var currentMove = 0;
								if (node1.movable) {
									currentMove = this.moveNode(node1, node2, graphContainer, model);
								}
								if (currentMove == 0 && node2.movable) {
									currentMove = this.moveNode(node2, node1, graphContainer, model);
								}
								if (currentMove != 0) {
									++move;
								}
							}
						}
					} finally {
						model.endUpdate();
					}
				}
			}
		
	}
};