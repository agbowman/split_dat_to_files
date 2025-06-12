CREATE PROGRAM bhs_rpt_exclusive_pplans:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  mcds_powerplan_filter_name = bd.filter_display, powerplan_description = pc.description,
  current_powerplan_version_selected = pc.version,
  powerplan_id = bdv.parent_entity_id, powerplan_last_updated_date_time = pc.updt_dt_tm,
  powerplan_updated_by = p.name_full_formatted,
  bedrock_filter_last_updated_date_time = bdv.value_dt_tm, bedrock_filter_last_updated_by = p2
  .name_full_formatted
  FROM br_datamart_category b,
   br_datamart_report bdr,
   br_datamart_report_filter_r bdrf,
   br_datamart_filter bd,
   br_datamart_value bdv,
   pathway_catalog pc,
   person p,
   person p2
  PLAN (b
   WHERE b.category_mean="MP_MCDS")
   JOIN (bdr
   WHERE bdr.br_datamart_category_id=b.br_datamart_category_id)
   JOIN (bdrf
   WHERE bdrf.br_datamart_report_id=bdr.br_datamart_report_id)
   JOIN (bd
   WHERE bd.br_datamart_filter_id=bdrf.br_datamart_filter_id
    AND bd.filter_mean IN ("PP_EXC_FILT_DUP_PLANS", "PP_EXC_FILT_DRUGDRUG_PLANS",
   "PP_EXC_FILT_ALLERGY_PLANS", "PP_FILT_DUP_PLANS", "PP_FILT_DRUGDRUG_PLANS",
   "PP_FILT_ALLERGY_PLANS"))
   JOIN (bdv
   WHERE (bdv.br_datamart_category_id= Outerjoin(bd.br_datamart_category_id))
    AND (bdv.br_datamart_filter_id= Outerjoin(bd.br_datamart_filter_id))
    AND (bdv.end_effective_dt_tm> Outerjoin(sysdate)) )
   JOIN (pc
   WHERE pc.pathway_catalog_id=bdv.parent_entity_id
    AND pc.active_ind=0)
   JOIN (p
   WHERE p.person_id=pc.updt_id)
   JOIN (p2
   WHERE p2.person_id=bdv.updt_id)
  ORDER BY bd.filter_display, pc.description
  WITH format(date,"DD-MMM-YYYY HH:MM"), format, separator = " ",
   nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  SET ms_filename_out = concat("exclusive_powerplans_",format(curdate,"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out,ms_address_list,"Exclusive Powerplans",1)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
