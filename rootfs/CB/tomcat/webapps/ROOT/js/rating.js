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

/**
 * Base class for Raging/Voting widget
 */
function RatingBase() {
}

RatingBase.prototype = {

	// the (jquery selector) for root element for the widget
	element: null,
	// the url to post to
	post_to: contextPath + "/ajax/setObjectRating.spr",
	// entity parameters for url
	entityTypeId: null,
	entityId: null,
	// the current statistics: an ObjectRatingStatsDto
	objectRatingStats: null,
	// the user's rating/voting object: an ObjectRatingDto
	userRating: null,
	// arguments for the dialog appears on hover
	dialogParams: {
		dialogClass: "ratingTooltipDialog",
		autoOpen:true,
		resizable: false,
		draggable: false,
		title: null,
		width: 400,
		maxWidth: 400,
		position: { of: null, my: "right top+5", at: "right bottom" },
		show: { effect: "fade",	duration: 300 },
		hide: { effect: "fade",	duration: 300 },
		closeDelay: 100000 /* using a really long time until the dialog closes*/
	},

	/**
	 * constructor
	 * @param element The root element for the widget
     * @param userRating The current user's rating, or null if not yet rated this object
     * @param entityTypeId The entity-type
     * @param entityId The entity id
     */
	init: function(element, objectRatingStats , userRating, entityTypeId, entityId) {
		this.element = element;
		this.objectRatingStats = objectRatingStats;
		this.userRating = userRating || {};	// avoid null
		this.entityTypeId = entityTypeId;
		this.entityId = entityId;
		if (entityTypeId == null || entityId == null) {
			throw "Missing required entityTypeId or entityId parameters!";
		}
		this.updateStats(false);
	},

	/**
	 * Submit the rating via ajax
	 * @param num The rating number (index of star) has been clicked on
	 * @param ratingType Boolean: if this is rating (true) or a voting (false)?
	 */
    submit_rating: function(num, ratingType, comment, dialog) {
    	if (num == null) {
    		alert(i18n.message("rating.select.one.warning"));
    		return;
    	}

        // check if submission is not in progress to avoid double submissions
        if (this.submitting) {
        	return;
        }
        var data = {
            	"rating" : num,
            	"ratingType": ratingType,
            	"entityTypeId" :  this.entityTypeId,
            	"entityId": this.entityId,
            	"comment": comment,
            	cancelled: false
            };
        if (this.confirm_submit(data)) {
        	this.do_submit_rating(data);
        }
        var self = this;

        var $widget = this.getWidget();
        $widget.one("afterRatingSubmitted", function() {
        	self.showSavedMessage(dialog);
        	var $dialog = $widget.data("ratingDialog");
        	$dialog.dialog("close");
        });
    },

    showSavedMessage:function(dialog) {
    	if (dialog) {
			var opts = {};
			if ($(dialog).length > 0) {
				opts.position = {
					my: "center top",
					at: "center top+4",
					of: dialog
				};
			};

			showOverlayMessageWithOptions(i18n.message("rating.saved.message"), opts);
    	}
    },

    /**
     * called before submitting to the server, it should return true if the data should be really submitted
     */
    confirm_submit: function(data) {
        // fire a custom event
        var $widget = this.getWidget();
        $widget.trigger("beforeRatingSubmitted", [data, this]);
        // if the event listeners set the data.cancelled=true then don't submit the data
        if (data.cancelled) {
        	console.log("Submitting rating is cancelled!");
        	return false;
        }
    	return true;
    },

    do_submit_rating: function(data) {
        // save user's rating
        this.userRating.rate = data.rating;
        this.userRating.comment = escapeHtml(data.comment);
		this.setSubmitting(true);

        // change the rating-value for the form and submit the form
        var url = this.post_to;
        var self = this;
        var $widget = this.getWidget();

        $.ajax({
        	type: 'POST',
        	url: url,
        	data: data,
        	success: function(data) {
        		// the json message contains properties for the new values of ObjectRatingStatsDto
        		self.objectRatingStats = data;
        		self.updateWidget();

        		$widget.trigger("afterRatingSubmitted", [data, self]);
        	}
        })
        .fail(function(o) {
        	$widget.trigger("afterRatingSubmitted", o, [data, self]);
        	if (o.status != 401) {
	        	// we shouldn't ever go down this path.
	        	AjaxErrorReport.reportAjaxFailure(o);
        	}
        })
        .always(function(){
        	self.setSubmitting(false);
        });
    },

    // change the status of widget, because we're submitting the the rating value
    setSubmitting: function(submitting) {
    	var widget = this.getWidget();
		$(widget).toggleClass("rating-submitting", submitting);

    	if (! submitting) {
    		this.updateStats(true);
    	}
    	this.submitting = submitting;
    },

    // update the statistics in tooltips with the current values
    // @param show if it immediately shows the tooltip
    updateStats: function(show) {
    	var msg = this.getTooltipMessage();
    	if (! msg) {
    		return;	// no message
    	}

    	var $widget = $(this.getWidget());
    	if ($widget.length == 0) {
    		return;
    	}

    	// add a button to close the dialog
    	msg = "<a href='#' class='closeRatingButton'></a>" + msg;

    	var self = this;

		var $dialog = $widget.data("ratingDialog");
		if (! $dialog) {
			// create the dialog's container
			$widget.append("<div class='ratingDialog' style='display:none;' ></div>");
			$dialog = $widget.find(".ratingDialog");
			$widget.data("ratingDialog", $dialog);
		}

		$dialog.html(msg);
		self.initTooltip($dialog);

		var hideDialog = function() {
			$dialog.dialog("close");
		};
		$dialog.find(".closeRatingButton").click(hideDialog);

		var showDialog = function() {
			try {
				if ($dialog.dialog("isOpen")) {
					// dialog is already there and open
        			return true;
        		}
			} catch (ex) {
			}

			// show the dialog
			var args = $.extend({}, self.dialogParams);
			args.position.of = $widget;
    		$dialog.dialog(args);
		};

		var closeDelay = self.dialogParams.closeDelay;
		var $trigger = self.trigger ? $(self.trigger) : $widget;
		if (self.event) {
			$trigger.on(self.event, showDialog);
		} else {
			showOnHoverAndAutoHide($trigger, $dialog, showDialog, hideDialog , 300, closeDelay);
		}
    },

    // Get the message shown as tooltip for statistics
    getTooltipMessage: function() {
    	return null;
    },

    // callback when the tooltip is shown intialize it
    initTooltip: function(tooltip) {
    },

    // Get the widget to align the tooltip too
    getWidget: function() {
    	return null;
    },

    // callback to update the widget after ajax response is received
    updateWidget: function() {
    }

};

