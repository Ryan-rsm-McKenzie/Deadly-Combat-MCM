ScriptName DCMCMScript Extends SKI_ConfigBase


Actor Property PlayerRef Auto
Perk Property DCPlayerPerk Auto
Quest Property DCInitQuest Auto
Spell property DCAbPlayerSpell Auto
Spell Property ConfigSpell Auto
DCInitQuestScript Property QuestScript Auto


; Called when the config menu is initialized.
Event OnConfigInit()
	ModName = "$DC_ModName"
	pages = New String[1]
	pages[0] = "$DC_pages0"
EndEvent


; Called when the config menu is closed.
Event OnConfigClose()
EndEvent


; Called when a version update of this script has been detected.
; a_version - The new version.
Event OnVersionUpdate(Int a_version)
EndEvent


; Called when a new page is selected, including the initial empty page.
; a_page - The name of the the current page, or "" if no page is selected.
Event OnPageReset(String a_page)
	If (a_page == "$DC_pages0")
		SetCursorFillMode(LEFT_TO_RIGHT)
		
		If (DCInitQuest.IsRunning())
			AddToggleOptionST("DC_StaggerPlayer_B", "$DC_ToggleOption_StaggerPlayer", QuestScript.DCIsPreventPlayerStaggerSpamEnabled())
			AddTextOptionST("DC_Save_T", "$SAVE", "")
			AddToggleOptionST("DC_StaggerEnemy_B", "$DC_ToggleOption_StaggerEnemy", QuestScript.DCIsPreventEnemyStaggerSpamEnabled())
			AddTextOptionST("DC_Load_T", "$LOAD", "")
			AddToggleOptionST("DC_TimedBlocking_B", "$DC_ToggleOption_TimedBlocking", QuestScript.DCIsTimedBlockingEnabled())
			AddTextOptionST("DC_RemoveSpell_T", "$DC_TextOption_RemoveSpell", "")
			AddToggleOptionST("DC_TimedWarding_B", "$DC_ToggleOption_TimedWarding", QuestScript.DCIsTimedWardingEnabled())
			AddTextOptionST("DC_Deactivate_T", "$DC_TextOption_Deactivate", "")
		Else
			AddTextOptionST("DC_Activate_T", "$DC_TextOption_Activate", "")
		EndIf
	EndIf
EndEvent


State DC_StaggerPlayer_B
	Event OnSelectST()
		If (QuestScript.DCIsPreventPlayerStaggerSpamEnabled())
			QuestScript.SetStaggerSpamPreventionPlayer(False)
		Else
			QuestScript.SetStaggerSpamPreventionPlayer(True)
		EndIf
		SetToggleOptionValueST(QuestScript.DCIsPreventPlayerStaggerSpamEnabled())
	EndEvent

	Event OnDefaultST()
		QuestScript.SetStaggerSpamPreventionPlayer(True)
		SetToggleOptionValueST(QuestScript.DCIsPreventPlayerStaggerSpamEnabled())
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_StaggerPlayer")
	EndEvent
EndState


State DC_Save_T
	Event OnSelectST()
		BeginSavePreset()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_Save")
	EndEvent
EndState


State DC_StaggerEnemy_B
	Event OnSelectST()
		If (QuestScript.DCIsPreventEnemyStaggerSpamEnabled())
			QuestScript.SetStaggerSpamPreventionNPCs(False)
		Else
			QuestScript.SetStaggerSpamPreventionNPCs(True)
		EndIf
		SetToggleOptionValueST(QuestScript.DCIsPreventEnemyStaggerSpamEnabled())
	EndEvent

	Event OnDefaultST()
		QuestScript.SetStaggerSpamPreventionNPCs(True)
		SetToggleOptionValueST(QuestScript.DCIsPreventEnemyStaggerSpamEnabled())
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_StaggerEnemy")
	EndEvent
EndState


State DC_Load_T
	Event OnSelectST()
		BeginLoadPreset()
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_Load")
	EndEvent
EndState


State DC_TimedBlocking_B
	Event OnSelectST()
		If (QuestScript.DCIsTimedBlockingEnabled())
			QuestScript.SetTimedBlocking(False)
		Else
			QuestScript.SetTimedBlocking(True)
		EndIf
		SetToggleOptionValueST(QuestScript.DCIsTimedBlockingEnabled())
	EndEvent

	Event OnDefaultST()
		QuestScript.SetTimedBlocking(True)
		SetToggleOptionValueST(QuestScript.DCIsTimedBlockingEnabled())
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_TimedBlocking")
	EndEvent
