CREATE PROGRAM ct_get_protocols_refhelp:dba
 DECLARE concept_cd = f8 WITH protect, noconstant(0.00)
 DECLARE approved_cd = f8 WITH protect, noconstant(0.00)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.00)
 DECLARE closed_cd = f8 WITH protect, noconstant(0.00)
 DECLARE indevelopment_cd = f8 WITH protect, noconstant(0.00)
 DECLARE tempsuspend_cd = f8 WITH protect, noconstant(0.00)
 RECORD treply(
   1 cnt = i4
   1 fieldname = vc
   1 qual[*]
     2 display = vc
     2 hidden = vc
 )
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,concept_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"APPROVED",1,approved_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"INDVLPMENT",1,indevelopment_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"CLOSED",1,closed_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"TEMPSUSPEND",1,tempsuspend_cd)
 SET treply->fieldname = "PROTOCOL"
 SET treply->cnt = 1
 SET stat = alterlist(treply->qual,treply->cnt)
 SELECT
  pm.primary_mnemonic
  FROM prot_master pm
  PLAN (pm
   WHERE pm.primary_mnemonic > ""
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pm.prot_status_cd IN (concept_cd, approved_cd, activated_cd, indevelopment_cd, closed_cd,
   tempsuspend_cd)
    AND pm.prescreen_type_flag=0)
  ORDER BY cnvtupper(pm.primary_mnemonic)
  DETAIL
   treply->cnt += 1, stat = alterlist(treply->qual,treply->cnt), treply->qual[treply->cnt].display =
   pm.primary_mnemonic,
   treply->qual[treply->cnt].hidden = pm.primary_mnemonic
  WITH nocounter
 ;end select
 CALL closereply(0)
 SUBROUTINE closereply(bstandard)
   DECLARE sql = vc
   DECLARE sqlreply = vc WITH private
   DECLARE sqlselect = vc WITH private
   SET reply->cnt = 0
   IF (bstandard=false)
    SET sqlselect = concat('select into "NL:"  ',trim(treply->fieldname),
     " = SubString(1, 1024, tReply->qual[d.seq].display), ",
     "_HIDDEN_PAR = SubString(1, 1024, tReply->qual[d.seq].hidden) ",
     "from (dummyt d with seq = Value(tReply->cnt)) /**/")
   ELSE
    SET sqlselect = concat('select into "NL:"  ',trim(treply->fieldname),
     " = SubString(1, 256, tReply->qual[d.seq].display), ",' _hidden = " " ',
     "from (dummyt d with seq = Value(tReply->cnt)) /**/")
   ENDIF
   SET sqlreply = concat(" where tReply->qual[d.seq].display > ' ' "," head report ",
    "stat = alterlist(reply->qual,reply->cnt + 50) ","stat = 0 ",
    'reply->fieldname = concat(reportinfo(1),"^") ',
    "reply->fieldsize = size(reply->fieldname) ","detail ","reply->cnt = reply->cnt + 1 ",
    "if(mod(reply->cnt,50) = 1) ","stat = alterlist(reply->qual,reply->cnt + 50) ",
    "endif ",'reply->qual[reply->cnt].result = concat(reportinfo(2),"^") ',"foot report ",
    "stat = alterlist(reply->qual,reply->cnt) ","with maxrow = 1, reporthelp, check go ")
   SET sql = concat(sqlselect,sqlreply)
   SET debug->sql = sql
   CALL parser(sql,1)
   IF ((reply->cnt=0))
    CALL helperror("No items found")
   ENDIF
   SET treply->cnt = 0
   SET stat = alterlist(treply->qual,0)
   CALL echo("SENDING REPLY WITH :")
   CALL echorecord(reply)
 END ;Subroutine
 SUBROUTINE helperror(errmsgx)
  SET strtext = errmsgx
  SELECT DISTINCT INTO "NL:"
   error_message = strtext, _hidden = d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   ORDER BY d1.seq
   HEAD REPORT
    stat = 0, reply->cnt = 0, reply->fieldname = concat(reportinfo(1),"^"),
    reply->fieldsize = size(reply->fieldname)
   DETAIL
    reply->cnt += 1
    IF (mod(reply->cnt,50)=1)
     stat = alterlist(reply->qual,(reply->cnt+ 50))
    ENDIF
    reply->qual[reply->cnt].result = concat(reportinfo(2),"^")
   FOOT REPORT
    stat = alterlist(reply->qual,reply->cnt)
   WITH maxrow = 1, reporthelp, check
  ;end select
 END ;Subroutine
 SET last_mod = "0002"
 SET mod_date = "November 15, 2018"
END GO
