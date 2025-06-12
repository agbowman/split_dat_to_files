CREATE PROGRAM bed_aud_rad_relevant_priors
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv,
    rad_procedure_group r,
    rad_procedure_assoc rp
   PLAN (cv
    WHERE cv.code_set=321570
     AND cv.cdf_meaning="PRIORGRPS")
    JOIN (r
    WHERE r.group_type_cd=cv.code_value
     AND r.active_ind=1)
    JOIN (rp
    WHERE r.proc_group_id=rp.proc_group_id)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "procedure_group_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Relevant Prior Grouping"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Catalog_Cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Procedures in Relevant Prior Group"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SELECT INTO "NL:"
  rp.proc_group_id, r.group_desc, o.catalog_cd,
  o.primary_mnemonic
  FROM code_value cv,
   rad_procedure_group r,
   rad_procedure_assoc rp,
   order_catalog o
  PLAN (cv
   WHERE cv.code_set=321570
    AND cv.cdf_meaning="PRIORGRPS")
   JOIN (r
   WHERE r.group_type_cd=cv.code_value
    AND r.active_ind=1)
   JOIN (rp
   WHERE r.proc_group_id=rp.proc_group_id)
   JOIN (o
   WHERE o.catalog_cd=rp.catalog_cd
    AND o.active_ind=1)
  ORDER BY r.group_desc
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,100)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=0)
    stat = alterlist(reply->rowlist,(100+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,4), reply->rowlist[cnt].celllist[1].double_value = r
   .proc_group_id, reply->rowlist[cnt].celllist[2].string_value = r.group_desc,
   reply->rowlist[cnt].celllist[3].double_value = o.catalog_cd, reply->rowlist[cnt].celllist[4].
   string_value = o.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_relevant_prior.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