/**
 * Class/Constructor for voting controller.
 * @param element The root element this voting belongs to
 * @param objectRatingStats
 * @param userRating The current user's rating, or null if not yet rated this object
 * @param entityTypeId The entity-type
 * @param entityId The entity id
 */
Voting = function(element, objectRatingStats, userRating, entityTypeId, entityId) {
	if (this == window) {
		// create new object
		return new Voting(element, objectRatingStats, userRating, entityTypeId, entityId);
	}

	this.init(element, objectRatingStats, userRating, entityTypeId, entityId);
};

$.extend(true, Voting, {
    // initialize event handlers once on document, will handle all rating widgets...
    initEvents: function() {
    	var vote = function(element, value, event) {
    		var parent = $(element).closest(".votingwidget");
    		var votingWidget = $(parent).data("votingWidget");
    		votingWidget.submit_rating(value, false);

    		event.preventDefault();
    		return false;
    	};

    	$(document).on("click", ".yes-vote", function(event) {
    		return vote(this, +1, event);
    	});
    	$(document).on("click", ".no-vote", function(event) {
    		return vote(this, -1, event);
    	});
    }
});

// New methods and method overrides for Voting object
$.extend(Voting.prototype, RatingBase.prototype, {

	// the title has read from the title of the widget, always appears at beginning of the dialog
	title: null,

	/**
	 * @param element The root element for the widget
	 * @param objectRatingStats
 	 * @param userRating The current user's rating, or null if not yet rated this object
     * @param entityTypeId The entity-type
     * @param entityId The entity id
 	 */
    init: function(element, objectRatingStats, userRating, entityTypeId, entityId) {
		var $votingwidget = $(element);

		// remove the title attribute from the widget, that will appear in the dialog. This avoids the ugly double tooltips
		this.title = $votingwidget.attr("title");
		$votingwidget.attr("title", null);

		this.dialogParams = $.extend({}, this.dialogParams, {
			dialogClass: "ratingTooltipDialog votingTooltipDialog",
			closeDelay: 1000,	// no need to keep it open long, because we don't edit anything inside just displaying the numbers
			width: "auto",
			height: "auto",
			minHeight: "auto",
			position: { of: $votingwidget, my: "left top+5", at: "left bottom" }	// changing alignment
		});

    	// call super constructor
    	RatingBase.prototype.init.call(this, element, objectRatingStats, userRating, entityTypeId, entityId);

		// add event listeners
		$votingwidget.data("votingWidget", this);
    },

    /**
     * Update the voting widget with the new value.
     */
	updateWidget:function() {
		var $votingwidget = $(this.element);
		var $votingtotal = $votingwidget.find(".votingtotal").first();

		$votingtotal.html(this.objectRatingStats.ratingTotal);

		// note: when the ratingTotal is 0 then don't put neither "positive" or "negative" CSS class on it.
		$votingwidget.toggleClass('voted-total-positive', this.objectRatingStats.ratingTotal > 0);
		$votingwidget.toggleClass('voted-total-negative', this.objectRatingStats.ratingTotal < 0);

		// update CSS for user's voting
		var rate = this.userRating.rate;
		$votingwidget.toggleClass('voted-as-negative', rate < 0);
		$votingwidget.toggleClass('voted-as-positive', rate > 0);
	},

    // Get the message shown as tooltip for statistics
    getTooltipMessage: function() {
    	var title = "";
    	if (this.title != null) {
    		title = this.title +"<br/>";
    	}

    	if (this.objectRatingStats.numberOfRatings == 0) {
    		title += i18n.message("vote.tooltip.no.votes.yet");
    	} else {
			var positivevotes = (this.objectRatingStats.numberOfRatings + this.objectRatingStats.ratingTotal) / 2;
			var negativevotes = (this.objectRatingStats.numberOfRatings - this.objectRatingStats.ratingTotal) / 2;
			title += i18n.message("vote.tooltip.summary", positivevotes, negativevotes, this.objectRatingStats.numberOfRatings);
			if (this.userRating.rate != null) {
				title += "<br/> ";
				title += i18n.message("vote.tooltip.yourvote", (this.userRating.rate > 0 ? i18n.message("vote.tooltip.yourvote.yes"): i18n.message("vote.tooltip.yourvote.no")));
			}
    	}
		return title;
    },

    // Get the widget to align the tooltip too
    getWidget: function() {
    	var votingwidget = $(this.element);
    	return votingwidget;
    },

    /**
     * Confirmation function, asks to confirm the vote, and asks for a comment too.
     * Attach this to the "beforeRatingSubmitted" event of the vote widget.
     */
    confirmVoteAndAskComment:function(event, data, votingWidget) {
		// don't send the data, we'll send it after confirmation
		data.cancelled = true;

		var question = i18n.message("vote.confirm", (data.rating > 0 ? "+" : "") + data.rating);
		var msg = "<div class='actionMenuBar'><div class='actionMenuBarIcon'></div><h3 style='margin-top:7px'>" + question +"</h3></div>";
		msg += "<p style='padding: 5px 10px 0 5px;'><b>" + i18n.message("vote.comment") + "</b>" +
				"<br/><textarea id='voteComment' cols='30' rows='5' style='width: 100%;'></textarea></p>";
		// ask for comment
		showFancyConfirmDialogWithCallbacks(msg, function() {
			var $textarea = $("#voteComment");
			var comment = $textarea.val();
			data.comment = comment;
			data.cancelled = false;
			votingWidget.do_submit_rating(data);
		}, null, "");
		setTimeout(function() {$("#voteComment").focus();}, 300);
	}

});

