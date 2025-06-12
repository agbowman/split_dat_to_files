CREATE PROGRAM bhs_ma_nologin_90_day_sn:dba
 PROMPT
  "Output to File/Printer/MINE" = '"David.Hounshell@bhs.org"'
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
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
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
    AND pr.active_status_cd=188.00
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 90),0)
    AND pr.username="SN*"
    AND  NOT (pr.person_id IN (
   (SELECT
    oai.person_id
    FROM omf_app_ctx_day_st oai
    WHERE oai.person_id=pr.person_id
     AND oai.start_day > cnvtdatetime((curdate - 90),000)))))
   JOIN (oa
   WHERE oa.person_id=outerjoin(pr.person_id))
  ORDER BY pr.person_id, oa.start_day DESC, 0
  HEAD REPORT
   cnt = 0
  HEAD pr.person_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].personid = pr.person_id,
   temp->qual[cnt].phyind = pr.physician_ind, temp->qual[cnt].position = pr.position_cd, temp->qual[
   cnt].username = trim(pr.username)
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->qual,5))
  UPDATE  FROM prsnl p
   SET p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.username = concat(p.username,"_",
     format(curdate,"YYYYMMDD;;d")), p.active_status_cd = 194,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99999999
   WHERE (p.person_id=temp->qual[x].personid)
    AND (((temp->qual[x].phyind != 1)) OR ((temp->qual[x].phyind=1)
    AND (temp->qual[x].position=925850)))
   WITH nocounter
  ;end update
  COMMIT
 ENDFOR
#end_prog
END GO
