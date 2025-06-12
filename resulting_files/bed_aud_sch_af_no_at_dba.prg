CREATE PROGRAM bed_aud_sch_af_no_at:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET scheduling_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  WHERE c.code_set=6000
   AND c.cdf_meaning="SCHEDULING"
  DETAIL
   scheduling_cd = c.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Accpept Format Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Missing Appointment Type Association"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET total_cnt = 0
 SELECT INTO "NL:"
  number = count(*)
  FROM order_entry_format oe
  PLAN (oe
   WHERE oe.catalog_type_cd=scheduling_cd)
  DETAIL
   total_cnt = number
  WITH nocounter
 ;end select
 SET count = 0
 SELECT INTO "NL:"
  FROM order_entry_format oe,
   code_value c
  PLAN (oe
   WHERE  NOT ( EXISTS (
   (SELECT
    sat.oe_format_id
    FROM sch_appt_type sat
    WHERE oe.oe_format_id=sat.oe_format_id)))
    AND oe.catalog_type_cd=scheduling_cd)
   JOIN (c
   WHERE c.code_value=oe.action_type_cd
    AND c.code_set=14232
    AND c.cdf_meaning IN ("APPOINTMENT", "CANCEL", "CHECKOUT", "COMPLETEREQ", "CONFIRM",
   "CONTACT", "HOLD", "LOCK", "MODIFY", "MODIFYREQ",
   "NOSHOW", "RESCHEDULE", "SHUFFLE", "UNLOCK", "VERIFY",
   "REQUEST"))
  DETAIL
   count = (count+ 1), stat = alterlist(reply->rowlist,count), stat = alterlist(reply->rowlist[count]
    .celllist,2),
   reply->rowlist[count].celllist[1].string_value = oe.oe_format_name, reply->rowlist[count].
   celllist[2].string_value = "X"
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "ACCEPTFNOAPPOINTMENTTYPE"
 SET reply->statlist[1].total_items = total_cnt
 SET reply->statlist[1].qualifying_items = count
 IF (count > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("accept_format_no_appointment_type.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
