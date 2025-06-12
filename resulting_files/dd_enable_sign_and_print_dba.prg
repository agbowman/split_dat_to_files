CREATE PROGRAM dd_enable_sign_and_print:dba
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Event Code:  " = "",
  "Print Behavior (overrides PRINT_DOCUMENTS in PrefMaint.exe for the above event code): " = "",
  "Default Print Template: (overrides DEFAULT_DRAFT_PRINT_TEMPLATE in PrefMaint.exe for the above event code): "
   = ""
  WITH outdev, event_code, print_behaviour,
  def_print_template
 RECORD request(
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 nv[3]
     2 pvc_name = c32
     2 pvc_value = vc
     2 sequence = i2
     2 merge_id = f8
     2 merge_name = vc
 )
 SET request->application_number = 600005
 SET request->position_cd = 0
 SET request->prsnl_id = 0
 SET request->nv[1].pvc_name = "PRINT_CHKBOX_EVENT_CD_41"
 SET request->nv[1].pvc_value =  $EVENT_CODE
 SET request->nv[2].pvc_name = "PRINT_DOCUMENTS_41"
 SET request->nv[2].pvc_value =  $PRINT_BEHAVIOUR
 SET request->nv[3].pvc_name = "DEFAULT_PRINT_TEMPLATE_NAME_41"
 SET request->nv[3].pvc_value =  $DEF_PRINT_TEMPLATE
 EXECUTE dcp_add_app_prefs
 COMMIT
END GO
