CREATE PROGRAM bed_aud_rad_procedure_group
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
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "procedure_group_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Procedure Group Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "catalog_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 SET reply->collist[4].header_text = "Procedures in Procedure Group"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=321570
     AND cv.cdf_meaning="PROCGRPS")
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
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  rpg.group_desc, oc.primary_mnemonic, cv.display
  FROM rad_procedure_group rpg,
   rad_procedure_assoc rpa,
   order_catalog oc,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=321570
    AND cv.cdf_meaning="PROCGRPS")
   JOIN (rpg
   WHERE rpg.proc_group_id > 0
    AND rpg.active_ind=1
    AND rpg.group_type_cd=cv.code_value)
   JOIN (rpa
   WHERE rpa.proc_group_id=rpg.proc_group_id)
   JOIN (oc
   WHERE oc.catalog_cd=rpa.catalog_cd
    AND oc.active_ind=1)
  ORDER BY rpg.group_desc, oc.primary_mnemonic
  HEAD REPORT
   cnt = 0, end_cnt = 0, stat = alterlist(reply->rowlist,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(10+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,4), reply->rowlist[cnt].celllist[1].double_value =
   rpg.proc_group_id, reply->rowlist[cnt].celllist[2].string_value = rpg.group_desc,
   reply->rowlist[cnt].celllist[3].double_value = oc.catalog_cd, reply->rowlist[cnt].celllist[4].
   string_value = oc.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radiology_procedure_groups.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
