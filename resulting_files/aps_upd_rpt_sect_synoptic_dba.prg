CREATE PROGRAM aps_upd_rpt_sect_synoptic:dba
 RECORD reply(
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE nrptqualcnt = i4 WITH protect, noconstant(0)
 DECLARE nupdatecntmatch = i4 WITH protect, noconstant(0)
 DECLARE sfailed = c1 WITH protect, noconstant("N")
 DECLARE sckisource = vc WITH protect, noconstant("")
 DECLARE sckiidentifier = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET nrptqualcnt = size(request->rpt_qual,5)
 SELECT INTO "nl:"
  scr.*
  FROM scr_pattern scr
  PLAN (scr
   WHERE (scr.scr_pattern_id=request->scr_pattern_id))
  HEAD scr.scr_pattern_id
   sckisource = scr.cki_source, sckiidentifier = scr.cki_identifier
  WITH nocounter
 ;end select
 IF ((request->updt_cnt > - (1)))
  SELECT INTO "nl:"
   ap.*
   FROM ap_synoptic_rpt_section_r ap
   PLAN (ap
    WHERE ap.cki_source=sckisource
     AND ap.cki_identifier=sckiidentifier
     AND (ap.updt_cnt=request->updt_cnt))
   HEAD ap.cki_source
    nupdatecntmatch = (nupdatecntmatch+ 1)
   WITH nocounter, forupdate(ap)
  ;end select
  IF (nupdatecntmatch < 1)
   SET sfailed = "L"
   CALL subevent_add("LOCK","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
  ENDIF
  IF (sfailed="N")
   DELETE  FROM ap_synoptic_rpt_section_r ap
    PLAN (ap
     WHERE ap.cki_source=sckisource
      AND ap.cki_identifier=sckiidentifier)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET sfailed = "D"
    CALL subevent_add("DELETE","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
   ENDIF
  ENDIF
 ENDIF
 IF (sfailed="N"
  AND nrptqualcnt > 0)
  SET reply->updt_cnt = (request->updt_cnt+ 1)
  INSERT  FROM ap_synoptic_rpt_section_r ap,
    (dummyt d  WITH seq = value(nrptqualcnt))
   SET ap.cki_source = sckisource, ap.cki_identifier = sckiidentifier, ap.catalog_cd = request->
    rpt_qual[d.seq].catalog_cd,
    ap.task_assay_cd = request->rpt_qual[d.seq].task_assay_cd, ap.updt_cnt = reply->updt_cnt, ap
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (ap)
   WITH nocounter
  ;end insert
  IF (curqual != nrptqualcnt)
   SET sfailed = "I"
   CALL subevent_add("INSERT","F","TABLE","AP_SYNOPTIC_RPT_SECTION_R")
  ENDIF
 ENDIF
#exit_script
 IF (sfailed="N")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
