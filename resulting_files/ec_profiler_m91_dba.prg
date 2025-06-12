CREATE PROGRAM ec_profiler_m91:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dradburned = f8 WITH noconstant(0.0)
 DECLARE dradanno = f8 WITH noconstant(0.0)
 DECLARE dradbdtemp = f8 WITH noconstant(0.0)
 DECLARE icnt = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE icur_list_size = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 DECLARE ifor_idx = i4 WITH noconstant(0)
 DECLARE bolnbrdiagind = i2 WITH noconstant(0)
 FREE RECORD xref_request
 RECORD xref_request(
   1 qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 content_types[*]
       3 dms_content_type_id = f8
 )
 FREE RECORD xref_reply
 RECORD xref_reply(
   1 qual[*]
     2 dms_media_instance_id = f8
     2 identifier = vc
     2 version = i4
     2 dms_content_type_id = f8
     2 content_uid = vc
     2 content_size = i4
     2 media_type = vc
     2 thumbnail_uid = vc
     2 created_dt_tm = dq8
     2 created_by_id = f8
     2 name = vc
     2 metadata_ver = i4
     2 metadata = vc
     2 xref[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 signatures[*]
       3 signature = vgc
     2 long_blob_id = f8
     2 status_flag = i2
     2 group_id = vc
     2 section_num = i4
     2 checksum = i4
     2 dms_repository_id = f8
     2 current_version = i4
     2 dicom_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD study_hold
 RECORD study_hold(
   1 qual[*]
     2 study_id = f8
 )
 SELECT INTO "nl:"
  FROM dm_columns_doc_local dm
  WHERE dm.table_name="RAD_FOLLOW_UP_CONTROL"
   AND dm.column_name="ONLINE_BREAST_DIAGRAM_IND"
  DETAIL
   bolnbrdiagind = 1
  WITH nocounter
 ;end select
 IF (bolnbrdiagind=1)
  SELECT INTO "nl:"
   FROM rad_follow_up_control fc
   WHERE fc.online_breast_diagram_ind=1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM dms_content_type dct
    WHERE dct.content_type_key IN ("RADBDBURNEDIMAGE", "RADBDANNOTATION", "RADBDTEMPLATE")
    DETAIL
     CASE (dct.content_type_key)
      OF "RADBDBURNEDIMAGE":
       dradburned = dct.dms_content_type_id
      OF "RADBDANNOTATION":
       dradanno = dct.dms_content_type_id
      OF "RADBDTEMPLATE":
       dradbdtemp = dct.dms_content_type_id
     ENDCASE
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM mammo_study ms
    WHERE ms.study_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm)
     AND ms.active_ind=1
    HEAD REPORT
     icnt = 0
    DETAIL
     icnt = (icnt+ 1)
     IF (mod(icnt,10)=1)
      stat = alterlist(study_hold->qual,(icnt+ 9))
     ENDIF
     study_hold->qual[icnt].study_id = ms.study_id
    FOOT REPORT
     stat = alterlist(study_hold->qual,icnt)
    WITH nocounter
   ;end select
   SET icnt = 0
   FOR (idx = 1 TO size(study_hold->qual,5))
     SET icnt = (icnt+ 1)
     IF (mod(icnt,10)=1)
      SET stat = alterlist(xref_request->qual,(icnt+ 9))
     ENDIF
     SET xref_request->qual[icnt].parent_entity_id = study_hold->qual[idx].study_id
     SET xref_request->qual[icnt].parent_entity_name = "MAMMO_STUDY"
     SET stat = alterlist(xref_request->qual[icnt].content_types,3)
     SET xref_request->qual[icnt].content_types[1].dms_content_type_id = dradburned
     SET xref_request->qual[icnt].content_types[2].dms_content_type_id = dradanno
     SET xref_request->qual[icnt].content_types[3].dms_content_type_id = dradbdtemp
   ENDFOR
   SET stat = alterlist(xref_request->qual,icnt)
   SET trace = nocost
   SET message = noinformation
   SET trace = nocallecho
   EXECUTE dms_get_media_by_xref  WITH replace("REQUEST","XREF_REQUEST"), replace("REPLY",
    "XREF_REPLY")
   SET trace = cost
   SET message = information
   SET trace = callecho
   IF ((xref_reply->status_data.status="S"))
    SET stat = alterlist(study_hold->qual,0)
    SET icnt = 0
    FOR (idx = 1 TO size(xref_reply->qual,5))
      FOR (idx2 = 1 TO size(xref_reply->qual[idx].xref,5))
        SET icnt = (icnt+ 1)
        IF (mod(icnt,10)=1)
         SET stat = alterlist(study_hold->qual,(icnt+ 9))
        ENDIF
        SET study_hold->qual[icnt].study_id = xref_reply->qual[idx].xref[idx2].parent_entity_id
      ENDFOR
    ENDFOR
    SET icur_list_size = size(study_hold->qual,5)
    SET iloop_cnt = ceil((cnvtreal(icur_list_size)/ ibatch_size))
    SELECT INTO "nl:"
     FROM mammo_study ms,
      encounter e,
      (dummyt d  WITH seq = value(iloop_cnt))
     PLAN (d
      WHERE initarray(istart,evaluate(d.seq,1,1,(istart+ ibatch_size))))
      JOIN (ms
      WHERE expand(iexpandidx,istart,minval((istart+ (ibatch_size - 1)),icur_list_size),ms.study_id,
       study_hold->qual[iexpandidx].study_id))
      JOIN (e
      WHERE e.encntr_id=ms.encntr_id
       AND e.active_ind=1)
     ORDER BY e.loc_facility_cd, e.encntr_id
     HEAD e.loc_facility_cd
      facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
       reply->facilities,facilitycnt),
      reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd, reply->facilities[facilitycnt].
      position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
      reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
      positions[1].capability_in_use_ind = 1, encntrcnt = 0
     HEAD e.encntr_id
      encntrcnt = (encntrcnt+ 1)
     FOOT  e.loc_facility_cd
      detailcnt = (reply->facilities[facilitycnt].positions[1].detail_cnt+ 1), reply->facilities[
      facilitycnt].positions[1].detail_cnt = detailcnt, stat = alterlist(reply->facilities[
       facilitycnt].positions[1].details,detailcnt),
      reply->facilities[facilitycnt].positions[1].details[detailcnt].detail_name = "", reply->
      facilities[facilitycnt].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(
        encntrcnt))
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
