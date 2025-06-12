CREATE PROGRAM bed_aud_rad_proxy_group
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
  )
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM proxy_group pg
   PLAN (pg)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "person_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Radiologist"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "proxy_id"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Proxy Radiologist"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted, p2.person_id,
  p2.name_full_formatted
  FROM code_value cv,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   dummyt d,
   proxy_group pgroup,
   prsnl p2
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning="RADIOLOGIST"
    AND cv.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.active_ind=1)
   JOIN (pgr
   WHERE pgr.prsnl_group_id=pg.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE p.person_id=pgr.person_id
    AND p.active_ind=1)
   JOIN (d)
   JOIN (pgroup
   WHERE pgroup.person_id=p.person_id)
   JOIN (p2
   WHERE p2.person_id=pgroup.proxy_id
    AND p2.active_ind=1)
  ORDER BY p.name_full_formatted, p2.name_full_formatted
  HEAD REPORT
   cnt = 0, end_cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,4), reply->rowlist[cnt].celllist[1].double_value = p
   .person_id, reply->rowlist[cnt].celllist[2].string_value = p.name_full_formatted,
   reply->rowlist[cnt].celllist[3].double_value = p2.person_id, reply->rowlist[cnt].celllist[4].
   string_value = p2.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheader, nocounter, outerjoin = d
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_proxy_group_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
