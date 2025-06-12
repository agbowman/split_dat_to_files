CREATE PROGRAM bhs_ma_nologin_gn_na:dba
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
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 FREE RECORD tempx
 RECORD tempx(
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
    AND ((pr.physician_ind != 1) OR (((pr.position_cd=228835487) OR (pr.position_cd=227480046)) ))
    AND pr.updt_dt_tm < cnvtdatetime((curdate - 90),0)
    AND pr.username != "SPND*"
    AND pr.username != "TERM*"
    AND pr.username != "NA-*"
    AND pr.username != "RF*"
    AND pr.username != "SN*"
    AND pr.username > " "
    AND pr.username != "TESTPR"
    AND pr.username != "REFUSORD"
    AND pr.username != "EDATTEND"
    AND pr.username != "INPTATTEND"
    AND pr.username != "FNDTLIST"
    AND pr.username != "FNENGINE"
    AND pr.username != "EDPLASMA"
    AND pr.username != "TRAUMARESIDENT"
    AND pr.username != "TRAUMARES"
    AND pr.username != "EDCACHE"
    AND pr.username != "DUM*"
    AND pr.username != "BHSDBA"
    AND pr.username != "CERSUP1"
    AND pr.username != "CERSUP2"
    AND pr.username != "CERSUP3"
    AND pr.username != "CERSUP4"
    AND pr.username != "CERSUP5"
    AND pr.username != "CERSUP5"
    AND pr.username != "ETE1"
    AND pr.username != "ETE2"
    AND pr.username != "ETE3"
    AND pr.username != "MED2A"
    AND pr.username != "MOBJECTS"
    AND pr.username != "RESET"
    AND pr.username != "PATROL"
    AND pr.username != "SHIELDS"
    AND pr.username != "PHTRIAGE"
    AND pr.username != "BEDROCK"
    AND pr.username != "SYSTEMHF"
    AND pr.username != "EXTRA"
    AND pr.name_last_key != "BHS*"
    AND pr.name_last_key != "BMC*"
    AND pr.name_last_key != "FMC*"
    AND pr.name_last_key != "MLH*"
    AND pr.name_last_key != "BWH*"
    AND pr.name_last_key != "BNH*"
    AND pr.name_last_key != "ORGS*"
    AND pr.name_last_key != "*INBOX*"
    AND pr.name_last_key != "FIRSTNET*"
    AND pr.name_last_key != "HISTORICAL*"
    AND pr.name_last_key != "CERNER*"
    AND pr.name_last_key != "*BYPASS*"
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
   cnt = (cnt+ 1), stat = alterlist(tempx->qual,cnt), tempx->qual[cnt].personid = pr.person_id,
   tempx->qual[cnt].phyind = pr.physician_ind, tempx->qual[cnt].position = pr.position_cd, tempx->
   qual[cnt].username = trim(pr.username)
  WITH nocounter
 ;end select
 IF (size(tempx->qual,5) > 0)
  FOR (x = 1 TO size(tempx->qual,5))
   UPDATE  FROM prsnl p
    SET p.active_status_cd = 194.00, p.username = concat("NA-",p.username,"_",format(curdate,
       "YYYYMMDD;;d")), p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id =
     99999999
    WHERE (p.person_id=tempx->qual[x].personid)
    WITH nocounter
   ;end update
   COMMIT
  ENDFOR
 ENDIF
#end_prog
END GO
