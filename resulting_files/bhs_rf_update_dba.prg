CREATE PROGRAM bhs_rf_update:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 CALL echo(output_dest)
 DECLARE date_qual = dq8
 SET date_qual = cnvtlookbehind("90,D",cnvtdatetime(curdate,curtime3))
 DECLARE ref_phys = f8
 SET ref_phys = uar_get_code_by("display",88,"Reference Physician")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 personid = f8
     2 username = vc
     2 position = f8
     2 phyind = i2
     2 alpha_id = vc
 )
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.active_status_cd=188.00
    AND pr.physician_ind=1
    AND pr.username=null
    AND pr.position_cd=ref_phys)
  ORDER BY pr.person_id
  HEAD REPORT
   cnt = 0
  HEAD pr.person_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].personid = pr.person_id,
   temp->qual[cnt].phyind = pr.physician_ind, temp->qual[cnt].position = pr.position_cd, temp->qual[
   cnt].username = trim(pr.username),
   temp->qual[cnt].alpha_id = cnvtstring(pr.person_id)
  WITH nocounter, maxrec = 50
 ;end select
 FOR (x = 1 TO size(temp->qual,5))
  UPDATE  FROM prsnl p
   SET p.username = concat("RF",trim(cnvtstring(p.person_id))), p.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), p.updt_cnt = (p.updt_cnt+ 1),
    p.updt_id = 99999999
   WHERE (p.person_id=temp->qual[x].personid)
    AND (temp->qual[x].phyind=1)
   WITH nocounter
  ;end update
  COMMIT
 ENDFOR
#end_prog
END GO
