CREATE PROGRAM dcp_verify_def_encntr:dba
 RECORD name_value(
   1 qual[*]
     2 pvc_name = vc
 )
 SET count = 0
 SET nbr_records = 0
 SET stat = alterlist(name_value->qual,1)
 SET app_prefs_id = 0.0
 SELECT INTO "nl:"
  aps.app_prefs_id
  FROM app_prefs aps
  WHERE aps.position_cd=0
   AND aps.prsnl_id=0
   AND aps.application_number=600005
  DETAIL
   app_prefs_id = aps.app_prefs_id
  WITH nocounter
 ;end select
 IF (app_prefs_id != 0)
  SELECT INTO "nl:"
   nvp.pvc_name
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_id=app_prefs_id
    AND nvp.pvc_name="encntrDisp.*"
   DETAIL
    CALL echo(nvp.pvc_name), count = (count+ 1), stat = alterlist(name_value->qual,count),
    name_value->qual[count].pvc_name = nvp.pvc_name
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO count)
   CASE (name_value->qual[count].pvc_name)
    OF "encntrDisp.INPATIENT":
     SET nbr_records = (nbr_records+ 1)
    OF "encntrDisp.OUTPATIENT":
     SET nbr_records = (nbr_records+ 1)
    OF "encntrDisp.EMERGENCY":
     SET nbr_records = (nbr_records+ 1)
    OF "encntrDisp.RECURRING":
     SET nbr_records = (nbr_records+ 1)
    OF "encntrDisp.DEFAULT":
     SET nbr_records = (nbr_records+ 1)
   ENDCASE
 ENDFOR
 SET request->setup_proc[1].process_id = 678
 IF (nbr_records < 5)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "App prefs for the encntrDisp have not been created"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "App prefs for the encntrDisp have been created"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
