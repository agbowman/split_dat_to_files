CREATE PROGRAM dsm_sec_matrix_ext
 FREE RECORD positions
 RECORD positions(
   1 qual[*]
     2 position_name = vc
     2 position_cd = f8
 )
 FREE RECORD app_group
 RECORD app_group(
   1 qual[*]
     2 app_group_cd = f8
     2 app_group_name = vc
     2 applications[*]
       3 application_num = i4
       3 application_name = vc
       3 tasks[*]
         4 task_number = i4
         4 task_desc = vc
         4 granted = c1
     2 position_access[*]
       3 access = c1
 )
 DECLARE create_row(row1=i4,row2=i4,row3=i4) = vc WITH protect
 DECLARE create_access_row(row1=i4) = vc WITH protect
 DECLARE create_header(filename=vc) = vc WITH protect
 DECLARE position_cnt = i4
 DECLARE app_grp_cnt = i4
 DECLARE app_cnt = i4
 DECLARE dba_cd = f8
 DECLARE app_desc = vc
 DECLARE file_name = vc
 DECLARE maxlist = i2
 DECLARE cur_row = i2
 DECLARE access_line = vc
 DECLARE app_grp_max = i4
 DECLARE app_max = i4
 DECLARE task_cnt = i4
 DECLARE task_cnt = i4
 SET file_name = "sec_matrix_extract.csv"
 SET dba_pos_cd = uar_get_code_by("MEANING",88,"DBA")
 SET dba_app_cd = uar_get_code_by("DISPLAY",500,"DBA")
 SET message = noinformation
 CALL clear(1,1)
 CALL echo("Retrieving Postions")
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND cv.code_value != dba_pos_cd)
  ORDER BY cv.display
  HEAD REPORT
   stat = alterlist(positions->qual,250), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,250)=0)
    stat = alterlist(positions->qual,(cnt+ 250))
   ENDIF
   positions->qual[cnt].position_name = trim(cv.display), positions->qual[cnt].position_cd = cv
   .code_value
  FOOT REPORT
   stat = alterlist(positions->qual,cnt), position_cnt = cnt
  WITH nocounter
 ;end select
 CALL echo("Retrieving Application Groups and Applications")
 SELECT INTO "NL:"
  a.description
  FROM code_value cv,
   dummyt d,
   application_access aa,
   application a
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=500
    AND cv.code_value != dba_app_cd)
   JOIN (d)
   JOIN (aa
   WHERE aa.app_group_cd=cv.code_value
    AND aa.active_ind=1)
   JOIN (a
   WHERE a.application_number=aa.application_number
    AND a.active_ind=1)
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0, stat = alterlist(app_group->qual,100)
  HEAD cv.code_value
   cnt = (cnt+ 1), app_cnt = 0
   IF (mod(cnt,100)=0)
    stat = alterlist(app_group->qual,(cnt+ 100))
   ENDIF
   stat = alterlist(app_group->qual[cnt].applications,250), app_group->qual[cnt].app_group_cd = cv
   .code_value, app_group->qual[cnt].app_group_name = cv.display
  DETAIL
   app_cnt = (app_cnt+ 1)
   IF (mod(app_cnt,250)=0)
    stat = alterlist(app_group->qual[cnt].applications,(app_cnt+ 250))
   ENDIF
   colon_len = findstring(":",a.description,1)
   IF (colon_len > 0)
    app_desc = substring((colon_len+ 2),size(a.description),a.description)
   ELSE
    app_desc = a.description
   ENDIF
   app_group->qual[cnt].applications[app_cnt].application_name = a.description, app_group->qual[cnt].
   applications[app_cnt].application_num = a.application_number
  FOOT  cv.code_value
   IF (app_desc != null)
    stat = alterlist(app_group->qual[cnt].applications,app_cnt)
   ELSE
    stat = alterlist(app_group->qual[cnt].applications,0)
   ENDIF
  FOOT REPORT
   stat = alterlist(app_group->qual,cnt), app_grp_cnt = cnt
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("Retrieving Tasks by Application")
 SELECT INTO "NL:"
  FROM (dummyt dtrs1  WITH seq = value(size(app_group->qual,5))),
   (dummyt dtrs2  WITH seq = 1),
   application_task_r atr,
   application_task at,
   task_access ta
  PLAN (dtrs1
   WHERE maxrec(dtrs2,size(app_group->qual[dtrs1.seq].applications,5)))
   JOIN (dtrs2)
   JOIN (atr
   WHERE (atr.application_number=app_group->qual[dtrs1.seq].applications[dtrs2.seq].application_num))
   JOIN (at
   WHERE at.task_number=atr.task_number
    AND at.active_ind=1)
   JOIN (ta
   WHERE ta.task_number=outerjoin(at.task_number)
    AND ta.app_group_cd=outerjoin(app_group->qual[dtrs1.seq].app_group_cd))
  HEAD dtrs1.seq
   app_cnt = 0
  HEAD dtrs2.seq
   stat = alterlist(app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks,100), app_cnt = 0
  DETAIL
   app_cnt = (app_cnt+ 1)
   IF (mod(app_cnt,100)=0)
    stat = alterlist(app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks,(app_cnt+ 100))
   ENDIF
   app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks[app_cnt].task_desc = at.description,
   app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks[app_cnt].task_number = at.task_number
   IF (ta.task_number > 0)
    app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks[app_cnt].granted = "G"
   ELSE
    app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks[app_cnt].granted = "R"
   ENDIF
  FOOT  dtrs2.seq
   stat = alterlist(app_group->qual[dtrs1.seq].applications[dtrs2.seq].tasks,app_cnt)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echo("Retrieving Tasks by App Group")
 SELECT INTO "nl:"
  FROM task_access ta,
   (dummyt d1  WITH seq = value(size(app_group->qual,5))),
   application_task at
  PLAN (d1)
   JOIN (ta
   WHERE (ta.app_group_cd=app_group->qual[d1.seq].app_group_cd)
    AND  NOT ( EXISTS (
   (SELECT
    atr.task_number
    FROM application_task_r atr
    WHERE atr.task_number=ta.task_number
     AND atr.application_number IN (
    (SELECT
     aa.application_number
     FROM application_access aa
     WHERE aa.app_group_cd=ta.app_group_cd
      AND aa.active_ind=1))))))
   JOIN (at
   WHERE ta.task_number=at.task_number)
  ORDER BY d1.seq, ta.task_number
  HEAD d1.seq
   grp_tsk_flg = 0, app_num = (size(app_group->qual[d1.seq].applications,5)+ 1), stat = alterlist(
    app_group->qual[d1.seq].applications,app_num),
   app_group->qual[d1.seq].applications[app_num].application_name = "Tasks Only", stat = alterlist(
    app_group->qual[d1.seq].applications[app_num].tasks,10), cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(app_group->qual[d1.seq].applications[app_num].tasks,(10+ cnt))
   ENDIF
   app_group->qual[d1.seq].applications[app_num].tasks[cnt].task_number = at.task_number, app_group->
   qual[d1.seq].applications[app_num].tasks[cnt].task_desc = at.description, app_group->qual[d1.seq].
   applications[app_num].tasks[cnt].granted = "G"
  FOOT  d1.seq
   stat = alterlist(app_group->qual[d1.seq].applications[app_num].tasks,cnt)
  WITH nocounter, noheading
 ;end select
 CALL echo("Creating Position Access List")
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(app_grp_cnt)),
   (dummyt d2  WITH seq = value(position_cnt)),
   application_group ag
  PLAN (d)
   JOIN (d2)
   JOIN (ag
   WHERE (ag.app_group_cd=app_group->qual[d.seq].app_group_cd)
    AND (ag.position_cd=positions->qual[d2.seq].position_cd))
  HEAD d.seq
   stat = alterlist(app_group->qual[d.seq].position_access,position_cnt)
  DETAIL
   app_group->qual[d.seq].position_access[d2.seq].access = "X"
  WITH nocounter
 ;end select
 CALL echo(concat("Write to File: ",'"',file_name,'"'))
 SET stat = create_header(file_name)
 SET app_grp_max = size(app_group->qual,5)
 SET app_grp_cnt = 1
 WHILE (app_grp_cnt <= app_grp_max)
   SET app_cnt = 1
   SET stat = create_access_row(app_grp_cnt)
   SET app_max = size(app_group->qual[app_grp_cnt].applications,5)
   WHILE (app_cnt <= app_max)
     SET task_cnt = 1
     SET task_max = size(app_group->qual[app_grp_cnt].applications[app_cnt].tasks,5)
     WHILE (task_cnt <= task_max)
      SET stat = create_row(app_grp_cnt,app_cnt,task_cnt)
      SET task_cnt = (task_cnt+ 1)
     ENDWHILE
     SET app_cnt = (app_cnt+ 1)
   ENDWHILE
   SET app_grp_cnt = (app_grp_cnt+ 1)
 ENDWHILE
 SUBROUTINE create_header(filename)
   SET maxlist = size(positions->qual,5)
   SET cur_row = 1
   FREE SET v_line
   DECLARE v_line = vc
   SET v_line =
   "Application Group,Application Description,Application Number,Tasks Associated,Tasks Number,Tasks Granted"
   WHILE (cur_row <= maxlist)
    SET v_line = build(v_line,',"',positions->qual[cur_row].position_name,'"')
    SET cur_row = (cur_row+ 1)
   ENDWHILE
   SELECT INTO value(filename)
    v_line
    FROM (dummyt  WITH seq = 1)
    WITH nocounter, noheading
   ;end select
 END ;Subroutine
 SUBROUTINE create_row(row1,row2,row3)
   DECLARE v_line = vc
   DECLARE app_num = vc
   IF ((app_group->qual[row1].applications[row2].application_num=0))
    SET app_num = ""
   ELSE
    SET app_num = cnvtstring(app_group->qual[row1].applications[row2].application_num)
   ENDIF
   FREE SET v_line
   SET v_line = build('"',app_group->qual[row1].app_group_name,'",','"',app_group->qual[row1].
    applications[row2].application_name,
    '",',app_num,",",'"',app_group->qual[row1].applications[row2].tasks[row3].task_desc,
    '",',app_group->qual[row1].applications[row2].tasks[row3].task_number,",",app_group->qual[row1].
    applications[row2].tasks[row3].granted,",",
    access_line)
   SELECT INTO value(file_name)
    v_line
    FROM (dummyt  WITH seq = 1)
    WITH nocounter, noheading, append
   ;end select
 END ;Subroutine
 SUBROUTINE create_access_row(row1)
   DECLARE access_line = vc
   DECLARE char = c1
   IF ((app_group->qual[row1].position_access[1].access="X"))
    SET access_line = build(app_group->qual[row1].position_access[1].access)
   ENDIF
   SET pos_cnt = 2
   SET pos_max = size(app_group->qual[row1].position_access,5)
   WHILE (pos_cnt <= pos_max)
    IF ((app_group->qual[row1].position_access[pos_cnt].access="X"))
     SET access_line = build(access_line,",X")
    ELSE
     SET access_line = build(access_line,",")
    ENDIF
    SET pos_cnt = (pos_cnt+ 1)
   ENDWHILE
 END ;Subroutine
 CALL echo("")
 CALL echo("DONE")
 CALL echo("")
 SET message = information
END GO
