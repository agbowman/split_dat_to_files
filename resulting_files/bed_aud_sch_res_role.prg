CREATE PROGRAM bed_aud_sch_res_role
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
   FROM sch_role s
   PLAN (s
    WHERE s.active_ind=1
     AND pf.codeset > 0
     AND pf.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pf.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (cv
    WHERE cv.code_set=pf.code_set)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 2500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1750)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Resource Role"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Resource Role Meaning"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Resource Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET count = 0
 SELECT DISTINCT INTO "NL:"
  FROM sch_role s,
   sch_res_role sr,
   sch_resource sre
  PLAN (s
   WHERE s.active_ind=1)
   JOIN (sr
   WHERE s.sch_role_cd=sr.sch_role_cd
    AND sr.active_ind=1)
   JOIN (sre
   WHERE sr.resource_cd=sre.resource_cd
    AND sre.active_ind=1)
  ORDER BY s.mnemonic, sre.mnemonic
  DETAIL
   count = (count+ 1), stat = alterlist(reply->rowlist,count), stat = alterlist(reply->rowlist[count]
    .celllist,3),
   reply->rowlist[count].celllist[1].string_value = s.mnemonic, reply->rowlist[count].celllist[2].
   string_value = sr.role_meaning, reply->rowlist[count].celllist[3].string_value = sre.mnemonic
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_resource_roles.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
