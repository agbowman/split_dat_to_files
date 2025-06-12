CREATE PROGRAM bhs_rpt_labcorp_aliasing:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Report Type" = 1
  WITH outdev, report_type
 DECLARE mf_cs73_labcorp_source = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,
   "LABCORPAMB"))
 DECLARE mf_cs6000_genlab_type = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,
   "GENERAL LAB"))
 DECLARE ml_report_type = i4 WITH protect, constant(cnvtreal( $REPORT_TYPE))
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_file_suffix = vc WITH protect, noconstant(" ")
 FREE RECORD lab_alias
 RECORD lab_alias(
   1 qual[*]
     2 s_domain = vc
     2 f_begin_dt_tm = dq8
     2 s_primary_name = vc
     2 f_catalog_cd = f8
     2 s_inbound_contributor = vc
     2 s_inbound_alias = vc
     2 s_outbound_contributor = vc
     2 s_outbound_alias = vc
     2 s_alias_validation = vc
 ) WITH protect
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
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  IF (ml_report_type=1)
   SET ms_file_suffix = "orders"
  ELSE
   SET ms_file_suffix = "results"
  ENDIF
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",ms_file_suffix,"-",format(
     cnvtdatetime(sysdate),"MMDDYYYYHHMMSS;;D"),
    ".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 IF (ml_report_type=1)
  SELECT INTO "nl:"
   curdomain, cv.begin_effective_dt_tm, oc.catalog_cd,
   order_name = uar_get_code_display(oc.catalog_cd), inbound = uar_get_code_display(cva
    .contributor_source_cd), cva.alias,
   outbound = uar_get_code_display(cvo.contributor_source_cd), cvo.alias
   FROM order_catalog oc,
    code_value cv,
    code_value_alias cva,
    code_value_outbound cvo
   PLAN (oc
    WHERE oc.catalog_type_cd=mf_cs6000_genlab_type)
    JOIN (cv
    WHERE cv.code_value=oc.catalog_cd)
    JOIN (cva
    WHERE (cva.code_value= Outerjoin(cv.code_value))
     AND (cva.contributor_source_cd= Outerjoin(mf_cs73_labcorp_source)) )
    JOIN (cvo
    WHERE (cvo.code_value= Outerjoin(cv.code_value)) )
   ORDER BY order_name, inbound
   HEAD REPORT
    ml_idx = 0
   DETAIL
    CALL echo(order_name), ml_idx += 1, stat = alterlist(lab_alias->qual,ml_idx),
    lab_alias->qual[ml_idx].s_domain = curdomain, lab_alias->qual[ml_idx].f_begin_dt_tm = cv
    .begin_effective_dt_tm, lab_alias->qual[ml_idx].s_primary_name = order_name,
    lab_alias->qual[ml_idx].f_catalog_cd = oc.catalog_cd, lab_alias->qual[ml_idx].
    s_inbound_contributor = inbound, lab_alias->qual[ml_idx].s_inbound_alias = cva.alias,
    lab_alias->qual[ml_idx].s_outbound_contributor = outbound, lab_alias->qual[ml_idx].
    s_outbound_alias = cvo.alias, lab_alias->qual[ml_idx].s_alias_validation =
    IF (textlen(trim(cva.alias,3))=6) "Valid Length"
    ELSE "Alias not standard length"
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   curdomain, cv.begin_effective_dt_tm, cv.display,
   inbound = uar_get_code_display(cva.contributor_source_cd), cva.alias, outbound =
   uar_get_code_display(cvo.contributor_source_cd),
   cvo.alias
   FROM code_value cv,
    code_value_alias cva,
    code_value_outbound cvo
   PLAN (cv
    WHERE cv.code_set=72)
    JOIN (cva
    WHERE (cva.code_value= Outerjoin(cv.code_value))
     AND (cva.contributor_source_cd= Outerjoin(mf_cs73_labcorp_source)) )
    JOIN (cvo
    WHERE (cvo.code_value= Outerjoin(cv.code_value)) )
   ORDER BY cv.display, inbound
   HEAD REPORT
    ml_idx = 0
   DETAIL
    ml_idx += 1, stat = alterlist(lab_alias->qual,ml_idx), lab_alias->qual[ml_idx].s_domain =
    curdomain,
    lab_alias->qual[ml_idx].f_begin_dt_tm = cv.begin_effective_dt_tm, lab_alias->qual[ml_idx].
    s_primary_name = cv.display, lab_alias->qual[ml_idx].s_inbound_contributor = inbound,
    lab_alias->qual[ml_idx].s_inbound_alias = cva.alias, lab_alias->qual[ml_idx].
    s_outbound_contributor = outbound, lab_alias->qual[ml_idx].s_outbound_alias = cvo.alias,
    lab_alias->qual[ml_idx].s_alias_validation =
    IF (textlen(trim(cva.alias,3))=6) "Valid Length"
    ELSE "Alias not standard length"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 IF (ml_report_type=1)
  SELECT
   IF (mn_email_ind=0)
    WITH format, separator = " "
   ELSE
    WITH pcformat('"',",",1), format = stream, format,
     skipreport = 1
   ENDIF
   INTO value(ms_output_dest)
   domain = trim(lab_alias->qual[d1.seq].s_domain,3), effective_date = format(lab_alias->qual[d1.seq]
    .f_begin_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"), catalog_cd = cnvtstring(lab_alias->qual[d1.seq].
    f_catalog_cd),
   name = trim(substring(1,100,lab_alias->qual[d1.seq].s_primary_name),3), inbound_source = trim(
    substring(1,100,lab_alias->qual[d1.seq].s_inbound_contributor),3), inbound_alias = trim(substring
    (1,100,lab_alias->qual[d1.seq].s_inbound_alias),3),
   outbound_source = trim(substring(1,100,lab_alias->qual[d1.seq].s_outbound_contributor),3),
   outbound_alias = trim(substring(1,100,lab_alias->qual[d1.seq].s_outbound_alias),3),
   alias_validation = trim(substring(1,100,lab_alias->qual[d1.seq].s_alias_validation),3)
   FROM (dummyt d1  WITH seq = size(lab_alias->qual,5))
   PLAN (d1
    WHERE d1.seq > 0)
  ;end select
 ELSE
  SELECT
   IF (mn_email_ind=0)
    WITH format, separator = " "
   ELSE
    WITH pcformat('"',",",1), format = stream, format,
     skipreport = 1
   ENDIF
   INTO value(ms_output_dest)
   domain = trim(lab_alias->qual[d1.seq].s_domain,3), effective_date = format(lab_alias->qual[d1.seq]
    .f_begin_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"), name = trim(substring(1,100,lab_alias->qual[d1.seq].
     s_primary_name),3),
   inbound_source = trim(substring(1,100,lab_alias->qual[d1.seq].s_inbound_contributor),3),
   inbound_alias = trim(substring(1,100,lab_alias->qual[d1.seq].s_inbound_alias),3), outbound_source
    = trim(substring(1,100,lab_alias->qual[d1.seq].s_outbound_contributor),3),
   outbound_alias = trim(substring(1,100,lab_alias->qual[d1.seq].s_outbound_alias),3),
   alias_validation = trim(substring(1,100,lab_alias->qual[d1.seq].s_alias_validation),3)
   FROM (dummyt d1  WITH seq = size(lab_alias->qual,5))
   PLAN (d1
    WHERE d1.seq > 0)
  ;end select
 ENDIF
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  SET ms_filename_out = concat("labcorp_aliasing_",ms_file_suffix,"_",format(curdate,"MMDDYYYY;;D"),
   ".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out,ms_address_list,"LabCorp Aliasing Report",1)
 ENDIF
 IF (validate(reply->status_data.status))
  SET reply->status_data.status = "S"
  SET reply->ops_event = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
 ENDIF
#exit_script
END GO
