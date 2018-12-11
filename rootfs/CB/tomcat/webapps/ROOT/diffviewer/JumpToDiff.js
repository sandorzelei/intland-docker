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

/**
 * Javascript class scrolls up and down to the next difference on the diff-viewer.
 */
( function() {

	JumpToDiff = {

		/**
		 * Find diff-elements which can be selected
		 */
		findDiffElements: function() {
			var $elements = $("#diffContainer").find(".diff-added,.diff-deleted,.diff-changed");
			return $elements;
		},

		/**
		 * Find the previous and next diff element of the currently selected
		 * @return An object with the previous and next diff element can be selected
		 */
		findNextPrevDiffElements:function() {
			var els = JumpToDiff.findDiffElements();

			var firstSelectedIdx = null;
			var lastSelectedIdx = null;

			for (var i=0; i<els.length; i++) {
				var el = els[i];
				if ($(el).hasClass("diff-selected")) {
					if (firstSelectedIdx == null) {
						firstSelectedIdx = i;
					}
					lastSelectedIdx = i;
				}
			}

			if (firstSelectedIdx != null) {
				var result = {
						prevElem: firstSelectedIdx >0 ? els[firstSelectedIdx-1]: null,
						nextElem: lastSelectedIdx+1 <els.length ? els[lastSelectedIdx+1]: null
				};

				return result;
			}

			// nothing is selected, return the first as "next" and last as "prev"
			if (els.length==0) {
				return { prevElem: null, nextElem:null };
			}
			return { prevElem: els[els.length-1], nextElem: els[0] };
		},

		clearAllSelection: function() {
			// clear all selection
			$("#diffContainer .diff-selected").removeClass("diff-selected");
		},

		jumpTo: function(newSelection, scrollToDelta) {
			JumpToDiff.clearAllSelection();
			// select new
			if (newSelection != null) {
				JumpToDiff.selectElement(newSelection);
				ScrollUtil.scrollPageToElement(newSelection, 200 /*sec*/, -140 /* leave 140px space above the selected diff */);
			}
		},

		jumpToPrev: function() {
			var els = JumpToDiff.findNextPrevDiffElements();
			if (els.prevElem == null) {
				// previous not found, wrap around
				JumpToDiff.clearAllSelection();
				els = JumpToDiff.findNextPrevDiffElements();
			}
			JumpToDiff.jumpTo(els.prevElem);
		},

		jumpToNext: function() {
			var els = JumpToDiff.findNextPrevDiffElements();
			if (els.nextElem == null) {
				// next not found, wrap around
				JumpToDiff.clearAllSelection();
				els = JumpToDiff.findNextPrevDiffElements();
			}
			JumpToDiff.jumpTo(els.nextElem);
		},

		/**
		 * Select the element and the other elements may appear immediately next to it, so they will all appear
		 */
		selectElement: function(newSelection) {
			var selected = "diff-selected";
			
			$(newSelection).addClass(selected);
			var selectedRegion = JumpToDiff.getRegion(newSelection);
			selectedRegion = JumpToDiff.growRegion(selectedRegion, 2);

			// extend the selection to all html elements, which appear right next to the element to be selected
			var els = JumpToDiff.findDiffElements();
			var regionChanged;
			do {
				regionChanged = false;
				for (var i=0; i< els.length; i++) {
					var el = els[i];
					if (! $(el).hasClass(selected)) {
						var region = JumpToDiff.getRegion(el);
						var overlaps = JumpToDiff.intersectRegion(selectedRegion, region);
						if (overlaps != null) {
							// extend the selection to this element, because it is very close/overlaps to the other element
							$(el).addClass(selected);
							selectedRegion = JumpToDiff.unionRegion(selectedRegion, region);	// extend the selection region
							selectedRegion = JumpToDiff.growRegion(selectedRegion, 2);
							regionChanged = true;
						}
					}
				}
			} while (regionChanged);	// keep extending the region untill all elements selected; necessary for "previous" selections
		},		

		/**
		 * Grow the region on each side with few pixels
		 * @param num The number of pixels to grow by
		 * @return The grown region
		 */
		growRegion: function(region, num) {
			return {
				top: region.top - num,
				left: region.left - num,
				bottom: region.bottom + num,
				right: region.right + num
			};
		},

		getRegion: function(el) {
			var offset = $(el).offset();
			return {
				top: offset.top,
				left: offset.left,
				bottom: offset.top + $(el).outerHeight(),
				right: offset.left + $(el).outerWidth()
			}
		},

		intersectRegion: function(region1, region2) {
			var t = Math.max(region1.top, region2.top),
				r = Math.min(region1.right, region2.right),
				b = Math.min(region1.bottom, region2.bottom ),
				l = Math.max(region1.left, region2.left);

			if (b >= t && r >= l) {
				return {
					top: t,
					left: l,
					bottom: b,
					right: r
				};
			} else {
				return null;
			}
		},

		unionRegion: function(region1, region2) {
			var t = Math.min(region1.top, region2.top),
				r = Math.max(region1.right, region2.right),
				b = Math.max(region1.bottom, region2.bottom),
				l = Math.min(region1.left, region2.left);
			return {
				top: t,
				left: l,
				bottom: b,
				right: r
			};
		}

	};

})();
