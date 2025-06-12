CREATE PROGRAM aging_report:dba
 PAINT
 CALL box(3,1,22,80)
 CALL text(2,1,"USER AGING REPORT",w)
 CALL text(4,2,"Disabled only/Enabled only/Both (D/E/B)?")
 CALL text(5,2,"Days past (30-60-90)?")
 CALL text(6,2,"Department: ")
 CALL text(7,2,"Enter output device:")
 CALL text(8,2,"Delimited format: ")
 CALL accept(4,43,"p;cu","B"
  WHERE curaccept IN ("D", "E", "B"))
 SET d_only = curaccept
 CALL accept(5,24,"nn;c","30"
  WHERE curaccept IN ("30", "60", "90"))
 SET numdays = cnvtreal(curaccept)
 CALL accept(6,24,"p(30);cu","*")
 SET dept = curaccept
 CALL accept(7,24,"p(30);cu","FORMS")
 SET odev = curaccept
 CALL accept(8,24,"p;cu","N"
  WHERE curaccept IN ("Y", "N"))
 SET dformat = curaccept
 SET ssn_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=4
    AND c.cdf_meaning="SSN")
  DETAIL
   ssn_cd = c.code_value
  WITH counter
 ;end select
 SELECT
  IF (dformat="Y")
   WITH maxrow = 1, noformfeed, outerjoin = d1,
    dontexist, outerjoin = d
  ELSE
   WITH counter, outerjoin = d1, dontexist,
    outerjoin = d
  ENDIF
  DISTINCT INTO trim(odev)
  p.name_full_formatted, p.name_last_key, p.name_first_key,
  department = c1.display, position = substring(1,30,c2.display), pr.username,
  ssn = substring(1,11,pa.alias), a.start_dt_tm, ax.start_dt_tm,
  enabled =
  IF (pr.active_ind=1
   AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate)) "Y"
  ELSE "N"
  ENDIF
  FROM application_context a,
   application_context ax,
   person p,
   prsnl pr,
   (dummyt d  WITH seq = 1),
   (dummyt d1  WITH seq = 1),
   person_alias pa,
   code_value c1,
   code_value c2
  PLAN (pr
   WHERE ((d_only="D"
    AND ((pr.active_ind=0) OR (((pr.end_effective_dt_tm < cnvtdatetime(sysdate)) OR (pr
   .beg_effective_dt_tm > cnvtdatetime(sysdate))) )) ) OR (((d_only="E"
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)) OR (d_only="B")) )) )
   JOIN (c1
   WHERE pr.department_cd=c1.code_value
    AND c1.display_key=patstring(dept))
   JOIN (p
   WHERE pr.person_id=p.person_id)
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(ssn_cd)) )
   JOIN (c2
   WHERE pr.position_cd=c2.code_value)
   JOIN (d
   WHERE 1=d.seq)
   JOIN (ax
   WHERE pr.person_id=ax.person_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (a
   WHERE pr.person_id=a.person_id
    AND a.start_dt_tm BETWEEN cnvtdatetime((curdate - numdays),0) AND cnvtdatetime(curdate,2400))
  ORDER BY department, p.name_last_key, p.name_first_key,
   p.name_full_formatted, ax.start_dt_tm DESC
  HEAD REPORT
   under = fillstring(131,"=")
   IF (dformat="Y")
    '"USERNAME","NAME","SSN","LAST_LOGON","POSITION","ENABLED"', row + 1
   ENDIF
  HEAD PAGE
   IF (dformat="N")
    col 0, "Date: ", curdate"dd-mmm-yyyy;;d",
    col 49, "U S E R   A G I N G   R E P O R T", col 120,
    "Time: ", curtime"hhmm;;m", row + 1,
    col 0, "Department: ", department,
    col 120, "Page: ", curpage"###",
    row + 1, col 0, "Lookback Days: ",
    numdays"###;l", row + 2, col 0,
    "Username", col 20, "Name",
    col 60, "SSN", col 72,
    "Last Logon", col 90, "Position",
    col 122, "Enabled", row + 1,
    col 0, under, row + 1
   ENDIF
  HEAD department
   row + 0
  HEAD p.name_full_formatted
   IF (dformat="N")
    col 0, pr.username, col 19,
    " ", p.name_full_formatted, col 59,
    " ", ssn, col 90,
    position, col 122, enabled
   ENDIF
  DETAIL
   IF (dformat="Y")
    '"',
    CALL print(trim(pr.username)), '",',
    '"',
    CALL print(trim(p.name_full_formatted)), '",',
    '"',
    CALL print(trim(ssn)), '",',
    '"',
    CALL print(format(ax.start_dt_tm,"dd-mmm-yyyy hhmm;;q")), '",',
    '"',
    CALL print(trim(position)), '",',
    '"', enabled, '"',
    row + 0
   ENDIF
  FOOT  p.name_full_formatted
   IF (dformat="N")
    col 72, ax.start_dt_tm"dd-mmm-yyyy hhmm;;q"
   ENDIF
   row + 1
  FOOT  department
   BREAK
 ;end select
END GO
