CREATE PROGRAM bhs_rpt_get_by_date_catalog_cd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Order Date" = "SYSDATE",
  "End Order Date" = "SYSDATE",
  "Search for Order" = "*",
  "Select Order" = 0,
  "Enter Emails:" = ""
  WITH outdev, start_date, end_date,
  s_orders, order_cat_cd, email_list
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_subject_line = vc WITH protect, noconstant("Palliative Care Monthly Consult Report")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 IF (((cnvtupper(ms_outdev)="OPS") OR (validate(request->batch_selection))) )
  SET ml_ops_ind = 1
  SET ms_outdev = trim(concat(trim("monthly_palliative_care_report"),"_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ENDIF
 IF (ml_ops_ind=1)
  IF ( NOT (validate(reply,0)))
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
  ENDIF
  IF (findstring("@", $EMAIL_LIST) > 0)
   SET ms_address_list =  $EMAIL_LIST
  ELSE
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Script Terminated Early"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "NEED TO SPECIFY EMAIL ADDRESS/ES"
   SET reply->status_data.subeventstatus[1].targetobjectname = ""
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT
  IF (ml_ops_ind=1)
   WITH nocounter, format, format = pcformat
  ELSE
   WITH nocounter, format, separator = " ",
    format(date,";;q")
  ENDIF
  DISTINCT INTO value(ms_outdev)
  domain = curdomain, powerplan =
  IF (o.pathway_catalog_id > 0) "Ordered from PowerPlan"
  ELSE "No Powerplan"
  ENDIF
  , powerplan_name = substring(1,100,pc.description),
  pathway_catalog_id = o.pathway_catalog_id, order_date_time = format(o.orig_order_dt_tm,
   "mm/dd/yyyy hh:mm;;D"), order_id = o.order_id,
  fin = ea.alias, facility = substring(1,25,uar_get_code_display(e.loc_facility_cd)), location =
  substring(1,25,uar_get_code_display(e.location_cd)),
  status = substring(1,25,uar_get_code_display(o.order_status_cd)), catalog_cd = o.catalog_cd,
  order_name = substring(1,100,uar_get_code_display(o.catalog_cd)),
  ordered_as_mnemonic = substring(1,150,o.ordered_as_mnemonic), clinical_display_line = substring(1,
   200,o.clinical_display_line), patient = substring(1,150,p.name_full_formatted),
  birth_date = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yy;;d"),
  order_entered_in_app = substring(1,150,app.description), order_entered_by = substring(1,150,p1
   .name_full_formatted),
  order_entered_by_position = substring(1,150,uar_get_code_display(p1.position_cd)),
  order_entered_by_username = substring(1,150,p1.username), ordering_doc = substring(1,150,p2
   .name_full_formatted),
  ordering_doc_position = substring(1,150,uar_get_code_display(p2.position_cd)),
  ordering_doc_username = substring(1,150,p2.username)
  FROM orders o,
   order_action oa,
   prsnl p1,
   prsnl p2,
   person p,
   application app,
   encntr_alias ea,
   encounter e,
   pathway_catalog pc
  PLAN (o
   WHERE (o.catalog_cd= $ORDER_CAT_CD)
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime( $START_DATE) AND cnvtdatetime( $END_DATE)
    AND o.template_order_id=0)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (p1
   WHERE p1.person_id=oa.action_personnel_id)
   JOIN (p2
   WHERE p2.person_id=oa.order_provider_id)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (app
   WHERE app.application_number=oa.order_app_nbr)
   JOIN (ea
   WHERE ea.encntr_id=o.originating_encntr_id
    AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (pc
   WHERE (pc.pathway_catalog_id= Outerjoin(o.pathway_catalog_id)) )
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
 ;end select
 IF (ml_ops_ind=1)
  IF (curqual > 0)
   SET ms_filename_in = trim(ms_outdev,3)
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_filename_in,ms_filename_in,ms_address_list,ms_subject_line,1)
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
 ENDIF
#exit_script
END GO
