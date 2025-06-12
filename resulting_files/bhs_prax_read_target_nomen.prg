CREATE PROGRAM bhs_prax_read_target_nomen
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 source_concept_cki = vc
   1 source_vocabulary_code = f8
   1 patient_relationship_cd = f8
   1 items[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4175107
 RECORD req4175107(
   1 source_nomenclature_id = f8
   1 source_concept_cki = vc
   1 source_vocabulary_code = f8
   1 begin_effective_dt_tm = dq8
   1 person_id = f8
   1 user_context
     2 user_id = f8
     2 patient_relationship_cd = f8
   1 carry_forward_ind = i2
   1 local_time_zone = i4
 ) WITH protect
 FREE RECORD rep4175107
 RECORD rep4175107(
   1 source_nomenclature
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
     2 source_vocabulary_code = f8
     2 specific_ind = i2
   1 target_nomenclatures[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 concept_cki = vc
     2 source_identifier = vc
     2 source_vocabulary_code = f8
     2 specific_ind = i2
   1 carried_forward_status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE calldiagnosisassistant(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE itemcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE app_tz = i4 WITH protect, constant(evaluate(curutc,1,curtimezoneapp,0))
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID NOMENCLATURE ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM nomenclature n
  PLAN (n
   WHERE (n.nomenclature_id= $4)
    AND n.active_ind=1)
  ORDER BY n.nomenclature_id
  HEAD n.nomenclature_id
   result->source_concept_cki = n.concept_cki, result->source_vocabulary_code = n
   .source_vocabulary_cd
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "NL:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $2)
    AND (epr.prsnl_person_id= $3)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm < sysdate
    AND epr.end_effective_dt_tm > sysdate)
  ORDER BY epr.priority_seq
  HEAD epr.encntr_id
   result->patient_relationship_cd = epr.encntr_prsnl_r_cd
  WITH nocounter, time = 30
 ;end select
 SET stat = calldiagnosisassistant(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1
   DETAIL
    col + 1, "<Nomenclatures>", row + 1
    FOR (idx = 1 TO size(result->items,5))
      col + 1, "<Nomenclature>", row + 1,
      v1 = build("<NomenclatureId>",cnvtint(result->items[idx].nomenclature_id),"</NomenclatureId>"),
      col + 1, v1,
      row + 1, v2 = build("<SourceString>",trim(replace(replace(replace(replace(replace(result->
             items[idx].source_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
         "&quot;",0),3),"</SourceString>"), col + 1,
      v2, row + 1, v3 = build("<SourceIdentifier>",trim(replace(replace(replace(replace(replace(
             result->items[idx].source_identifier,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</SourceIdentifier>"),
      col + 1, v3, row + 1,
      v4 = build("<ConceptCki>",trim(replace(replace(replace(replace(replace(result->items[idx].
             concept_cki,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
        ),"</ConceptCki>"), col + 1, v4,
      row + 1, col + 1, "</Nomenclature>",
      row + 1
    ENDFOR
    col + 1, "</Nomenclatures>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req4175107
 FREE RECORD rep4175107
 SUBROUTINE calldiagnosisassistant(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(3202004)
   DECLARE requestid = i4 WITH protect, constant(4175107)
   SET req4175107->source_nomenclature_id =  $4
   SET req4175107->source_concept_cki = result->source_concept_cki
   SET req4175107->source_vocabulary_code = result->source_vocabulary_code
   SET req4175107->begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET req4175107->person_id = result->person_id
   SET req4175107->user_context.user_id =  $3
   SET req4175107->user_context.patient_relationship_cd = result->patient_relationship_cd
   SET req4175107->carry_forward_ind = 1
   SET req4175107->local_time_zone = app_tz
   CALL echorecord(req4175107)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req4175107,
    "REC",rep4175107,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep4175107)
   IF ((rep4175107->status_data.status != "F"))
    SET itemcnt = size(rep4175107->target_nomenclatures,5)
    SET stat = alterlist(result->items,itemcnt)
    FOR (idx = 1 TO itemcnt)
      SET result->items[idx].nomenclature_id = rep4175107->target_nomenclatures[idx].nomenclature_id
      SET result->items[idx].source_string = rep4175107->target_nomenclatures[idx].source_string
      SET result->items[idx].source_identifier = rep4175107->target_nomenclatures[idx].
      source_identifier
      SET result->items[idx].concept_cki = rep4175107->target_nomenclatures[idx].concept_cki
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
