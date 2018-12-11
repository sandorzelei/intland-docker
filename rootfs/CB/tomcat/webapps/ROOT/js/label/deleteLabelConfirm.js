/*
	Confirm javascript for Tags page when deleting a tag
*/
function deleteLabel(labelName) {
	return confirm(i18n.message('tag.delete.confirm', escapeHtmlEntities(labelName)));
}
