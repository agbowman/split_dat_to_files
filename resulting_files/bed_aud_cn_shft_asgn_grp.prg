CREATE PROGRAM bed_aud_cn_shft_asgn_grp
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    prsnl_group pg,
    prsnl_group_reltn pgr
   PLAN (cv
    WHERE cv.code_set=357
     AND cv.cdf_meaning="ASGMTGRP"
     AND cv.active_ind=1)
    JOIN (pg
    WHERE pg.prsnl_group_type_cd=cv.code_value
     AND pg.active_ind=1)
    JOIN (pgr
    WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Shift Assignment Group Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Personnel"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SELECT INTO "nl:"
  pg.prsnl_group_name, p.name_full_formatted
  FROM code_value cv,
   prsnl_group_reltn pgr,
   prsnl p,
   prsnl_group pg
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="ASGMTGRP"
    AND cv.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id)
   JOIN (p
   WHERE pgr.person_id=p.person_id)
  GROUP BY pg.prsnl_group_name, p.name_full_formatted
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,2), reply->rowlist[cnt].celllist[1].string_value =
   pg.prsnl_group_name, reply->rowlist[cnt].celllist[2].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("carenet_shift_assign_grps.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
