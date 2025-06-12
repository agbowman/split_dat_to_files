CREATE PROGRAM bed_aud_ap_spec_protocols:dba
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
   1 specimens[*]
     2 code_value = f8
     2 display = vc
     2 active_ind = i2
     2 prefix = vc
     2 pathologist = vc
     2 protocol_id = f8
     2 tasks[*]
       3 code_value = f8
       3 mnemonic = vc
       3 block_seq = vc
       3 slide_seq = vc
       3 no_charge_ind = i2
 )
 DECLARE approcess = f8 WITH public, noconstant(0.0)
 DECLARE apbilling = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning="APPROCESS"
    AND cv.active_ind=1)
  DETAIL
   approcess = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning="APBILLING"
    AND cv.active_ind=1)
  DETAIL
   apbilling = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM code_value cv1,
    ap_specimen_protocol asp
   PLAN (cv1
    WHERE cv1.code_set=1306)
    JOIN (asp
    WHERE asp.specimen_cd=cv1.code_value)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET scnt = 0
 SELECT INTO "NL:"
  FROM code_value cv1,
   ap_specimen_protocol asp,
   ap_prefix ap,
   code_value c,
   person p
  PLAN (cv1
   WHERE cv1.code_set=1306)
   JOIN (asp
   WHERE asp.specimen_cd=cv1.code_value)
   JOIN (ap
   WHERE ap.prefix_id=outerjoin(asp.prefix_id)
    AND ap.active_ind=outerjoin(1))
   JOIN (c
   WHERE c.code_value=outerjoin(ap.site_cd)
    AND c.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(asp.pathologist_id)
    AND p.active_ind=outerjoin(1))
  ORDER BY cv1.display, ap.prefix_name, p.name_full_formatted
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(temp->specimens,scnt), temp->specimens[scnt].code_value = cv1
   .code_value,
   temp->specimens[scnt].display = cv1.display, temp->specimens[scnt].active_ind = cv1.active_ind,
   temp->specimens[scnt].prefix = ap.prefix_name
   IF (c.code_value > 0)
    temp->specimens[scnt].prefix = concat(trim(c.display)," ",trim(ap.prefix_name))
   ENDIF
   temp->specimens[scnt].pathologist = p.name_full_formatted, temp->specimens[scnt].protocol_id = asp
   .protocol_id
  WITH nocounter
 ;end select
 IF (scnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = scnt),
    ap_processing_grp_r apgr,
    discrete_task_assay dta,
    profile_task_r ptr,
    order_catalog oc
   PLAN (d)
    JOIN (apgr
    WHERE (apgr.parent_entity_id=temp->specimens[d.seq].protocol_id))
    JOIN (dta
    WHERE dta.task_assay_cd=apgr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (ptr
    WHERE ptr.task_assay_cd=apgr.task_assay_cd
     AND ptr.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ptr.catalog_cd
     AND oc.activity_subtype_cd IN (apbilling, approcess)
     AND oc.active_ind=1)
   ORDER BY d.seq, apgr.begin_section, apgr.begin_level,
    apgr.sequence
   HEAD d.seq
    tcnt = 0
   DETAIL
    tcnt = (tcnt+ 1), stat = alterlist(temp->specimens[d.seq].tasks,tcnt), temp->specimens[d.seq].
    tasks[tcnt].code_value = dta.task_assay_cd,
    temp->specimens[d.seq].tasks[tcnt].mnemonic = dta.mnemonic
    IF ((apgr.begin_section=- (1)))
     temp->specimens[d.seq].tasks[tcnt].block_seq = "Order Entry"
    ELSE
     temp->specimens[d.seq].tasks[tcnt].block_seq = cnvtstring(apgr.begin_section)
    ENDIF
    temp->specimens[d.seq].tasks[tcnt].slide_seq = cnvtstring(apgr.begin_level), temp->specimens[d
    .seq].tasks[tcnt].no_charge_ind = apgr.no_charge_ind
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Specimen Code"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Specimen Code Active"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Prefix"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Pathologist"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Task Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Block Sequence"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Slide Sequence"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "No Charge"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 IF (scnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (s = 1 TO scnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->specimens[s].display
   IF ((temp->specimens[s].active_ind=1))
    SET reply->rowlist[row_nbr].celllist[2].string_value = "active"
   ELSE
    SET reply->rowlist[row_nbr].celllist[2].string_value = "inactive"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->specimens[s].prefix
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->specimens[s].pathologist
   SET taskcnt = size(temp->specimens[s].tasks,5)
   IF (taskcnt > 0)
    FOR (t = 1 TO taskcnt)
      SET reply->rowlist[row_nbr].celllist[5].string_value = temp->specimens[s].tasks[t].mnemonic
      SET reply->rowlist[row_nbr].celllist[6].string_value = temp->specimens[s].tasks[t].block_seq
      SET reply->rowlist[row_nbr].celllist[7].string_value = temp->specimens[s].tasks[t].slide_seq
      IF ((temp->specimens[s].tasks[t].no_charge_ind=1))
       SET reply->rowlist[row_nbr].celllist[8].string_value = "Yes"
      ELSE
       SET reply->rowlist[row_nbr].celllist[8].string_value = "No"
      ENDIF
      IF (t < taskcnt)
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
       SET reply->rowlist[row_nbr].celllist[1].string_value = temp->specimens[s].display
       IF ((temp->specimens[s].active_ind=1))
        SET reply->rowlist[row_nbr].celllist[2].string_value = "active"
       ELSE
        SET reply->rowlist[row_nbr].celllist[2].string_value = "inactive"
       ENDIF
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->specimens[s].prefix
       SET reply->rowlist[row_nbr].celllist[4].string_value = temp->specimens[s].pathologist
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_specimen_protocols.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
