CREATE PROGRAM djh_ma_prsnl_spnd_cnx_nologin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("15,D",cnvtdatetime(curdate,curtime3))
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 personid = f8
     2 username = vc
     2 position = f8
     2 phyind = i2
 )
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT INTO "nl:"
  FROM prsnl pr,
   omf_app_ctx_day_st oa
  PLAN (pr
   WHERE pr.active_ind=1
    AND ((pr.physician_ind != 1) OR (pr.physician_ind=1
    AND pr.position_cd=925850))
    AND pr.active_status_cd=188.00
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 15),0)
    AND pr.username > " "
    AND pr.username="CN6*"
    AND  NOT (pr.position_cd IN (0, 925824, 925830, 925831, 925832,
   925833, 925834, 925835, 925836, 925837,
   925841, 925842, 925843, 925844, 925845,
   925846, 925847, 925848, 925851, 925852,
   925824, 925825, 925826, 925827, 925828,
   96630, 719476, 966300, 966301, 1646210,
   777650, 457, 65699687))
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 15),000)))))
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.name_last, pr.name_first, oa.start_day DESC,
   0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].personid = pr.person_id,
   temp->qual[cnt].phyind = pr.physician_ind, temp->qual[cnt].position = pr.position_cd, temp->qual[
   cnt].username = trim(pr.username)
  WITH maxrec = 10, maxrow = 66
 ;end select
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = size(temp->qual,5))
  WHERE d.seq > 0
  HEAD REPORT
   line = fillstring(80,"="), username = fillstring(20," ")
  HEAD PAGE
   col 5, line, row + 1,
   col 10, "CN No Activity Report", row + 1,
   col 5, line, row + 1,
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), username = trim(temp->qual[cnt].username), row + 1
  WITH maxrec = 2, maxrow = 66
 ;end select
 GO TO end_prog
#end_prog
END GO
