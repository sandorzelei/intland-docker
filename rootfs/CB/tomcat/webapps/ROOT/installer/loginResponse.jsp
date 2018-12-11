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

<meta name="decorator" content="popup"/>

<script type="text/javascript" src="<ui:urlversioned value='/js/installer/jquery-serialize.js'/>"></script>

<%-- <form name="result">
	<c:forEach items="${result}" var="entry">
		<input type="hidden" name="${entry.key}" value="${entry.value}"/>
	</c:forEach>
</form>--%>

<script type="text/javascript">
	jQuery.fn.serializeObject = function () {
		var arrayData, objectData;
		arrayData = this.serializeArray();
		objectData = {};

		$.each(arrayData, function () {
			var value;

			if (this.value != null) {
				value = this.value;
			} else {
				value = '';
			}

			if (objectData[this.name] != null) {
				if (!objectData[this.name].push) {
					objectData[this.name] = [objectData[this.name]];
				}

				objectData[this.name].push(value);
			} else {
				objectData[this.name] = value;
			}
		});

		return objectData;
	};
	$(document).ready(function () {
		//var data = $("form").serializeObject();
		window.parent.postMessage("${result}", "*");
	});
</script>
