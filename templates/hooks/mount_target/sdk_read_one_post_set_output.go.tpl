
	// --- Populate LifeCycleState from GetMountTarget response ---
	// The Status field in the API response conflicts with the Kubernetes
	// Status subresource, so it's in ignore.field_paths. We manually map
	// the LifeCycleState here from the resp variable (in scope from sdkFind).
	{
		lifecycleState := string(resp.Status)
		ko.Status.LifeCycleState = &lifecycleState
	}

	// --- Terminal condition on error lifecycle state ---
	// The synced.when config handles setting Synced=False for non-available
	// states, but it does not set ACK.Terminal for the "error" lifecycle
	// state. This hook sets Terminal=True when the mount target is in error
	// state, and clears it otherwise.
	if ko.Status.LifeCycleState != nil && *ko.Status.LifeCycleState == "error" {
		msg := "MountTarget is in error state"
		if ko.Status.StatusMessage != nil {
			msg = *ko.Status.StatusMessage
		}
		ackcondition.SetTerminal(&resource{ko}, corev1.ConditionTrue, &msg, nil)
	} else {
		ackcondition.SetTerminal(&resource{ko}, corev1.ConditionFalse, nil, nil)
	}
