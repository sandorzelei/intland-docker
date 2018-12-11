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
 * This object handle office edit
 */
var OfficeEdit = {

   sharepointDocument : "SharePoint.OpenDocuments",
   maxUrlLength : 128,
   storeUserInfoInServer : false,
   showInstructions : true,
   officeInfoUrl : "https://codebeamer.com/cb/wiki/531477",
   showInstructionsLabel : i18n.message("document.officeEdit.info.never.show",
         "Never show this notification again"),
   instructionURL : "",
   instructionURLLabel : i18n.message("document.officeEdit.info.link.label",
         "Codebeamer Office Edit installation guide"),
   instructionMessage : i18n
         .message(
               "document.officeEdit.info.instruction",
               "You need an installed plugin on your operating system to run office edit! <br> More information about setup office edit on your computer: <br/>"),

   doEditing : function(docId, contextPath, callback) {
	   if (contextPath.match("/$") != "/") {
		   contextPath = contextPath + "/";
	   }
	   var getUriURL = window.location.protocol + "//" + window.location.host + contextPath
	         + "getofficeediturl.spr?issueid=" + docId;
	   me = this;
	   $.ajax({
	      url : getUriURL,
	      type : 'GET',
	      success : function(data) {
	    	  if (data.error){
	    		  showFancyAlertDialog(data.error);
	    	  }
	    	  else {
	    		  if (callback){
	    			  callback();
	    		  }
	    		  me.doOfficeEditing(docId, data.editUri, contextPath);
	    	  }
	      }
	   });
   },

   addComment : function(docId, fullPath, contextPath) {
	   this.doOfficeEditing(docId, fullPath + this.makeRandomString() + ".docx", contextPath);
   },

   doOfficeEditing : function(docId, fullPath, contextPath) {
	   var documentURL = this.getWebDavLocation(fullPath, contextPath);
	   var me = this;
	   var sharepointObject = this.getActiveXObject();
	   if (this.isExplorer() && sharepointObject) {
		   try {
			   if (!sharepointObject.EditDocument(documentURL)) {
				   var version = sharepointObject.GetOfficeVersion();
				   sharepointObject.EditDocument(documentURL, version);
			   }
		   }
		   catch (e) {
			   this.showInstuctionMessage(function(needIframe) {
				   me.openLocation(needIframe, "cboffice://" + documentURL);
			   });
		   }
	   }
	   else {
		   this.showInstuctionMessage(function(needIframe) {
			   me.openLocation(needIframe, "cboffice://" + documentURL);
		   });
	   }
   },

   openLocation : function(needIframe, url) {

	   // the location.href can be user if the
	   if (!needIframe || navigator.userAgent.match(/Chrome/)) {
		   window.location.href = url;
	   }
	   else {
		   var officeIframe = $("#officeEditIframe");
		   if (officeIframe) {
			   officeIframe.remove();
		   }

		   officeIframe = $('<iframe />', {
		      width : '0px',
		      height : '0px',
		      name : 'officeEditIframe',
		      id : 'officeEditIframe',
		      src : url
		   });

		   officeIframe.appendTo('body');
		   // hide to preven multiple opening - bug: #340490
		   officeIframe.hide();
	   }
   },

   getWebDavLocation : function(fullPath, contextPath, noHost) {
	   var documentURL = this.replaceSpecialChars(encodeURI((noHost ? "" : window.location.protocol
	         + "//" + window.location.host)
	         + contextPath + fullPath.replace(/\s/g, "_")));
	   /* The URL length cannot be more than max characters */
	   if (documentURL.length > this.maxUrlLength) {
		   var urlPath = documentURL.substring(0, documentURL.lastIndexOf("/"));
		   var fileNamePart = fullPath.substring(fullPath.lastIndexOf("/") + 1);
		   fileNamePart = fileNamePart.replace(/\s/g, "_");
		   var extension = fileNamePart.substring(fileNamePart.lastIndexOf(".") + 1);
		   /*
			 * If the URL path length without file name more than max-2 (max + '/' +
			 * '.') characters, than the URL cannot be corrected
			 */
		   var maxLengthWithCorrection = this.maxUrlLength - 2;
		   if (urlPath.length > (maxLengthWithCorrection - extension.length)) {
			   throw "URL path is too long for live editing!";
		   }
		   else {
			   /* remove file names last characters to correct the URL length */
			   var maxFileNameLength = maxLengthWithCorrection - urlPath.length;
			   /*
				 * maxFileNameLength = (maxFileNameLength > 60) ? 60 :
				 * maxFileNameLength;
				 */
			   var lastCharacterIndex = maxFileNameLength - extension.length;
			   var fileNameWithoutExt = fileNamePart.substring(0, fileNamePart.lastIndexOf("."));
			   var fileName = fileNameWithoutExt.substring(0, lastCharacterIndex);

			   /*
				 * remove last character from file name till it's encoded length
				 * less than maximum size
				 */
			   encodedFileName = this.replaceSpecialChars(encodeURI(fileName));
			   while (encodedFileName.length >= maxFileNameLength && lastCharacterIndex > 0) {
				   lastCharacterIndex--;
				   fileName = fileNameWithoutExt.substring(0, lastCharacterIndex);
				   encodedFileName = this.replaceSpecialChars(encodeURI(fileName));
			   }
			   documentURL = urlPath + "/" + encodedFileName + "." + extension;
		   }
	   }
	   return documentURL;
   },

   replaceSpecialChars : function(str) {
	   return str.replace(/\$/g, "%24").replace(/\&/g, "%26").replace(/\'/g, "%27").replace(/\(/g,
	         "%28").replace(/\#/g, "%23").replace(/\)/g, "%29").replace(/\*/g, "%2A").replace(/\;/g,
	         "%3B").replace(/\,/g, "%2C").replace(/\+/g, "%2B").replace(/\_/g, "%5F").replace(/\=/g,
	         "%3D").replace(/\?/g, "%3F").replace(/\@/g, "%40").replace(/\[/g, "%5B").replace(/\]/g,
	         "%5D");
   },

   makeRandomString : function() {
	   var text = "";
	   var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

	   for (var i = 0; i < 10; i++)
		   text += possible.charAt(Math.floor(Math.random() * possible.length));

	   return text;
   },

   notShowInstructionsAgain : function() {
	   if (this.storeUserInfoInServer) {
		   $.post(contextPath + "/userSetting.spr?name=SHOW_OFFICE_EDIT_INSTRUCTIONS&value=1");
	   }
	   else {
		   $.cookie("office.help.dialog", 1, {
		      path : "/",
		      expires : 10000
		   });
	   }
   },

   setMessageProperties : function(officeInfoUrl, instructionDisabled) {
	   this.showInstructions = instructionDisabled != "1";
	   this.instructionURL = officeInfoUrl;
   },

   showInstuctionMessage : function(callback) {
	   var me = this;
	   if (this.storeUserInfoInServer) {
		   var getUriURL = window.location.protocol + "//" + window.location.host + contextPath
		         + "/editinfoes.spr";
		   $.ajax({
		      url : getUriURL,
		      type : 'GET',
		      success : function(data) {
			      var needIframe = false;
			      if (data.instructionDisabled != "1") {
				      me.showMessage(data.officeInfoUrl);
				      needIframe = true;
			      }
			      if (callback) {
				      callback(needIframe);
			      }
		      }
		   });
	   }
	   else {
		   var noShowHelpDialog = $.cookie("office.help.dialog");

		   var needIframe = false;
		   if (!noShowHelpDialog) {
			   me.showMessage(me.officeInfoUrl);
			   needIframe = true;
		   }
		   if (callback) {
			   callback(needIframe);
		   }
	   }

   },

   showMessage : function(url) {
	   var content = "<div class=\"officeedit-info\"><span>"
	         + this.instructionMessage
	         + "<a target='_blank' href='" + url + "'>" + this.instructionURLLabel + "</a>"
	         + "</span><br/><label class=\"officeedit-label\"><input class=\"officeedit-checkbox\" type=\"checkbox\" name=\"checkbox\" onclick=\"OfficeEdit.notShowInstructionsAgain();\">"
	         + this.showInstructionsLabel + "</label></div>";
	   var notifier = $("<div>").append(content);

	   var notifierDialog = $(notifier).dialog({
	      "title" : i18n.message("document.officeEdit.help"),
	      "modal" : false,
	      "autoOpen" : true,
	      "width" : 500,
	      "draggable" : false,
	      "resizable" : false,
	      "position" : {
	         my : "left+15 bottom-25",
	         at : "left bottom",
	         of : window
	      },
	      "dialogClass" : "notifier-dialog",
	      "show" : 'fade',
	      "hide" : 'fade',
	      "open" : function() {
		      $('.ui-widget-overlay', this).hide().fadeIn();
		      $('.ui-icon-closethick').bind('click.close', function() {
			      $('.ui-widget-overlay').fadeOut(function() {
				      $('.ui-icon-closethick').unbind('click.close');
				      $('.ui-icon-closethick').trigger('click');
			      });
			      return false;
		      });
	      },
	      create : function(event, ui) {
		      $(event.target).parent().css('position', 'fixed');
	      }
	   });

	   var id = setTimeout(function() {
		   notifierDialog.dialog('close');
	   }, 15000);
   },

   isExplorer : function() {
	   var ua = window.navigator.userAgent;
	   var msie = ua.indexOf("MSIE ");
	   var trident = ua.indexOf("Trident/");
	   if (msie > 0 || trident > 0) {
		   return true;
	   }
	   return false;
   },

   getActiveXObject : function() {
	   var sharePointObject = null;
	   try {
		   sharePointObject = new ActiveXObject(this.sharepointDocument);
	   }
	   catch (e) {
		   for (var sharepointVersion = 5; sharepointVersion > 0; sharepointVersion--) {
			   try {
				   sharePointObject = new ActiveXObject(this.sharepointDocument + "."
				         + sharepointVersion);
				   break;
			   }
			   catch (officeException) {
			   }
		   }
	   }
	   return sharePointObject;
   }

};
