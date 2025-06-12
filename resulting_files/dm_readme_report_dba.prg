CREATE PROGRAM dm_readme_report:dba
 SET env_id =  $1
 SET mode =  $2
 RECORD list(
   1 qual[*]
     2 process_id = f8
     2 com_file_name = vc
     2 success_ind = i4
     2 owner_email = c6
     2 owner_team = c30
     2 description = vc
     2 run_time = i4
     2 start_dt_tm = dq8
     2 error_msg = vc
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT INTO "nl:"
  l.process_id, l.success_ind, l.start_dt_tm,
  e.com_file_name, p.owner_email, p.owner_team,
  p.description, l.error_msg, x = datetimediff(l.updt_dt_tm,l.start_dt_tm)
  FROM dm_pkt_setup_proc_log l,
   dm_pkt_setup_process p,
   dm_pkt_com_file_env e
  WHERE l.environment_id=env_id
   AND l.start_dt_tm IS NOT null
   AND l.process_id=p.process_id
   AND e.environment_id=l.environment_id
   AND e.process_id=l.process_id
   AND l.success_ind=0
   AND p.instance_nbr=e.instance_nbr
   AND l.updt_dt_tm != cnvtdatetime("31-DEC-2100")
  ORDER BY e.com_file_name, l.process_id
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->qual,list->count), list->qual[list->count].
   process_id = l.process_id,
   list->qual[list->count].com_file_name = e.com_file_name, list->qual[list->count].success_ind = l
   .success_ind, list->qual[list->count].owner_email = p.owner_email,
   list->qual[list->count].owner_team = p.owner_team, list->qual[list->count].description = p
   .description, list->qual[list->count].start_dt_tm = l.start_dt_tm,
   list->qual[list->count].error_msg = l.error_msg, list->qual[list->count].run_time = ((60 * 24) * x
   )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.com_file_name, l.process_id, l.start_dt_tm,
  p.owner_email, p.owner_team, p.description
  FROM dm_pkt_setup_proc_log l,
   dm_pkt_setup_process p,
   dm_pkt_com_file_env e
  WHERE l.environment_id=env_id
   AND l.start_dt_tm IS NOT null
   AND l.process_id=p.process_id
   AND e.environment_id=l.environment_id
   AND e.process_id=l.process_id
   AND l.updt_dt_tm=cnvtdatetime("31-DEC-2100")
   AND p.instance_nbr=e.instance_nbr
  ORDER BY l.start_dt_tm
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->qual,list->count), list->qual[list->count].
   process_id = l.process_id,
   list->qual[list->count].com_file_name = e.com_file_name, list->qual[list->count].success_ind = 2,
   list->qual[list->count].owner_email = p.owner_email,
   list->qual[list->count].owner_team = p.owner_team, list->qual[list->count].description = p
   .description, list->qual[list->count].start_dt_tm = l.start_dt_tm,
   list->qual[list->count].run_time = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.com_file_name, p.owner_email, p.owner_team,
  p.description
  FROM dm_pkt_setup_process p,
   dm_pkt_com_file_env e
  WHERE p.process_id=e.process_id
   AND p.instance_nbr=e.instance_nbr
   AND e.environment_id=env_id
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_pkt_setup_proc_log l
   WHERE l.environment_id=e.environment_id
    AND l.process_id=e.process_id)))
  ORDER BY p.process_id
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->qual,list->count), list->qual[list->count].
   process_id = p.process_id,
   list->qual[list->count].com_file_name = e.com_file_name, list->qual[list->count].success_ind = 3,
   list->qual[list->count].owner_email = p.owner_email,
   list->qual[list->count].owner_team = p.owner_team, list->qual[list->count].description = p
   .description, list->qual[list->count].start_dt_tm = 0,
   list->qual[list->count].run_time = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.com_file_name, l.start_dt_tm, l.process_id,
  l.success_ind, p.owner_email, p.owner_team,
  p.description, l.error_msg, x = datetimediff(l.updt_dt_tm,l.start_dt_tm)
  FROM dm_pkt_setup_proc_log l,
   dm_pkt_setup_process p,
   dm_pkt_com_file_env e
  WHERE l.environment_id=env_id
   AND l.start_dt_tm IS NOT null
   AND l.updt_dt_tm != cnvtdatetime("31-DEC-2100")
   AND l.process_id=p.process_id
   AND e.environment_id=l.environment_id
   AND e.process_id=l.process_id
   AND l.success_ind=1
   AND p.instance_nbr=e.instance_nbr
  ORDER BY x DESC
  DETAIL
   list->count = (list->count+ 1), stat = alterlist(list->qual,list->count), list->qual[list->count].
   process_id = l.process_id,
   list->qual[list->count].com_file_name = e.com_file_name, list->qual[list->count].success_ind = l
   .success_ind, list->qual[list->count].owner_email = p.owner_email,
   list->qual[list->count].owner_team = p.owner_team, list->qual[list->count].description = p
   .description, list->qual[list->count].start_dt_tm = l.start_dt_tm,
   list->qual[list->count].error_msg = l.error_msg, list->qual[list->count].run_time = ((60 * 24) * x
   )
  WITH nocounter
 ;end select
 IF (mode=1)
  SELECT
   *
   FROM (dummyt d  WITH seq = value(list->count))
   HEAD REPORT
    line = fillstring(324,"="), line2 = fillstring(324,"*"), col 0,
    line, row + 1, col 30,
    "README REPORT", row + 1, col 0,
    line, row + 1
   HEAD PAGE
    col 5, "Process", col 22,
    "Success", col 42, "Error",
    col 140, "Com File ", col 162,
    "Running", col 181, "Run",
    col 195, "Owner", col 215,
    "Owner", col 250, "Description",
    row + 1, col 7, "Id",
    col 23, "Ind", col 42,
    "Message", col 140, "Name",
    col 162, "Since", col 181,
    "Time (mins)", col 195, "Email",
    col 215, "Team", row + 1,
    col 0, line2, row + 1
   DETAIL
    b = list->qual[d.seq].process_id, col 0, b,
    col 15, list->qual[d.seq].success_ind, c = substring(1,100,list->qual[d.seq].error_msg),
    col 35, c, col 138,
    list->qual[d.seq].com_file_name, a = format(list->qual[d.seq].start_dt_tm,"MM/DD/YY HH:MM:SS;;d"),
    col 160,
    a, col 174, list->qual[d.seq].run_time,
    col 194, list->qual[d.seq].owner_email, col 214,
    list->qual[d.seq].owner_team, e = substring(1,65,list->qual[d.seq].description), col 249,
    e, row + 1
   WITH nocounter, maxcol = 325, formfeed = none
  ;end select
 ELSEIF (mode=2)
  SET ename = fillstring(20," ")
  SET dm_fname = fillstring(30," ")
  SELECT INTO "nl:"
   e.environment_name
   FROM dm_environment e
   WHERE e.environment_id=env_id
   DETAIL
    ename = e.environment_name
   WITH nocounter
  ;end select
  SET dm_fname = build("dm_readme_rpt_",ename,".csv")
  SELECT INTO value(dm_fname)
   FROM (dummyt d  WITH seq = value(list->count))
   HEAD REPORT
    col 5,
    "Process Id,Success Ind,Error Message,Com File Name,Running Since,Run Time (mins),Owner Email,Owner Team,Description"
   DETAIL
    a = list->qual[d.seq].process_id, b = list->qual[d.seq].success_ind, c = substring(1,100,list->
     qual[d.seq].error_msg),
    d = list->qual[d.seq].com_file_name, e = format(list->qual[d.seq].start_dt_tm,
     "MM/DD/YY HH:MM:SS;;d"), f = list->qual[d.seq].run_time,
    g = list->qual[d.seq].owner_email, h = list->qual[d.seq].owner_team, i = substring(1,65,list->
     qual[d.seq].description),
    row + 1, a, ",",
    b, ',"', c,
    '","', d, '","',
    e, '",', f,
    ',"', g, '","',
    h, '","', i,
    '"'
   WITH nocounter, maxcol = 355, formfeed = none
  ;end select
 ENDIF
END GO