EndState


State DC_RemoveSpell_T
	Event OnSelectST()
		If (ConfigSpell && PlayerRef.RemoveSpell(ConfigSpell))
			ShowMessage("$DC_RemoveSpell_Success", False, "$OK")
		Else
			ShowMessage("$DC_RemoveSpell_Failure", False, "$OK")
		EndIf
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_RemoveSpell")
	EndEvent
EndState


State DC_TimedWarding_B
	Event OnSelectST()
		If (QuestScript.DCIsTimedWardingEnabled())
			QuestScript.SetTimedWarding(False)
		Else
			QuestScript.SetTimedWarding(True)
		EndIf
		SetToggleOptionValueST(QuestScript.DCIsTimedWardingEnabled())
	EndEvent

	Event OnDefaultST()
	QuestScript.SetTimedWarding(True)
		SetToggleOptionValueST(QuestScript.DCIsTimedWardingEnabled())
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_TimedWarding")
	EndEvent
EndState


State DC_Deactivate_T
	Event OnSelectST()
		DCInitQuest.Stop()
		If (DCAbPlayerSpell)
			PlayerRef.RemoveSpell(DCAbPlayerSpell)
		EndIf
		If (DCPlayerPerk)
			PlayerRef.RemovePerk(DCPlayerPerk)
		EndIf
		ShowMessage("$DC_Deactivated", False, "$OK")
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_Deactivate")
	EndEvent
EndState


State DC_Activate_T
	Event OnSelectST()
		DCInitQuest.Start()
		ShowMessage("$DC_Activated", False, "$OK")
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("$DC_InfoText_Activate")
	EndEvent
EndState


; Returns the static version of this script.
; RETURN - The static version of this script.
; History:
; 1 - Initial Release (v1.0.0)
Int Function GetVersion()
	Return 1
EndFunction


; Saves the current preset using FISS
Function BeginSavePreset()
	If (!ShowMessage("$DC_Save_AreYouSure") || !ShowMessage("$DC_PleaseWait"))
		Return
	EndIf

	FISSInterface fiss = FISSFactory.getFISS()
	If (!fiss)
		ShowMessage("$DC_FISSNotFound", False, "$OK")
		Return
	EndIf

	fiss.beginSave("DeadlyCombatMCM.xml", "Deadly Combat MCM")

	fiss.saveBool("DC_StaggerPlayer_B", QuestScript.DCIsPreventPlayerStaggerSpamEnabled())
	fiss.saveBool("DC_StaggerEnemy_B", QuestScript.DCIsPreventEnemyStaggerSpamEnabled())
	fiss.saveBool("DC_TimedBlocking_B", QuestScript.DCIsTimedBlockingEnabled())
	fiss.saveBool("DC_TimedWarding_B", QuestScript.DCIsTimedWardingEnabled())

	String saveResult = fiss.endSave()

	If (saveResult != "")
		ShowMessage("$DC_Save_Failure", False, "$OK")
	Else
		ShowMessage("$DC_Save_Success", False, "$OK")
	EndIf
EndFunction


; Loads the saved preset using FISS
Function BeginLoadPreset()
	If (!ShowMessage("$DC_Load_AreYouSure") || !ShowMessage("$DC_PleaseWait"))
		Return
	EndIf

	FISSInterface fiss = FISSFactory.getFISS()
	If (!fiss)
		ShowMessage("$DC_FISSNotFound", False, "$OK")
		Return
	EndIf

	fiss.beginLoad("DeadlyCombatMCM.xml")

	QuestScript.SetStaggerSpamPreventionPlayer(fiss.loadBool("DC_StaggerPlayer_B"))
	QuestScript.SetStaggerSpamPreventionNPCs(fiss.loadBool("DC_StaggerEnemy_B"))
	QuestScript.SetTimedBlocking(fiss.loadBool("DC_TimedBlocking_B"))
	QuestScript.SetTimedWarding(fiss.loadBool("DC_TimedWarding_B"))

	String loadResult = fiss.endLoad()

	If (loadResult != "")
		ShowMessage("$DC_Load_Failure", False, "$OK")
	Else
		ShowMessage("$DC_Load_Success", False, "$OK")
	EndIf
EndFunction