CREATE PROGRAM bed_get_pref_frames:dba
 DECLARE requestframetypescount = i4
 DECLARE replyframetypescount = i4
 DECLARE replyviewnamescount = i4
 DECLARE errormsg = vc
 DECLARE frame_types_list_expand_size = i4
 DECLARE view_names_list_expand_size = i4
 DECLARE populateframesviews(positioncd=f8) = null
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 is_global = i2
    1 frame_types[*]
      2 frame_type = vc
      2 view_names[*]
        3 view_prefs_id = f8
        3 view_name = vc
        3 display_seq = vc
        3 view_caption = vc
        3 view_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 CALL echo("Entry Point")
 IF ( NOT (validate(request,0)))
  GO TO fail_exit
 ENDIF
 IF ((request->application_number=0))
  GO TO fail_exit
 ENDIF
 SET frame_types_list_expand_size = 5
 SET view_names_list_expand_size = 10
 SET requestframetypescount = size(request->frame_types,5)
 IF (requestframetypescount < 1)
  GO TO fail_exit
 ENDIF
 SET reply->is_global = 0
 CALL populateframesviews(request->position_code_value)
 IF (size(reply->frame_types,5)=0
  AND (request->position_code_value != cnvtreal(0)))
  CALL populateframesviews(cnvtreal(0))
 ENDIF
#success_exit
 SET reply->status_data.status = "S"
 GO TO exit_program
#fail_exit
 SET reply->status_data.status = "F"
 SET reply->error_msg = errormsg
 GO TO exit_program
 SUBROUTINE populateframesviews(positioncd)
  IF (positioncd=cnvtreal(0))
   SET reply->is_global = 1
  ENDIF
  SELECT INTO "nl:"
   FROM view_prefs vp,
    name_value_prefs nvp,
    name_value_prefs nvp2,
    (dummyt d  WITH seq = value(requestframetypescount))
   PLAN (d)
    JOIN (vp
    WHERE (vp.application_number=request->application_number)
     AND vp.position_cd=positioncd
     AND vp.active_ind=1
     AND (vp.frame_type=request->frame_types[d.seq].frame_type)
     AND vp.prsnl_id=0)
    JOIN (nvp2
    WHERE nvp2.parent_entity_name=outerjoin("VIEW_PREFS")
     AND nvp2.parent_entity_id=outerjoin(vp.view_prefs_id)
     AND trim(nvp2.pvc_name)=outerjoin("DISPLAY_SEQ"))
    JOIN (nvp
    WHERE nvp.parent_entity_name=outerjoin("VIEW_PREFS")
     AND nvp.parent_entity_id=outerjoin(vp.view_prefs_id)
     AND trim(nvp.pvc_name)=outerjoin("VIEW_CAPTION"))
   ORDER BY vp.frame_type
   HEAD REPORT
    stat = alterlist(reply->frame_types,frame_types_list_expand_size), replyframetypescount = 0
   HEAD vp.frame_type
    replyviewnamescount = 0, replyframetypescount = (replyframetypescount+ 1)
    IF (mod(replyframetypescount,frame_types_list_expand_size)=0)
     stat = alterlist(reply->frame_types,(replyframetypescount+ frame_types_list_expand_size))
    ENDIF
    reply->frame_types[replyframetypescount].frame_type = vp.frame_type, stat2 = alterlist(reply->
     frame_types[replyframetypescount].view_names,view_names_list_expand_size)
   DETAIL
    replyviewnamescount = (replyviewnamescount+ 1)
    IF (mod(replyviewnamescount,view_names_list_expand_size)=0)
     stat = alterlist(reply->frame_types[replyframetypescount].view_names,(replyviewnamescount+
      view_names_list_expand_size))
    ENDIF
    reply->frame_types[replyframetypescount].view_names[replyviewnamescount].view_prefs_id = vp
    .view_prefs_id, reply->frame_types[replyframetypescount].view_names[replyviewnamescount].
    view_name = vp.view_name, reply->frame_types[replyframetypescount].view_names[replyviewnamescount
    ].display_seq = nvp2.pvc_value,
    reply->frame_types[replyframetypescount].view_names[replyviewnamescount].view_caption = nvp
    .pvc_value, reply->frame_types[replyframetypescount].view_names[replyviewnamescount].view_seq =
    vp.view_seq
   FOOT  vp.frame_type
    stat = alterlist(reply->frame_types[replyframetypescount].view_names,replyviewnamescount)
   FOOT REPORT
    stat = alterlist(reply->frame_types,replyframetypescount)
   WITH format, separator = " "
  ;end select
 END ;Subroutine
#exit_program
END GO
