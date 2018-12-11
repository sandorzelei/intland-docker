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
 * $Id$
--%>
<%@ tag language="java" pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<%--
	Tag renders two columns, which are split by a drag-able splitter, so ratio of the left/right part can be changed
	Similar to ui:splitTwoColumnLayout, except that this is implemented in JQuery's layout
--%>
<%@ attribute name="leftContent" fragment="true" required="false" description="The content of the left column" %>
<%@ attribute name="rightContent" fragment="true" required="false" description="The content of the right column" %>
<%@ attribute name="leftMinWidth" required="false" description="The minimum width of the left column" %>
<%@ attribute name="rightMinWidth" required="false" description="The minimum width of the right column" %>
<%@ attribute name="rightQuickOpenDisabled" required="false" description="Can open right panel just by clicking on the closed border" %>
<%@ attribute name="leftPaneActionBar" fragment="true" required="false"
	description="Optional header/action-bar will appear on top of the left pane"  %>
<%@ attribute name="middlePaneActionBar" fragment="true" required="false" %>
<%@ attribute name="rightPaneActionBar" fragment="true" required="false" %>
<%@ attribute name="layoutCookie" required="false"%>
<%@ attribute name="cssClass" description="Optional css class added to top element, can customize the look of the layout. Use 'fullPage' for covering the full-page" %>
<%@ attribute name="hideRightPane" required="false"%>
<%@ attribute name="disableCloserButtons" required="false"%>
<%@ attribute name="config" required="false"%>
<%@ attribute name="isPopup" required="false"%>

<style type="text/css">
	/**
	 * style for covering the full page
	 */
	.layoutfullPage {
		height: 100%;
	}
	.layoutfullPage #rightPane {
		height: 100%;
	}
	.layoutfullPage #west {
		height: 100%;
		overflow: hidden;
		padding-right: 0;
		padding-bottom: 1px;
		width: 200px;
	}
	#panes {
		display: none;
	}
	#panes .header {
		margin: 0;
	}

	.no-left-border {
		border-left: 0 !important;
	}

	.no-right-border {
		border-right: 0 !important;
	}
</style>

<c:set var="hasMiddleActionBar" value="${! empty middlePaneActionBar}"/>
<div id="panes" class="${cssClass}">
	<div class="ui-layout-center no-left-border" id="centerDiv" style="${hasMiddleActionBar ? 'overflow:hidden' : ''}">
		<c:if test="${hasMiddleActionBar}">
			<div class="header actionBar" id="middleHeaderDiv" style="margin:0px;top:0px !important;position:relative;">
				<jsp:invoke fragment="middlePaneActionBar"/>
			</div>
		</c:if>
		<!-- toolbar container for the shared froala editor -->
		<div id="toolbarContainer" class="editor-wrapper"></div>
		<div id="rightPane" style="${hasMiddleActionBar ? 'overflow:auto;' : ''}">
			<jsp:doBody/>
		</div>
	</div>
	<c:if test="${! empty leftContent}">
	<c:set var="leftHeaderDivId" value=""/>
	<div id="west" class="ui-layout-west no-right-border">
		<c:set var="leftHeaderDivId" value="headerDiv"/>
		<c:if test="${! empty leftPaneActionBar}">
			<div class="header actionBar" id="headerDiv" style="margin:0px;">
				<jsp:invoke fragment="leftPaneActionBar"/>
			</div>
		</c:if>
		<jsp:invoke fragment="leftContent"/>
	</div>
	</c:if>
	<c:set var="rightHeaderDivId" value=""/>
	<c:if test="${!empty rightContent && !hideRightPane}">
		<div id="east" class="ui-layout-east">
			<c:if test="${! empty rightPaneActionBar}">
				<c:set var="rightHeaderDivId" value="rightHeaderDiv"/>
				<div class="header actionBar" id="rightHeaderDiv" style="margin:0px;">
					<jsp:invoke fragment="rightPaneActionBar"/>
				</div>
			</c:if>
			<jsp:invoke fragment="rightContent"/>
		</div>
	</c:if>
</div>

<script type="text/javascript">
	jQuery(function($) {
		codebeamer.initLayout("panes", "${leftHeaderDivId}", "${rightHeaderDivId}", "closer", ${!empty layoutCookie ? '"' + layoutCookie + '"' : '""'},
			${!empty leftMinWidth ? leftMinWidth : "null"}, ${!empty rightMinWidth ? rightMinWidth : "null"}, ${rightQuickOpenDisabled ? 'true' : 'false'},
			${disableCloserButtons ? 'true' : false}, ${!empty config ? config : '{}'}, ${isPopup ? 'true' : 'false'});

		var panes = $("#panes");
		var $window = $(window);

		// these two variables are needed to fix flaws in IE8 which might otherwise enter an infinite loop
		// see: http://stackoverflow.com/questions/1852751/window-resize-event-firing-in-internet-explorer
		var lastWindowHeight = $window.height();
		var lastWindowWidth = $window.width();

		/**
		 * Schedule an adjustment function a specified times with a specified interval in between, that is needed
		 * because border layout (re)initializes itself slowly, but we have to wait for it to be ready.
		 * @param callback Callback function
		 * @param step How much milliseconds to wait between calls (default is 300). First call is applied after that, too
		 * @param times How many times to call it (default is 2)
		 * @param finalCallback Callback to invoke right after last iteration is ready (optional, can be supplied as 2nd parameter as well)
		 */
		var schedulePaneAdjustment = function(callback, step, times, finalCallback) {
			if ($.isFunction(step)) {
				finalCallback = step;
				step = null;
			}
			step = step || 300;
			times = times || 2;
			for (var i = 1; i <= times; i++) {
				(function(i) {
					setTimeout(function() {
						callback.call();
						if (i == times && $.isFunction(finalCallback)) {
							finalCallback.call();
						}
					}, i * step);
				})(i);
			}
		};

		/**
		 * If panes container has this 'autoAdjustPanesHeight' class, container height will be adjusted to window
		 * size automatically, taking also the footer height into account.
		 */
		if (panes.hasClass("autoAdjustPanesHeight")) {

			var adjustPanesHeight = function() {
				autoAdjustPanesHeight($window);
				panes.find(".ui-accordion.ui-widget").accordion("refresh"); // also refresh accordion controls
			};

			var windowResizeHandler = throttleWrapper(function() {
				if ($(window).height() != lastWindowHeight || $(window).width() != lastWindowWidth) {
					lastWindowHeight = $(window).height();
					lastWindowWidth = $(window).width();

					schedulePaneAdjustment(adjustPanesHeight);
				}
			}, 25);

			var forceWindowResizeHandler = function() {
				lastWindowHeight = lastWindowWidth = 0;
				windowResizeHandler();
			};

			$("body").css("overflow", "hidden");
			schedulePaneAdjustment(adjustPanesHeight);
			$(window).resize(windowResizeHandler);

			panes.bind("westResize", forceWindowResizeHandler);
			panes.bind("eastResize", forceWindowResizeHandler);
		}

		setTimeout(function() {
			var $existingOpener = $("#opener-west");
			if ($existingOpener.length > 0) {
				var $leftPanel = $("#west");
				$existingOpener.toggle($leftPanel.length == 0 || !$leftPanel.is(":visible"));
			}
		}, 500);
	});

</script>
