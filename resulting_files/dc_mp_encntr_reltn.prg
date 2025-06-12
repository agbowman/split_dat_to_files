CREATE PROGRAM dc_mp_encntr_reltn
 IF ( NOT (validate(reltnrequest)))
  RECORD reltnrequest(
    1 plist[*]
      2 prsnl_person_id = f8
      2 person_prsnl_reltn_cd = f8
      2 person_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 elist[*]
      2 prsnl_person_id = f8
      2 encntr_prsnl_reltn_cd = f8
      2 encntr_id = f8
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(reltnreply)))
  RECORD reltnreply(
    1 lookup_status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE statusscript = vc WITH constant("dc_mp_encntr_reltn")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE jrec = i4 WITH protect
 DECLARE reltnvalidind = i2 WITH protect
 IF (( $2 != null))
  SET jrec = cnvtjsontorec( $2)
  CALL echo("This is the converted json string to record")
  CALL echorecord(qmreq)
 ENDIF
 SET reltnrequest->status_data.status = "F"
 DECLARE errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) = null
 IF ((qmreq->reltncd > 0))
  SELECT INTO "NL:"
   cv1.code_set, cv1.code_value
   FROM code_value cv1
   PLAN (cv1
    WHERE cv1.code_set=333
     AND (cv1.code_value=qmreq->reltncd))
   DETAIL
    reltnvalidind = 1
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Req Columns",errmsg)
  ENDIF
 ENDIF
 IF (reltnvalidind > 0)
  SET now = alterlist(reltnrequest->elist,size(qmreq->list,5))
  FOR (x = 1 TO size(qmreq->list,5))
    SET reltnrequest->elist[x].prsnl_person_id = qmreq->prsnlid
    SET reltnrequest->elist[x].encntr_prsnl_reltn_cd = qmreq->reltncd
    SET reltnrequest->elist[x].encntr_id = qmreq->list[x].eid
  ENDFOR
  CALL echo("===============================================")
  CALL echorecord(reltnrequest)
  CALL echo("================execute reltn program===============================")
  EXECUTE pts_add_mult_prsnl_reltn  WITH replace(request,reltnrequest), replace(reply,reltnreply)
  CALL echo("================reply from reltn program===============================")
  CALL echorecord(reltnreply)
 ELSE
  CALL echo("================reltn program not run===============================")
  CALL echo(concat("type code = ",cnvtstring(qmreq->reltncd)))
  GO TO exit_script
 ENDIF
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reltnrequest->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reltnrequest->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET lstat = alter(reltnrequest->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reltnrequest->status_data.status = "F"
   SET reltnrequest->status_data.subeventstatus[error_cnt].operationname = statusscript
   SET reltnrequest->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reltnrequest->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reltnrequest->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SET reltnrequest->status_data.status = "S"
#exit_script
 CALL echo("SCRIPT VERSION IS  03/12/2010 Christopher Canida    Initial Release  ")
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(reltnrequest)
 ELSE
  CALL echojson(reltnrequest, $1)
 ENDIF
 SELECT INTO "nl:"
  DETAIL
   row + 0
  WITH nocounter
 ;end select
END GO
