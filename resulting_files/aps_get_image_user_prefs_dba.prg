CREATE PROGRAM aps_get_image_user_prefs:dba
 RECORD reply(
   1 person_id = f8
   1 group_qual[*]
     2 sequence = i4
     2 name = vc
     2 item_qual[*]
       3 sequence = i4
       3 name = vc
       3 type_flag = i2
       3 item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET nbr_groups = 0
 SET nbr_items = 0
 SET constant_item_type = 0
 SET folder_item_type = 1
 SET case_mode_type_flag = 1
 SET folder_mode_type_flag = 2
 SET retrieval_mode_type_flag = 3
 SET multi_image_type_flag = 4
 SET folder_type_flag = 5
 SELECT INTO "nl:"
  aigi.person_id, aigi.sequence, aiii.person_id,
  aiii.sequence, aiii_exists = decode(aiii.seq,1,0), af_exists = decode(af.seq,1,0),
  af.folder_id
  FROM ap_image_group_ini aigi,
   ap_image_item_ini aiii,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   ap_folder af
  PLAN (aigi
   WHERE (aigi.person_id=request->person_id))
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (aiii
   WHERE (aiii.person_id=request->person_id)
    AND aiii.parent_sequence=aigi.sequence)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (af
   WHERE aiii.parent_entity_name="AP_FOLDER"
    AND aiii.parent_entity_id=af.folder_id)
  ORDER BY aigi.sequence, aiii.sequence
  HEAD REPORT
   reply->person_id = aigi.person_id, stat = alterlist(reply->group_qual,5), nbr_groups = 0
  HEAD aigi.sequence
   nbr_groups = (nbr_groups+ 1)
   IF (mod(nbr_groups,5)=1
    AND nbr_groups != 1)
    stat = alterlist(reply->group_qual,(nbr_groups+ 4))
   ENDIF
   reply->group_qual[nbr_groups].sequence = aigi.sequence, reply->group_qual[nbr_groups].name = aigi
   .name, stat = alterlist(reply->group_qual[nbr_groups].item_qual,5),
   nbr_items = 0
  DETAIL
   IF (aiii_exists=1)
    IF (aiii.type_flag != folder_type_flag)
     nbr_items = (nbr_items+ 1)
     IF (mod(nbr_items,5)=1
      AND nbr_items != 1)
      stat = alterlist(reply->group_qual[nbr_groups].item_qual,(nbr_items+ 4))
     ENDIF
     reply->group_qual[nbr_groups].item_qual[nbr_items].sequence = aiii.sequence, reply->group_qual[
     nbr_groups].item_qual[nbr_items].name = aiii.name, reply->group_qual[nbr_groups].item_qual[
     nbr_items].type_flag = aiii.type_flag
    ELSE
     IF (af_exists=1
      AND aiii.type_flag=folder_type_flag)
      nbr_items = (nbr_items+ 1)
      IF (mod(nbr_items,5)=1
       AND nbr_items != 1)
       stat = alterlist(reply->group_qual[nbr_groups].item_qual,(nbr_items+ 4))
      ENDIF
      reply->group_qual[nbr_groups].item_qual[nbr_items].sequence = aiii.sequence, reply->group_qual[
      nbr_groups].item_qual[nbr_items].type_flag = aiii.type_flag, reply->group_qual[nbr_groups].
      item_qual[nbr_items].item_id = af.folder_id,
      reply->group_qual[nbr_groups].item_qual[nbr_items].name = af.folder_name
     ENDIF
    ENDIF
   ENDIF
  FOOT  aigi.sequence
   stat = alterlist(reply->group_qual[nbr_groups].item_qual,nbr_items)
  FOOT REPORT
   stat = alterlist(reply->group_qual,nbr_groups)
  WITH nocounter, outerjoin = d1, dontcare = aiii,
   outerjoin = d2
 ;end select
#exit_script
 IF (nbr_groups=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
