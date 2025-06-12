CREATE PROGRAM dcp_del_prsnl_loc_temp_reltn
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE listsize = i4
 SET listsize = size(request->relation_list,5)
 IF (listsize > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(listsize)),
    note_type_template_reltn nttr
   PLAN (d1
    WHERE (request->relation_list[d1.seq].note_type_template_reltn_id=0))
    JOIN (nttr
    WHERE (nttr.note_type_id=request->relation_list[d1.seq].note_type_id)
     AND (nttr.template_id=request->relation_list[d1.seq].template_id)
     AND nttr.note_type_template_reltn_id > 0)
   DETAIL
    request->relation_list[d1.seq].note_type_template_reltn_id = nttr.note_type_template_reltn_id
   WITH nocounter
  ;end select
  DELETE  FROM prsnl_loc_template_reltn pltr,
    (dummyt d  WITH seq = value(listsize))
   SET pltr.seq = 1
   PLAN (d)
    JOIN (pltr
    WHERE (pltr.note_type_template_reltn_id=request->relation_list[d.seq].note_type_template_reltn_id
    )
     AND (pltr.prsnl_id=request->relation_list[d.seq].prsnl_id)
     AND (pltr.location_cd=request->relation_list[d.seq].location_cd))
  ;end delete
 ENDIF
 IF (curqual=listsize)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
