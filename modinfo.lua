name = 'Feats of the World'
description = 'Feats for you to achieve!'
author = 'debugman18'
version = "1.3"
forumthread = "19505-Modders-Your-new-friend-at-Klei!"
api_version = 6
dont_starve_compatible = true
reign_of_giants_compatible = true
icon_atlas = "Feats.xml"
icon = "Feats.tex"
priority = -1

configuration_options =
{
	{
		name = "debugprint",
        label = "Debugging",
		options = 
		{
			{description = "Enabled", data = true}, 
			{description = "Disabled", data = false}
		}, 
		default = false,
	}
}