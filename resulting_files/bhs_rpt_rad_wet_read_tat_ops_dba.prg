CREATE PROGRAM bhs_rpt_rad_wet_read_tat_ops:dba
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
 DECLARE mf_emergency_pattypeexam = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "EMERGENCY"))
 DECLARE mf_inpatient_pattypeexam = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENT"))
 DECLARE mf_bmcedct_sect = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",221,"BMCEDCT"))
 DECLARE md_beg_dt_tm = dq8 WITH protect
 DECLARE md_end_dt_tm = dq8 WITH protect
 DECLARE ms_start_date_ops = vc WITH protect, noconstant(" ")
 DECLARE ms_end_date_ops = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 SET md_beg_dt_tm = datetimefind(cnvtdatetime((curdate - 2),0),"W","B","B")
 SET md_end_dt_tm = datetimefind(cnvtdatetime((curdate - 2),0),"W","E","E")
 SET ms_start_date_ops = format(md_beg_dt_tm,"DD-MMM-YYYY;;D")
 SET ms_end_date_ops = format(md_end_dt_tm,"DD-MMM-YYYY;;D")
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="BHS_RPT_RAD_WET_READ_TAT"
    AND di.info_char="EMAIL")
  HEAD REPORT
   ms_address_list = " "
  DETAIL
   IF (ms_address_list=" ")
    ms_address_list = trim(di.info_name)
   ELSE
    ms_address_list = concat(ms_address_list," ",trim(di.info_name))
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE bhs_rpt_rad_wet_read_tat value(ms_address_list), value(ms_start_date_ops), value(
  ms_end_date_ops),
 value(mf_emergency_pattypeexam,mf_inpatient_pattypeexam), value(mf_bmcedct_sect), "CT"
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
