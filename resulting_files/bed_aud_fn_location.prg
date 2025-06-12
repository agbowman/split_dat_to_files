CREATE PROGRAM bed_aud_fn_location
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
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Facility Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Building"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Ambulatory Unit"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Room"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Bed"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Last Update By"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET request->skip_volume_check_ind = 1
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM br_name_value bnv
   PLAN (bnv
    WHERE bnv.br_nv_key1="EDUNIT")
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 150)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 100)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  lg2.parent_loc_cd, lg.parent_loc_cd, lg.child_loc_cd,
  lg3.child_loc_cd, lg4.child_loc_cd
  FROM br_name_value bnv,
   location_group lg,
   location_group lg2,
   code_value cv,
   location_group lg3,
   prsnl p,
   location_group lg4,
   dummyt d
  PLAN (bnv
   WHERE bnv.br_nv_key1="EDUNIT")
   JOIN (lg
   WHERE lg.child_loc_cd=cnvtreal(bnv.br_value)
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.active_ind=1
    AND lg2.root_loc_cd=0)
   JOIN (cv
   WHERE cv.code_value=lg2.parent_loc_cd)
   JOIN (lg3
   WHERE lg3.parent_loc_cd=cnvtreal(bnv.br_value)
    AND lg3.active_ind=1
    AND lg3.root_loc_cd=0)
   JOIN (p
   WHERE p.person_id=lg3.updt_id)
   JOIN (d)
   JOIN (lg4
   WHERE lg4.parent_loc_cd=lg3.child_loc_cd
    AND lg4.active_ind=1
    AND lg4.root_loc_cd=0)
  ORDER BY cv.display_key, lg2.sequence, lg.sequence,
   lg3.sequence, lg4.sequence
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,6), reply->rowlist[cnt].celllist[1].double_value =
   lg2.parent_loc_cd, reply->rowlist[cnt].celllist[2].double_value = lg.parent_loc_cd,
   reply->rowlist[cnt].celllist[3].double_value = lg.child_loc_cd, reply->rowlist[cnt].celllist[4].
   double_value = lg3.child_loc_cd, reply->rowlist[cnt].celllist[5].double_value = lg4.child_loc_cd,
   reply->rowlist[cnt].celllist[6].string_value = p.name_full_formatted
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH noheading, nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(reply->rowlist,5))),
   (dummyt d2  WITH seq = 5),
   code_value cv
  PLAN (d)
   JOIN (d2)
   JOIN (cv
   WHERE (cv.code_value=reply->rowlist[d.seq].celllist[d2.seq].double_value))
  DETAIL
   IF (d2.seq=4)
    reply->rowlist[d.seq].celllist[d2.seq].string_value = cv.description
   ELSE
    reply->rowlist[d.seq].celllist[d2.seq].string_value = cv.display
   ENDIF
  WITH noheading, nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_locations.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
