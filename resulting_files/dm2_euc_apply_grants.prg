CREATE PROGRAM dm2_euc_apply_grants
 DECLARE deag_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD deag_grants
 RECORD deag_grants(
   1 cnt = i4
   1 qual[*]
     2 script = vc
     2 grant_cmd = vc
 )
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DM2_PENDING_SCRIPT_GRANT"
  DETAIL
   deag_grants->cnt = (deag_grants->cnt+ 1), stat = alterlist(deag_grants->qual,deag_grants->cnt),
   deag_grants->qual[deag_grants->cnt].script = trim(d.info_name),
   deag_grants->qual[deag_grants->cnt].grant_cmd = trim(d.info_char)
  WITH nocounter
 ;end select
 FOR (deag_cnt = 1 TO deag_grants->cnt)
   SET errmsg = fillstring(132," ")
   SET errcode = error(errmsg,1)
   CALL parser(deag_grants->qual[deag_cnt].grant_cmd,1)
   SET errcode = error(errmsg,0)
   IF (errcode != 0)
    MERGE INTO dm_info d
    USING DUAL ON (d.info_domain="DM2_PENDING_SCRIPT_GRANT_ERROR"
     AND (d.info_name=deag_grants->qual[deag_cnt].script))
    WHEN MATCHED THEN
    (UPDATE
     SET d.info_char = substring(1,100,errmsg)
     WHERE 1=1
    ;end update
    )
    WHEN NOT MATCHED THEN
    (INSERT  FROM d
     (info_domain, info_name, info_char)
     VALUES("DM2_PENDING_SCRIPT_GRANT_ERROR", deag_grants->qual[deag_cnt].script, errmsg)
     WITH nocounter
    ;end insert
    )
    COMMIT
   ELSE
    DELETE  FROM dm_info d
     WHERE d.info_domain="DM2_PENDING_SCRIPT_GRANT*"
      AND (d.info_name=deag_grants->qual[deag_cnt].script)
     WITH nocounter
    ;end delete
    COMMIT
   ENDIF
 ENDFOR
#exit_script
END GO
