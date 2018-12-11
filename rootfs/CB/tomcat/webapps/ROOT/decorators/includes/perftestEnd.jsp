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

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<%--
	scriptlet prints out the performance test's results.
--%>

<script type="text/javascript">
	// print out pertest statistics
	function printStatistics() {
		var stat = "";
		var startTime = perftest.startTime;
		// stat += "startTime: " + perftest.startTime +"\n";
		stat += "headerLoaded: " + (perftest.headerLoaded - startTime)   +"\n";
		stat += "footerLoaded: " + (perftest.footerLoaded - startTime)   +"\n";
		stat += "firstDOMReady: " + (perftest.firstDOMReady - startTime) +"\n";
		stat += "lastDOMReady: " + (perftest.lastDOMReady - startTime)   +"\n";
		alert(stat);
	}

	perftest.footerLoaded = (new Date()).getTime();

	$(function() {
		perftest.lastDOMReady = (new Date()).getTime();

		// a bit later print the statistics
		window.setTimeout(printStatistics, 3000);
	});
</script>
