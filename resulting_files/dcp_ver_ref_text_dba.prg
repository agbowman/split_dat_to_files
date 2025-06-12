CREATE PROGRAM dcp_ver_ref_text:dba
 RECORD ref_text_reltn(
   1 ref_text_reltn_cnt = i4
   1 qual[*]
     2 ref_text_reltn_id = f8
     2 reltn_new_id = f8
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 refr_text_id = f8
     2 text_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 DECLARE cfailed = c1 WITH private, noconstant("F")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  FROM ref_text_reltn rtr
  PLAN (rtr
   WHERE (rtr.parent_entity_id=request->pathway_id)
    AND rtr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY rtr.ref_text_reltn_id
  HEAD REPORT
   stat = alterlist(ref_text_reltn->qual,10), count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(ref_text_reltn->qual,(count1+ 10))
   ENDIF
   ref_text_reltn->qual[count1].ref_text_reltn_id = rtr.ref_text_reltn_id, ref_text_reltn->qual[
   count1].parent_entity_name = rtr.parent_entity_name, ref_text_reltn->qual[count1].parent_entity_id
    = rtr.parent_entity_id,
   ref_text_reltn->qual[count1].refr_text_id = rtr.refr_text_id, ref_text_reltn->qual[count1].
   text_type_cd = rtr.text_type_cd, ref_text_reltn->qual[count1].beg_effective_dt_tm = cnvtdatetime(
    rtr.beg_effective_dt_tm),
   ref_text_reltn->qual[count1].end_effective_dt_tm = cnvtdatetime(rtr.end_effective_dt_tm),
   ref_text_reltn->ref_text_reltn_cnt = count1
  FOOT REPORT
   stat = alterlist(ref_text_reltn->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 FOR (q = 1 TO ref_text_reltn->ref_text_reltn_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     ref_text_reltn->qual[q].reltn_new_id = nextseqnum
    WITH nocounter
   ;end select
   IF ((ref_text_reltn->qual[q].reltn_new_id=0.0))
    CALL report_failure("UPDATE","F","DCP_VER_REF_TEXT","Unable to create new ID for REF_TEXT_RELTN")
    GO TO exit_script
   ENDIF
   INSERT  FROM ref_text_reltn rtr
    SET rtr.ref_text_reltn_id = ref_text_reltn->qual[q].reltn_new_id, rtr.parent_entity_name =
     ref_text_reltn->qual[q].parent_entity_name, rtr.parent_entity_id = pw_catalog->
     pathway_catalog_id,
     rtr.refr_text_id = ref_text_reltn->qual[q].refr_text_id, rtr.text_type_cd = ref_text_reltn->
     qual[q].text_type_cd, rtr.beg_effective_dt_tm = cnvtdatetime(ref_text_reltn->qual[q].
      beg_effective_dt_tm),
     rtr.end_effective_dt_tm = cnvtdatetime(ref_text_reltn->qual[q].end_effective_dt_tm), rtr
     .updt_dt_tm = cnvtdatetime(curdate,curtime3), rtr.updt_cnt = 0,
     rtr.updt_id = reqinfo->updt_id, rtr.updt_task = reqinfo->updt_task, rtr.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_VER_REF_TEXT",
     "Unable to insert new row into REF_TEXT_RELTN")
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 FREE RECORD ref_text_reltn
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