/**
 * Class/Constructor for rating controller.
 * @param element The root element
 * @param objectRatingStats
 * @param userRating The current user's rating, or null if not yet rated this object
 * @param entityTypeId The entity-type
 * @param entityId The entity id
 * @param trigger The selector for the element that will trigger the opening of the voting overlay
 */
Rating = function (element, objectRatingStats, userRating, entityTypeId, entityId, trigger, event) {
	if (this == window) {
		// create new object
		return new Rating(element, objectRatingStats, userRating, entityTypeId, entityId, trigger, event);
	}

	this.init(element, objectRatingStats, userRating, entityTypeId, entityId, trigger, event);
};

$.extend(true, Rating, {

    // initialize event handlers once on document, will handle all rating widgets...
    initEvents: function() {
    	var callRatingWidget = function(star, action) {
    		var $star = $(star);
    		var $rating = $star.closest(".rating");
    		if ($rating.hasClass("ratingDisabled")) {
    			return;
    		}
    		var ratingObj = $rating.data("ratingWidget");
    		if (ratingObj) {
    			var starIdx = parseInt($star.attr("value"));
    			action.apply(ratingObj, [starIdx]);
    		} else {
    			console.log("Rating widget not found for:" + $rating);
    		}
    	};

    	// using shared event handlers for all rating widgets on page
    	$(document).on("mouseover", ".rating .star", function() {
    		callRatingWidget(this, function(starIdx) {
    			this.hover_star(starIdx);
    		});
    	});

    	$(document).on("mouseout", ".rating .star", function() {
    		callRatingWidget(this, function(starIdx) {
    			this.reset_stars(starIdx);
    		});
    	});

    	$(document).on("click", ".rating .star", function() {
    		callRatingWidget(this, function(starIdx) {
    			this.submit_rating(starIdx, true);
    		});
    	});
    }

});

