CREATE PROGRAM cp_test_micro:dba
 PAINT
 SET width = 132
 SET modify = system
 CALL clear(1,1)
 CALL box(2,1,10,127)
 CALL text(1,25,"CP_TEST_MICRO2")
 CALL text(3,2,"Quick (Q) / Detailed (D) >> ")
 CALL accept(3,30,"P(1);C","Q"
  WHERE curaccept IN ("Q", "q", "D", "d"))
 SET run_type = fillstring(1," ")
 SET run_type = cnvtupper(curaccept)
 CALL text(4,2,"  Enter CHART_REQUEST_ID >> ")
 SET cr_id = 0.0
 CALL accept(4,30,"P(12);C"," ")
 SET help = off
 SET cr_id = cnvtreal(curaccept)
 SET chart_format_id = 0.0
 FREE RECORD request
 RECORD request(
   1 scope_flag = i4
   1 pending_flag = i2
   1 person_id = f8
   1 encntr_id = f8
   1 order_id = f8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 request_type = i2
   1 accession_nbr = c20
   1 chart_format_id = f8
   1 date_range_ind = i2
   1 mcis_ind = i2
   1 code_list[*]
     2 code = f8
     2 procedure_type_flag = i2
   1 option_list[*]
     2 option_flag = i4
     2 option_value = vc
   1 encntr_list[*]
     2 encntr_id = f8
   1 chart_request_id = f8
   1 result_lookup_ind = i2
 )
 SET request->chart_request_id = cr_id
 CALL echo(build("CR_ID:  ",request->chart_request_id))
 SELECT INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr
  WHERE cr.chart_request_id=cr_id
  HEAD REPORT
   do_nothing = 0
  DETAIL
   request->chart_format_id = cr.chart_format_id, request->encntr_id = cr.encntr_id, request->
   person_id = cr.person_id,
   request->order_id = cr.order_id, request->scope_flag = cr.scope_flag, request->pending_flag = cr
   .chart_pending_flag,
   request->start_dt_tm = cr.begin_dt_tm, request->end_dt_tm = cr.end_dt_tm, request->accession_nbr
    = cr.accession_nbr,
   request->request_type = cr.request_type, request->date_range_ind = cr.date_range_ind, request->
   mcis_ind = cr.mcis_ind,
   request->result_lookup_ind = cr.result_lookup_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(12,12,"* * * ERROR!  INVALID CHART_REQUEST_ID, EXITING * * *")
  GO TO exit_script
 ENDIF
 SET script_number = 0
 IF (run_type="D")
  CALL text(6,2,"  Select CHART_SECTION   >> ")
  SET help =
  SELECT DISTINCT INTO "nl:"
   cs.chart_section_desc
   FROM chart_form_sects cfs,
    chart_section cs
   PLAN (cfs
    WHERE (cfs.chart_format_id=request->chart_format_id)
     AND cfs.active_ind=1)
    JOIN (cs
    WHERE cs.chart_section_id=cfs.chart_section_id
     AND cs.section_type_flag IN (10, 26))
   ORDER BY cs.chart_section_desc
   WITH nocounter
  ;end select
  SET chart_section_desc = fillstring(100," ")
  CALL accept(6,30,"P(64);C"," Shift/F5 for Help ")
  SET help = off
  SET chart_section_desc = trim(curaccept)
  SET chart_section_id = 0.0
  IF (size(chart_section_desc)=0)
   CALL text(12,12,"* * * ERROR!  INVALID CHART_SECTION, EXITING * * *")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   cs.chart_section_id
   FROM chart_section cs,
    chart_form_sects cfs
   PLAN (cs
    WHERE cs.chart_section_desc=trim(chart_section_desc))
    JOIN (cfs
    WHERE cfs.chart_section_id=cs.chart_section_id
     AND (cfs.chart_format_id=request->chart_format_id))
   HEAD REPORT
    do_nothing = 0
   DETAIL
    chart_section_id = cs.chart_section_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL text(12,12,"* * * ERROR!  INVALID CHART_SECTION, EXITING * * *")
   GO TO exit_script
  ENDIF
 ELSEIF (run_type="Q")
  CALL text(6,2,"Enter Script #:")
  CALL text(8,2,
   "0 = cp_micro_chart, 1 = cp_dyn_micro_chart, 2 = cp_iso_micro_chart, 9 = cp_micro_chart_custom")
  CALL accept(6,20,"P(1);C","1"
   WHERE curaccept IN ("0", "1", "2", "9"))
  SET script_number = cnvtint(curaccept)
 ENDIF
 IF ((request->scope_flag=1))
  SELECT DISTINCT INTO "nl:"
   v500.event_set_cd
   FROM clinical_event ce,
    v500_event_set_explode v500
   PLAN (ce
    WHERE (ce.person_id=request->person_id))
    JOIN (v500
    WHERE v500.event_cd=ce.event_cd)
   ORDER BY v500.event_set_cd
   HEAD REPORT
    cd_cnt = 0
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = v500.event_set_cd,
    request->code_list[cd_cnt].procedure_type_flag = 0
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=2))
  SELECT DISTINCT INTO "nl:"
   v500.event_set_cd
   FROM clinical_event ce,
    v500_event_set_explode v500
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.encntr_id+ 0)=request->encntr_id))
    JOIN (v500
    WHERE v500.event_cd=ce.event_cd)
   ORDER BY v500.event_set_cd
   HEAD REPORT
    cd_cnt = 0
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = v500.event_set_cd,
    request->code_list[cd_cnt].procedure_type_flag = 0
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=4))
  SELECT DISTINCT INTO "nl:"
   v500.event_set_cd
   FROM clinical_event ce,
    v500_event_set_explode v500
   PLAN (ce
    WHERE ce.accession_nbr=trim(request->accession_nbr))
    JOIN (v500
    WHERE v500.event_cd=ce.event_cd)
   ORDER BY v500.event_set_cd
   HEAD REPORT
    cd_cnt = 0
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = v500.event_set_cd,
    request->code_list[cd_cnt].procedure_type_flag = 0
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=5))
  SELECT DISTINCT INTO "nl:"
   v500.event_set_cd
   FROM clinical_event ce,
    v500_event_set_explode v500
   PLAN (ce
    WHERE (ce.person_id=request->person_id)
     AND ((ce.encntr_id+ 0) IN (
    (SELECT
     encntr_id
     FROM chart_request_encntr
     WHERE (chart_request_id=request->chart_request_id)))))
    JOIN (v500
    WHERE v500.event_cd=ce.event_cd)
   ORDER BY v500.event_set_cd
   HEAD REPORT
    cd_cnt = 0
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = v500.event_set_cd,
    request->code_list[cd_cnt].procedure_type_flag = 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->scope_flag=1))
  SELECT DISTINCT INTO "nl:"
   ce.catalog_cd
   FROM clinical_event ce
   WHERE (ce.person_id=request->person_id)
   ORDER BY ce.catalog_cd
   HEAD REPORT
    cd_cnt = size(request->code_list,5)
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = ce.catalog_cd,
    request->code_list[cd_cnt].procedure_type_flag = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=2))
  SELECT DISTINCT INTO "nl:"
   ce.catalog_cd
   FROM clinical_event ce
   WHERE (ce.person_id=request->person_id)
    AND ((ce.encntr_id+ 0)=request->encntr_id)
   ORDER BY ce.catalog_cd
   HEAD REPORT
    cd_cnt = size(request->code_list,5)
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = ce.catalog_cd,
    request->code_list[cd_cnt].procedure_type_flag = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=4))
  SELECT DISTINCT INTO "nl:"
   ce.catalog_cd
   FROM clinical_event ce
   WHERE ce.accession_nbr=trim(request->accession_nbr)
   ORDER BY ce.catalog_cd
   HEAD REPORT
    cd_cnt = size(request->code_list,5)
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = ce.catalog_cd,
    request->code_list[cd_cnt].procedure_type_flag = 1
   WITH nocounter
  ;end select
 ELSEIF ((request->scope_flag=5))
  SELECT DISTINCT INTO "nl:"
   ce.catalog_cd
   FROM clinical_event ce
   WHERE (ce.person_id=request->person_id)
    AND ((ce.encntr_id+ 0) IN (
   (SELECT
    encntr_id
    FROM chart_request_encntr
    WHERE (chart_request_id=request->chart_request_id))))
   ORDER BY ce.catalog_cd
   HEAD REPORT
    cd_cnt = size(request->code_list,5)
   DETAIL
    cd_cnt = (cd_cnt+ 1), stat = alterlist(request->code_list,cd_cnt), request->code_list[cd_cnt].
    code = ce.catalog_cd,
    request->code_list[cd_cnt].procedure_type_flag = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (run_type="D")
  SET chart_group_id = 0.0
  SELECT DISTINCT INTO "nl:"
   cg.chart_group_id
   FROM chart_group cg
   WHERE cg.chart_section_id=chart_section_id
   HEAD REPORT
    chart_group_id = cg.chart_group_id
   WITH nocounter
  ;end select
  IF (chart_group_id=0)
   CALL text(12,12,"* * * ERROR!  INVALID CHART_GROUP, EXITING * * *")
   GO TO exit_script
  ENDIF
  IF (((chart_group_id=0) OR (chart_section_id=0)) )
   CALL text(12,12,"* * * ERROR!  INVALID CHART_GROUP OR CHART_SECTION, EXITING * * *")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   cmf.*
   FROM chart_micro_format cmf
   WHERE cmf.chart_group_id=chart_group_id
   HEAD REPORT
    option_cnt = 0
   DETAIL
    option_cnt = (option_cnt+ 1), stat = alterlist(request->option_list,option_cnt), request->
    option_list[option_cnt].option_flag = cmf.option_flag,
    request->option_list[option_cnt].option_value = cmf.option_value
   WITH nocounter
  ;end select
  SET size_opts = 0
  SET size_opts = size(request->option_list,5)
  SET x = 0
  SET iso_script = 0
 ENDIF
 SET message = nowindow
 CALL echorecord(request)
 CALL echo(build("SCRIPT_NUMBER = ",script_number))
 IF (run_type="D")
  CALL echo(build("* * * * EXECUTING CP_CONTROL_MICRO * * * *"))
  EXECUTE cp_control_micro
  CALL echo("* * * * FINISHED * * * *")
 ELSEIF (run_type="Q")
  IF (script_number=0)
   CALL echo(build("* * * * EXECUTING CP_MICRO_CHART * * * *"))
   EXECUTE cp_micro_chart
   CALL echo("* * * * FINISHED * * * *")
  ELSEIF (script_number=1)
   CALL echo(build("* * * * EXECUTING CP_CONTROL_MICRO * * * *"))
   EXECUTE cp_control_micro
   CALL echo("* * * * FINISHED * * * *")
  ELSEIF (script_number=2)
   CALL echo(build("* * * * EXECUTING CP_ISO_MICRO_CHART * * * *"))
   EXECUTE cp_iso_micro_chart
   CALL echo("* * * * FINISHED * * * *")
  ELSEIF (script_number=9)
   CALL echo(build("* * * * EXECUTING CP_MICRO_CHART_CUSTOM * * * *"))
   EXECUTE cp_micro_chart_custom
   CALL echo("* * * * FINISHED * * * *")
  ENDIF
 ENDIF
#exit_script
END GO
