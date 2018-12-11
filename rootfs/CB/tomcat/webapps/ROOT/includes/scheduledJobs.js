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
	$.fn.showScheduledJobs = function(objectId, jobs, options) {
		var settings = $.extend( {}, $.fn.showScheduledJobs.defaults, options );

		function getSetting(name) {
			return settings[name];
		}

		function runJob(trigger, job, refresh) {
			if (!trigger.data('running')) {
				trigger.data('running', true).attr('src', settings.runningImage);

			    $.ajax(settings.runURL, {
			    	type 		: 'POST',
					contentType : 'application/json',
			    	async		: true,
			    	cache		: false,
					dataType 	: 'json',
					data 		: JSON.stringify(job)
			    }).done(function(schedule) {
			    	showSchedule(trigger.closest('tr.job'), schedule);
				}).fail(function(jqXHR, textStatus, errorThrown) {
		    		try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
		    		} catch(err) {
			    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
		    		}
		        }).always(function() {
		        	trigger.data('running', false).attr('src', settings.runImage);
			    });
			}
		}

		function checkJobInterval(job, value) {
			var minValue = null;

			var handler = settings.jobHandler[job];
			if (handler && typeof(handler.minIntervalMillis) == 'number') {
				minValue = handler.minIntervalMillis;
			}

		    $.ajax(settings.intervalURL, {
		    	type 		: 'GET',
		    	data 		: { interval : value, minMillis : minValue },
		    	dataType 	: 'json',
		    	cache		: false,
		    	async		: false
		    }).done(function(result) {
				value = result;
			}).fail(function(jqXHR, textStatus, errorThrown) {
				value = undefined;
	    		try {
		    		var exception = $.parseJSON(jqXHR.responseText);
		    		alert(exception.message);
	    		} catch(err) {
		    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
	    		}
	        });

			return value;
		}

		function setJobInterval(value) {
			var job    = $(this).closest('tr.job');
			var name   = job.data('job');
			var params = job.data('params');

			value = $.trim(value);
			if (value && value.length > 0) {
				value = checkJobInterval(name, value);
				if (value === undefined) {
					value = params.interval;
				} else {
					params.interval = value;
				}
			} else {
				delete params.interval;
			}

			if (typeof(settings.callback) == 'function') {
				settings.callback();
			}

			return value;
		}

		function showSchedule(job, dates) {
			if (dates) {
				$('td.lastAt', job).text(dates.lastAt);
				$('td.nextAt', job).text(dates.nextAt);
			}
		}

		function loadSchedule(jobs, objectId) {
		    $.ajax(settings.scheduleURL, {
		    	type 		: 'GET',
		    	data 		: { objectId : objectId },
		    	dataType 	: 'json',
		    	cache		: false
		    }).done(function(schedule) {
				$('tr.job', jobs).each(function() {
					var job  = $(this);
					var name = job.data('job');

					showSchedule(job, schedule[name]);
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

		function init(container, objectId, jobs) {
			if (!$.isPlainObject(jobs)) {
				jobs = {};
			}

			container.empty();

			var popup = $('<div>', { style : 'display: None;' });
			container.append(popup);

			var table = $('<table>', { "class" : 'displaytag jobs' });
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>');
			headline.append($('<th>', { "class" : 'textData columnSeparator jobLabel' }).text(settings.jobLabel));
			headline.append($('<th>', { "class" : 'textData columnSeparator jobInterval', title : settings.jobIntervalTitle, style : 'width: 5%;' }).text(settings.jobIntervalLabel));
			headline.append($('<th>', { "class" : 'dateData columnSeparator lastAt', title : settings.lastAtTitle, style : 'width: 5%;' }).text(settings.lastAtLabel));
			headline.append($('<th>', { "class" : 'dateData columnSeparator nextAt', title : settings.nextAtTitle, style : 'width: 5%;' }).text(settings.nextAtLabel));
			var action =    $('<th>', { "class" : 'column-minwidth' });
			headline.append(action);

			header.append(headline);

			var body = $('<tbody>');
			table.append(body);

			var loader = function() {
				loadSchedule(body, objectId);
			};

			action.append($('<img>', { src : settings.refreshImage, title : settings.refreshTitle }).click(loader));

			$.each(jobs, function(job, params) {
				if (!$.isPlainObject(params)) {
					params = {};
				}

				var row = $('<tr>', { "class" : 'job even' }).data('job', job).data('params', params);
				body.append(row);

				var jobLabel = $('<td>', { "class" : 'textData columnSeparator jobLabel' });
				row.append(jobLabel);

				var handler = settings.jobHandler[job];
				if (handler) {
					var link = $('<a>', { href : '#' }).text(handler.title).click(function() {
						popup.empty();
						handler.edit(popup, { id : objectId, name : job }, row.data('params'), function(result) {
							$.extend(row.data('params'), result);

							var callback = getSetting('callback');
							if (typeof(callback) == 'function') {
								callback();
							}
						});
					});

					jobLabel.append(link);

					if (handler.helpURL) {
						jobLabel.append($('<span>', { "class" : 'ui-icon ui-icon-info', style : 'display: inline-block;', title : settings.jobHelpTitle}).click(function() {
							window.open(handler.helpURL, "_blank");
						}));
					}
				} else {
					jobLabel.text(job);
				}

				var jobInterval = $('<td>', { "class" : 'textData columnSeparator jobInterval' });
				row.append(jobInterval);

				var intervalSpan = $('<span>', { "class" : 'jobInterval' });
				jobInterval.append(intervalSpan);

				var interval = params ? params.interval : null;
				if (interval) {
					intervalSpan.text(interval);
				}

				intervalSpan.editable(setJobInterval, {
			        type      : 'text',
			        event     : 'click',
			        onblur    : 'cancel',
			        submit    : settings.submitText,
			        cancel    : settings.cancelText,
			        tooltip   : settings.inlineEditHint,
			        placeholder : '--',
			        callback: function() {
			    		$('#saveButton').click();
			        	return true;
			        }
			    });
				intervalSpan.on('click', function() {
					intervalSpan.find('input').attr('placeholder', i18n.message('project.job.interval.placeholder'));
				});

				row.append($('<td>', { "class" : 'dateData columnSeparator lastAt' }));
				row.append($('<td>', { "class" : 'dateData columnSeparator nextAt' }));

				var trigger = $('<img>', { src : settings.runImage, title : settings.runTitle }).data('running', false).click(function() {
					runJob($(this), { id : objectId, name : job }, loader);
				});
				trigger.hover(function() {
					$(this).css('cursor','pointer');
				}, function() {
					$(this).css('cursor','auto');
				});
				row.append($('<td>', { "class" : 'column-minwidth' }).append(trigger));
			});

			loadSchedule(body, objectId);
		}

		return this.each(function() {
			init($(this), objectId, jobs);
		});
	};

	$.fn.showScheduledJobs.defaults = {
		jobHandler 		: {},
		jobLabel 		: 'Job',
		jobHelpTitle	: 'Get more information about this job',
		jobIntervalLabel: 'Interval',
		jobIntervalTitle: 'The interval, to periodically execute this job in the background, or empty, to not run the job periodically.',
		lastAtLabel     : 'Last execution',
		lastAtTitle     : 'The date and time of the last job execution, or empty, if the job has not been executed yet.',
		nextAtLabel     : 'Next execution',
		nextAtTitle     : 'The date and time of the next scheduled job execution, or empty, if the job has no scheduled next execution date.',
	    submitText    	: 'OK',
	    cancelText   	: 'Cancel',
	    inlineEditHint  : 'Click to edit',
	    refreshTitle    : 'Reload the job execution schedule',
		refreshImage	: contextPath + '/images/refreshtopic.gif',
		runImage		: contextPath + '/images/exec.gif',
		runningImage	: contextPath + '/images/ajax-running.gif',
	    runLabel    	: 'Run now',
	    runTitle    	: 'Run the specified job immediately and synchronously in the foreground',
	    startLabel    	: 'Start now',
	    startTitle    	: 'Start executing the specified job immediately but asynchronously in the background',
		intervalURL		: contextPath + '/docs/ajax/jobInterval.spr',
	    scheduleURL		: contextPath + '/docs/ajax/jobSchedules.spr',
	    startURL		: contextPath + '/docs/ajax/startJobInBackground.spr',
	    runURL			: contextPath + '/docs/ajax/runJobImmediately.spr'
	};


	// Plugin to show a form to edit the values of the specified Jira connection
	$.fn.getScheduledJobs = function() {
		var jobs = {};

		$('table.jobs tr.job', this).each(function() {
			var job    = $(this);
			var name   = job.data('job');
			var params = job.data('params');

			jobs[name] = params;
		});

		return jobs;
	};


})( jQuery );
