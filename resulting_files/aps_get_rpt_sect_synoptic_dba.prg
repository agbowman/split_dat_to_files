CREATE PROGRAM aps_get_rpt_sect_synoptic:dba
 RECORD reply(
   1 rpt_qual[*]
     2 scr_pattern_id = f8
     2 updt_cnt = i4
     2 catalog_cd = f8
     2 task_assay_cd = f8
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
 DECLARE nrptcount = i4 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 IF ((request->scr_pattern_id > 0))
  SELECT INTO "nl:"
   ap.*
   FROM ap_synoptic_rpt_section_r ap,
    scr_pattern scr
   PLAN (scr
    WHERE (scr.scr_pattern_id=request->scr_pattern_id))
    JOIN (ap
    WHERE ap.cki_source=scr.cki_source
     AND ap.cki_identifier=scr.cki_identifier)
   DETAIL
    nrptcount = (nrptcount+ 1)
    IF (mod(nrptcount,10)=1)
     stat = alterlist(reply->rpt_qual,(nrptcount+ 9))
    ENDIF
    reply->rpt_qual[nrptcount].scr_pattern_id = scr.scr_pattern_id, reply->rpt_qual[nrptcount].
    catalog_cd = ap.catalog_cd, reply->rpt_qual[nrptcount].task_assay_cd = ap.task_assay_cd,
    reply->rpt_qual[nrptcount].updt_cnt = ap.updt_cnt
   FOOT REPORT
    stat = alterlist(reply->rpt_qual,nrptcount)
   WITH nocounter
  ;end select
 ENDIF
 IF (nrptcount=0)
  CALL subevent_add("SELECT","F","TABLE","AP_SYNOPTIC_RPT_SECTION")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
