CREATE PROGRAM djh_updt_prsnl_email:dba
 DECLARE ml_rs_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD pe_rs
 RECORD pe_rs(
   1 list[*]
     2 s_username = vc
     2 s_email = vc
 ) WITH protect
 CALL echorecord(requestin)
 IF (size(requestin->list_0,5)=0)
  CALL echo("CSV file is empty")
  GO TO exit_script
 ENDIF
 FOR (ml_rs_cnt = 1 TO size(requestin->list_0,5))
   SET stat = alterlist(pe_rs->list,ml_rs_cnt)
   SET pe_rs->list[ml_rs_cnt].s_username = trim(requestin->list_0[ml_rs_cnt].username,3)
   SET pe_rs->list[ml_rs_cnt].s_email = trim(requestin->list_0[ml_rs_cnt].email,3)
 ENDFOR
 CALL echorecord(pe_rs)
 FOR (ml_rs_cnt = 1 TO size(pe_rs->list,5))
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.username=pe_rs->list[ml_rs_cnt].s_username)
    AND p.active_ind=1
    AND  NOT (p.active_status_cd IN (189.0, 194.0))
    AND trim(p.email) IN ("", " ", null)
   WITH nocounter
  ;end select
  IF (curqual != 0)
   UPDATE  FROM prsnl p
    SET p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id =
     99999999.0,
     p.email = pe_rs->list[ml_rs_cnt].s_email
    WHERE (p.username=pe_rs->list[ml_rs_cnt].s_username)
     AND p.active_ind=1
     AND  NOT (p.active_status_cd IN (189.0, 194.0))
     AND trim(p.email) IN ("", " ", null)
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
 ENDFOR
 CALL echorecord(pe_rs)
#exit_script
END GO
