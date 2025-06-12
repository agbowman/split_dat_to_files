CREATE PROGRAM bhs_sys_get_location:dba
 DECLARE accnbr = vc
 SET a1 = substring(1,1,acct_nbr)
 IF (a1="0")
  SET accnbr = trim(cnvtstring(cnvtint(acct_nbr)),3)
 ELSE
  SET accnbr = trim(acct_nbr,3)
 ENDIF
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   code_value_alias cvo
  PLAN (ea
   WHERE ea.alias=accnbr
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=value(uar_get_code_by("displaykey",319,"FINNBR")))
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (cvo
   WHERE cvo.code_value=e.loc_nurse_unit_cd
    AND cvo.contributor_source_cd=673943.00
    AND  EXISTS (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_value=cvo.code_value
     AND cv.end_effective_dt_tm > sysdate)))
  DETAIL
   localias = trim(cvo.alias,3),
   CALL echo(build("code value:",e.loc_nurse_unit_cd)),
   CALL echo(build("encntrid:",e.encntr_id)),
   CALL echo(build("account:",acct_nbr,"->",accnbr))
  WITH nocounter
 ;end select
 CALL echo(build("Inbound alias:",localias))
 SET data = replace(localias,"^~",";",0)
 CALL echo(data)
 WHILE (str != notfnd)
   SET str = piece(data,";",num,notfnd)
   CALL echo(build("piece",num,"=",str))
   SET num = (num+ 1)
   IF (str != "<not_found>")
    SET localias = str
   ENDIF
 ENDWHILE
 SET localias = check(trim(localias,3))
 CALL echo(build("Inbound alias:",localias))
END GO
