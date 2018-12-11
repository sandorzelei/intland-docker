// $Id$
// script handles Ajax action calls for locking/unlocking a document/artifact

/*
	Do an ajax call to the server to lock/unlock a document

	@param elem The elem that triggered this function
	@param doc_id The id of the artifact to lock
	@param lock Boolean whether the artifact should get locked
 */
function ajaxDocumentLock(elem, doc_id, lock) {
	var controller = new AjaxDocumentLockController(doc_id, lock);
	if (elem) {
		controller.reloadPage = jQuery(elem).hasClass("reloadPage");
	}
	controller.ajaxCall();
}

	/**
	 * Constructor for the controller handles the Ajax-document-lock calls
	 * @param doc_id
	 * @param lock
	 */
	function AjaxDocumentLockController(doc_id, lock) {
		this.doc_id = doc_id;
		this.lock = lock;
	}

	// methods for AjaxDocumentLockController object
	AjaxDocumentLockController.prototype = {

		// ajax time-out constant
		ajaxTimeout: 10000,

		// icon url showing the status when artifact is locked
		ICON_URL_LOCKED: "/images/newskin/action/lock.png",
		// icon url showing the status when artifact is not locked
		ICON_URL_NOT_LOCKED: "/images/newskin/action/unlock.png",
		// icon url showing ajax call in progress
		ICON_URL_LOADING: "/images/ajax-loading_16.gif",

		// constant: fixed part of the html id for the icon or the menu of lock/unlock
		LOCK_UNLOCK_ID_PART: "LockUnlockAction_",

		// initiate the ajax call to the server
		ajaxCall:function() {
		   this.url = contextPath + "/ajax/artifactLock.spr?doc_id=" + this.doc_id +"&lock=" + this.lock;
		   //alert("ajaxDocumentLock on url:" + this.url);
		   console.log("starting Ajax request to " + this.url);

			$.ajax(this.url, {
				success: this.handleSuccess,
				error: this.handleFailure,
				context: this,
				timeout: this.ajaxTimeout
			});

	       // change the icon to indicate the ajax call in progress
	       this.setIcon(this.ICON_URL_LOADING);
	    },

		// member method handle the success response of the ajax call
		handleSuccess:function(o){
			//alert("Ajax call success:" + o.responseText);
			console.log("Ajax call success:" + o);
			console.log(this);
			if (o) {
				// successful lock/unlock
				var newiconurl;
				var newtitle;
				var oldtitle;
				var unlockText = i18n.message("button.unlock");
				var lockText = i18n.message("button.lock");

				if (this.lock) {
					// change icon to locked
					newiconurl = this.ICON_URL_NOT_LOCKED;
					newtitle = unlockText;
					oldtitle = lockText;
				} else {
					// change icon to unlocked
					newiconurl = this.ICON_URL_LOCKED;
					newtitle = lockText;
					oldtitle = unlockText;
				}
				// find the icon's domElement is a <a href="#" title="Lock/Unlock" /><img src="..."/></a> html element what was clicked on
				var domElem = this.getDomElem();
				domElem.title = newtitle;
				var onclick = domElem.onclick;
				// alert("onclick func:" + onclick);
				this.setIcon(newiconurl);

				// replace the onclick function, so can switch back the lock state by clicking again
				var _revertLock = !this.lock;
				var _doc_id = this.doc_id;
				var newOnClickFunc = function(event) {
				    ajaxDocumentLock(domElem, _doc_id, _revertLock);
				    return false;
				};
				domElem.onclick = newOnClickFunc;

				var $row = $(domElem).closest("tr");
				var $summaryLink = $row.find(".nameLink");
				var $children = $summaryLink.children();
				if ($children.length > 0) {
					if (this.lock) {
						$children.first().addClass("documentinuse");
						$children.get(1).innerHTML = i18n.message("document.locked.label");
					} else {
						$children.first().removeClass("documentinuse");
						$children.get(1).innerHTML = "";
					}
				}

				// update the menu item in the context menu to be in sync with the icon
				var menuElem = document.getElementById(this.LOCK_UNLOCK_ID_PART + this.doc_id);
				menuElem.title = newtitle;
				menuElem.onclick = newOnClickFunc;

				// change the icon-image in the menu, this contains the label too
				$(menuElem).find("img.tableIcon").each(function() {
					$(this).attr("src", contextPath + newiconurl);
				});
				// find the text-node child with the old title, and put the changed title there
				$.each(menuElem.childNodes, function(index, el) {
					if (el.nodeType == 3 && el.nodeValue == oldtitle) {
						el.nodeValue = newtitle;
					}
				});

				if (this.reloadPage) {
					window.location.reload();
				}

			} else {
				this.resetIcons();
				alert("Sorry the requested " + (this.lock ? "Lock" : "Unlock") + " operation can not be performed!");
			}
	    },

	    handleFailure:function(o) {
			console.log("Ajax call Failure:" + o);
	    	alert("Ajax call failure:" + o);
	    	this.resetIcons();
	    },

	    // find the icon's domElement
	    getDomElem: function() {
	    	var domElem = document.getElementById(this.LOCK_UNLOCK_ID_PART + this.doc_id);
	    	return domElem;
	    },

	    // change the icon
	    // @param iconurl The icon url without contextPath
	    setIcon: function(iconurl) {
			var menuElem = document.getElementById(this.LOCK_UNLOCK_ID_PART + this.doc_id);
			var img = menuElem.childNodes[0];
			if (img) {
				img.src = contextPath + iconurl;
			}
	    },

	    // reset icons when call failed, showing the original state
	    resetIcons:function() {
			if (this.lock) {
				this.setIcon(this.ICON_URL_NOT_LOCKED);
			} else {
				this.setIcon(this.ICON_URL_LOCKED);
			}
	    }

	};

