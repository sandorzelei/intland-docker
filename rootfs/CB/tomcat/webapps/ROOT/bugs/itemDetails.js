
/**
 * Hide/show the long list of the elements/references: only the first 10 elements is visible, and adds a toggle image-button that can be used to show the rest...
 * @returns
 */
function hideLongListOfElements() {
	// hide the long list of elements
	$(".hideLongListOfElements").each(function() {
		var $el = $(this),
			$choiceFieldWrapper = $el.children('.choice-field-wrapper');

		if ($el.find(".showLongListOfElementsToggle").length >0) {
			//already initalized
			return;
		}
		var numHidden = $el.find("a:hidden").length;
		if (numHidden == 0) {
			// nothing is hidden
			return;
		}

		var title = i18n.message("show.x.more", numHidden);

		// add the link that shows the hidden items, "position" it to remove from the flow
		$choiceFieldWrapper.append(
		    $('<a class="showLongListOfElementsToggle" href="#" title="' + title +'"><img src="' + contextPath + '/images/expand_icon_right.gif"/></a>').click( function(event){
		      	event.preventDefault();
		      	$el.removeClass("hideLongListOfElements");
		      	$(this).remove();
		    })
		   );
	});
}