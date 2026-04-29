
	// --- Terminal condition on error lifecycle state ---
	// The synced.when config handles setting Synced=False for non-available
	// states, but it does not set ACK.Terminal for the "error" lifecycle
	// state. The error state is unrecoverable — the user must delete and
	// recreate the resource.
	if ko.Status.Status != nil && *ko.Status.Status == "error" {
		msg := "MountTarget is in error state"
		if ko.Status.StatusMessage != nil {
			msg = *ko.Status.StatusMessage
		}
		ackcondition.SetTerminal(&resource{ko}, corev1.ConditionTrue, &msg, nil)
	} else {
		ackcondition.SetTerminal(&resource{ko}, corev1.ConditionFalse, nil, nil)
	}
