CREATE PROGRAM aps_upd_spec_synoptic:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD cki_key(
   1 upd_qual[*]
     2 worksheet_qual[*]
       3 cki_source = vc
       3 cki_identifier = vc
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
 DECLARE nupdqualcnt = i4 WITH protect, noconstant(0)
 DECLARE bupdatecntmatch = i4 WITH protect, noconstant(0)
 DECLARE sfailed = c1 WITH protect, noconstant("N")
 DECLARE updrow = i4 WITH protect, noconstant(0)
 DECLARE total_worksheets = i4 WITH protect, noconstant(0)
 DECLARE max_nbr_worksheets = i4 WITH protect, noconstant(0)
 DECLARE nbr_of_worksheets = i4 WITH protect, noconstant(0)
 DECLARE bupdateflag = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET nupdqualcnt = size(request->upd_qual,5)
 FOR (updrow = 1 TO nupdqualcnt)
   SET nbr_of_worksheets = size(request->upd_qual[updrow].worksheet_qual,5)
   IF (nbr_of_worksheets > max_nbr_worksheets)
    SET max_nbr_worksheets = nbr_of_worksheets
   ENDIF
   SET total_worksheets = (total_worksheets+ nbr_of_worksheets)
   IF ((request->upd_qual[updrow].updt_cnt > - (1)))
    SET bupdateflag = 1
   ENDIF
 ENDFOR
 IF (bupdateflag=1)
  SELECT INTO "nl:"
   d.seq
   FROM ap_synoptic_spec_prefix_r ap,
    (dummyt d  WITH seq = value(nupdqualcnt))
   PLAN (d
    WHERE (request->upd_qual[d.seq].updt_cnt > - (1)))
    JOIN (ap
    WHERE (ap.specimen_cd=request->upd_qual[d.seq].specimen_cd)
     AND (ap.updt_cnt=request->upd_qual[d.seq].updt_cnt))
   HEAD d.seq
    bupdatecntmatch = 1
   WITH nocounter, forupdate(ap)
  ;end select
  IF (bupdatecntmatch != 1)
   SET sfailed = "L"
   CALL subevent_add("LOCK","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
  ENDIF
  IF (sfailed="N")
   DELETE  FROM ap_synoptic_spec_prefix_r ap,
     (dummyt d  WITH seq = value(nupdqualcnt))
    SET ap.seq = 1
    PLAN (d)
     JOIN (ap
     WHERE (ap.specimen_cd=request->upd_qual[d.seq].specimen_cd))
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET sfailed = "D"
    CALL subevent_add("DELETE","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
   ENDIF
  ENDIF
 ENDIF
 IF (sfailed="N")
  SET stat = alterlist(cki_key->upd_qual,nupdqualcnt)
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(nupdqualcnt)),
    (dummyt d1  WITH seq = value(max_nbr_worksheets)),
    scr_pattern scr
   PLAN (d)
    JOIN (d1
    WHERE size(request->upd_qual[d.seq].worksheet_qual,5) >= d1.seq)
    JOIN (scr
    WHERE (scr.scr_pattern_id=request->upd_qual[d.seq].worksheet_qual[d1.seq].scr_pattern_id))
   DETAIL
    stat = alterlist(cki_key->upd_qual[d.seq].worksheet_qual,d1.seq), cki_key->upd_qual[d.seq].
    worksheet_qual[d1.seq].cki_source = scr.cki_source, cki_key->upd_qual[d.seq].worksheet_qual[d1
    .seq].cki_identifier = scr.cki_identifier
   WITH nocounter
  ;end select
  INSERT  FROM ap_synoptic_spec_prefix_r ap,
    (dummyt d  WITH seq = value(nupdqualcnt)),
    (dummyt d1  WITH seq = value(max_nbr_worksheets))
   SET ap.specimen_cd = request->upd_qual[d.seq].specimen_cd, ap.prefix_id = request->upd_qual[d.seq]
    .worksheet_qual[d1.seq].prefix_id, ap.cki_source = cki_key->upd_qual[d.seq].worksheet_qual[d1.seq
    ].cki_source,
    ap.cki_identifier = cki_key->upd_qual[d.seq].worksheet_qual[d1.seq].cki_identifier, ap
    .suggested_flag = request->upd_qual[d.seq].worksheet_qual[d1.seq].suggest_flag, ap.sequence =
    request->upd_qual[d.seq].worksheet_qual[d1.seq].sequence,
    ap.updt_cnt = (request->upd_qual[d.seq].updt_cnt+ 1), ap.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), ap.updt_id = reqinfo->updt_id,
    ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (d1
    WHERE size(request->upd_qual[d.seq].worksheet_qual,5) >= d1.seq)
    JOIN (ap)
   WITH nocounter
  ;end insert
  IF (curqual != total_worksheets)
   SET sfailed = "I"
   CALL subevent_add("INSERT","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
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
