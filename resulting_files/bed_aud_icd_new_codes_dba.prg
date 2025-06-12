CREATE PROGRAM bed_aud_icd_new_codes:dba
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
 SET reply->status_data.status = "F"
 SET tot_col = 3
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "Code"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Term"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Contributor System"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SET content_version_id = 0.0
 SELECT INTO "nl:"
  c.version_ft
  FROM cmt_content_version c
  WHERE c.source_vocabulary_cd=icd_code
  ORDER BY c.version_number DESC
  DETAIL
   content_version_id = c.cmt_content_version_id
  WITH maxqual(c,1)
 ;end select
 IF (content_version_id=0)
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM cmt_content_version c,
   nomenclature n,
   nomenclature n2,
   code_value cs
  PLAN (c
   WHERE c.cmt_content_version_id=content_version_id)
   JOIN (n
   WHERE n.source_vocabulary_cd=c.source_vocabulary_cd
    AND n.beg_effective_dt_tm=c.ver_beg_effective_dt_tm
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND n.primary_vterm_ind=1)
   JOIN (n2
   WHERE n2.source_identifier=outerjoin(n.source_identifier)
    AND n2.source_vocabulary_cd=outerjoin(n.source_vocabulary_cd)
    AND n2.primary_vterm_ind=outerjoin(n.primary_vterm_ind)
    AND n2.nomenclature_id != outerjoin(n.nomenclature_id))
   JOIN (cs
   WHERE cs.code_value=n.contributor_system_cd
    AND cs.active_ind=1)
  ORDER BY n.source_identifier
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->rowlist,100)
  HEAD n.source_identifier
   new_ind = 1
  DETAIL
   IF (n2.nomenclature_id > 0)
    new_ind = 0
   ENDIF
  FOOT  n.source_identifier
   IF (new_ind=1)
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->rowlist,(tcnt+ 100)), cnt = 1
    ENDIF
    stat = alterlist(reply->rowlist[tcnt].celllist,tot_col), reply->rowlist[tcnt].celllist[1].
    string_value = n.source_identifier, reply->rowlist[tcnt].celllist[2].string_value = n
    .source_string,
    reply->rowlist[tcnt].celllist[3].string_value = cs.display
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,tcnt)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (tcnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (tcnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("icd_vocabualry_codes.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
