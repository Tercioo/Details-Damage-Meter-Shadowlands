	local _detalhes = 		_G._detalhes
	local _

	local atributo_custom = _detalhes.atributo_custom
	local ToKFunctions = _detalhes.ToKFunctions

	function atributo_custom:UpdateHealingDoneBracket()
		SelectedToKFunction = ToKFunctions [_detalhes.ps_abbreviation]
		FormatTooltipNumber = ToKFunctions [_detalhes.tooltip.abbreviation]
		TooltipMaximizedMethod = _detalhes.tooltip.maximize_method
	end