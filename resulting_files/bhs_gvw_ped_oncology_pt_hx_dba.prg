CREATE PROGRAM bhs_gvw_ped_oncology_pt_hx:dba
 RECORD m_request(
   1 desired_format_cd = f8
   1 origin_format_cd = f8
   1 origin_text = gvc
   1 page_height = vc
   1 page_width = vc
   1 page_margin_top = vc
   1 page_margin_bottom = vc
   1 page_margin_left = vc
   1 page_margin_right = vc
 )
 RECORD m_reply(
   1 converted_text = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE mf_cd72_pedioncologyhistory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PEDIATRICONCOLOGYHISTORY")), protect
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_rtf_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE mf_html_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"HTML"))
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE md_reg_dt_tm = dq8 WITH protect
 DECLARE ms_msg_temp = vc WITH protect, noconstant(" ")
 DECLARE mf_event_id = f8 WITH protect, noconstant(0.00)
 DECLARE mn_strip_rtf_ind = i2 WITH protect, noconstant(0)
 SET mf_per_id = request->person[1].person_id
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_blob ceb
  PLAN (ce
   WHERE ce.person_id=mf_per_id
    AND ce.event_cd=mf_cd72_pedioncologyhistory
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_modified_cd))
   JOIN (ceb
   WHERE ceb.event_id=ce.event_id
    AND ceb.valid_until_dt_tm=ce.valid_until_dt_tm)
  ORDER BY ce.event_end_dt_tm DESC, ce.event_cd
  HEAD REPORT
   mf_event_id = ce.event_id
  WITH nocounter
 ;end select
 EXECUTE bhs_hlp_ccl
 SET ms_msg_temp = bhs_sbr_get_blob(value(mf_event_id),mn_strip_rtf_ind)
 SET m_request->desired_format_cd = mf_rtf_cd
 SET m_request->origin_format_cd = mf_html_cd
 SET m_request->origin_text = ms_msg_temp
 SET stat = tdbexecute(3202004,3202004,969553,"REC",m_request,
  "REC",m_reply)
 SET m_reply->converted_text = replace(m_reply->converted_text,"\fs20","\fs18")
 SET m_reply->converted_text = replace(m_reply->converted_text,"\fs24","\fs18")
 SET m_reply->converted_text = replace(m_reply->converted_text,"\f3","\f4")
 SET reply->text = m_reply->converted_text
#exit_script
 SET reply->status_data.status = "S"
END GO
