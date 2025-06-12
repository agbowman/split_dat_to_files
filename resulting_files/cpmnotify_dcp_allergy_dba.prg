CREATE PROGRAM cpmnotify_dcp_allergy:dba
 SET modify = predeclare
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 allergy_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET reply->overlay_ind = 1
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE status_ind = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE rep_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE undocumented = i2 WITH protect, constant(0)
 DECLARE documented_nka = i2 WITH protect, constant(1)
 DECLARE documented_allergies = i2 WITH protect, constant(2)
 DECLARE documented_nkma = i2 WITH protect, constant(3)
 DECLARE no_dataqualify = i2 WITH protect, constant(1)
 DECLARE request_zero = i2 WITH protect, constant(2)
 DECLARE canceled_reaction_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE req_cnt = i4 WITH public, constant(size(request->entity_list,5))
 IF (req_cnt=0)
  SET status_ind = request_zero
  GO TO exit_script
 ENDIF
 DECLARE nkma_source_string = vc WITH protect, constant("No Known Medication Allergies")
 DECLARE nkma_concept_cki = vc WITH protect, noconstant("")
 DECLARE nkadocumented = i2 WITH protect, noconstant(0)
 DECLARE nkmadocumented = i2 WITH protect, noconstant(0)
 DECLARE allergydocumented = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  n.concept_cki
  FROM nomenclature n
  WHERE n.source_string=nkma_source_string
  DETAIL
   nkma_concept_cki = n.concept_cki
  WITH nocounter
 ;end select
 DECLARE initializereply(null) = null
 DECLARE identifyallergies(null) = null
 CALL initializereply(null)
 CALL identifyallergies(null)
 SUBROUTINE initializereply(null)
   SELECT DISTINCT INTO "nl:"
    entity_id = request->entity_list[d1.seq].entity_id
    FROM (dummyt d1  WITH seq = value(size(request->entity_list,5)))
    PLAN (d1)
    ORDER BY entity_id
    HEAD REPORT
     entity_cnt = 0
    HEAD entity_id
     entity_cnt = (entity_cnt+ 1)
     IF (mod(entity_cnt,10)=1)
      stat = alterlist(reply->entity_list,(entity_cnt+ 9))
     ENDIF
     reply->entity_list[entity_cnt].entity_id = request->entity_list[d1.seq].entity_id, stat =
     alterlist(reply->entity_list[entity_cnt].datalist,1), reply->entity_list[entity_cnt].datalist[1]
     .allergy_ind = undocumented
    FOOT REPORT
     stat = alterlist(reply->entity_list,entity_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE identifyallergies(null)
   DECLARE numx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM allergy a,
     nomenclature n
    PLAN (a
     WHERE expand(numx,1,size(request->entity_list,5),a.person_id,request->entity_list[numx].
      entity_id)
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND  NOT (a.reaction_status_cd=canceled_reaction_cd))
     JOIN (n
     WHERE n.nomenclature_id=a.substance_nom_id)
    ORDER BY a.person_id, a.allergy_instance_id
    HEAD a.person_id
     idx = locatevalsort(numx,1,size(reply->entity_list,5),a.person_id,reply->entity_list[numx].
      entity_id), nkadocumented = 0, nkmadocumented = 0,
     allergydocumented = 0
    HEAD a.allergy_instance_id
     IF (idx > 0
      AND a.allergy_instance_id > 0)
      IF (n.mnemonic="NKA")
       nkadocumented = 1
      ELSEIF (n.concept_cki=nkma_concept_cki)
       nkmadocumented = 1
      ELSE
       allergydocumented = 1
      ENDIF
     ENDIF
    DETAIL
     IF (nkadocumented)
      reply->entity_list[idx].datalist[1].allergy_ind = documented_nka
     ELSEIF (allergydocumented)
      reply->entity_list[idx].datalist[1].allergy_ind = documented_allergies
     ELSEIF (nkmadocumented)
      reply->entity_list[idx].datalist[1].allergy_ind = documented_nkma
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (curqual=0)
    SET status_ind = no_dataqualify
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 SET err_code = error(err_msg,1)
 IF (err_code != 0)
  CALL reportfailure("ERROR","F","cpmnotify_dcp_allergy",err_msg)
 ELSEIF (((status_ind=no_dataqualify) OR (status_ind=request_zero)) )
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET modify = nopredeclare
END GO