/**
 * Class/Constructor for object shows rating stars widget only, without any tooltips whatsoever
 * @param element The root element
 * @param objectRatingStats
 * @param userRating The current user's rating, or null if not yet rated this object
 * @param entityTypeId The entity-type
 * @param entityId The entity id
 */
RatingStars = function (element, objectRatingStats, userRating, entityTypeId, entityId) {
	if (this == window) {
		// create new object
		return new RatingStars(element, objectRatingStats, userRating, entityTypeId, entityId);
	}

	this.init(element, objectRatingStats, userRating, entityTypeId, entityId);
};

$.extend(RatingStars.prototype, RatingBase.prototype, {
	/**
	 * @param element The root element for the widget
 	 * @param objectRatingStats
 	 * @param userRating The current user's rating, or null if not yet rated this object
     * @param entityTypeId The entity-type
     * @param entityId The entity id
 	 */
    init: function(element, objectRatingStats, userRating, entityTypeId, entityId) {
    	// call super constructor
    	RatingBase.prototype.init.call(this, element, objectRatingStats, userRating, entityTypeId, entityId);

    	this.createWidget();

    	// assign this to the HTML dom elements so we can find it
    	this.getWidget().data("ratingWidget", this);
    },

    createWidget: function() {
    	// already created in the tooltip
    },

	hover_star: function(which_star) {
	    /* highlights the selected star plus every star before it */
		this.getWidget().find(".star").each(function() {
			var $star = $(this);
			var i = $star.attr("value");
	        if (i <= which_star) {
	        	$star.addClass('hover');
	        } else {
	        	$star.removeClass('on');
	        }
			var $a = $star.find("a");
	        $a.css('width', '100%');
		});
	},

    _getLastStarWidth:function(value) {
        var percent = Math.round((value - Math.floor(value))* 1000) / 10.0;
        if (percent == 0) {
        	// the value happens to be an integer -> the whole last star is on
        	percent = 100;
        }
        return last_star_width = percent + '%';
    },

    // get the value shown
    getValue: function() {
    	// show the current selected value
        var value = this.userRating.rate;
        return value;
    },

	/* Resets the status of each star */
    reset_stars: function() {
    	// always showing average value
        var value = this.getValue();

        // compute how many stars are on, and the width for the last for the last
        var stars_on = Math.ceil(value);
        var last_star_width = this._getLastStarWidth(value);
    	this.getWidget().find(".star").each(function() {
    		var $star = $(this);
    		var i = $star.attr("value");
            $star.removeClass('hover on');

            // for every star that should be on, turn them on
            if (i<=stars_on) {
                $star.addClass('on');
            }

            // and for the last one, set width if needed
            var $a = $star.find("a");
            $a.css('width', (i == stars_on) ? last_star_width : "100%");
        });
    },

    // Get the widget to align the tooltip too
    getWidget: function() {
    	var $el = $(this.element);
    	if ($el.hasClass("rating")) {
    		return $el;
    	}
    	return $el.find(" > div.rating");
    }

});

