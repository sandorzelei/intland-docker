$(document).ready(function() {

	var editorId, editor, modalId;

	// the alias should get the selection value from the froala editor
	function initAlias() {
		try {
			var selected = editor.$oel.froalaEditor("selection.text");
			$("[name='alias']").val(selected);
		} catch (ex) {
			console.log("Can not set initial value of alias" + ex);
		}
	}

	function getAlias() {
		return $("[name='alias']:visible").val();
	}

	function createWikiLinkHtml(wikiLink) {
		var wikiLink, alias, aliasEndIndex;

		wikiLinkElement = $('<a href=""></a>');

		aliasEndIndex = wikiLink.indexOf('|');
		if (aliasEndIndex > 0) {
			alias = wikiLink.substring(1, aliasEndIndex);
		} else {
			alias = wikiLink.substring(1, wikiLink.length - 1);
		}
		wikiLinkElement.attr('alt', alias);
		wikiLinkElement.text(alias);

		wikiLinkElement.attr('rev', wikiLink);

		return wikiLinkElement.outerHTML();
	}

	function createWikiLinkHtmlFromElement(element){
		var $clone, alias, wiki, html;

		$clone = $(element).clone();
		$clone.removeAttr('onclick');
		$clone.removeAttr('title');
		$clone.removeAttr('style');
		alias = getAlias();
		wiki = $clone.text().trim();	// the link shows the wiki like [WIKIPAGE:1234]
		if (alias == '') {
			alias = $clone.attr('alt');	// the alt contains the item's name
			alias = alias.replace(/^\[[a-zA-Z]+:[0-9]+\] /, "") // leave just the name part
			alias = alias.replace("[", "");
			alias = alias.replace("]", "");
		}
		$clone.attr('rev', wiki.replace("-", ":"));	// the wiki alternative is passed in the rev
		$clone.text(alias);

		var html = $clone.outerHTML();
		return html;
	}
	
	function createWikiLinkFromElement(element){
		var $clone, alias, wiki, html;

		$clone = $(element).clone();
		$clone.removeAttr('onclick');
		$clone.removeAttr('title');
		$clone.removeAttr('style');
		alias = getAlias();
		wiki = $clone.text().trim();	// the link shows the wiki like [WIKIPAGE:1234]
		if (alias == '') {
			alias = $clone.attr('alt');	// the alt contains the item's name
			alias = alias.replace(/^\[[a-zA-Z]+:[0-9]+\] /, "") // leave just the name part
			alias = alias.replace("[", "");
			alias = alias.replace("]", "");
		}
		$clone.attr('rev', wiki.replace("-", ":"));	// the wiki alternative is passed in the rev
		$clone.text(alias);

		return $clone;
	}

	function insertToEditor(wikiLinkHtml) {
		var fieldId = $("#fieldId").val();
		$("#" + fieldId, parent.document).val(wikiLinkHtml);
		// Trigger events for Document Edit view
		window.parent.$("#" + fieldId).trigger("change");
		window.parent.$("#" + fieldId).closest('form').trigger('checkform.areYouSure');
	}

	function onInsertHistoryLinkButtonClick() {
		var selectedRadioButtons = [], siblingLink, wikiLinkHtml;
		if ($("#searchTab-tab").hasClass("ditch-focused")) {
			if ($("#search-documents-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchDocumentItem').find('input[name=searchItem]:checked');
			}
			if ($("#search-wikipages-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchWikipageItem').find('input[name=searchItem]:checked');
			}
			if ($("#search-issues-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchTrackerItem').find('input[name=searchItem]:checked');
			}
			if ($("#search-projects-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchProjectItem').find('input[name=searchItem]:checked');
			}
			if ($("#search-reports-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchReportsItem').find('input[name=searchItem]:checked');
			}
			if ($("#searchBranchItems-tab").hasClass("ditch-focused")) {
				selectedRadioButtons = $('#searchBranchTrackerItem').find('input[name=searchItem]:checked');
			}
			if (selectedRadioButtons.length > 0) {
				siblingLink = selectedRadioButtons.closest('tr').find('a');
				if ($("#search-issues-tab").hasClass("ditch-focused")) {
					var wikilink = $(siblingLink[0]).prev().attr("data-wikilink");
					var link = $("<a>");
				    link.attr("rev", wikilink);
				    var alias = getAlias();
				    if (alias == '') {
						alias = $(siblingLink[0]).text();
						alias = alias.replace(/^\[[a-zA-Z]+-[0-9]+\] /, "");
						alias = alias.replace("[", "");
						alias = alias.replace("]", "");
					}
				    link.text(alias);
				    link[0].setAttribute('alt',  $(siblingLink[0]).text());
				    link[0].setAttribute('href', siblingLink[0].getAttribute('href'));
					insertToEditor(/*link[0].outerHTML*/wikilink);
				} else {
					var rev = "";
					var href= "";
					var alt = "";
					if ($("#search-wikipages-tab").hasClass("ditch-focused")) {
						wikiLinkHtml = siblingLink[1].outerHTML;
						var id = $("#searchWikipageItem input[name=searchItem]:checked").val().trim();
						id = id.substring(id.indexOf('-') + 1);
						rev = "[DOC:" + id + "]";
						href = siblingLink[1].getAttribute("href");
						alt = $(siblingLink[0]).text();
					} else if ($("#search-documents-tab").hasClass("ditch-focused")) {
						wikiLinkHtml = siblingLink[1].outerHTML;
						var id = $("#searchDocumentItem input[name=searchItem]:checked").val().trim();
						id = id.substring(id.indexOf('-') + 1);
						rev = "[DOC:" + id + "]";
						href = siblingLink[1].getAttribute("href");
						alt = $(siblingLink[1]).text();
					} else if ($("#search-reports-tab").hasClass("ditch-focused")) {
						wikiLinkHtml = siblingLink[1].outerHTML;
						var id = $("#searchReportsItem input[name=searchItem]:checked").val().trim();
						id = id.substring(id.indexOf('-') + 1);
						rev = "[QUERY:" + id + "]";
						href = siblingLink[1].getAttribute("href");
						alt = $(siblingLink[1]).text();
					} else if ($("#searchBranchItems-tab").hasClass("ditch-focused")) {
						wikiLinkHtml = siblingLink[1].outerHTML;
						var id = $("#searchBranchTrackerItem input[name=searchItem]:checked").val().trim();
						id = id.substring(id.indexOf('-') + 1);
						rev = "[ITEM:" + id + "]";
						href = siblingLink[1].getAttribute("href");
						alt = $(siblingLink[1]).text();
					} else {
						wikiLinkHtml = siblingLink[0].outerHTML;
						var id = $("#searchProjectItem input[name=searchItem]:checked").val().trim();
						id = id.substring(id.indexOf('-') + 1);
						rev = "[PROJ:" + id + "]";
						href = siblingLink[0].getAttribute("href");
						alt = $(siblingLink[0]).text();
					}
					var alias = getAlias();
					if (alias == '') {
						alias = $(wikiLinkHtml).text();
						alias = alias.replace(/^\[[a-zA-Z]+-[0-9]+\] /, "");
						alias = alias.replace("[", "");
						alias = alias.replace("]", "");
					}
					var link = $("<a>");
					link.attr("rev", rev);
					link.attr("alt", alt);
					link.attr("href", "CB:" + href);
				    link.text(alias);
					insertToEditor(/*link[0].outerHTML*/rev);
				}

				inlinePopup.close();
				//editor.modals.hide(modalId);
			}
		} if ($("#attachmentWikiLinkTabPane-tab").hasClass("ditch-focused")) {
			try {
				selectedRadioButtons = $('#wikiAttachmentLinkTable input[type=radio]:checked');
				if (selectedRadioButtons.length > 0) {
					siblingLink = selectedRadioButtons.closest('tr').find('a');
					if ($(siblingLink[0]).attr("href") == '#') {
						var wikilink = $(siblingLink[1]).attr("href");
						var link = $("<a>");
					    link.attr("rev", wikilink);
					    link.attr("href", wikilink);
					    var alias = getAlias();
					    if (alias == '') {
							alias = $(siblingLink[1]).attr("alt");
						}
					    link.text(alias);
					    insertToEditor(/*link[0].outerHTML*/wikilink);
					} else {
						var wikilink = $(siblingLink[1]).attr("href");
						var link = $("<a>");
					    link.attr("rev", wikilink);
					    link.attr("href", wikilink);
					    var alias = getAlias();
					    if (alias == '') {
							alias = $(siblingLink[1]).attr("alt");
						}
					    link.text(alias);
					    insertToEditor(/*link[0].outerHTML*/wikilink);
					}
					inlinePopup.close();
					//editor.modals.hide(modalId);
				}
			} catch(ex) {
				console.log("Error:" + ex);
				inlinePopup.close();
				//editor.modals.hide(modalId);
			}
		} else {
			try {
				selectedRadioButtons = $('#wikiLinkHistoryTabPane input[type=radio]:checked');
				if (selectedRadioButtons.length > 0) {
					siblingLink = selectedRadioButtons.closest('tr').find('a');
					wikiLink = createWikiLinkFromElement(siblingLink[1]);
					insertToEditor($(wikiLink).attr('rev'));
					inlinePopup.close();
					//editor.modals.hide(modalId);
				}
			} catch(ex) {
				console.log("Error:" + ex);
				inlinePopup.close();
				//editor.modals.hide(modalId);
			}
		}
	}

	function onInsertCustomLinkClick() {
		var wikiLink, wikiLinkHtml;

		try {
			wikiLink = $.trim($('#wikiLink').val());
			var alias = getAlias();

			// build the link:
			if (!wikiLink.startsWith("[")) {
				wikiLink = wikiLink.replace("[", "");
				wikiLink = "[" + wikiLink;
			} else {
				wikiLink = "[" + wikiLink.substring(1).replace("[", "");
			}

			if (!wikiLink.endsWith("]")) {
				wikiLink = wikiLink.replace("]", "~]");
				wikiLink += "]";
			} else {
				wikiLink = wikiLink.substring(0, wikiLink.length - 1).replace("]", "") + "]";
			}

			if (alias.length > 0) {
				alias = alias.replace("[", "");
				alias = alias.replace("]", "");
				wikiLink = wikiLink.replace("[", "[" + alias +"|");
			}

			/*wikiLinkHtml = createWikiLinkHtml(wikiLink);
			insertToEditor(wikiLinkHtml);*/
			insertToEditor(wikiLink);
			inlinePopup.close();
			//editor.modals.hide(modalId);
		} catch(ex) {
			console.log("Error:" + ex);
			inlinePopup.close();
			//editor.modals.hide(modalId);
		}
	}

	function onCancelButtonClick() {
		inlinePopup.close();
		//editor.modals.hide(modalId);
	}

	function onTableRowClick(event) {
		var trElement, radioButtonElement;

		trElement = $(event.currentTarget);
		radioButtonElement = trElement.find('input[type=radio]');
		$(radioButtonElement).prop('checked', true);
	}

	function onTableRowDoubleClick(event) {
		onTableRowClick(event);
		onInsertHistoryLinkButtonClick();
	}

	function doInsert() {
		if ($('#wikiHistoryLinkTable').is(':visible') || $("#searchTab-tab").hasClass("ditch-focused") || $('#attachmentWikiLinkTabPane-tab').hasClass("ditch-focused") ) {
			onInsertHistoryLinkButtonClick();
		} else {
			onInsertCustomLinkClick();
		}
	}

	function onKeyUp(event) {
		if (event.keyCode === 13) {
			doInsert();
		}
	}

	function onWikiLinkClick(event) {
		event.preventDefault();
	}

	function onFilterKeyUp(event) {
		var filterTextField, filterValue;

		filterTextField = event.currentTarget;
		filterValue = $.trim(filterTextField.value).toLocaleLowerCase();

		if (filterValue.length >= 2) {
			$('#wikiHistoryLinkTable .filterable').each(function(index, item) {
				var $item, text;

				$item = $(item);
				text = $item.text().toLocaleLowerCase();

				var show = (text.indexOf(filterValue) != -1);
				$item.closest('tr').toggle(show);
			});
		} else {
			$('tbody tr').show();
		}
		event.stopPropagation();
	}

	function onAttachmentFilterKeyUp(event) {
		var filterTextField, filterValue;

		filterTextField = event.currentTarget;
		filterValue = $.trim(filterTextField.value).toLocaleLowerCase();

		if (filterValue.length >= 2) {
			$('#wikiAttachmentLinkTable .filterable').each(function(index, item) {
				var $item, text;

				$item = $(item);
				text = $item.text().toLocaleLowerCase();

				var show = (text.indexOf(filterValue) != -1);
				$item.closest('tr').toggle(show);
			});
		} else {
			$('tbody tr').show();
		}
		event.stopPropagation();
	}

	function onKeyDown(event) {
		event.stopPropagation();
	}

	function initModal() {
		// Prevent Froala modal to swallow this event
		$("#insertWikiLinkTabContainer").on("keydown", onKeyDown);

		$('.actionBar input[name=insert]').click(doInsert);
		$('#wikiHistoryLinkTable tbody tr').click(onTableRowClick)
										   .dblclick(onTableRowDoubleClick);
		$('#wikiHistoryLinkTable tbody a').click(onWikiLinkClick);

		$('.cancelButton').click(onCancelButtonClick);

		$('#linkFilter').keyup(onFilterKeyUp);
		$('#attachmentFilter').keyup(onAttachmentFilterKeyUp);

		initAlias();

		// document tab
		$('#searchDocumentItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchDocumentItem a.documentLink').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// projects tab
		$('#searchProjectItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchProjectItem a.normal').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// reports tab
		$('#searchReportsItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchReportsItem a.normal').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// wiki tab
		$('#searchWikipageItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchWikipageItem a.documentLink').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// items tab
		$('#searchTrackerItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchTrackerItem a.trackerItemLink').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// branched items tab
		$('#searchBranchTrackerItem tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#searchBranchTrackerItem a.trackerItemLink').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});
		// document tab
		$('#wikiAttachmentLinkTable tbody tr').click(onTableRowClick).dblclick(onTableRowDoubleClick);
		// find name links
		$('#wikiAttachmentLinkTable a').each(function() {
			// modify click on name
			$(this).click(onWikiLinkClick);
			// modify click on icon
			$(this).prev().click(onWikiLinkClick);
		});

		// find anchors and add target to open pages on new tab (not in this iframe) except where links set the parent href (for ex.: properties menu item)
		$("#searchTrackerItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
		$("#searchWikipageItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
		$("#searchDocumentItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
		$("#searchReportsItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
		$("#searchBranchTrackerItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
		$("#searchProjectItem").find("a").each(function() {
			if (!this.hasAttribute("target") && (!this.hasAttribute("onclick") || (this.getAttribute("onclick") && this.getAttribute("onclick") != "" && this.getAttribute("onclick").indexOf("parent.location.href") == -1))) {
				this.setAttribute("target", "_blank");
			}
		});
	}

	initModal();
});