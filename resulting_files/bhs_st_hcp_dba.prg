CREATE PROGRAM bhs_st_hcp:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = gvc
    1 status_data[1]
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE mf_cs8_active = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_cs8_altered = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_auth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs53_placeholder = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE mf_cs72_hcp_scanned = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEALTHCAREPROXYSCANNEDFORM"))
 DECLARE mf_cs72_no_adv_dir = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NOADVANCEDIRECTIVEINCISBECAUSE"))
 DECLARE mf_cs72_psy_no_adv_dir = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PSYCHNOADVANCEDIRECTIVEINCISBC"))
 DECLARE mf_cs72_ord_lif_sus = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ORDERSFORLIFESUSTAININGTREATMENT"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_scanned = vc WITH protect, noconstant(" ")
 DECLARE ms_no_adv_dir = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  pl_sort =
  IF (ce.event_cd=mf_cs72_hcp_scanned) 1
  ELSEIF (ce.event_cd=mf_cs72_ord_lif_sus) 2
  ENDIF
  FROM clinical_event ce
  WHERE (ce.person_id=request->person[1].person_id)
   AND ce.event_cd IN (mf_cs72_hcp_scanned, mf_cs72_ord_lif_sus)
   AND ce.result_status_cd IN (mf_cs8_active, mf_cs8_altered, mf_cs8_auth, mf_cs8_modified)
   AND ce.event_class_cd != mf_cs53_placeholder
   AND ce.view_level=1
   AND ce.valid_until_dt_tm >= sysdate
  ORDER BY pl_sort, ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD pl_sort
   null
  HEAD ce.event_cd
   CALL echo(build2("ce.event_cd: ",trim(cnvtstring(ce.event_cd),3)," ",uar_get_code_display(ce
     .event_cd)," ",
    ce.result_val))
   IF (ce.event_cd=mf_cs72_hcp_scanned)
    ms_scanned = "Yes - Health Care Proxy"
   ENDIF
   IF (ce.event_cd=mf_cs72_ord_lif_sus)
    IF (textlen(trim(ms_scanned,3))=0)
     ms_scanned = "Yes - MOLST"
    ELSE
     ms_scanned = concat(ms_scanned,ms_reol," Yes - MOLST")
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.event_cd IN (mf_cs72_no_adv_dir, mf_cs72_psy_no_adv_dir)
    AND ce.result_status_cd IN (mf_cs8_active, mf_cs8_altered, mf_cs8_auth, mf_cs8_modified)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= sysdate
   ORDER BY ce.encntr_id, ce.valid_from_dt_tm DESC
   HEAD ce.encntr_id
    ms_no_adv_dir = trim(ce.result_val,3)
   WITH nocounter
  ;end select
 ENDIF
 SET ms_tmp = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 IF (textlen(trim(ms_scanned,3)) > 0)
  CALL echo("add type to scanned")
  SET ms_tmp = concat(ms_tmp,ms_scanned,"}")
 ELSE
  SET ms_tmp = concat(ms_tmp,"No",ms_reol," ",ms_no_adv_dir,
   "}")
 ENDIF
 SET reply->text = ms_tmp
 CALL echo(reply->text)
#exit_script
END GO
