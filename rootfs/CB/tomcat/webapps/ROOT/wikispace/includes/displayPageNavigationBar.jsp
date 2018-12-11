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
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="uitaglib" prefix="ui" %>

<div class="navigationHeader noPrint">
	<div style="float:left;"><c:out value="${navBarRevision.dto.name}" /></div>
	<div style="float:left;">
		<ui:actionMenu builder="wikiNavigationBarActionMenuBuilder" subject="${navBarRevision}" />
	</div>
	<div style="clear:both;"></div>
</div>
<div class="wikiNavigationBar noPrint">
	<c:out value="${navBarContent}" escapeXml="false" />
</div>

<script type="text/javascript">
	$(function() {
		var $navigationCell = $('.wikiNavigationBar').closest('.navigation');

		function attachHandlers() {
			$('#closer-east').on('click', function() {
				$navigationCell.hide();
				$('#opener-east').show();
				$('#closer-east').hide();
				window.localStorage.codebeamerWikiNavigationBar = 'closed'; 
			});

			$('#opener-east').on('click', function() {
				$navigationCell.show();
				$('#opener-east').hide();
				$('#closer-east').show();
				window.localStorage.codebeamerWikiNavigationBar = 'opened';
			});
		}

		attachHandlers();
		
		if (window.localStorage.codebeamerWikiNavigationBar == 'closed') {
			$navigationCell.hide();
			$('#opener-east').show();
		} else {
			$('#closer-east').show();
		}
		
		var wikiActionBarChanged = function() {
			if (window.localStorage.codebeamerWikiNavigationBar == 'closed') {
				$('#opener-east').show();
			} else {
				$('#closer-east').show();	
			}
			attachHandlers();
			$('#rightPane').off('wikiActionBarChanged', wikiActionBarChanged);	
		};
		
		$('#rightPane').on('wikiActionBarChanged', wikiActionBarChanged);
	});
</script>