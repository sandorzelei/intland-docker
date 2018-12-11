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
 *
 * $Id$
 */

/**
 * This object handle polling
 */

if (typeof window.currentOfficeEditPollNumber === 'undefined') {
	window.currentOfficeEditPollNumber = 1;
}

var IssueDescriptionPoller = {

   issues : {},
   selectors : {},
   pollTime : 5000, // 5 sec
   timeout: 15000, // 15 sec
   pollStarted : false,
   lastActiveTimes : [],
   cumulatedErrorNumber : 0,
   maxContinuousError : 10,
   maxSize : 0,
   maxPollNumber: 180,

   successCallback : function(updated) {
   },

   startPolling : function(pollUri, callback) {
	   if (!this.pollStarted) {
		   var changeUrl = window.location.protocol + "//" + window.location.host + pollUri;
		   this.pollStarted = true;
		   this.poll(changeUrl);
		   if (callback) {
			   this.successCallback = callback;
		   }
	   }
   },

   poll : function(changeUrl) {
	   if (this.maxContinuousError < this.cumulatedErrorNumber) {
		   this.pollStarted = false;
		   this.cumulatedErrorNumber = 0;
		   showOverlayMessage(i18n.message("document.officeEdit.pollfailed"), 5, true);
	   }
	   else {
		   var me = this;
		   var timeout = this.timeout;
		   var maxPollNumber = this.maxPollNumber;
		   setTimeout(function() {
			   $.ajax({
			      url : changeUrl,
			      type : 'POST',
			      data : JSON.stringify(me.getInput()),
			      contentType : 'application/json',
				  timeout: timeout,
			      success : function(data) {
					  me.cumulatedErrorNumber = 0;
				      me.processPollResult(data);
			      },
			      error : function(jqXHR, textStatus, errorThrown) {
				      me.cumulatedErrorNumber++;
			      },
			      complete : function(jqXHR, textStatus) {
					  if (textStatus != 'timeout' && // do not poll again if once reached the timeout
					  	  window.currentOfficeEditPollNumber < maxPollNumber) { // do not poll if poll limit reached
						  window.currentOfficeEditPollNumber++;
						  me.poll(changeUrl);
					  } else {
						  showFancyAlertDialog(i18n.message('document.officeEdit.pollStopped'));
					  }
				  }
			   });
		   }, this.pollTime);
	   }
   },

   processPollResult : function(resultData) {
	   var me = this;
	   $.each(resultData, function(index, value) {
		   var idString = value.id.toString();
		   me.issues[idString] = value.modified;
		   $updateable = $(me.selectors[idString]);
		   var oldHtml = $updateable.html();
		   $updateable.empty();
	   	$updateable.append(value.value);
		   if ($updateable.html() != oldHtml){
		   	flashChanged($updateable);
		   }
		   me.lastActiveTimes[idString] = new Date().valueOf();
		   me.successCallback(value);
	   });
   },

   getInput : function() {
	   var input = [];
	   $.each(this.issues, function(key, value) {
		   input.push({
		      "id" : parseInt(key),
		      "modified" : value
		   });
	   });
	   return input;
   },

   addIssue : function(issueId, modified, selector) {
	   if (this.maxSize > 0 && (this.maxSize - 1) == Object.keys(this.issues).length) {
		   var mostInactive = "";
		   var time = new Date().valueOf();
		   $.each(this.issues, function(key, value) {
			   if (time > value) {
				   mostInactive = key;
				   time = value;
			   }
		   });
		   delete this.issues[mostInactive];
		   delete this.selectors[mostInactive];
		   delete this.lastActiveTimes[mostInactive];
	   }
	   var issueIdString = issueId + "";
	   this.issues[issueIdString] = modified;
	   this.selectors[issueIdString] = selector;
	   this.lastActiveTimes[issueIdString] = new Date().valueOf();
   },

   reset : function() {
	   this.issues = {};
	   this.selectors = {};
   }

};
