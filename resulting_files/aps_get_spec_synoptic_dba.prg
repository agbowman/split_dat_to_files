CREATE PROGRAM aps_get_spec_synoptic:dba
 RECORD reply(
   1 spec_qual[*]
     2 specimen_cd = f8
     2 prefix_id = f8
     2 scr_pattern_id = f8
     2 suggest_flag = i2
     2 sequence = i2
     2 updt_cnt = i4
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
 DECLARE nspeccount = i4 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 IF ((request->specimen_cd > 0))
  SELECT INTO "nl:"
   ap.specimen_cd, pfx_name = trim(pr.prefix_name,3), ap.sequence
   FROM ap_synoptic_spec_prefix_r ap,
    ap_prefix pr,
    scr_pattern scr,
    dummyt d
   PLAN (ap
    WHERE (request->specimen_cd=ap.specimen_cd))
    JOIN (pr
    WHERE ap.prefix_id=pr.prefix_id)
    JOIN (d)
    JOIN (scr
    WHERE scr.cki_source=ap.cki_source
     AND scr.cki_identifier=ap.cki_identifier)
   ORDER BY ap.specimen_cd, pfx_name, ap.sequence
   DETAIL
    nspeccount = (nspeccount+ 1)
    IF (mod(nspeccount,10)=1)
     stat = alterlist(reply->spec_qual,(nspeccount+ 9))
    ENDIF
    reply->spec_qual[nspeccount].specimen_cd = ap.specimen_cd, reply->spec_qual[nspeccount].prefix_id
     = ap.prefix_id
    IF (trim(ap.cki_identifier) != ""
     AND scr.scr_pattern_id=0)
     reply->spec_qual[nspeccount].scr_pattern_id = - (1)
    ELSEIF (trim(ap.cki_identifier) != "")
     reply->spec_qual[nspeccount].scr_pattern_id = scr.scr_pattern_id
    ELSE
     reply->spec_qual[nspeccount].scr_pattern_id = 0
    ENDIF
    reply->spec_qual[nspeccount].suggest_flag = ap.suggested_flag, reply->spec_qual[nspeccount].
    sequence = ap.sequence, reply->spec_qual[nspeccount].updt_cnt = ap.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->spec_qual,nspeccount)
   WITH nocounter, outerjoin = d
  ;end select
 ENDIF
 IF (nspeccount=0)
  CALL subevent_add("SELECT","F","TABLE","AP_SYNOPTIC_SPEC_PREFIX_R")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
