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

	/**
	 * Review configuration editor.
	 * - context must be an object, with at least
	 *    + tracker : an object with at least id, name and project (id and name)
	 *    + status  : either an object with at least id and name or a function, that returns a status object
	 */
	$.fn.reviewConfiguration = function(context, review, config) {
		var settings = $.extend( {}, $.fn.reviewConfiguration.defaults, config );

		function getStatusSelector(name, value) {
			var selector = $('<select>', { name : name, disabled : !settings.editable });
			selector.append($('<option>', { value : '' }).text('--'));

			if (!$.isArray(settings.statusOptions)) {
				var params = {
					tracker_id : context.tracker.id,
					fieldId    : 7
				};

				var status = $.isFunction(context.status) ? context.status() : context.status;
				if (status && status.id) {
					params.statusId = status.id;
				}

				$.ajax(settings.statusOptionsURL, {
					type	 : 'GET',
					data     : params,
					async	 : false,
					dataType : 'json'
				}).done(function(options) {
					settings.statusOptions = options;
				}).fail(function(jqXHR, textStatus, errorThrown) {
					settings.statusOptions = [];
					try {
			    		var exception = $.parseJSON(jqXHR.responseText);
			    		alert(exception.message);
					} catch(err) {
						alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
					}
			    });
			}

			for (var i = 0; i < settings.statusOptions.length; ++i) {
				var option = settings.statusOptions[i];
				selector.append($('<option>', { value : option.id, title : option.description, selected : (value && value.id ? value.id == option.id : false) }).text(option.name).data('status', option));
			}

			return selector;
		}

		function init(container, context, review) {
			if (!$.isPlainObject(review)) {
				review = {
					signature : 0
				};
			} else if (review.closed) {
				settings.editable = false;
			}

			var table = $('<table>', { "class" : 'reviewConfig formTableWithSpacing' });
			if (settings.border) {
				table.css('border', '1px solid silver');
			}

			container.append(table);

			var signatureRow = $('<tr>', { style: "vertical-align: middle; "});
			signatureRow.append($('<td>', { "class" : 'labelCell optional', title : settings.signatureTitle, style : 'width: 5%;' }).text(settings.signatureLabel + ':'));
			var signatureCell = $('<td>', { "class" : 'dataCell', style: 'vertical-align: middle; white-space: nowrap;', colspan : 3 });

			var signatureSelector = $('<select>', { name : 'signature', title :  settings.signatureTitle, disabled : !settings.editable });
			for (var i = 0; i < settings.signature.length; ++i) {
				signatureSelector.append($('<option>', { value : i, title : settings.signature[i].title, selected : i == (review.signature || 0) }).text(settings.signature[i].label));
			}

			signatureCell.append(signatureSelector);
			signatureRow.append(signatureCell);
			table.append(signatureRow);


			var approvedRow = $('<tr>', { style: "vertical-align: middle;" });
			approvedRow.append($('<td>', {"class" : 'labelCell optional', title : settings.approvedTitle, style : 'width: 5%;' }).text(settings.approvedLabel + ':'));
			var approvalsCell = $('<td>', { "class" : 'dataCell', title : settings.approvalsTitle, style: 'vertical-align: middle; white-space: nowrap; width: 30%;' });
			approvalsCell.append(settings.approvalsLabel);
			approvalsCell.append($('<input>', { type : 'number', name : 'approvals', value : review.approvals || '' , placeholder : settings.approvalsAll, min : 1, step : 1, size : 2, disabled : !settings.editable, style: 'width: 2em; margin-left: 3px; margin-right: 3px;' }));
			approvalsCell.append(settings.approvalsVotes);
			approvalsCell.append(', ');
			approvedRow.append(approvalsCell);

			approvedRow.append($('<td>', { "class" : 'labelCell optional', title : settings.approvedStatusTitle, style : 'width: 5%;' }).text(settings.statusLabel + ':'));
			var approvedStatusCell = $('<td>', { "class" : 'dataCell', title : settings.approvedStatusTitle, style: 'vertical-align: middle; white-space: nowrap;' });
			if (settings.editable) {
				approvedStatusCell.append(getStatusSelector("approved", review.approved));
			} else {
				approvedStatusCell.text(review.approved ? review.approved.name || review.approved.id : '--');
			}
			approvedRow.append(approvedStatusCell);
			table.append(approvedRow);

			var rejectedRow = $('<tr>', { style: "vertical-align: middle;" });
			rejectedRow.append($('<td>', {"class" : 'labelCell optional', title : settings.rejectedTitle, style : 'width: 5%;' }).text(settings.rejectedLabel + ':'));
			var rejectsCell = $('<td>', { "class" : 'dataCell', title : settings.rejectsTitle, style: 'vertical-align: middle; white-space: nowrap; width: 30%;' });
			rejectsCell.append(settings.rejectsLabel);
			rejectsCell.append($('<input>', { type : 'number', name : 'rejects', value : review.rejects || 0, min : 0, step : 1, size : 2, disabled : !settings.editable, style: 'width: 2em; margin-left: 3px; margin-right: 3px;' }));
			rejectsCell.append(settings.rejectsVotes);
			rejectsCell.append(', ');
			rejectedRow.append(rejectsCell);

			rejectedRow.append($('<td>', { "class" : 'labelCell optional', title : settings.rejectedStatusTitle, style : 'width: 5%;' }).text(settings.statusLabel + ':'));
			var rejectedStatusCell = $('<td>', { "class" : 'dataCell', title : settings.rejectedStatusTitle, style: 'vertical-align: middle; white-space: nowrap;' });
			if (settings.editable) {
				rejectedStatusCell.append(getStatusSelector("rejected", review.rejected));
			} else {
				rejectedStatusCell.text(review.rejected ? review.rejected.name || review.rejected.id : '--');
			}

			rejectedRow.append(rejectedStatusCell);
			table.append(rejectedRow);
		}

		return this.each(function() {
			init($(this), context, review);
		});
	};

	$.fn.reviewConfiguration.defaults = {
		editable			: true,
		border				: true,
		approvedLabel		: 'Approved',
		approvedTitle		: 'This (work) item was approved/accepted by this user',
		approvalsTitle		: 'The minimum number of approvals (positive votes), that are required for the review to be considered approved.',
		approvalsLabel		: 'Requires',
		approvalsAll		: 'all',
		approvalsVotes		: 'Votes',
		approvalsInvalid	: 'The required number of approvals must be either "all" or an Integer > 0',
		approvedStatusLabel : 'Approved Status',
		approvedStatusTitle : 'The subject item should be forwarded to this status, after it was approved.',
		rejectedLabel		: 'Rejected',
		rejectedTitle		: 'This (work) item was rejected by this user',
		rejectsLabel		: 'If more than',
		rejectsTitle		: 'The maximum number of rejects (negative votes), that are allowed, before the review should be considered rejected',
		rejectsVotes		: 'Rejects',
		rejectedStatusLabel : 'Rejected Status',
		rejectedStatusTitle : 'The subject item should be forwarded to this status, after it was rejected.',
		statusLabel			: 'Status',
		statusOptionsURL	:  contextPath + 'trackers/ajax/choiceOptions.spr',
		signatureLabel		: 'Signature',
		signatureTitle		: 'The type of electronic signature, that is required for this rating/approval',
		signature			: [{
			label			: 'None',
			title			: 'No electronic signature required',
		}, {
			label			: 'Password',
			title			: 'The users must enter their password',
		}, {
			label			: 'Username and Password',
			title			: 'The users must enter must enter their username and password',
		}]
	};


	// Plugin to get a review configuration from an editor
	$.fn.getReviewConfiguration = function(config) {
		var settings = $.extend( {}, $.fn.reviewConfiguration.defaults, config );

		var result = {
			signature : parseInt($('select[name="signature"]', this).val()),
			approvals : 0,
			rejects   : parseInt($('input[name="rejects"]', this).val())
		};

		var approvals = $('input[name="approvals"]', this).val();
		if (approvals && approvals.length > 0) {
			result.approvals = parseInt(approvals);
			if (!(result.approvals > 0)) {
				throw settings.approvalsInvalid;
			}
		}

		var approved = $('select[name="approved"]', this).find('option:selected').data('status');
		if (approved) {
			result.approved = {
				id   : approved.id,
				name : approved.name
			};
		}

		var rejected = $('select[name="rejected"]', this).find('option:selected').data('status');
		if (rejected) {
			result.rejected = {
				id   : rejected.id,
				name : rejected.name
			};
		}

		return result;
	};


	/**
	 * Show a review configuration dialog
	 * - context must be an object, with at least
	 *    + tracker : an object with at least id, name and project (id and name)
	 *    + status  : either an object with at least id and name or a function, that returns a status object
	 */
	$.fn.reviewConfigurationDialog = function(context, review, options, dialog, callback) {
		var settings = $.extend( {}, $.fn.reviewConfigurationDialog.defaults, dialog );

		var popup = $('#issueCopyMovePopup');
		if (popup.length == 0) {
			popup = $('<div>', { id : 'issueCopyMovePopup', "class" : 'editorPopup', style : 'display: None;' });
			this.closest('form').append(popup);
		} else {
			popup.empty();
		}

		callback = callback || function(result) {
			if (result) {
				// document.location.reload();
			}
		};

		popup.reviewConfiguration(context, review, $.extend( {}, options, {
			border : false
		}));

		if (options.editable && !review.closed) {
			settings.buttons = [{
				text  : settings.submitText,
				click : function() {
					try {
						var config = popup.getReviewConfiguration(options);
						if (callback(config) != false) {
				  			popup.dialog("close");
				  			popup.remove();
						}
					} catch(ex) {
						alert(ex);
					}
				}
			}, {
				text  : settings.cancelText,
			   "class": "cancelButton",
				click : function() {
		  			popup.dialog("close");
		  			popup.remove();

		  			callback(null);
				}
			}];
		}

		settings.close = function() {
  			popup.remove();
  			callback(null);
		};

		popup.dialog(settings);
	};

	$.fn.reviewConfigurationDialog.defaults = {
		title			: 'Review Configuration',
		dialogClass		: 'popup',
		width			: 640,
		draggable		: true,
		modal			: true,
		closeOnEscape	: false,
		submitText    	: 'OK',
		cancelText   	: 'Cancel'
	};


	// Plugin shows a table/list of reviews for tracker item
	$.fn.trackerItemReviews = function(context, reviews, config) {
		var settings = $.extend( {}, $.fn.trackerItemReviews.defaults, config );

		settings.configSettings = $.extend( {}, settings.configSettings, {
			editable : settings.editable
		});

		function setup() {

		}

		function addReview(tbody, context, review) {
			if ($.isPlainObject(review)) {
				var row = $('<tr>', {
					"class" 		 : 'trackerItemReview even',
					"data-tt-id" 	 : review.item.id + '/' + review.item.version,
					"data-tt-branch" : true
				}).data('review', review);

				var link = $('<a>', { href  : contextPath + review.urlLink, title : review.item.name + ' v' +  review.item.version }).text(review.item.status.name);
				if (review.config.closed) {
					link.css('text-decoration', 'line-through');
				}

				var subject = $('<td>', { "class" : 'trackerItemReviewSubject', style : 'width: 15em;'	});
				subject.append(link);
				subject.append($('<span>', { "class" : 'subtext' }).text(' v' + review.item.version));

				var settingsLink = $("<span>", {"href": "#", "class": "settings-icon", title: settings.configLabel});
				subject.append(settingsLink)
				settingsLink.click(function () {
					var $target = $(this).closest('td');
			   		var review = $target.closest('tr').data('review');

					$.ajax(settings.configURL + '?task_id=' + review.item.id + "&revision=" + review.item.version, {
						type		: 'GET',
						dataType 	: 'json'
					}).done(function(config1) {
				   		var rvCtxt = $.extend({}, context, {
				   			status : review.item.status
				   		});

						review.config = config1;

						$target.reviewConfigurationDialog(rvCtxt, config1, settings.configSettings, settings.configDialog, function(config2) {
							if (config2) {
								$.ajax(settings.configURL + '?task_id=' + review.item.id + "&revision=" + review.item.version, {
									type		: 'PUT',
									data 		: JSON.stringify(config2),
									contentType : 'application/json',
									dataType 	: 'json'
								}).done(function(result) {
									if (result) {
										if (result.url && confirm(result.label)) {
											document.location.href = result.url;
										} else {
											document.location.reload();
										}
									}
								}).fail(function(jqXHR, textStatus, errorThrown) {
						    		try {
							    		var exception = $.parseJSON(jqXHR.responseText);
							    		alert(exception.message);
						    		} catch(err) {
							    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
						    		}

						    		return false;
						        });
							}
						});
					}).fail(function(jqXHR, textStatus, errorThrown) {
			    		try {
				    		var exception = $.parseJSON(jqXHR.responseText);
				    		alert(exception.message);
			    		} catch(err) {
				    		alert("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
			    		}

			    		return false;
			        });
				});

				row.append(subject);

				var result = $('<td>', { "class" : 'trackerItemReviewResult', style : 'width: 10em;'	});
				var span = $('<span>', { "class" : 'approval' + (review.rejected ? ' rejected' : review.approved ? ' approved' : '') });

				if (review.rejected) {
					span.attr('title', settings.rejectedTooltip).text(settings.rejectedLabel);
				} else if (review.approved) {
					span.attr('title', settings.approvedTooltip).text(settings.approvedLabel);
				} else if (review.config.closed) {
					span.attr('title', settings.undecidedTitle).text(settings.undecidedLabel);
				} else {
					span.attr('title', settings.inProgressTitle).text(settings.inProgressLabel);
				}

				result.append(span);
				row.append(result);

				var votes = $('<td>', { "class" : 'trackerItemReviewVotes' });
				if (review.rejected) {
					votes.append(settings.approvedXofY.replace('XX', review.votes - review.approvals).replace('YY', review.approvals));
				} else if (review.approved) {
					votes.append(settings.approvedXofY.replace('XX', review.approvals).replace('YY', review.votes - review.approvals));
				} else {
					votes.append(settings.votesXofY.replace('XX', review.votes).replace('YY', review.voters));
				}
				row.append(votes);

				tbody.append(row);
			}
		}

		function addVote(tbody, parentId, review) {
			if ($.isPlainObject(review)) {
				var row = $('<tr>', {
					"class" 			: 'itemUserReview odd',
					"data-tt-parent-id" : parentId,
					"data-tt-id" 		: parentId + '-' + review.reviewer.id
				}).data('review', review);

				row.append($('<td>', { style : 'width: 15em;' }));

				var result = $('<td>', { "class" : 'trackerItemReviewResult', style : 'width: 10em;' });

				if (review.reviewedAt) {
					result.append($('<span>', { "class" : 'approval' + (review.rating ? ' approved' : ' rejected') }).text(review.rating ? settings.approvedLabel : settings.rejectedLabel));
				} else {
					result.text("--");
				}

				row.append(result);

				var reviewer = $('<td>', { "class" : 'trackerItemReviewVotes' });
				reviewer.append($('<a>', { href : settings.reviewerURL + review.reviewer.id, title : review.reviewer.realName }).text(review.reviewer.name));

				if (review.reviewedAt) {
					reviewer.append($('<span>', { "class" : 'subtext' }).text(', ' +  review.reviewedAt));
				}

				row.append(reviewer);

				tbody.append(row);
			}
		}

		function init(container, context, reviews) {
			var table = $('<table>', { "class" : 'trackerItemReviews displaytag' }).data('item', item);
			container.append(table);

			var header = $('<thead>');
			table.append(header);

			var headline = $('<tr>',  { "class" : 'head' });
			headline.append($('<th>', { "class" : 'textData', title : settings.subjectTooltip, style : 'width: 15em;' }).text(settings.subjectLabel));
			headline.append($('<th>', { "class" : 'textData', title : settings.resultTooltip,  style : 'width: 10em;' }).text(settings.resultLabel));
			headline.append($('<th>', { "class" : 'textData', title : settings.votesTooltip 						  }).text(settings.votesLabel));
			header.append(headline);

			var tbody = $('<tbody>');
			table.append(tbody);

			if ($.isArray(reviews) && reviews.length > 0) {
				for (var i = 0; i < reviews.length; ++i) {
					addReview(tbody, context, reviews[i]);
				}

				table.treetable({
					expandable			: true,
					column 				: 2,
					indent 				: 0,
					clickableNodeNames	: true,

					onNodeExpand 		: function() {
						var node = this;
						var parts = node.id.split('/');

						$.ajax(settings.reviewsURL + '?task_id=' + parts[0] + "&revision=" +  parts[1], {
							type	 : 'GET',
							dataType : 'json'
						}).done(function(votes) {
							var children = $('<tbody>');

							if ($.isArray(votes) && votes.length > 0) {
								for (var i = 0; i < votes.length; ++i) {
									addVote(children, node.id, votes[i]);
								}
							}

							table.treetable("loadBranch", node, $('tr.itemUserReview', children));
						}).fail(function(jqXHR, textStatus, errorThrown) {
							try {
					    		var exception = $.parseJSON(jqXHR.responseText);
					    		alert(exception.message);
							} catch(err) {
								console.log("failed: " + textStatus + ", errorThrown=" + errorThrown + ", response=" + jqXHR.responseText);
							}
					    });
					},

					onNodeCollapse : function() {
						table.treetable("unloadBranch", this);
					}
				});

			} else {
				tbody.append($('<tr>').append($('<td>', { colspan : 3 }).text(settings.noneLabel)));
			}
		}

		if ($.fn.trackerItemReviews._setup) {
			$.fn.trackerItemReviews._setup = false;
			setup();
		}

		return this.each(function() {
			init($(this), context, reviews);
		});
	};

	$.fn.trackerItemReviews._setup = true;

	$.fn.trackerItemReviews.defaults = {
		editable		: false,
		noneLabel		: 'There are no reviews for this item',
		subjectLabel 	: 'Subject',
		subjectTooltip	: 'The specific revision/status of the tracker item to review',
		resultLabel		: 'Result',
		resultTooltip	: 'The result of the review',
	    inProgressLabel : 'In Progress',
	    inProgressTitle : 'The review is still in progress',
	    undecidedLabel 	: 'Undecided',
	    undecidedTitle	: 'The review was closed without a sufficiently decisive result.',
		votesLabel		: 'Votes',
		votesTooltip	: 'Number of submitted votes for this review',
		votesXofY		: 'after XX of YY votes',
		approvedLabel	: 'Approved',
		approvedTooltip	: 'This (work) item was approved/accepted by this user',
		approvedXofY	: 'by <b>XX</b> to <b>YY</b> votes',
		rejectedLabel	: 'Rejected',
		rejectedTooltip	: 'This (work) item was rejected by this user',
		configSettings	: $.fn.reviewConfiguration.defaults,
		configLabel		: 'Settings',
		configTitle		: 'Review',
		configURL		: contextPath + '/trackers/ajax/trackerItemReviewConfig.spr',
		reviewsURL		: contextPath + '/trackers/ajax/trackerItemReviews.spr',
		reviewerURL		: contextPath +'/user/'
	};

})( jQuery );

