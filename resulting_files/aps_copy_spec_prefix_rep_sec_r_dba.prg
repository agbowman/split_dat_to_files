CREATE PROGRAM aps_copy_spec_prefix_rep_sec_r:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD spec_prefix(
   1 list[*]
     2 prefix_id = f8
     2 specimen_cd = f8
     2 suggested_flag = i2
     2 sequence = i4
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE maxseq = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 INSERT  FROM ap_synoptic_rpt_section_r apri
  (apri.catalog_cd, apri.task_assay_cd, apri.cki_source,
  apri.cki_identifier, apri.updt_cnt, apri.updt_dt_tm,
  apri.updt_id, apri.updt_task, apri.updt_applctx)(SELECT
   aprs.catalog_cd, aprs.task_assay_cd, cki_source = request->to_cki_source,
   cki_identifier = request->to_cki_identifier, 1, cnvtdatetime(curdate,curtime3),
   reqinfo->updt_id, reqinfo->updt_task, reqinfo->updt_applctx
   FROM ap_synoptic_rpt_section_r aprs
   WHERE (aprs.cki_source=request->from_cki_source)
    AND (aprs.cki_identifier=request->from_cki_identifier)
   WITH nocounter)
 ;end insert
 IF (error(serror,0) > 0)
  CALL subevent_add("SELECT","F","TABLE","AP_SYNOPTIC_RPT_SECTION")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ap_synoptic_spec_prefix_r apss
  WHERE (apss.cki_source=request->from_cki_source)
   AND (apss.cki_identifier=request->from_cki_identifier)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(spec_prefix->list,cnt), spec_prefix->list[cnt].prefix_id = apss
   .prefix_id,
   spec_prefix->list[cnt].specimen_cd = apss.specimen_cd, spec_prefix->list[cnt].suggested_flag =
   apss.suggested_flag, spec_prefix->list[cnt].sequence = apss.sequence
  WITH nocounter
 ;end select
 IF (cnt > 0)
  CALL echorecord(spec_prefix)
  SELECT INTO "nl:"
   FROM ap_synoptic_spec_prefix_r apss,
    (dummyt d  WITH seq = value(cnt))
   PLAN (d)
    JOIN (apss
    WHERE (apss.specimen_cd=spec_prefix->list[d.seq].specimen_cd)
     AND (apss.prefix_id=spec_prefix->list[d.seq].prefix_id))
   ORDER BY apss.specimen_cd, d.seq, apss.sequence DESC
   HEAD apss.specimen_cd
    maxseq = 0
   DETAIL
    IF (maxseq <= apss.sequence)
     maxseq = (apss.sequence+ 1)
    ENDIF
   FOOT  d.seq
    IF ((spec_prefix->list[d.seq].sequence <= maxseq))
     spec_prefix->list[d.seq].sequence = maxseq, maxseq = (maxseq+ 1)
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(spec_prefix)
  IF (error(serror,0) > 0)
   CALL subevent_add("SELECT","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_synoptic_spec_prefix_r apsi,
    (dummyt d  WITH seq = value(cnt))
   SET apsi.prefix_id = spec_prefix->list[d.seq].prefix_id, apsi.specimen_cd = spec_prefix->list[d
    .seq].specimen_cd, apsi.suggested_flag = spec_prefix->list[d.seq].suggested_flag,
    apsi.sequence = spec_prefix->list[d.seq].sequence, apsi.cki_source = request->to_cki_source, apsi
    .cki_identifier = request->to_cki_identifier,
    apsi.updt_cnt = 1, apsi.updt_dt_tm = cnvtdatetime(curdate,curtime3), apsi.updt_id = reqinfo->
    updt_id,
    apsi.updt_task = reqinfo->updt_task, apsi.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (apsi)
   WITH nocounter
  ;end insert
  IF (((error(serror,0) > 0) OR (curqual != cnt)) )
   CALL subevent_add("INSERT","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
