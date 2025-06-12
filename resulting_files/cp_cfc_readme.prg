CREATE PROGRAM cp_cfc_readme
 SET data_team_pid = request->setup_proc[1].process_id
 SET data_team_env = request->setup_proc[1].env_id
 FREE SET request
 RECORD request(
   1 chart_format_id = f8
 )
 FREE SET cfs
 RECORD cfs(
   1 qual[*]
     2 chart_format_id = f8
 )
 SET i = 0
 SET count = 0
 SELECT INTO "nl:"
  cf.chart_format_id
  FROM chart_format cf
  WHERE cf.active_ind=1
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alterlist(cfs->qual,(count+ 9))
   ENDIF
   cfs->qual[count].chart_format_id = cf.chart_format_id
  WITH nocounter
 ;end select
 IF (count > 0)
  SET stat = alterlist(cfs->qual,count)
  CALL echo(build("Number of chart formats:",count))
 ENDIF
 FOR (i = 1 TO count)
   FREE SET reply
   CALL echo(build("Populating for chart format:",cfs->qual[i].chart_format_id))
   SET request->chart_format_id = cfs->qual[i].chart_format_id
   SET trace = recpersist
   EXECUTE cp_populate_chart_format_codes
   CALL echo(build("Status:",reply->status_data.status))
   IF ((reply->status_data.status="S"))
    COMMIT
   ENDIF
   SET trace = norecpersist
 ENDFOR
 FREE SET request
 RECORD request(
   1 setup_proc[1]
     2 env_id = f8
     2 process_id = f8
     2 success_ind = i2
     2 error_msg = c200
 )
 CALL echo("Restoration")
 SET request->setup_proc[1].process_id = data_team_pid
 SET request->setup_proc[1].env_id = data_team_env
 FREE SET cfc_recs
 RECORD cfc_recs(
   1 qual[*]
     2 chart_format_id = f8
     2 num_cfc_rows = i4
 )
 SET failed = "F"
 SET cfc_count = 0
 SELECT INTO "nl:"
  cfc.chart_format_id
  FROM chart_format_codes cfc
  ORDER BY cfc.chart_format_id
  HEAD REPORT
   cfc_count = 0, cfc_rec_count = 0
  HEAD cfc.chart_format_id
   cfc_count += 1, cfc_rec_count = 0
   IF (mod(cfc_count,10)=1)
    stat = alterlist(cfc_recs->qual,(cfc_count+ 9))
   ENDIF
   cfc_recs->qual[cfc_count].chart_format_id = cfc.chart_format_id
  DETAIL
   cfc_rec_count += 1
  FOOT  cfc.chart_format_id
   cfc_recs->qual[cfc_count].num_cfc_rows = cfc_rec_count
  FOOT REPORT
   stat = alterlist(cfc_recs->qual,cfc_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cf.chart_format_id, ec.event_cd
  FROM chart_format cf,
   chart_form_sects cfs,
   chart_section cs,
   chart_group cg,
   chart_grp_evnt_set cges,
   v500_event_set_code esc,
   v500_event_set_explode ese,
   v500_event_code ec,
   chart_ap_format capf
  PLAN (cf
   WHERE cf.active_ind=1)
   JOIN (cfs
   WHERE cfs.chart_format_id=cf.chart_format_id)
   JOIN (cs
   WHERE cs.chart_section_id=cfs.chart_section_id)
   JOIN (cg
   WHERE cg.chart_section_id=cs.chart_section_id)
   JOIN (cges
   WHERE (cges.chart_group_id= Outerjoin(cg.chart_group_id)) )
   JOIN (esc
   WHERE (esc.event_set_name= Outerjoin(cges.event_set_name)) )
   JOIN (ese
   WHERE (ese.event_set_cd= Outerjoin(esc.event_set_cd)) )
   JOIN (ec
   WHERE (ec.event_cd= Outerjoin(ese.event_cd)) )
   JOIN (capf
   WHERE (capf.chart_group_id= Outerjoin(cg.chart_group_id)) )
  ORDER BY cf.chart_format_id
  HEAD REPORT
   cf_count = 0, num_expected_cfc_rows = 0
  HEAD cf.chart_format_id
   cf_count += 1, num_expected_cfc_rows = 0
  DETAIL
   num_expected_cfc_rows += 1
  FOOT  cf.chart_format_id
   IF (cf_count > cfc_count)
    failed = "T",
    CALL echo(build("ERROR! No chart_format_codes rows found for chart_format:",cf.chart_format_id))
   ELSE
    IF ((cf.chart_format_id=cfc_recs->qual[cf_count].chart_format_id)
     AND (num_expected_cfc_rows != cfc_recs->qual[cf_count].num_cfc_rows))
     failed = "T",
     CALL echo(build("Error - chart format:",cf.chart_format_id," Found # rows:",cfc_recs->qual[
      cf_count].num_cfc_rows," Expected #  rows:",
      num_expected_cfc_rows))
    ELSE
     CALL echo(build("Everything's OK for chart format:",cf.chart_format_id," Number of rows:",
      num_expected_cfc_rows))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (failed="F")
  CALL echo("Yes!")
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = ""
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo("Doh!")
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Mismatched number of rows in chart_format_codes table"
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
END GO
