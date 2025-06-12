CREATE PROGRAM bed_aud_sec_auth
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
 FREE RECORD positions
 RECORD positions(
   1 qual[*]
     2 position_cd = f8
     2 col_pos = i2
 )
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value c
   PLAN (c
    WHERE c.code_set=88
     AND c.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 200)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  position_cd = cv.code_value, cv.display
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD REPORT
   cnt = 1, stat = alterlist(reply->collist,10), stat = alterlist(positions->qual,10),
   reply->collist[1].header_text = "Application Group", reply->collist[1].data_type = 1, reply->
   collist[1].hide_ind = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(positions->qual,(10+ cnt)), stat = alterlist(reply->collist,(10+ cnt))
   ENDIF
   reply->collist[cnt].header_text = cv.display, reply->collist[cnt].data_type = 1
   IF (cnt > 20)
    reply->collist[cnt].hide_ind = 1
   ELSE
    reply->collist[cnt].hide_ind = 0
   ENDIF
   positions->qual[cnt].col_pos = cnt, positions->qual[cnt].position_cd = cv.code_value
  FOOT REPORT
   stat = alterlist(positions->qual,cnt), stat = alterlist(reply->collist,cnt)
  WITH noheading, nocounter
 ;end select
 CALL echo("Retrieving Application Groups")
 SET header_size = size(reply->collist,5)
 SELECT INTO "NL:"
  FROM code_value cv,
   dummyt d,
   application_group ag,
   (dummyt d2  WITH seq = value(size(positions->qual,5)))
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=500)
   JOIN (d)
   JOIN (ag
   WHERE ag.app_group_cd=cv.code_value)
   JOIN (d2
   WHERE (positions->qual[d2.seq].position_cd=ag.position_cd))
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  HEAD cv.code_value
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,header_size), reply->rowlist[cnt].celllist[1].
   string_value = cv.display
  DETAIL
   IF ((positions->qual[d2.seq].col_pos > 0))
    reply->rowlist[cnt].celllist[positions->qual[d2.seq].col_pos].string_value = "X"
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, outerjoin = d, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bedrock_security_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
