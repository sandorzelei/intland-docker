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
 * $Revision$ $Date$
 */

(function($) {

	// Plugin to show a form to edit the values of the specified Jira connection
	$.fn.editJiraConnection = function(connection, project, options) {
		var settings = $.extend( {}, $.fn.editJiraConnection.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function loadProjects(selector, connection, selected) {
			$.ajax(settings.projectURL, {
				type  		: 'POST',
				contentType : 'application/json',
				dataType 	: 'json',
				data 		: JSON.stringify(connection)
			}).done(function(projects) {
				$('option', selector).remove();
	            $.each(projects, function(i, project) {
					selector.append($("<option>", {	value : project.keyName, selected: project.keyName == selected }).text(project.name));
	            });
			}).fail(function(jqXHR, textStatus, errorThrown) {
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });
		}

		function init(form, connection) {
			if (!$.isPlainObject(connection)) {
				connection = {};
			}

			var table = $('<table>', { "class" : 'jiraConnection formTableWithSpacing' }).data('connection', connection);
			form.append(table);

			var line = $('<tr>', { title : settings.serverTitle });
			table.append(line);

			var label = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.serverLabel + ':');
			line.append(label);

			var content = $('<td>', { "class" : 'dataCell' });
			line.append(content);

			var server = $('<input>', { type : 'text', name : 'server', size : 80, maxlength : 255, value : connection.server });
			content.append(server);

			line = $('<tr>', { title : settings.usernameTitle });
			table.append(line);

			label = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.usernameLabel + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell' });
			line.append(content);

			var username = $('<input>', { type : 'text', name : 'username', size : 40, maxlength : 80, value : connection.username });
			content.append(username);

			line = $('<tr>', { title : settings.passwordTitle });
			table.append(line);

			label = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.passwordLabel + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell' });
			line.append(content);

			var password = $('<input>', { type : 'password', name : 'password', size : 40, maxlength : 80, value : connection.password });
			content.append(password);
/*
			line = $('<tr>', { title : settings.projectTitle });
			table.append(line);

			label = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.projectLabel + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell', style : 'vertical-align: middle;' });
			line.append(content);

			var selector = $('<select>', { name : 'project', title : settings.projectTitle });
			content.append(selector);

			var refresh = $('<img>', { src : settings.refreshImage, title : settings.projectReload, style : 'margin-left: 2px;' }).click(function() {
				loadProjects(selector, { server : server.val(), username : username.val(), password : password.val() }, selector.val());
			});

			content.append(refresh);

			loadProjects(selector, connection, project);
*/

			line = $('<tr>', { title : settings.syncTitle });
			table.append(line);

			label = $('<td>', { "class" : 'labelCell mandatory' }).text(settings.syncLabel + ':');
			line.append(label);

			content = $('<td>', { "class" : 'dataCell', style : 'vertical-align: middle;' });
			line.append(content);

			var selector = $('<select>', { name : 'synchronize', title : settings.syncTitle });
			content.append(selector);

			for (var i = 0; i < settings.syncMode.length; ++i) {
				selector.append($('<option>', { value : settings.syncMode[i].value, title : settings.syncMode[i].title, selected : connection.synchronize == settings.syncMode[i].value }).text(settings.syncMode[i].label));
			}

		}

		return this.each(function() {
			init($(this), connection, project);
		});
	};

	$.fn.editJiraConnection.defaults = {
		serverLabel   	: 'Server',
		serverTooltip 	: 'The URL (web address) of the remote server/host',
		serverRequired	: 'Please enter the URL (web address) of the remote server/host',
		usernameLabel 	: 'Username',
		usernameTitle 	: 'The username to login at the remote server/host. Can be ommitted, if the remote server allows anonymous access.',
		usernameRequired: 'Please enter a username and password to authenticate at the specified server',
		passwordLabel	: 'Password',
		passwordTitle	: 'The password to authenticate at the remote server/host. Can be ommitted, if the remote server allows anonymous access.',
		projectLabel	: 'Project',
		projectTitle	: 'Please select the Atlassian Jira project to import',
		projectReload   : 'Click here, to reload the list of available projects from the specified Atlassian Jira server',
		projectURL		: contextPath + '/ajax/jira/projects.spr',
		refreshImage	: contextPath + '/images/refreshtopic.gif',
		syncLabel		: 'Synchronize',
		syncTitle		: 'How should the local CodeBeamer project be synchronized with the remote Atlassian Jira project, where it was originally cloned from ?',
		syncMode		: [{
			value  : 'one-way',
			label  : 'One-way',
			title  : 'Update the project from the remote Atlassian Jira project, where it was originally cloned from'
		}, {
			value  : 'bidirect',
			label  : 'Bi-directional',
			title  : 'Synchronize changes between the local CodeBeamer project and the remote Atlassian Jira project in both directions'
		}]
	};


	// A second plugin to get the Jira connection from an editor
	$.fn.getJiraConnection = function() {
		var result = null;
		var table = $('table.jiraConnection', this);
		if (table.length > 0) {
			result = $.extend( {}, table.data('connection'),  {
				server   : $.trim($('input[name="server"]',   table).val()),
				username : $.trim($('input[name="username"]', table).val()),
				password :        $('input[name="password"]', table).val(),
//				project  : 		  $('select[name="project"]', table).val(),
				synchronize:  $('select[name="synchronize"]', table).val()
			});
		}
		return result;
	};


	// A plugin to edit a Jira connection in a popup dialog
	$.fn.showJiraConnectionDialog = function(job, connection, config, dialog, callback) {
		var settings = $.extend( {}, $.fn.showJiraConnectionDialog.defaults, dialog );
		var popup    = this;

	    $.ajax(settings.validateURL, {
	    	type 		: 'GET',
	    	data 		: connection,
	    	dataType 	: 'json',
	    	cache		: false
	    }).done(function(connection_) {
			popup.editJiraConnection($.extend( {}, connection, connection_ ), /*connection.project*/null, config);
		}).fail(function(jqXHR, textStatus, errorThrown) {
    		try {
	    		var exception = $.parseJSON(jqXHR.responseText);
	    		alert(exception.message);
    		} catch(err) {
	    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
    		}
        });

		if (typeof(callback) == 'function') {
			settings.buttons = [
			   { text : settings.submitText,
				 click: function() {
					 		var edited = popup.getJiraConnection();

						    $.ajax(settings.validateURL, {
						    	type 		: 'POST',
								contentType : 'application/json',
						    	async		: false,
						    	cache		: false,
								dataType 	: 'json',
								data 		: JSON.stringify({ job : job, params : edited })
						    }).done(function(connection_) {
							 	var result = callback($.extend(edited, connection_));
							 	if (!(result == false)) {
						  			popup.dialog("close");
						  			popup.remove();
							 	}
							}).fail(function(jqXHR, textStatus, errorThrown) {
					    		try {
						    		var exception = $.parseJSON(jqXHR.responseText);
						    		alert(exception.message);
					    		} catch(err) {
						    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					    		}
					        });
						}
				},
				{ text : settings.cancelText,
				  "class": "cancelButton",
				  click: function() {
				  			popup.dialog("close");
				  			popup.remove();
						 }
				}
			];
		} else {
			settings.buttons = [];
		}

		popup.dialog(settings);
	};

	$.fn.showJiraConnectionDialog.defaults = {
		title			: 'Jira Server Connection',
		validateURL		: contextPath + '/ajax/jira/connection.spr',
	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
		dialogClass		: 'popup',
		position		: { my: "center", at: "center", of: window, collision: 'fit' },
		modal			: true,
		draggable		: true,
		closeOnEscape	: true,
		width			: 800
	};


})( jQuery );
