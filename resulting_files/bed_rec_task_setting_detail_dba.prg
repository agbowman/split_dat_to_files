CREATE PROGRAM bed_rec_task_setting_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_fail
 RECORD temp_fail(
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 SET col_cnt = 6
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Check Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Task Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Overdue Time"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Retention Time"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Recommended Setting"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Resolution"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE short_desc = vc
 DECLARE resolution_txt = vc
 DECLARE od_time = vc
 DECLARE rt_time = vc
 SET plsize = size(request->paramlist,5)
 FOR (x = 1 TO plsize)
  IF ((request->paramlist[x].meaning="MEDADMINOVERTIME"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="MEDADMINOVERTIME")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_task ot
    PLAN (ot
     WHERE ((ot.overdue_units=1
      AND ot.overdue_min > 60) OR (((ot.overdue_units=2
      AND ot.overdue_min > 1) OR (ot.overdue_min=0)) ))
      AND ot.active_ind=1
      AND ot.cernertask_flag=0)
    ORDER BY ot.task_description, ot.overdue_units
    DETAIL
     od_time = cnvtstring(ot.overdue_min)
     IF (ot.overdue_units=1)
      od_time = concat(od_time," Minute")
     ELSEIF (ot.overdue_units=2)
      od_time = concat(od_time," Hour")
     ENDIF
     IF (ot.overdue_min > 1)
      od_time = concat(od_time,"s")
     ENDIF
     stat = add_rep(short_desc,ot.task_description,od_time,"","1 hour or less",
      resolution_txt)
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->paramlist[x].meaning="MEDADMINRETTIMES"))
   SET short_desc = ""
   SET resolution_txt = ""
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE b.rec_mean="MEDADMINRETTIMES")
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     short_desc = trim(b.short_desc), resolution_txt = trim(bl2.long_text)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM order_task ot,
     code_value cv
    PLAN (cv
     WHERE cv.code_set=6026
      AND cv.cdf_meaning IN ("IV", "MED")
      AND cv.active_ind=1)
     JOIN (ot
     WHERE ot.task_type_cd=cv.code_value
      AND ((ot.retain_time > 0) OR (ot.retain_units > 0))
      AND ot.active_ind=1)
    ORDER BY ot.task_description, ot.overdue_units
    DETAIL
     rt_time = cnvtstring(ot.retain_time)
     CASE (ot.retain_units)
      OF 1:
       rt_time = concat(rt_time," Minute")
      OF 2:
       rt_time = concat(rt_time," Hour")
      OF 3:
       rt_time = concat(rt_time," Day")
      OF 4:
       rt_time = concat(rt_time," Week")
      OF 5:
       rt_time = concat(rt_time," Month")
     ENDCASE
     IF (ot.retain_time > 1)
      rt_time = concat(rt_time,"s")
     ENDIF
     stat = add_rep(short_desc,ot.task_description,"",rt_time,"Not Set",
      resolution_txt)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET rep_size = size(temp_fail->rowlist,5)
 IF (rep_size > 0)
  SET stat = alterlist(reply->rowlist,rep_size)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rep_size))
   ORDER BY cnvtupper(temp_fail->rowlist[d.seq].celllist[2].string_value), cnvtupper(temp_fail->
     rowlist[d.seq].celllist[1].string_value)
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(reply->rowlist[ocnt].celllist,col_cnt), reply->rowlist[ocnt].
    celllist[1].string_value = temp_fail->rowlist[d.seq].celllist[1].string_value,
    reply->rowlist[ocnt].celllist[2].string_value = temp_fail->rowlist[d.seq].celllist[2].
    string_value, reply->rowlist[ocnt].celllist[3].string_value = temp_fail->rowlist[d.seq].celllist[
    3].string_value, reply->rowlist[ocnt].celllist[4].string_value = temp_fail->rowlist[d.seq].
    celllist[4].string_value,
    reply->rowlist[ocnt].celllist[5].string_value = temp_fail->rowlist[d.seq].celllist[5].
    string_value, reply->rowlist[ocnt].celllist[6].string_value = temp_fail->rowlist[d.seq].celllist[
    6].string_value
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE add_rep(p1,p2,p3,p4,p5,p6)
   SET row_tot_cnt = (size(temp_fail->rowlist,5)+ 1)
   SET stat = alterlist(temp_fail->rowlist,row_tot_cnt)
   SET stat = alterlist(temp_fail->rowlist[row_tot_cnt].celllist,col_cnt)
   SET temp_fail->rowlist[row_tot_cnt].celllist[1].string_value = p1
   SET temp_fail->rowlist[row_tot_cnt].celllist[2].string_value = p2
   SET temp_fail->rowlist[row_tot_cnt].celllist[3].string_value = p3
   SET temp_fail->rowlist[row_tot_cnt].celllist[4].string_value = p4
   SET temp_fail->rowlist[row_tot_cnt].celllist[5].string_value = p5
   SET temp_fail->rowlist[row_tot_cnt].celllist[6].string_value = p6
   RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
