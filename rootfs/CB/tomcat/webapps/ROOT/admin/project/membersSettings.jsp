<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="uitaglib" prefix="ui" %>
<%@ taglib uri="taglib" prefix="taglib" %>
<%@ taglib uri="http://displaytag.sf.net" prefix="display" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<c:url var="setMemberRoleUrl" value="/ajax/proj/setMemberRole.spr"/>
<c:url var="removeMemberUrl" value="/ajax/proj/removeMember.spr"/>
<c:url var="editRoleUrl" value="/proj/admin/editRole.spr?proj_id=${project.id}"/>

<style type="text/css">
	.newskin li.groupMember {
		background-color: #fff7eb;
	}

	.groupMember .role{
		border-color: #fff7eb !important;
	}

	.groupMember .role .hovered{
		border-color: #e2e2e2 !important;
	}

	.countInfo {
		text-transform: none;
		letter-spacing: normal;
		margin-left: 1em;
	}

</style>

<ui:splitTwoColumnLayoutJQuery cssClass="layoutFullPage autoAdjustPanesHeight" disableCloserButtons="true" leftMinWidth="270">

	<jsp:attribute name="leftPaneActionBar">
		<c:if test="${canViewRoles and !projectIsDisabled and canAdminMembers}">
			<c:url var="addRoleUrl" value="/proj/admin/editRole.spr?proj_id=${project.id}"/>
			<a class="addRole" href="${addRoleUrl}"><spring:message code="project.role.add.label" text="Add Role"/></a>
		</c:if>

	</jsp:attribute>

	<jsp:attribute name="leftContent" >
		<c:if test="${canViewRoles}">
			<div class="roleContent">
				<h3 class="roleHeader"><spring:message code="project.roles.label" text="Roles"/>
					<c:if test="${!projectIsDisabled && canAdminMembers}">
						<span class="helpLink large" title="<spring:message code="project.newMember.dragAndDrop.information" text="To assing role you can easily Drag&Drop role/member in both directions!"/>"></span>
					</c:if>
					<span><input class="selectAllRole" type="checkbox"></span></h3>
				<div>
					<ul class="roleSelector">
						<c:forEach items="${roles}" var="role">
							<spring:message var="roleName" code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/>
							<spring:message var="roleTitle" code="role.${role.name}.tooltip" text="${role.shortDescription}" htmlEscape="true"/>
							<c:set var="roleDesc"><c:out value="${role.shortDescription}" escapeXml="true" /></c:set>
							<c:if test="${not empty roleDesc && roleTitle != roleDesc}">
							    <c:set var="roleTitle" value="${roleDesc}" />
							</c:if>
							<c:set var="roleIsProjectAdmin" value="${projectAdminRoles[role.id]}" />
							<c:set var="canDragRole" value="${!projectIsDisabled && canAdminMembers && ((roleIsProjectAdmin && isProjectAdmin) || (!roleIsProjectAdmin))}" />
							<li class="listedRole<c:if test="${canDragRole}"> canDragRole</c:if>" data-role-id="${role.id}">
								<table>
									<tr>
										<td class="handle<c:if test="${canDragRole}"> draggable</c:if>" title="<c:if test="${canDragRole}"><spring:message code="project.newMember.drag.role"/></c:if>"></td>
										<td class="name">
											<span class="roleName" title="${roleTitle}">${roleName}</span>
											<div class="count">
												<div title="<spring:message code="project.newMember.role.count.tooltip"/>" class="storyPointsLabel open">0</div>
											</div>
										</td>
										<td class="manage">
											<c:if test="${canDragRole}">
												<span class="edit" title="<spring:message code="project.newMember.edit.role"/>"></span>
											</c:if>
											<spring:message var="roleCheckboxTooltip" code="project.newMember.role.checkbox.tooltip" arguments="${roleName}"></spring:message>
											<span class="selector"><input type="checkbox" title="${roleCheckboxTooltip}"></span>
										</td>
									</tr>
								</table>
							</li>
						</c:forEach>
					</ul>
				</div>
			</div>
		</c:if>
	</jsp:attribute>

	<jsp:attribute name="middlePaneActionBar">
		<jsp:include page="membersActionBar.jsp"/>
	</jsp:attribute>

	<jsp:body>

		<spring:message var="removeMemberLabel" code="project.member.remove.label" text="Remove Project Member"/>
		<c:url var="editMemberRoleUrl" value="${editMemberRoleUrl}"/>

		<c:url var="removeRoleUrl" value="${removeRoleUrl}"/>

		<c:set var="groupsSize" value="${fn:length(userGroups)}"/>
		<c:set var="membersSize" value="${fn:length(users)}"/>
		<spring:message var="countInfoHint" code="project.newMember.count.info.hint"/>

		<c:if test="${statusId eq 0}">
			<div class="information">
				<spring:message code="project.newMember.resigned.status.info"/>
			</div>
		</c:if>
		<c:if test="${statusId eq -1 || empty statusId}">
			<div class="information">
				<spring:message code="project.newMember.any.status.info"/>
			</div>
		</c:if>

		<div class="accordion">

			<h3 class="accordion-header"><spring:message code="useradmin.groups.label" text="Groups"/>
				<span class="countInfo" title="${canViewRoles ? countInfoHint : ''}"><spring:message code="project.newMember.groups.count.info" arguments="${groupsSize},${groupsSize}"/></span>
			</h3>
			<div class="accordion-content">
				<table class="memberHeader">
					<tr>
						<td class="groupname"><spring:message code="group.name.label" text="Group"/></td>
						<td class="role">
							<c:if test="${canViewRoles}">
								<spring:message code="project.roles.label" text="Roles"/>
							</c:if>
						</td>
					</tr>
				</table>
				<ul class="memberList" id="groups">
					<li class="empty"><spring:message code="account.filter.no.matching.group.short" /></li>
					<c:forEach var="group" items="${userGroups}">
						<li class="member<c:if test="${projectIsDisabled || !canAdminMembers}"> disabled </c:if> groupMember" data-type-id="${userGroupTypeId}" data-member-id="${group.key}">
							<table>
								<tr>
									<td class="handle<c:if test="${canAdminMembers}"> draggable</c:if>" title="<c:if test="${canAdminMembers}"><spring:message code="project.newMember.drag.member"/></c:if>"></td>
									<td class="groupname username">
										<spring:message code="group.${group.value.name}.label" text="${group.value.name}"/>
									</td>
									<td class="role">
										<c:if test="${canViewRoles}">
											<ul class="roleList">
												<c:forEach var="role" items="${userGroupRoles[group.key]}">
													<c:set var="roleIsProjectAdmin" value="${projectAdminRoles[role.id]}" />
													<c:set var="canModifyRole" value="${!projectIsDisabled && canAdminMembers && ((roleIsProjectAdmin && isProjectAdmin) || (!roleIsProjectAdmin))}" />
													<c:set var="assoc" value="${userGroupAssocs[group.key][role.id]}"/>
													<c:if test="${not empty assoc && (empty statusId || statusId eq (not empty assoc.status && not empty assoc.status.id ? assoc.status.id : 0))}">
														<c:set var="isRejected" value="${empty assoc.status || empty assoc.status.id || assoc.status.id eq assocStatusRejectedId}"/>
														<li class="role" data-role-id="${role.id}" data-role-status-rejected="${isRejected}">
															<span class="roleName<c:if test="${isRejected}"> rejected</c:if>"><spring:message code="role.${role.name}.label" text="${role.name}"/></span>
															<c:if test="${canModifyRole && !isRejected}">
																<span class="deleteRole" title="<spring:message code="project.newMember.resign.role"/>"></span>
															</c:if>
															<c:if test="${canModifyRole && isRejected}">
																<span class="reassignRole" title="<spring:message code="project.newMember.reassign.role"/>"></span>
															</c:if>
														</li>
													</c:if>
												</c:forEach>
											</ul>
										</c:if>
									</td>
									<c:if test="${!projectIsDisabled && canAdminMembers}">
										<td class="manage">
											<span class="editMember"><spring:message code="project.member.edit.label" text="Edit"/></span>
											<span class="removeMember" title="${removeMemberLabel}"></span>
										</td>
									</c:if>
								</tr>
							</table>
						</li>
					</c:forEach>
				</ul>
			</div>

			<h3 class="accordion-header"><spring:message code="project.members.title" text="Members"/>
				<span class="countInfo" title="${canViewRoles ? countInfoHint : ''}"><spring:message code="project.newMember.members.count.info" arguments="${membersSize},${membersSize}"/></span>
			</h3>
			<div class="accordion-content">
				<table class="memberHeader">
					<tr>
						<td class="username"><spring:message code="user.name.label" text="User Name"/></td>
						<td class="name"><spring:message code="user.realName.label" text="Real Name"/></td>
						<td class="role">
							<c:if test="${canViewRoles}">
								<spring:message code="project.roles.label" text="Roles"/>
							</c:if>
						</td>
					</tr>
				</table>
				<ul class="memberList" id="members">
					<li class="empty"><spring:message code="account.filter.no.matching.account.short" /></li>
					<c:forEach var="user" items="${users}">
						<li class="member<c:if test="${projectIsDisabled || !canAdminMembers}"> disabled</c:if>" data-type-id="${userTypeId}" data-member-id="${user.key}">
							<table>
								<tr>
									<td class="handle<c:if test="${canAdminMembers}"> draggable</c:if>" title="<c:if test="${canAdminMembers}"><spring:message code="project.newMember.drag.member"/></c:if>"></td>
									<td class="photo">
										<ui:userPhoto userId="${user.key}" userName="${user.value.name}"/>
									</td>
									<td class="username"
										data-user-real-name="${user.value.lastName}, ${user.value.firstName}"
										data-user-company="${canViewCompany ? user.value.company : ''}"
										data-user-email="${canViewEmail ? user.value.email : ''}"
										data-user-phone="${canViewPhone ? user.value.phone : ''}"
										data-user-mobile="${canViewPhone ? user.value.mobile : ''}"
										data-user-address="${canViewAddress ? user.value.address : ''}"
										data-user-zip="${canViewAddress ? user.value.zip : ''}"
										data-user-city="${canViewAddress ? user.value.city : ''}">
											${empty userLinks[user.key] ? user.value.name : userLinks[user.key]}
											<taglib:userLoginIndicator userId="${user.key}"></taglib:userLoginIndicator>
									</td>
									<td class="name">
										<span>${user.value.lastName}, ${user.value.firstName}</span>
									</td>
									<td class="role">
										<c:if test="${canViewRoles}">
											<ul class="roleList">
												<c:forEach var="role" items="${userRoles[user.key]}">
													<c:set var="roleIsProjectAdmin" value="${projectAdminRoles[role.id]}" />
													<c:set var="canModifyRole" value="${!projectIsDisabled && canAdminMembers && ((roleIsProjectAdmin && isProjectAdmin) || (!roleIsProjectAdmin))}" />
													<c:set var="assoc" value="${userAssocs[user.key][role.id]}"/>
													<c:if test="${not empty assoc && (empty statusId || statusId eq (not empty assoc.status && not empty assoc.status.id ? assoc.status.id : 0))}">
														<c:set var="isRejected" value="${empty assoc.status || empty assoc.status.id || assoc.status.id eq assocStatusRejectedId}"/>
														<li class="role" data-role-id="${role.id}" data-role-status-rejected="${isRejected}">
															<span class="roleName<c:if test="${isRejected}"> rejected</c:if>"><spring:message code="role.${role.name}.label" text="${role.name}" htmlEscape="true"/></span>
															<c:if test="${canModifyRole && !isRejected}">
																<span class="deleteRole" title="<spring:message code="project.newMember.resign.role"/>"></span>
															</c:if>
															<c:if test="${canModifyRole && isRejected}">
																<span class="reassignRole" title="<spring:message code="project.newMember.reassign.role"/>"></span>
															</c:if>
														</li>
													</c:if>
												</c:forEach>
											</ul>
										</c:if>
									</td>
									<c:if test="${!projectIsDisabled && canAdminMembers}">
										<td class="manage" data-is-current-user-project-admin="${isProjectAdmin}" data-is-admin-user="${not empty projectAdmins[user.key]}">
											<span class="editMember"><spring:message code="project.member.edit.label" text="Edit"/></span>
											<span class="removeMember" title="${removeMemberLabel}"></span>
										</td>
									</c:if>
								</tr>
							</table>
						</li>
					</c:forEach>
				</ul>
			</div>
		</div>
	</jsp:body>
