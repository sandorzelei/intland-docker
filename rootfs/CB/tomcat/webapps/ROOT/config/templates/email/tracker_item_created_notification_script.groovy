// list of project IDs, tracker IDs and tracker item IDs
// that will be ignored when sending notification emails
def ignoredProjects = [-1, -2]
def ignoredTrackers = [-1, -2]
def ignoredTrackerItems = [-1, -2]

// reject if listed
if(trackerItem.tracker.project.id in ignoredProjects ||
   trackerItem.tracker.id in ignoredTrackers ||
   trackerItem.id in ignoredTrackerItems) {
	return false
}

return true
