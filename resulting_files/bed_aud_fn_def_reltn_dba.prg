CREATE PROGRAM bed_aud_fn_def_reltn:dba
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
 FREE RECORD temp
 RECORD temp(
   1 fcnt = i2
   1 fqual[*]
     2 facility = vc
     2 cnt = i2
     2 qual[*]
       3 catalog_type = vc
       3 activity_type = vc
       3 desc = vc
       3 mnemonic = vc
       3 match = vc
       3 add = vc
       3 oc_desc = vc
       3 oc_cd = f8
       3 synonym = vc
       3 remove = vc
       3 match_ind = i2
       3 match_cd = f8
       3 concept_cki = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM track_reference tr
   PLAN (tr
    WHERE tr.active_ind=1)
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
 SET reply->collist[1].header_text = "Tracking Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Provider Role"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Default Relationship"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Last Update By"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM track_reference tr,
   code_value cv1,
   code_value cv2,
   track_prefs tp,
   code_value cv3,
   track_comp_prefs tcp,
   code_value cv4,
   person p
  PLAN (tr
   WHERE tr.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=tr.tracking_group_cd)
   JOIN (cv2
   WHERE cv2.code_value=tr.tracking_ref_type_cd
    AND cv2.cdf_meaning="PRVRELN")
   JOIN (tp
   WHERE tp.comp_name_unq=concat(trim(cnvtstring(tr.tracking_group_cd),3),";",trim(cnvtstring(tr
      .tracking_ref_id),3)))
   JOIN (cv3
   WHERE cv3.code_value=tp.comp_type_cd
    AND cv3.cdf_meaning="DEFRELNROLE")
   JOIN (tcp
   WHERE tcp.track_pref_id=tp.track_pref_id)
   JOIN (cv4
   WHERE cv4.code_value=cnvtreal(tcp.sub_comp_pref))
   JOIN (p
   WHERE p.person_id=outerjoin(tcp.updt_id))
  ORDER BY cv1.display_key, tr.display_key, cv4.display_key
  HEAD REPORT
   xcnt = 0
  HEAD cv4.display_key
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,4),
   reply->rowlist[row_nbr].celllist[1].string_value = cv1.display, reply->rowlist[row_nbr].celllist[2
   ].string_value = tr.display, reply->rowlist[row_nbr].celllist[3].string_value = cv4.display,
   reply->rowlist[row_nbr].celllist[4].string_value = p.name_full_formatted
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("firstnet_def_reltn_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
