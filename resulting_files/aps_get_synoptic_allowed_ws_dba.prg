CREATE PROGRAM aps_get_synoptic_allowed_ws:dba
 IF ((validate(reply->curqual,- (99))=- (99)))
  RECORD reply(
    1 ws_qual[*]
      2 scr_pattern_id = f8
      2 scr_pattern_disp = c40
      2 task_assay_cd = f8
      2 sequence = i2
      2 pattern_description = vc
      2 pattern_cki_source = vc
      2 pattern_cki_identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE nwscount = i4 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 IF ((request->specimen_cd > 0))
  SELECT INTO "nl:"
   ap.*
   FROM ap_synoptic_spec_prefix_r ap,
    ap_synoptic_rpt_section_r ar,
    scr_pattern scr
   PLAN (ap
    WHERE (request->specimen_cd=ap.specimen_cd)
     AND ((ap.suggested_flag=1) OR ((request->default_only_flag=0)))
     AND (((request->prefix_id=ap.prefix_id)) OR (ap.prefix_id=0
     AND  NOT ( EXISTS (
    (SELECT
     aa.prefix_id
     FROM ap_synoptic_spec_prefix_r aa
     WHERE (request->prefix_id=aa.prefix_id)
      AND (request->specimen_cd=aa.specimen_cd)))))) )
    JOIN (ar
    WHERE ap.cki_source=ar.cki_source
     AND ap.cki_identifier=ar.cki_identifier
     AND (request->catalog_cd=ar.catalog_cd))
    JOIN (scr
    WHERE scr.cki_source=ap.cki_source
     AND scr.cki_identifier=ap.cki_identifier)
   ORDER BY ap.sequence
   DETAIL
    nwscount = (nwscount+ 1)
    IF (mod(nwscount,10)=1)
     stat = alterlist(reply->ws_qual,(nwscount+ 9))
    ENDIF
    reply->ws_qual[nwscount].scr_pattern_id = scr.scr_pattern_id, reply->ws_qual[nwscount].
    scr_pattern_disp = scr.display, reply->ws_qual[nwscount].sequence = ap.sequence,
    reply->ws_qual[nwscount].task_assay_cd = ar.task_assay_cd, reply->ws_qual[nwscount].
    pattern_description = scr.definition, reply->ws_qual[nwscount].pattern_cki_source = scr
    .cki_source,
    reply->ws_qual[nwscount].pattern_cki_identifier = scr.cki_identifier
   FOOT REPORT
    stat = alterlist(reply->ws_qual,nwscount)
   WITH nocounter
  ;end select
 ENDIF
 IF (nwscount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