// New methods and method overrides for RatingStars object
$.extend(Rating.prototype, RatingStars.prototype, {

    // if the control is enabled, i.e. it reacts on mouse movement and allow changing rating
    enabled: true,

	/**
	 * @param element The root element for the widget
 	 * @param objectRatingStats
 	 * @param userRating The current user's rating, or null if not yet rated this object
     * @param entityTypeId The entity-type
     * @param entityId The entity id
     * @param trigger the selector of the element that will trigger the opening of the voting overlay
 	 */
    init: function(element, objectRatingStats, userRating, entityTypeId, entityId, trigger, event) {
    	// call super constructor
    	RatingStars.prototype.init.call(this, element, objectRatingStats, userRating, entityTypeId, entityId);

    	var $ratingDiv = $(element);
        if ($ratingDiv.length == 0) {
        	alert("Rating div not found :" + element);
        	return;
        }

        this.trigger = trigger;
        this.event = event;

        this.updateStats(false);
    },

    _createWidgetHTML: function(enabled, value, cssClass) {
        var stars_on = Math.ceil(value);
        var last_star_width = this._getLastStarWidth(value);

        if (!cssClass) {
        	cssClass = "";
        }

    	var html = [];
    	html.push("<div class='rating " + cssClass + " " + (! enabled ? 'ratingDisabled' : '') + "'>");
        // make the stars
        for (var i=1; i<=5; i++) {
        	var css = "";
        	if (i<= stars_on) {
        		css = "on";
        	}
        	var tooltip = "";
        	if (enabled) {
        		tooltip = i18n.message("rating.star" + i +".title");
        	}
        	html.push("<div class='star " + css +"' value='" + i+"' title=\"" + tooltip +"\">");

        	var style = "";
        	if (i == stars_on) {
        		style = " style='width:" + last_star_width +"' ";
        	}
        	html.push("<a " + style +"/>"); // don't set href, because IE will move the screen a bit if href='#' is set
        	html.push("</div>");
        }
    	html.push("</div>");
    	return html.join("");
    },

	/* Replaces original form with the star images */
    createWidget: function() {
    	var $ratingDiv = $(this.element);
        // hide star-div elem so changing its DOM won't cause flicker
    	var startdivHTML = this._createWidgetHTML(false, this.objectRatingStats.averageRating);
    	var $stardiv = $(startdivHTML);
    	$stardiv.hide();
        $ratingDiv.append($stardiv);
        $ratingDiv.toggleClass('ratingDisabled', ! this.enabled);	// the "ratingDisabled" css class marks the rating block if that is disabled

        // show the average
        this.reset_stars();

       	// reveal modified DOM elem
        $stardiv.show();
    },

	/**
     * Update the voting widget with the new value.
     */
	updateWidget:function() {
		this.reset_stars();
	},

    // get the value shown
    getValue: function() {
    	// always showing average value
        var value = this.objectRatingStats.averageRating;
        return value;
    },

    _formatNumber:function(n) {
    	return numeral(n).format('0,0');
    },

    // Get the message shown as tooltip for statistics
    getTooltipMessage: function() {
    	var msg = [];

    	msg.push("<table cellpadding='0' cellspacing='0'><tr>");
    	msg.push("<td>");
    	msg.push("<b>" + i18n.message("rating.your.rating") +"</b>");
    	msg.push("</td>");

    	msg.push("<td>");
    	// showing the user's ratings here
    	msg.push(this._createWidgetHTML(true, this.userRating.rate, "myRating"));
    	msg.push("</td>");

    	msg.push("<td>");
    	msg.push("<input type='button' class='button' value='" + i18n.message("rating.save.button") +"'></input>");
    	msg.push("</td>");
    	msg.push("</tr>");
    	msg.push("</table>");

    	msg.push("<br/>");
    	var canAddComment = this.userRating.canAddComment;
    	msg.push("<textarea class='ratingComment' " + (!canAddComment ? "disabled='disabled'" :"") + " >" + (this.userRating.comment ? this.userRating.comment : '') +"</textarea>");
    	msg.push("<br/>");
    	msg.push(this.renderProgressStats());

    	msg.push("<table cellpadding='0' cellspacing='0'>");
    	msg.push("<tr>");
    	msg.push("<td>");
    	msg.push("<b>" + i18n.message("rating.average.rating", this._formatNumber(this.objectRatingStats.numberOfRatings)) +"</b>");
    	msg.push("</td>");

    	msg.push("<td>");
    	// showing the avarage rating's stars here
    	msg.push(this._createWidgetHTML(false, this.objectRatingStats.averageRating));
    	msg.push("</td>");
    	msg.push("</tr>");

    	msg.push("</table>");

    	return msg.join("");
    },

    renderProgressStats:function() {
    	var stats = this.objectRatingStats.ratingDistribution;
    	var distribution = {};
    	for (var i=0; i<stats.length; i++) {
    		var rate = stats[i].rate;
    		var count = stats[i].count;
    		distribution[rate] = count;
    	}
    	var html = "<table border='0' cellspacing='0' cellpadding='0' class='ratingDetails'>";
    	var numRatings = this.objectRatingStats.numberOfRatings;
    	// var total = this.objectRatingStats.ratingTotal;
    	for (var i=5; i>0; i--) {
    		var count = distribution[i];
    		if (! count) {
    			count = 0;
    		}
    		var percent = 0;
    		if (numRatings > 0) {
    			percent = (count * 100.0) / numRatings;
    		}
//			percent = Math.random() * 100.0;	// only for testing
    		var stars = "";
    		for (var j=1; j<=i; j++) {
    			var style = "";
        		if (j == 1 && i != 5) {
        			style = " style='margin-left:" + (5-i)*12 +"px;' ";
        		}
    			stars += "<img " + style +" src='" + contextPath +"/images/newskin/action/star-active-small.png'></img>";
    		}
    		html += "<tr><td>" + stars  +"</td><td>" + this.renderProgressBar(percent) + "</td><td>" + this._formatNumber(count) +"</td></tr>";
    	}
    	html += "</table>";
    	return html;
    },

    renderProgressBar: function(percent) {
    	percent = Math.round(percent);
    	// TODO: should this use the existing "miniprogressbar" style ?
    	return "<div class='ratingPercent'><div style='width:" + percent +"%;'></div><label>" + percent +"%</label></div>";
    },

    // callback when the tooltip is shown intialize it
    initTooltip: function(tooltip) {
    	var self = this;
    	var $myRating = $(tooltip).find(".myRating");
    	// create a new widget for the "myRating" star inside the tooltip
    	var myRatingWidget = new RatingStars($myRating, this.objectRatingStats, this.userRating, this.entityTypeId, this.entityId);

    	// replace the submit_rating, so the click on the stars won't submit it!
    	myRatingWidget.submit_rating= function(num, comment) {
    		// don't submit it, but keep the selected value
            this.userRating.rate = num;
    	};

    	// the save button will submit it only!
    	var $saveButton = $(tooltip).find("input[type='button']");
    	$saveButton.click(function() {
    		var comment = $(tooltip).find("textarea").val();
    		if (comment == self.getDefaultComment()) {
    			comment = "";
    		}
    		var rate = myRatingWidget.userRating.rate;
    		var $dialog = $saveButton.closest(".ui-dialog");
    		self.submit_rating(rate, true, comment, $dialog);
    	});

    	$(tooltip).find(".rating .star").on("dblclick", function (event) {
    		$saveButton.click();
    	});

        applyHintInputBox(".ratingComment", self.getDefaultComment());
    },

    getDefaultComment: function () {
    	return i18n.message("document.comment.label") + "...";
    }

});

// initialize event handlers once
$(Voting.initEvents);
$(Rating.initEvents);
