CREATE PROGRAM bed_aud_micro_alt_coll:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD rpt_request(
   1 skip_volume_check_ind = i2
   1 output_filename = vc
   1 catalog_type_cd = f8
   1 activity_type_cd = f8
 ) WITH protect
 SET rpt_request->skip_volume_check_ind = request->skip_volume_check_ind
 SET rpt_request->output_filename = request->output_filename
 SET rpt_request->catalog_type_cd = uar_get_code_by("MEANING",6000,"GENERAL LAB")
 SET rpt_request->activity_type_cd = uar_get_code_by("MEANING",106,"MICROBIOLOGY")
 EXECUTE bed_aud_alt_collections  WITH replace("REQUEST",rpt_request)
 IF ((reply->output_filename > " "))
  SET request->output_filename = build("bed_aud_micro_alt_coll.csv")
  CALL echo(build("request->output_filename set to: ",request->output_filename))
 ENDIF
END GO
