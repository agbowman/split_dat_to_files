CREATE PROGRAM bhs_gvw_admit_reason:dba
 DECLARE mf_cs72_chiefcomplaint_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "CHIEFCOMPLAINT"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs200_admitrequestedonly_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITREQUESTEDONLY"))
 DECLARE mf_cs200_admitrequestedonlybfmc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"ADMITREQUESTEDONLYBFMC"))
 DECLARE mf_cs200_admitrequestedonlybmc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"ADMITREQUESTEDONLYBMC"))
 DECLARE mf_cs200_admitrequestedonlybnh_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"ADMITREQUESTEDONLYBNH"))
 DECLARE mf_cs200_admitrequestedonlybwhbmlh_cd = f8 WITH protect, constant(uar_get_code_by(
   "DISPLAYKEY",200,"ADMITREQUESTEDONLYBWHBMLH"))
 DECLARE mf_cs6004_completed_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100")
  )
 DECLARE mf_cs6004_inprocess_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224")
  )
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6004_discontinued_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3101"))
 DECLARE mf_cs6004_pending_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2564278"
   ))
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE ms_complaint = vc WITH protect, noconstant("")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND (ce.person_id=request->person[1].person_id)
    AND ce.event_cd=mf_cs72_chiefcomplaint_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd)
    AND ce.event_title_text != "Date\Time Correction"
    AND ce.view_level=1)
  ORDER BY ce.performed_dt_tm
  HEAD ce.performed_dt_tm
   ms_complaint = trim(ce.result_val,3)
  WITH nocounter
 ;end select
 IF (size(trim(ms_complaint,3))=0)
  SELECT INTO "nl:"
   FROM orders o,
    order_detail od,
    order_entry_fields oef
   PLAN (o
    WHERE (o.person_id=request->person[1].person_id)
     AND (o.encntr_id=request->visit[1].encntr_id)
     AND o.active_ind=1
     AND o.order_status_cd IN (mf_cs6004_completed_cd, mf_cs6004_inprocess_cd, mf_cs6004_ordered_cd,
    mf_cs6004_discontinued_cd, mf_cs6004_pending_cd)
     AND o.catalog_cd IN (mf_cs200_admitrequestedonly_cd, mf_cs200_admitrequestedonlybfmc_cd,
    mf_cs200_admitrequestedonlybmc_cd, mf_cs200_admitrequestedonlybnh_cd,
    mf_cs200_admitrequestedonlybwhbmlh_cd))
    JOIN (od
    WHERE od.order_id=o.order_id)
    JOIN (oef
    WHERE oef.oe_field_id=od.oe_field_id
     AND cnvtupper(trim(oef.description,3))="REASON FOR ADMISSION")
   ORDER BY o.order_id DESC, od.action_sequence DESC
   HEAD REPORT
    ms_complaint = trim(od.oe_field_display_value,3)
   WITH nocounter
  ;end select
 ENDIF
 SET s_text = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18 "
 IF (size(trim(ms_complaint,3)) > 0)
  SET s_text = concat(s_text," ",ms_complaint," \par ")
 ENDIF
 SET s_text = concat(s_text,"}")
 SET reply->text = s_text
 CALL echorecord(reply)
#exit_script
END GO
