CREATE PROGRAM bhs_athn_get_order_diag
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req510800
 RECORD req510800(
   1 orders[*]
     2 order_id = f8
 ) WITH protect
 FREE RECORD rep510800
 RECORD rep510800(
   1 transaction_status
     2 success_ind = i2
     2 debug_error_message = vc
   1 orders[*]
     2 order_id = f8
     2 diagnoses[*]
       3 diagnosis_id = f8
       3 source_identifier = vc
       3 search_nomenclature_id = f8
       3 target_nomenclature_id = f8
       3 target_vocabulary_cd = f8
       3 annotated_display = vc
       3 priority = i2
       3 potential_indicator = i2
 ) WITH protect
 DECLARE callgetordersdiagnoses(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ORDER ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetordersdiagnoses(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  IF ((result->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1
     FOR (idx = 1 TO size(rep510800->orders[1].diagnoses,5))
       col + 1, "<Diagnosis>", row + 1,
       v2 = build("<DiagnosisId>",cnvtstring(rep510800->orders[1].diagnoses[idx].diagnosis_id),
        "</DiagnosisId>"), col + 1, v2,
       row + 1, v3 = build("<SourceIdentifier>",trim(replace(replace(replace(replace(replace(
              rep510800->orders[1].diagnoses[idx].source_identifier,"&","&amp;",0),"<","&lt;",0),">",
            "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</SourceIdentifier>"), col + 1,
       v3, row + 1, v4 = build("<SearchNomenclatureId>",cnvtstring(rep510800->orders[1].diagnoses[idx
         ].search_nomenclature_id),"</SearchNomenclatureId>"),
       col + 1, v4, row + 1,
       v5 = build("<NomenclatureId>",cnvtstring(rep510800->orders[1].diagnoses[idx].
         target_nomenclature_id),"</NomenclatureId>"), col + 1, v5,
       row + 1, v6 = build("<SourceVacabulary>",cnvtstring(rep510800->orders[1].diagnoses[idx].
         target_vocabulary_cd),"</SourceVacabulary>"), col + 1,
       v6, row + 1, v7 = build("<DiagnosisDisplay>",trim(replace(replace(replace(replace(replace(
              rep510800->orders[1].diagnoses[idx].annotated_display,"&","&amp;",0),"<","&lt;",0),">",
            "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</DiagnosisDisplay>"),
       col + 1, v7, row + 1,
       v8 = build("<Priority>",rep510800->orders[1].diagnoses[idx].priority,"</Priority>"), col + 1,
       v8,
       row + 1, v9 = build("<PotentialIndicator>",rep510800->orders[1].diagnoses[idx].
        potential_indicator,"</PotentialIndicator>"), col + 1,
       v9, row + 1, col + 1,
       "</Diagnosis>", row + 1
     ENDFOR
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req510800
 FREE RECORD rep510800
 SUBROUTINE callgetordersdiagnoses(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(3202004)
   DECLARE requestid = i4 WITH protect, constant(510800)
   SET stat = alterlist(req510800->orders,1)
   SET req510800->orders[1].order_id =  $2
   CALL echorecord(req510800)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req510800,
    "REC",rep510800,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep510800)
   IF ((rep510800->transaction_status.success_ind=1))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