</ui:splitTwoColumnLayoutJQuery>

<script type="text/javascript">
	jQuery(function($) {
		$(function() {

			var shownRejected = "${empty statusId || statusId eq 0}" == "true";
			var canViewRoles = ${canViewRoles ? 'true' : 'false'};

			var groupsSize = ${groupsSize};
			var membersSize = ${membersSize};

			$("#closer-west").hide();
			var accordion = $('.accordion');
			accordion.cbMultiAccordion();
			accordion.cbMultiAccordion("open", 0);
			accordion.cbMultiAccordion("open", 1);
			accordion.cbMultiAccordion("open", 2);

			var populateRoleNumbers = function() {
				$('.listedRole').each(function() {
					var roleId = $(this).data('role-id');
					var roles = $('.memberList li .roleList li[data-role-status-rejected="false"][data-role-id="' + roleId + '"]');
					$(this).find('.count .storyPointsLabel').text(roles.length);
				});
			};
			populateRoleNumbers();

			var setRoleNumber = function(roleId, increase) {
				var listedRole = $('.listedRole[data-role-id="' + roleId + '"]');
				var numberLabel = listedRole.find('.count .storyPointsLabel');
				var currentNumber = parseInt(numberLabel.text(), 10);
				numberLabel.text(increase ? currentNumber + 1 : currentNumber - 1);
			};

			var toggleEmptyLabel = function() {
				$('.memberList').each(function() {
					var lis = $(this).find("li.member:visible");
					var emptyLi = $(this).find('li.empty');
					var memberHeader = emptyLi.parents('ul').siblings('.memberHeader');
					if (lis.length == 0) {
						emptyLi.show();
						memberHeader.hide();
					} else {
						emptyLi.hide();
						memberHeader.show();
					}
				});
			};
			toggleEmptyLabel();

			$('.memberList').on('mouseenter', 'li.role', function() {
				$(this).addClass('hovered');
			});

			$('.memberList').on('mouseleave', 'li.role', function() {
				$(this).removeClass('hovered');
			});

			$('.memberList li.member').hover(function() {
				$(this).addClass('hovered');
			}, function() {
				$(this).removeClass('hovered');
			});

			// Role content height adjustment because of the scrollbar
			var adjustRoleContent = function() {
				var adjustRoleContentHeight = function() {
					$(".roleContent").height($('#west').height() - $('#headerDiv').height() - 5);
				};
				adjustRoleContentHeight();
				setTimeout(adjustRoleContentHeight, 1000);
			};

			var adjustLongRoleNames = function() {
				var maxWidth = $('.roleSelector li.listedRole').first().width();
				$('.roleSelector li.listedRole').each(function() {
					$(this).find('td.name .roleName').css("width", maxWidth - 90);
				});
			};

			var adjustLeftPaneActionbar = function() {
				$('#headerDiv').height($('#middleHeaderDiv').height() + 4);
			};

			var adjustLayout = function() {
				adjustLongRoleNames();
				adjustRoleContent();
				adjustLeftPaneActionbar();
			};
			adjustLayout();
			setTimeout(adjustLayout, 500);
			$(window).resize(adjustLayout);

			$(".ui-layout-resizer-west").bind("drag", adjustLongRoleNames);
			$(".ui-layout-resizer-east").bind("drag", adjustLongRoleNames);

			var hasVisibleRole = function(memberRoleIds, visibleRoleIds) {
				for (var i = 0; i < memberRoleIds.length; i++) {
					if ($.inArray(memberRoleIds[i], visibleRoleIds) != -1) {
						return true;
					}
				}
				return false;
			};

			var toggleCountingInfo = function(groupsCount, membersCount, groupsSize, membersSize) {
				var groupsMessage = groupsCount == 0 && groupsSize == 0 ? '' : i18n.message("project.newMember.groups.count.info", groupsCount, groupsSize);
				$("#groups").parent().prev("h3").find(".countInfo").html(groupsMessage);
				$("#members").parent().prev("h3").find(".countInfo").html(i18n.message("project.newMember.members.count.info", membersCount, membersSize));
			};

			var displayMembers = function() {
				var groupsCount = 0;
				var membersCount = 0;
				var visibleRoleIds = [];
				$('.roleSelector li.listedRole input').each(function() {
					var checked = $(this).is(':checked');
					if (checked) {
						visibleRoleIds.push($(this).closest('li.listedRole').data('role-id'));
					}
				});
				// Disable visible role ids cookie
				// $.cookie("codebeamer.members.visibleRoleIds", visibleRoleIds.join(','));
				$('.memberList li.member').each(function() {
					var listContainer =  $(this).closest("ul");
					var isGroup = listContainer.is("#groups");
					var isMember = listContainer.is("#members");
					if (canViewRoles) {
						var memberRoleIds = [];
						$(this).find('li.role').each(function() {
							memberRoleIds.push($(this).data('role-id'));
						});
						if (hasVisibleRole(memberRoleIds, visibleRoleIds)) {
							$(this).show();
							if (isGroup) {
								groupsCount++;
							} else if (isMember) {
								membersCount++;
							}
						} else {
							$(this).hide();
						}
					} else {
						$(this).show();
					}
				});
				toggleCountingInfo(canViewRoles ? groupsCount : groupsSize, canViewRoles ? membersCount : membersSize, groupsSize, membersSize);
				toggleEmptyLabel();
			};

			// Preselect stored visible roles - disabled
			var storedVisibleRoleIdsString =  null; //$.cookie("codebeamer.members.visibleRoleIds");
			var storedVisibleRoleIds = storedVisibleRoleIdsString == null || storedVisibleRoleIdsString.length == 0 ? [] : storedVisibleRoleIdsString.split(',');
			var selectAllCheckBox = $('.roleHeader .selectAllRole');
			if (storedVisibleRoleIds.length > 0) {
				var allSelected = true;
				$('.roleSelector li.listedRole input').each(function() {
					if ($.inArray($(this).closest('li').data('role-id').toString(), storedVisibleRoleIds) != -1) {
						$(this).prop('checked', true);
					} else {
						allSelected = allSelected && false;
					}
				});
				if (allSelected) {
					selectAllCheckBox.prop('checked', true);
				}
			} else {
				selectAllCheckBox.prop('checked', true);
				$('.roleSelector li.listedRole input').prop('checked', true);
			}
			displayMembers();

			$(".roleHeader .helpLink").tooltip({
				position: {my: "left top+5", collision: "flipfit"},
				tooltipClass : "tooltip"
			});

			var setRoleSelector = function() {

				$('.roleSelector li.listedRole input').change(function() {
					displayMembers();
				});

				$('.roleHeader .selectAllRole').change(function() {
					$('.roleSelector li.listedRole input').prop('checked', $(this).is(':checked'));
					displayMembers();
				});

				$('.roleSelector li.listedRole .edit').click(function(e) {
					var li = $(this).closest('li.listedRole');
					window.location.href = "${editRoleUrl}" + "&role_id=" + li.data('role-id');
				});

				$('.roleSelector li.listedRole .count .storyPointsLabel').click(function() {
					$('.roleSelector li.listedRole input').prop('checked', false);
					$('.roleHeader .selectAllRole').prop('checked', false);
					$(this).closest('li.listedRole').find('input').prop('checked', true);
					displayMembers();
				});
			};

			setRoleSelector();

			var getMemberTypeAndIdUrl = function(li) {
				return "&member_type=" +  li.data('type-id') + "&member_id=" + li.data('member-id');
			};

			var removeMember = function(el) {
				var member = el.closest('li.member');
				var listContainer =  member.closest("ul");
				var isGroup = listContainer.is("#groups");
				var isMember = listContainer.is("#members");
				var groupsCount = $('#groups').find("li.member:not(.empty):visible").length;
				var membersCount = $('#members').find("li.member:not(.empty):visible").length;
				var userName = member.find('.username a').length > 0 ? member.find('.username a').text() : member.find('.username').text();
				showFancyConfirmDialogWithCallbacks(i18n.message("project.member.remove.label.confirm", userName),
						function() {
							flashChanged(member);
							var parameters = {
								"proj_id" : ${project.id},
								"member_type" : member.data('type-id'),
								"member_id" : member.data('member-id')
							};

							$.ajax("${removeMemberUrl}", {
								"type": "POST",
								"data": parameters,
								"success": function(data) {
									if (data['success']) {
										showOverlayMessage();
										member.find('.roleList').find('li.role').each(function() {
											if ($(this).attr('data-role-status-rejected') == "false") {
												setRoleNumber($(this).data('role-id'), false);
											}
										});
										member.fadeOut(function() {
											member.remove();
											toggleEmptyLabel();
											if (isMember) {
												membersSize--;
											} else if (isGroup) {
												groupsSize--;
											}
											toggleCountingInfo(isGroup ? groupsCount - 1 : groupsCount, isMember ? membersCount - 1 : membersCount, groupsSize, membersSize);
										});
									} else {
										if (data['message'] != null){
											showOverlayMessage(data['message'], null, true);
										} else {
											showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
										}
									}
								},
								"error": function () {
									showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
								}
							});
						}, function() {
							//
						});
			};

			var editMemberRole = function(el, isReadOnly) {
				var li = el.closest('li.member'),
					parameters = getMemberTypeAndIdUrl(li);
				
				if (isReadOnly) {
					parameters += '&isReadOnly=true';
				}
				
				showPopupInline("${editMemberRoleUrl}" + parameters, { geometry: 'half-half'});
			};

			$('.removeMember').click(function() {
				var $element = $(this),
					$parent = $element.parent();

				if (!$parent.data('isCurrentUserProjectAdmin') && $parent.data('isAdminUser')) {
					showFancyAlertDialog(i18n.message('project.members.admin.role.only.warning'));
					return;
				}
				
				removeMember($element);
			});

			$('.editMember').click(function(){
				var $element = $(this),
					$parent = $element.parent();

				editMemberRole($element, (!$parent.data('isCurrentUserProjectAdmin') && $parent.data('isAdminUser')));
			});


			var setMemberRole = function(role, member, remove, callback) {

				var roleList = member.find('.roleList');
				var roleIds = "";
				var currentRoleId = role.data('role-id');
				roleList.find('li.role').each(function() {
					var roleId = $(this).data('role-id');
					if ($(this).attr('data-role-status-rejected') == "false") {
						if ((remove && roleId != currentRoleId) || !remove) {
							roleIds += roleId + ',';
						}
					}
				});
				if (!remove) {
					roleIds += currentRoleId + ',';
				}
				roleIds = roleIds.slice(0, -1);

				var parameters = {
					"proj_id" : ${project.id},
					"member_type" : member.data('type-id'),
					"member_id" : member.data('member-id'),
					"role_ids" : roleIds
				};

				$.ajax("${setMemberRoleUrl}", {
					"type": "POST",
					"data": parameters,
					"success": callback,
					"error": function () {
						showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
					}
				});

			};

			var removeRole = function(role, member) {

				if (!shownRejected && role.closest('.roleList').find('li').length == 1) {
					removeMember(role);
				} else {
					setMemberRole(role.closest('.role'), member, true, function(data) {
						if (data['success']) {
							showOverlayMessage();
							var li = role.closest('li');
							if (shownRejected) {
								li.attr('data-role-status-rejected', "true");
								li.find('.roleName').addClass('rejected');
								li.find('.deleteRole').remove();
								li.append($('<span class="reassignRole" title="' + i18n.message('project.newMember.reassign.role') + '"></span>'));
								flashChanged(li.find('.roleName'));
							} else {
								li.remove();
							}
							setRoleNumber(li.data("role-id"), false);
						} else {
							if (data['message'] != null){
								showOverlayMessage(data['message'], null, true);
							} else {
								showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
							}
						}
					});

				}

			};

			var getRejectedRoleIds = function(member) {
				var roleIds = [];
				member.find('.roleList .role').each(function() {
					if ($(this).attr('data-role-status-rejected') == "true") {
						roleIds.push($(this).data('role-id'));
					}
				});
				return roleIds;
			};

			var reassignRole = function(roleLi, member) {
				var li = member.find('.roleList .role[data-role-id="' + roleLi.data('role-id') + '"]');
				li.attr("data-role-status-rejected", "false");
				li.find('.roleName').removeClass('rejected');
				li.find('.reassignRole').remove();
				li.append($('<span class="deleteRole" title="' + i18n.message('project.newMember.resign.role') + '"></span>'));
				flashChanged(li.find('.roleName'));
				setRoleNumber(li.data('role-id'), true);
			};

			$('.memberList').on('click', '.deleteRole', function() {
				removeRole($(this), $(this).closest('.member'));
			});

			$('.memberList').on('click', '.reassignRole', function() {
				var roleLi = $(this).closest('.role');
				var member = roleLi.closest('.member');
				setMemberRole(roleLi, member, false, function(data) {
					if (data['success']) {
						showOverlayMessage();
						reassignRole(roleLi, member);
					} else {
						showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
					}
				});
			});

			var makeListsDraggable = function() {

				var allMembers = $('.memberList .member');
				var allRoles = $('.roleSelector .listedRole.canDragRole');

				var layoutResizer = $('.ui-layout-resizer');
				var originalLayoutResizerZIndex = layoutResizer.css('z-index');

				var getRoleIds = function(member) {
					var roleIds = [];
					member.find('.roleList .role').each(function() {
						if ($(this).attr('data-role-status-rejected') == "false") {
							roleIds.push($(this).data('role-id'));
						}
					});
					return roleIds;
				};

				var setHelper = function(originalItem, helper) {
					helper.find('.manage').remove();
					helper.width(originalItem.width());
					helper.height(originalItem.height());
					layoutResizer.css('z-index', 0);
					helper.css('z-index', 1000);
				};

				var appendRoleToList = function(roleLi, member) {

					setMemberRole(roleLi, member, false, function(data) {
						if (data['success']) {
							showOverlayMessage();
							if (shownRejected && $.inArray(roleLi.data('role-id'), getRejectedRoleIds(member)) != -1) {
								reassignRole(roleLi, member);
							} else {
								var newRole = $('<li class="role" data-role-status-rejected="false" data-role-id="' + roleLi.data('role-id') + '"></li>');
								var newRoleName = roleLi.find('.name .roleName').text();
								newRole.append($('<span class="roleName">' + newRoleName +'</span>'));
								newRole.append($('<span class="deleteRole" title="' + i18n.message('project.newMember.resign.role') + '"></span>'));
								member.find(".roleList").append(newRole);
								flashChanged(newRole.find('.roleName'));
								setRoleNumber(roleLi.data('role-id'), true);
							}
						} else {
							showOverlayMessage(i18n.message("project.member.save.role.error"), null, true);
						}
					});
				};

				var removeDroppable = function(elements) {
					elements.removeClass('highlighted');
					// remove previous droppable
					elements.each(function() {
						if ($(this).data('uiDroppable')) {
							$(this).droppable('destroy');
						}
					});
				};

				// Member list D&D
				var makeMemberListDraggable = function() {

					var getDroppableRoles = function(member) {
						var roleIds = getRoleIds(member);
						var roles = $();
						allRoles.each(function() {
							if ($.inArray($(this).data('role-id'), roleIds) == -1) {
								$(this).addClass('highlighted');
								roles = roles.add($(this));
							}
						});
						return roles;
					};

					$('.memberList .member').draggable({
						appendTo : '#west',
						cursor : 'move',
						delay: 300,
						start : function(e, ui) {
							setHelper($(this), ui.helper);
							var droppableRoles = getDroppableRoles(ui.helper);

							droppableRoles.droppable({
								hoverClass : 'dropHover',
								tolerance : 'pointer',
								drop : function(e, ui) {
									appendRoleToList($(this), ui.draggable);
								}
							});
						},
						helper : 'clone',
						stop : function(e, ui) {
							ui.helper.remove();
							layoutResizer.css('z-index', originalLayoutResizerZIndex);
							removeDroppable(allRoles);
						}
					});
				};

				// Role list D@D
				var makeRoleListDraggable = function() {

					var getDroppableMembers = function(roleId) {
						var members = $();
						allMembers.each(function() {
							var roleIds = getRoleIds($(this));
							if ($.inArray(roleId, roleIds) == -1) {
								$(this).addClass('highlighted');
								members = members.add($(this));
							}
						});
						return members;
					};

					allRoles.draggable({
						cursor : 'move',
						delay: 300,
						start : function(e, ui) {
							setHelper($(this), ui.helper);

							var roleId = $(this).data('role-id');
							var droppableMembers = getDroppableMembers(roleId);

							droppableMembers.droppable({
								hoverClass : 'dropHover',
								drop : function(e, ui) {
									appendRoleToList(ui.helper, $(this));
								}
							});

						},
						helper : 'clone',
						stop : function(e, ui) {
							ui.helper.remove();
							layoutResizer.css('z-index', originalLayoutResizerZIndex);
							removeDroppable(allMembers);
						}
					});
				};

				makeMemberListDraggable();
				makeRoleListDraggable();

			};

			var setFloatingDiv = function() {

				var tooltipArgs = {
					position: {my: "left top+5", collision: "flipfit"},
					tooltipClass : "tooltip",
					content : function() {

						var td = $(this).closest('tr').find('td.username');
						var addProperty = function(htmlText, propertyName) {
							var prop = td.data('user-' + propertyName);
							if (prop.length > 0) {
								htmlText += '<p class="' + propertyName + '">' + prop + '</p>';
							}
							return htmlText;
						};

						var info = '';
						info = addProperty(info, 'real-name');
						info = addProperty(info, 'company');
						info = addProperty(info, 'email');
						info = addProperty(info, 'phone');
						info = addProperty(info, 'mobile');
						info = addProperty(info, 'address');
						info = addProperty(info, 'zip');
						info = addProperty(info, 'city');

						return info;
					}
				};

				$('#members .username').tooltip(tooltipArgs);
				$('#members .photo').tooltip(tooltipArgs);


				$(".listedRole .roleName").tooltip({
					position: {my: "left top+5", collision: "flipfit"},
					tooltipClass : "tooltip"
				});
			};

			<c:if test="${!projectIsDisabled && canAdminMembers}">
			makeListsDraggable();
			setFloatingDiv();
			</c:if>

		});
	});
</script>
