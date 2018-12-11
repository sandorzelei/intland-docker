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
 *
 * $Revision$ $Date$
 */

/**
 * class supporting the ajax-Tagging and the Favourites/Starred widget
 */
function TaggingWidget(elementId, entityTypeId, entityId, tagged, tagName, onTitle, offTitle, enabled) {
	if (this == window) {
		return new Favourites(elementId, entityTypeId, entityId, tagged, tagName, onTitle, offTitle, enabled);
	}
	this.init(elementId, entityTypeId, entityId, tagged, tagName, onTitle, offTitle, enabled);
}

TaggingWidget.prototype = {

	CSS_CLASS: "tagged",

	/**
	 * Initialize the TaggingWidget html element
	 * @param elementId The element id
	 * @param tagged If the element is marked as tagged
	 * @param tagName The tag's name which is added/removed
	 * @param onTitle The html title for the "on" status
	 * @param offTitle The html title for the "off" status
	 * @param enabled If the widget is enabled
	 */
	init: function(elementId, entityTypeId, entityId, tagged, tagName, onTitle, offTitle, enabled) {
		this.elementId = elementId;
		this.entityTypeId = entityTypeId;
		this.entityId = entityId;
		this.tagName = tagName;
		this.onTitle = onTitle;
		this.offTitle = offTitle;
		this.enabled = enabled;
		this.addEventListener(elementId);
		this.setTagged(tagged);
	},

	addEventListener: function(elementId) {
		this.el = $("#" + elementId);
		var self = this;
		this.el.click(function() {
			self.onClick();
		});
	},

	onClick: function() {
		if (this.enabled == false) {
			alert(i18n.message("tags.starring.disabled"));
			return;
		}
		var tagged = this.isTagged();

		var self = this;
		// fire ajax request
		this.submitTagging(this.entityTypeId, this.entityId, this.tagName, !tagged, function(data) {
			console.log("Successfully changed tag <" + self.tagName + "> on <" + data +">" );
			self.setTagged(!tagged);
		});
		return false;
	},
	
	submitTagging:function(entityTypeId, entityId, tagName, applyTag, onSuccess) {
		var self = this;
		if (self.updateRunning) {
			console.log("Ajax update is already running, ignoring this click.");
			return;
		}
		self.updateRunning = true;

		var url = contextPath + "/ajax/setTagApplied.spr";
		var data = {
			"entityTypeId": entityTypeId,
			"entityId": entityId,
			"apply": applyTag,
			"tagName": tagName
		};
		$.ajax({
			url: url,
			data: data,
			method: "POST",
			success: function(data) {
				onSuccess(data);
			},
			error: function(jqXHR) {
				AjaxErrorReport.reportAjaxFailure(jqXHR, "Failed to change Tag/set Starred on " + entityTypeId + ", id=" + entityId + ", because:" + jqXHR.responseText);				
			}		
		}).done(function(){
			self.updateRunning = false;
		});
	},

	isTagged: function() {
		return $(this.el).hasClass(this.CSS_CLASS);
	},

	setTagged: function(tagged) {
		$(this.el).toggleClass(this.CSS_CLASS, tagged);

		var title;
		if (this.enabled == false) {
			title = i18n.message("tags.starring.disabled");
		} else {
			title = tagged ? this.onTitle : this.offTitle;
		}
		$(this.el).attr("title", title);
	}

};

function toggleFavouriteMenu(menu, groupType, entityId) {
	var onTitle = i18n.message("tags.starring.on.title");
	var offTitle = i18n.message("tags.starring.off.title");
	var $menu = $(menu);
	var tagging = $menu.hasClass("starIt");
	TaggingWidget.prototype.submitTagging(groupType, entityId, "#Starred", tagging, function() {
		var html = $menu.html();
		if (tagging) {
			html = html.replace(offTitle, onTitle);
			html = html.replace("star-inactive", "star-active");
			$menu.removeClass("starIt");
			$menu.addClass("unstarIt");
		} else {
			html = html.replace(onTitle, offTitle);
			html = html.replace("star-active", "star-inactive");
			$menu.removeClass("unstarIt");
			$menu.addClass("starIt");
		}
		$menu.html(html);

		if ($menu.hasClass("reloadPage")) {
			window.location.reload();
		}
	});
}
