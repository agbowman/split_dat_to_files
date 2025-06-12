CREATE PROGRAM bed_aud_bb_displays:dba
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
 RECORD cs1640(
   1 qual[*]
     2 cd = f8
     2 display = vc
 )
 RECORD cs1643(
   1 qual[*]
     2 cd = f8
     2 display = vc
     2 match_ind = i2
 )
 RECORD temp(
   1 qual[*]
     2 1640_disp = vc
     2 1643_disp = vc
 )
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Code Set 1640 Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Code Set 1643 Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET 1640_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1640)
  ORDER BY cv.display
  DETAIL
   1640_cnt = (1640_cnt+ 1), stat = alterlist(cs1640->qual,1640_cnt), cs1640->qual[1640_cnt].cd = cv
   .code_value,
   cs1640->qual[1640_cnt].display = cv.display
  WITH nocounter
 ;end select
 SET 1643_cnt = 0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1643)
  ORDER BY cv.display
  DETAIL
   1643_cnt = (1643_cnt+ 1), stat = alterlist(cs1643->qual,1643_cnt), cs1643->qual[1643_cnt].cd = cv
   .code_value,
   cs1643->qual[1643_cnt].display = cv.display
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (x = 1 TO 1640_cnt)
   SET rcnt = (rcnt+ 1)
   SET stat = alterlist(temp->qual,rcnt)
   SET temp->qual[rcnt].1640_disp = cs1640->qual[x].display
   FOR (y = 1 TO 1643_cnt)
     IF ((cs1643->qual[y].match_ind=0))
      IF ((cs1640->qual[x].display=cs1643->qual[y].display))
       SET temp->qual[rcnt].1643_disp = cs1643->qual[y].display
       SET cs1643->qual[y].match_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (y = 1 TO 1643_cnt)
   IF ((cs1643->qual[y].match_ind=0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(temp->qual,rcnt)
    SET temp->qual[rcnt].1643_disp = cs1643->qual[y].display
   ENDIF
 ENDFOR
 SET qcnt = 0
 FOR (x = 1 TO rcnt)
   IF ((((temp->qual[x].1640_disp=" ")) OR ((temp->qual[x].1643_disp=" "))) )
    SET qcnt = (qcnt+ 1)
    SET stat = alterlist(reply->rowlist,qcnt)
    SET stat = alterlist(reply->rowlist[qcnt].celllist,2)
    SET reply->rowlist[qcnt].celllist[1].string_value = temp->qual[x].1640_disp
    SET reply->rowlist[qcnt].celllist[2].string_value = temp->qual[x].1643_disp
   ENDIF
 ENDFOR
 IF (qcnt > 0)
  SET reply->run_status_flag = 3
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "BBDISPISSUES"
  SET reply->statlist[1].total_items = rcnt
  SET reply->statlist[1].qualifying_items = qcnt
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
  SET stat = alterlist(reply->statlist,1)
  SET reply->statlist[1].statistic_meaning = "BBDISPISSUES"
  SET reply->statlist[1].total_items = rcnt
  SET reply->statlist[1].qualifying_items = 0
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->status_data.status = "S"
END GO
