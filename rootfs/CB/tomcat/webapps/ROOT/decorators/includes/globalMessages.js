
/**
 * Dynamically show some message from javascript
 * as if it would have been displayed using GlobalMessages javascript object.
 */
var GlobalMessages = {

	/**
	 * if the animations are enabled
	 */
	enableAnimation: false,
	/**
	 * The duration for the animations
	 */
	duration: 0.5,

	/*
	 * show a global error message
	 */
	showErrorMessage:function(msg) {
		return GlobalMessages.showMessage("error", msg);
	},
	/*
	 * show a global warning message
	 */
	showWarningMessage:function(msg) {
		return GlobalMessages.showMessage("warning", msg);
	},

	/**
	 * show a global information message
	 */
	showInfoMessage:function(msg) {
		return GlobalMessages.showMessage("information", msg);
	},

	findMessageList:function(level) {
		var $messageList = $("#globalMessages div." + level +" >ul");
		if ($messageList == null || $messageList.length < 1) {
			throw "GlobalMessages: Can't find global message HTML elements, probably invalid message level:" + level;
		}
		return $messageList.get(0);
	},

	/*
	 * show a global message
	 * @param level The level for the message
	 * @param msg The message to show
	 * @param callback Optional function called back when the message is shown (after the animations are complete)
	 *
	 * @return The new HTML "li" element has been added. This can be hidden later using the hideMessage() function.
	 */
	showMessage:function(level, msg, callback) {
		var globalMessagesDiv = document.getElementById("globalMessages");
		var messageList = GlobalMessages.findMessageList(level);

		// check if the GlobalMessage is already shown the same message
		for (var i=0; i< messageList.childNodes.length; i++) {
			var li = messageList.childNodes[i];
			if ($(li).html() == msg) {
				// message is already shown, drop it
				return;
			}
		}

		// create dom elem for new message
		var newMessageLine = document.createElement('li');
		newMessageLine.innerHTML = msg;

		var messageListParent = messageList.parentNode;
		var messageWasInvisible = $(messageListParent).hasClass("invisible");

		var addMessage = function() {
			messageList.appendChild(newMessageLine);
			$(messageListParent).toggleClass("onlyOneMessage", messageList.childNodes.length == 1);
		};

		if (GlobalMessages.enableAnimation) {
			try {
				var target;
				if (messageWasInvisible) {
					// fade in the container box which vas invisible
					target = messageListParent;
					$(messageListParent).css("opacity", 0);
					$(messageListParent).animate({
						"opacity": 1,
						"height": "34px"
					}, GlobalMessages.duration, function() {
						addMessage();
						$(messageListParent).css('height', "0px");
						if (callback) {
							callback(newMessageLine);
						}
					});
					$(messageListParent).css("height", "0px");
	            } else {
	            	$(newMessageLine).css("height", "0px");
	            	addMessage();
				    // fade in the new message
				    target = newMessageLine;

					$(newMessageLine).css("opacity", 0);
					$(newMessageLine).animate({
						"opacity": 1,
						"height": "12px"
					}, GlobalMessages.duration, function() {
						$(newMessageLine).css("height", "0px");
					});
	            }
			} catch (e) { alert("Error:" +e); }
		} else {
			addMessage();
		}

		// show the message block on top
		$(globalMessagesDiv).removeClass("invisible");
		$(messageListParent).removeClass("invisible");

		return newMessageLine;
	},

	/**
	 * Hide a message element.
	 * @param el The element, which was returned in a previous call of showMessage()
	 */
	hideMessage: function(el) {
		el = $(el).closest("li")[0];
		var messageList = $(el).closest("ul")[0];
		var hideFunc = function() {
			messageList.removeChild(el);
			GlobalMessages.compact();
		};

		var elementToHide = el;
		// if the block will be empty remove that whole "information"/"error" block
		var liChildren = $(messageList).children("li");
		if (liChildren.length == 1) {
			elementToHide = messageList.parentNode;
		}
		$(messageList.parentNode).toggleClass("onlyOneMessage", liChildren.length <= 2);

		GlobalMessages._hideElement(elementToHide, hideFunc);
	},

	/**
	 * hide content elements if no more message is shown
	 * @param level Optional parameter for which message-areas to hide. If missing all areas will be compacted
	 * @return True if the compact was successful, and all messages of that level become invisible.
	 */
	compact: function(level) {
		var globalMessagesDiv = document.getElementById("globalMessages");
		if (!level) {
			var allInvisible = true;
			allInvisible = allInvisible & this.compact("error");
			allInvisible = allInvisible & this.compact("warning");
			allInvisible = allInvisible & this.compact("information");
			if (allInvisible) {
				GlobalMessages._hideElement(globalMessagesDiv);
			}
			return allInvisible;
		}
		var messageList = GlobalMessages.findMessageList(level);

		var messageListParent = messageList.parentNode;
		// return early if already hidden
		if ($(messageListParent).hasClass("invisible")) {
			return true;
		}

		var liChildren = $(messageList).children("li");
		if (liChildren.length == 0) {
			GlobalMessages._hideElement(messageListParent);
			return true;
		}
		return false;
	},

	/**
	 * Hide the element with animation
	 * @param el The element to hide
	 * @param onComplete The callback function called on animation complete
	 */
	_hideElement:function(el, onComplete) {

		var hideFunc = function() {
			$(el).addClass("invisible");
			if (onComplete != null) {
				onComplete.call();
			}
		};

		if (GlobalMessages.enableAnimation) {
			$(el).animate({
				"opacity": 0,
				"height": "0px"
			}, GlobalMessages.duration, function() {
				hideFunc();
				$(el).css({"opacity": "1", "height" : "auto"}); // reset the properties changed by the animation
			});
		} else {
			hideFunc();
		}
	}

};
