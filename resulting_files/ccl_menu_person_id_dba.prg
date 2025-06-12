CREATE PROGRAM ccl_menu_person_id:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = mine,
  "Enter max number of records: " = 5000
 SET maxnumrecs =  $2
 RECORD p_info(
   1 qual[*]
     2 name = c30
     2 app_group = c30
     2 person_id = f8
     2 position = c30
     2 position_cd = f8
 )
 SET cnt = 0
 SET cnt2 = 0
 SET max = 5000
 SET dba_value = 0.0
 SELECT INTO "nl:"
  code_value
  FROM code_value cv
  WHERE cv.code_set=500
   AND cv.display_key="DBA"
  DETAIL
   dba_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO  $1
  name = substring(1,30,pe.name_full_formatted), app_group = substring(1,30,uar_get_code_display(ag
    .app_group_cd)), pe.person_id,
  position = substring(1,30,uar_get_code_display(pr.position_cd)), ag.position_cd
  FROM person pe,
   prsnl pr,
   application_group ag
  PLAN (pe)
   JOIN (pr
   WHERE pr.person_id=pe.person_id)
   JOIN (ag
   WHERE pr.position_cd=ag.position_cd)
  ORDER BY name, pe.person_id, app_group
  HEAD REPORT
   stat = alterlist(p_info->qual,100), dba_flag = 0, line = fillstring(30,"="),
   maxd = format(max,"#####")
  HEAD PAGE
   col 50, "PERSONS WITHOUT DBA APP GROUP CODE", row + 1,
   col 55, "(WITH MAXREC = ", maxnumrecs,
   ")", row + 2, col 0,
   "NAME", col 32, "APP GROUP",
   col 64, "PERSON_ID", col 96,
   "POSITION", row + 1, col 0,
   line, col 32, line,
   col 64, line, col 96,
   line, row + 1
  HEAD pe.person_id
   dba_flag = 0, cnt = 0, cnt2 = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(p_info->qual,(cnt+ 10))
   ENDIF
   p_info->qual[cnt].name = name, p_info->qual[cnt].app_group = app_group, p_info->qual[cnt].
   person_id = pe.person_id,
   p_info->qual[cnt].position = position, p_info->qual[cnt].position_cd = ag.position_cd
   IF (ag.app_group_cd=dba_value)
    dba_flag = 1
   ENDIF
  FOOT  pe.person_id
   IF (dba_flag=0)
    FOR (cnt2 = 1 TO cnt)
      IF (cnt2=1)
       col 0, p_info->qual[cnt2].name
      ENDIF
      col 32, p_info->qual[cnt2].app_group, col 64,
      p_info->qual[cnt2].person_id, col 96, p_info->qual[cnt2].position,
      row + 1
    ENDFOR
    row + 1
   ENDIF
   dba_flag = 0
  WITH maxrec = value( $2), format = variable
 ;end select
END GO
