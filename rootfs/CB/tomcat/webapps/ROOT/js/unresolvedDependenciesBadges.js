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
codebeamer.UnresolvedDependenciesBadges = codebeamer.UnresolvedDependenciesBadges || (function($) {
	function _handleBadgeClick() {
		var itemId = $(this).data('item-id');
		
		if (itemId) {
			inlinePopup.show(contextPath + '/unresolvedDependencies.spr?itemId=' + itemId);
			
			return false;
		}
	}
	function init($container) {
		var $context = $container && $container.length ? $container : $(document);
		
		$context.off('click', '.udBadge.active', _handleBadgeClick);
		$context.on('click', '.udBadge.active', _handleBadgeClick);
	}
	return {
		init: init
	}
})(jQuery);