CREATE PROGRAM aps_get_child_proc_tasks:dba
 RECORD reply(
   1 case_id = f8
   1 spec_qual[*]
     2 specimen_id = f8
     2 spec_tag = c7
     2 spec_tag_sequence = i4
     2 spec_barcode = vc
     2 spec_cd = f8
     2 spec_disp = vc
     2 spec_descr = vc
     2 cass_qual[*]
       3 cassette_id = f8
       3 cass_tag = c7
       3 cass_tag_seq = i4
       3 cass_path = vc
       3 cass_barcode = vc
       3 cass_pieces = c3
       3 slide_qual[*]
         4 slide_id = f8
         4 slide_tag = c7
         4 slide_tag_seq = i4
         4 slide_path = vc
         4 slide_barcode = vc
     2 slide_qual[*]
       3 slide_id = f8
       3 slide_tag = c7
       3 slide_tag_seq = i4
       3 slide_path = vc
       3 slide_barcode = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD tempreq(
   1 qual[*]
     2 item_id = f8
     2 unformatted_accn = vc
     2 specimen_tag_seq = i4
     2 cassette_tag_seq = i4
     2 slide_tag_seq = i4
     2 container_nbr = i4
 )
 RECORD temprep(
   1 qual[*]
     2 item_id = f8
     2 barcode_string = vc
     2 truncated_barcode_accn = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE sblockseparator = vc WITH public
 DECLARE sslideseparator = vc WITH public
 DECLARE sslidepath = vc WITH public
 DECLARE scasspath = vc WITH public
 DECLARE sunformattedaccn = vc WITH public
 DECLARE dserviceresourcecd = f8 WITH public
 DECLARE ninvcnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE k = i4 WITH protect, noconstant(0)
 DECLARE l = i4 WITH protect, noconstant(0)
 DECLARE code_cancel = f8 WITH constant(uar_get_code_by("MEANING",1305,"CANCEL")), public
 DECLARE nprefinstrumentcancel = i2 WITH public, noconstant(0)
 DECLARE getbarcodes(null) = null WITH protect
#script
 SET reply->status_data.status = "F"
 IF ((request->case_id=0.0))
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM pathology_case pc,
   ap_prefix_tag_group_r aptgr,
   ap_prefix ap
  PLAN (pc
   WHERE (pc.case_id=request->case_id))
   JOIN (aptgr
   WHERE aptgr.prefix_id=pc.prefix_id)
   JOIN (ap
   WHERE ap.prefix_id=pc.prefix_id)
  ORDER BY pc.case_id
  HEAD pc.case_id
   sunformattedaccn = pc.accession_nbr
   IF ((request->interface_type_flag=2))
    dserviceresourcecd = ap.imaging_service_resource_cd
   ELSE
    dserviceresourcecd = ap.tracking_service_resource_cd
   ENDIF
  DETAIL
   CASE (aptgr.tag_type_flag)
    OF 2:
     sblockseparator = aptgr.tag_separator
    OF 3:
     sslideseparator = aptgr.tag_separator
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_group cvr
  WHERE cvr.child_code_value=dserviceresourcecd
   AND  EXISTS (
  (SELECT
   cve.field_value
   FROM code_value_extension cve
   WHERE cve.code_value=cvr.parent_code_value
    AND cve.field_name="CANCEL_SENDS_CHILD_INVENTORY"
    AND cve.code_set=2074
    AND cve.field_value="1"))
  DETAIL
   nprefinstrumentcancel = 1
  WITH nocounter
 ;end select
 IF (nprefinstrumentcancel=0)
  SET reply->status_data.status = "S"
  GO TO exit_program
 ENDIF
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt += 1
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_program
 ENDIF
 SET reply->case_id = request->case_id
 IF ((request->hierarchy_leaf_flag=1))
  SET stat = getspecimens(reply->case_id)
 ELSEIF ((request->hierarchy_leaf_flag=2))
  FOR (i = 1 TO size(request->spec_qual,5))
   SET stat = alterlist(reply->spec_qual,i)
   SET reply->spec_qual[i].specimen_id = request->spec_qual[i].specimen_id
  ENDFOR
  SET stat = getcassetteforspecimens(reply->case_id)
  SET stat = getslidesforspecimens(reply->case_id)
 ELSEIF ((request->hierarchy_leaf_flag=3))
  FOR (i = 1 TO size(request->spec_qual,5))
    SET stat = alterlist(reply->spec_qual,i)
    SET reply->spec_qual[i].specimen_id = request->spec_qual[i].specimen_id
    FOR (j = 1 TO size(request->spec_qual[i].cass_qual,5))
     SET stat = alterlist(reply->spec_qual[i].cass_qual,j)
     SET reply->spec_qual[i].cass_qual[j].cassette_id = request->spec_qual[i].cass_qual[j].
     cassette_id
    ENDFOR
    SET stat = getslidesforcassettes(reply->case_id,reply->spec_qual[i].specimen_id)
  ENDFOR
 ENDIF
 IF (size(tempreq->qual,5) > 0)
  CALL getbarcodes(null)
  SET reply->status_data.status = "S"
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE (getslidesforcassettes(case_id=f8,specimen_id=f8) =null WITH protect)
   DECLARE spec_idx = i4 WITH protect, noconstant(0)
   IF (((case_id=0) OR (specimen_id=0)) )
    RETURN
   ENDIF
   SET spec_idx = locateval(idx1,1,size(reply->spec_qual,5),specimen_id,reply->spec_qual[idx1].
    specimen_id)
   IF (spec_idx=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM processing_task pt,
     slide s
    PLAN (pt
     WHERE pt.case_id=case_id
      AND pt.case_specimen_id=specimen_id
      AND expand(idx,1,size(reply->spec_qual[spec_idx].cass_qual,5),pt.cassette_id,reply->spec_qual[
      spec_idx].cass_qual[idx].cassette_id)
      AND pt.create_inventory_flag IN (2, 3)
      AND pt.status_cd != code_cancel
      AND pt.slide_id != 0.0)
     JOIN (s
     WHERE s.slide_id=pt.slide_id)
    ORDER BY pt.cassette_id, pt.slide_id
    HEAD REPORT
     cass_idx = 0, ap_tag_slide_idx = 0, ap_tag_cass_idx = 0,
     ap_tag_spec_idx = 0
    HEAD pt.cassette_id
     cnt = 0
    HEAD pt.slide_id
     cass_idx = locateval(idx1,1,size(reply->spec_qual[spec_idx].cass_qual,5),pt.cassette_id,reply->
      spec_qual[spec_idx].cass_qual[idx1].cassette_id)
     IF (cass_idx > 0)
      cnt += 1, stat = alterlist(reply->spec_qual[spec_idx].cass_qual[cass_idx].slide_qual,cnt),
      reply->spec_qual[spec_idx].cass_qual[cass_idx].slide_qual[cnt].slide_id = s.slide_id,
      ap_tag_slide_idx = locateval(idx1,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx1].tag_id),
      ap_tag_cass_idx = locateval(idx1,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx1].tag_id
       ), ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[
       idx1].tag_id)
      IF (ap_tag_slide_idx > 0
       AND ap_tag_cass_idx > 0
       AND ap_tag_spec_idx > 0)
       reply->spec_qual[spec_idx].cass_qual[cass_idx].slide_qual[cnt].slide_tag = temp_ap_tag->qual[
       ap_tag_slide_idx].tag_disp, reply->spec_qual[spec_idx].cass_qual[cass_idx].slide_qual[cnt].
       slide_tag_seq = temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence, reply->spec_qual[spec_idx].
       cass_qual[cass_idx].cass_tag = temp_ap_tag->qual[ap_tag_cass_idx].tag_disp,
       reply->spec_qual[spec_idx].cass_qual[cass_idx].cass_tag_seq = temp_ap_tag->qual[
       ap_tag_cass_idx].tag_sequence, reply->spec_qual[spec_idx].spec_tag = temp_ap_tag->qual[
       ap_tag_spec_idx].tag_disp, reply->spec_qual[spec_idx].spec_tag_sequence = temp_ap_tag->qual[
       ap_tag_spec_idx].tag_sequence,
       sl_path = concat(trim(reply->spec_qual[spec_idx].spec_tag),sblockseparator,trim(reply->
         spec_qual[spec_idx].cass_qual[cass_idx].cass_tag),sslideseparator,trim(reply->spec_qual[
         spec_idx].cass_qual[cass_idx].slide_qual[cnt].slide_tag)), reply->spec_qual[spec_idx].
       cass_qual[cass_idx].slide_qual[cnt].slide_path = sl_path, ninvcnt += 1,
       stat = alterlist(tempreq->qual,ninvcnt), tempreq->qual[ninvcnt].unformatted_accn =
       sunformattedaccn, tempreq->qual[ninvcnt].item_id = reply->spec_qual[spec_idx].cass_qual[
       cass_idx].slide_qual[cnt].slide_id,
       tempreq->qual[ninvcnt].specimen_tag_seq = reply->spec_qual[spec_idx].spec_tag_sequence,
       tempreq->qual[ninvcnt].cassette_tag_seq = reply->spec_qual[spec_idx].cass_qual[cass_idx].
       cass_tag_seq, tempreq->qual[ninvcnt].slide_tag_seq = reply->spec_qual[spec_idx].cass_qual[
       cass_idx].slide_qual[cnt].slide_tag_seq
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getcassetteforspecimens(case_id=f8) =null WITH protect)
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   IF (case_id=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM processing_task pt,
     cassette c
    PLAN (pt
     WHERE pt.case_id=case_id
      AND expand(idx,1,size(reply->spec_qual,5),pt.case_specimen_id,reply->spec_qual[idx].specimen_id
      )
      AND pt.create_inventory_flag IN (1, 3)
      AND pt.status_cd != code_cancel
      AND pt.cassette_id != 0.0)
     JOIN (c
     WHERE c.cassette_id=pt.cassette_id)
    ORDER BY pt.case_specimen_id, pt.cassette_id
    HEAD REPORT
     spec_idx = 0, ap_tag_cass_idx = 0, ap_tag_spec_idx = 0
    HEAD pt.case_specimen_id
     cnt = 0
    HEAD pt.cassette_id
     spec_idx = locateval(idx1,1,size(reply->spec_qual,5),pt.case_specimen_id,reply->spec_qual[idx1].
      specimen_id)
     IF (spec_idx > 0)
      cnt += 1, stat = alterlist(reply->spec_qual[spec_idx].cass_qual,cnt), reply->spec_qual[spec_idx
      ].cass_qual[cnt].cassette_id = pt.cassette_id,
      reply->spec_qual[spec_idx].cass_qual[cnt].cass_pieces = c.pieces, ap_tag_spec_idx = locateval(
       idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].tag_id), ap_tag_cass_idx =
      locateval(idx1,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx1].tag_id)
      IF (ap_tag_cass_idx > 0
       AND ap_tag_spec_idx > 0)
       reply->spec_qual[spec_idx].cass_qual[cnt].cass_tag = temp_ap_tag->qual[ap_tag_cass_idx].
       tag_disp, reply->spec_qual[spec_idx].cass_qual[cnt].cass_tag_seq = temp_ap_tag->qual[
       ap_tag_cass_idx].tag_sequence, reply->spec_qual[spec_idx].spec_tag = temp_ap_tag->qual[
       ap_tag_spec_idx].tag_disp,
       reply->spec_qual[spec_idx].spec_tag_sequence = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence,
       scasspath = concat(trim(reply->spec_qual[spec_idx].spec_tag),sblockseparator,trim(reply->
         spec_qual[spec_idx].cass_qual[cnt].cass_tag)), reply->spec_qual[spec_idx].cass_qual[cnt].
       cass_path = scasspath,
       ninvcnt += 1, stat = alterlist(tempreq->qual,ninvcnt), tempreq->qual[ninvcnt].unformatted_accn
        = sunformattedaccn,
       tempreq->qual[ninvcnt].item_id = reply->spec_qual[spec_idx].cass_qual[cnt].cassette_id,
       tempreq->qual[ninvcnt].specimen_tag_seq = reply->spec_qual[spec_idx].spec_tag_sequence,
       tempreq->qual[ninvcnt].cassette_tag_seq = reply->spec_qual[spec_idx].cass_qual[cnt].
       cass_tag_seq
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FOR (s_idx = 1 TO size(reply->spec_qual,5))
     CALL getslidesforcassettes(reply->case_id,reply->spec_qual[s_idx].specimen_id)
   ENDFOR
   RETURN
 END ;Subroutine
 SUBROUTINE (getslidesforspecimens(case_id=f8) =null WITH protect)
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   DECLARE trackingsendslidefromspecflag = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value_group cvr
    WHERE cvr.child_code_value=dserviceresourcecd
     AND  EXISTS (
    (SELECT
     cve.field_value
     FROM code_value_extension cve
     WHERE cve.code_value=cvr.parent_code_value
      AND cve.field_name="SEND_SLIDE_FROM_SPECIMEN"
      AND cve.code_set=2074
      AND cve.field_value="1"))
    DETAIL
     trackingsendslidefromspecflag = 1
    WITH nocounter
   ;end select
   IF (((case_id=0) OR ((request->interface_type_flag=1)
    AND trackingsendslidefromspecflag=0)) )
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM processing_task pt,
     slide s
    PLAN (pt
     WHERE pt.case_id=case_id
      AND expand(idx,1,size(reply->spec_qual,5),pt.case_specimen_id,reply->spec_qual[idx].specimen_id
      )
      AND pt.cassette_id=0.0
      AND pt.create_inventory_flag IN (2)
      AND pt.status_cd != code_cancel
      AND pt.slide_id != 0.0)
     JOIN (s
     WHERE s.slide_id=pt.slide_id)
    ORDER BY pt.slide_id
    HEAD REPORT
     spec_idx = 0, ap_tag_slide_idx = 0, ap_tag_spec_idx = 0,
     spec_idx = 0
    HEAD pt.case_specimen_id
     cnt = 0
    HEAD pt.slide_id
     spec_idx = locateval(idx1,1,size(reply->spec_qual,5),pt.case_specimen_id,reply->spec_qual[idx1].
      specimen_id)
     IF (spec_idx > 0)
      cnt += 1, stat = alterlist(reply->spec_qual[spec_idx].slide_qual,cnt), reply->spec_qual[
      spec_idx].slide_qual[cnt].slide_id = s.slide_id,
      ap_tag_slide_idx = locateval(idx1,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx1].tag_id),
      ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
       tag_id)
      IF (ap_tag_slide_idx > 0
       AND pt.cassette_tag_id=0
       AND ap_tag_spec_idx > 0)
       reply->spec_qual[spec_idx].slide_qual[cnt].slide_tag = temp_ap_tag->qual[ap_tag_slide_idx].
       tag_disp, reply->spec_qual[spec_idx].slide_qual[cnt].slide_tag_seq = temp_ap_tag->qual[
       ap_tag_slide_idx].tag_sequence, reply->spec_qual[spec_idx].spec_tag = temp_ap_tag->qual[
       ap_tag_spec_idx].tag_disp,
       reply->spec_qual[spec_idx].spec_tag_sequence = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence,
       sl_path = concat(trim(reply->spec_qual[spec_idx].spec_tag),sblockseparator,sslideseparator,
        trim(reply->spec_qual[spec_idx].slide_qual[cnt].slide_tag)), reply->spec_qual[spec_idx].
       slide_qual[cnt].slide_path = sl_path,
       ninvcnt += 1, stat = alterlist(tempreq->qual,ninvcnt), tempreq->qual[ninvcnt].unformatted_accn
        = sunformattedaccn,
       tempreq->qual[ninvcnt].item_id = reply->spec_qual[spec_idx].slide_qual[cnt].slide_id, tempreq
       ->qual[ninvcnt].specimen_tag_seq = reply->spec_qual[spec_idx].spec_tag_sequence, tempreq->
       qual[ninvcnt].cassette_tag_seq = 0,
       tempreq->qual[ninvcnt].slide_tag_seq = reply->spec_qual[spec_idx].slide_qual[cnt].
       slide_tag_seq
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getspecimens(case_id=f8) =null WITH protect)
   IF (case_id=0)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM processing_task pt,
     case_specimen cs
    PLAN (pt
     WHERE pt.case_id=case_id
      AND pt.create_inventory_flag=4
      AND pt.status_cd != code_cancel)
     JOIN (cs
     WHERE cs.case_specimen_id=pt.case_specimen_id)
    HEAD REPORT
     cnt = 0, ap_tag_spec_idx = 0
    DETAIL
     cnt += 1, stat = alterlist(reply->spec_qual,cnt), reply->spec_qual[cnt].specimen_id = pt
     .case_specimen_id,
     reply->spec_qual[cnt].spec_cd = cs.specimen_cd, reply->spec_qual[cnt].spec_disp =
     uar_get_code_display(cs.specimen_cd), reply->spec_qual[cnt].spec_descr = cs.specimen_description,
     ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,cs.specimen_tag_id,temp_ap_tag->qual[idx1].tag_id)
     IF (ap_tag_spec_idx > 0)
      reply->spec_qual[cnt].spec_tag = temp_ap_tag->qual[ap_tag_spec_idx].tag_disp, reply->spec_qual[
      cnt].spec_tag_sequence = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence, ninvcnt += 1,
      stat = alterlist(tempreq->qual,ninvcnt), tempreq->qual[ninvcnt].unformatted_accn =
      sunformattedaccn, tempreq->qual[ninvcnt].item_id = reply->spec_qual[cnt].specimen_id,
      tempreq->qual[ninvcnt].specimen_tag_seq = reply->spec_qual[cnt].spec_tag_sequence
     ENDIF
    WITH nocounter
   ;end select
   CALL getcassetteforspecimens(reply->case_id)
   CALL getslidesforspecimens(reply->case_id)
   RETURN
 END ;Subroutine
 SUBROUTINE getbarcodes(null)
   IF (ninvcnt > 0)
    EXECUTE aps_get_inventory_barcode  WITH replace("REQUEST",tempreq), replace("REPLY",temprep)
    IF ((temprep->status_data.status != "S"))
     RETURN
    ENDIF
    FOR (l = 1 TO size(temprep->qual,5))
      FOR (i = 1 TO size(reply->spec_qual,5))
        IF ((temprep->qual[l].item_id=reply->spec_qual[i].specimen_id))
         SET reply->spec_qual[i].spec_barcode = temprep->qual[l].barcode_string
        ENDIF
        FOR (j = 1 TO size(reply->spec_qual[i].cass_qual,5))
         IF ((temprep->qual[l].item_id=reply->spec_qual[i].cass_qual[j].cassette_id))
          SET reply->spec_qual[i].cass_qual[j].cass_barcode = temprep->qual[l].barcode_string
         ENDIF
         FOR (k = 1 TO size(reply->spec_qual[i].cass_qual[j].slide_qual,5))
           IF ((temprep->qual[l].item_id=reply->spec_qual[i].cass_qual[j].slide_qual[k].slide_id))
            SET reply->spec_qual[i].cass_qual[j].slide_qual[k].slide_barcode = temprep->qual[l].
            barcode_string
           ENDIF
         ENDFOR
        ENDFOR
        FOR (k = 1 TO size(reply->spec_qual[i].slide_qual,5))
          IF ((temprep->qual[l].item_id=reply->spec_qual[i].slide_qual[k].slide_id))
           SET reply->spec_qual[i].slide_qual[k].slide_barcode = temprep->qual[l].barcode_string
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
 END ;Subroutine
#exit_program
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
 FREE RECORD tempreq
 FREE RECORD temprep
END GO
