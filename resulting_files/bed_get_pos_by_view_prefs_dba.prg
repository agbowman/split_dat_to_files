CREATE PROGRAM bed_get_pos_by_view_prefs:dba
 RECORD view_hier(
   1 views[*]
     2 view_name = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 targets[*]
      2 global_indicator = i2
      2 position_code_value = f8
      2 position_display = vc
      2 views[*]
        3 view_prefs_id = f8
        3 view_name = vc
        3 view_caption = vc
        3 view_seq = i4
        3 display_seq = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD global_views(
   1 views[*]
     2 view_prefs_id = f8
     2 view_name = vc
     2 view_caption = vc
     2 view_seq = i4
     2 display_seq = vc
 )
 RECORD temp_pos(
   1 positions[*]
     2 pos_code_value = f8
 )
 RECORD temp_prefs_ids(
   1 prefs_ids[*]
     2 prefs_id = f8
 )
 DECLARE findpositions(isglobal=i2,islevel2=i2) = null
 DECLARE fillupglobalpositions(appnum=i4) = i4
 DECLARE counter = i4
 DECLARE targetcount = i4
 DECLARE viewscount = i4
 DECLARE lastview = vc
 DECLARE is_level2 = i2
 DECLARE globalexists = i2
 DECLARE countpos = i4
 DECLARE num = i4
 DECLARE countglobals = i4
 DECLARE temppos = f8
 DECLARE expand_size = i4
 SET globalexists = 0
 SET targetcount = 0
 SET expand_size = 10
 SELECT INTO "nl:"
  FROM view_prefs vp
  WHERE (vp.view_prefs_id=request->view_prefs_id)
  HEAD REPORT
   stat = alterlist(view_hier->views,2), counter = 2, is_level2 = 1
  DETAIL
   view_hier->views[1].view_name = vp.view_name, view_hier->views[2].view_name = vp.frame_type,
   lastview = vp.frame_type,
   temppos = vp.position_cd
  WITH nocounter
 ;end select
 FOR (ind = 1 TO size(request->root_frame_types,5))
   IF ((lastview=request->root_frame_types[ind].frame_type))
    SET is_level2 = 0
   ENDIF
 ENDFOR
 IF (is_level2=1)
  SELECT INTO "nl"
   FROM view_prefs vp
   WHERE (vp.application_number=request->app_num)
    AND vp.position_cd=temppos
    AND vp.view_name=lastview
   DETAIL
    counter = 3, stat = alterlist(view_hier->views,counter), view_hier->views[counter].view_name = vp
    .frame_type
   WITH nocounter
  ;end select
 ENDIF
 CALL findpositions(0,is_level2)
 SET countglobals = 0
 SET stat = alterlist(global_views->views,expand_size)
 CALL findpositions(1,is_level2)
 CALL echo(build("globalExists:",globalexists))
 IF (globalexists=1)
  CALL fillupglobalpositions(request->app_num)
  CALL echo(build("tagetsCount after global=",targetcount))
 ENDIF
#success_exit
 SET reply->status_data.status = "S"
 GO TO exit_program
#fail_exit
 SET reply->status_data.status = "F"
 SET reply->error_msg = errormsg
 GO TO exit_program
 SUBROUTINE fillupglobalpositions(appnum)
   DECLARE countpos = i4
   DECLARE num = i4
   SELECT DISTINCT INTO "nl:"
    vp.position_cd
    FROM view_prefs vp
    WHERE vp.application_number=appnum
     AND vp.prsnl_id=cnvtreal(0)
     AND vp.position_cd != cnvtreal(0)
    HEAD REPORT
     stat = alterlist(temp_pos->positions,expand_size), countpos = 0
    DETAIL
     countpos = (countpos+ 1)
     IF (mod(countpos,expand_size)=0)
      stat = alterlist(temp_pos->positions,(expand_size+ countpos))
     ENDIF
     temp_pos->positions[countpos].pos_code_value = vp.position_cd
    FOOT REPORT
     stat = alterlist(temp_pos->positions,countpos)
    WITH nocounter
   ;end select
   SET targetcount = size(reply->targets,5)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=88
     AND  NOT (expand(num,1,countpos,cv.code_value,temp_pos->positions[num].pos_code_value))
     AND cv.active_ind=1
    HEAD REPORT
     stat = alterlist(reply->targets,(expand_size+ targetcount))
    DETAIL
     targetcount = (targetcount+ 1)
     IF (mod(targetcount,expand_size)=1)
      stat = alterlist(reply->targets,(expand_size+ targetcount))
     ENDIF
     reply->targets[targetcount].global_indicator = 1, reply->targets[targetcount].
     position_code_value = cv.code_value, reply->targets[targetcount].position_display = cv.display,
     stat = moverec(global_views->views,reply->targets[targetcount].views)
    FOOT REPORT
     stat = alterlist(reply->targets,targetcount)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE findpositions(isglobal,islevel2)
   DECLARE locposcheck = vc
   DECLARE locpvcindicator = i2
   DECLARE locaccepttarget = i2
   DECLARE locacceptview = i2
   DECLARE locglobalind = i2
   DECLARE locposcd = f8
   DECLARE locviewcap = vc
   DECLARE locviewprefsid = f8
   DECLARE loctargetsize = i2
   DECLARE locviewsize = i2
   DECLARE locvisitedtarget = i2
   DECLARE locposdisplay = vc
   DECLARE locviewseq = i4
   DECLARE locdisplayseq = vc
   DECLARE locpostioncase = vc
   IF (size(request->pvc_name,1) > 0
    AND (request->pvc_name != ""))
    SET locpvcindicator = 1
   ELSE
    SET locpvcindicator = 0
   ENDIF
   IF (isglobal=1)
    SET locpostioncase = "vp.position_cd = 0"
   ELSE
    SET locpostioncase = "vp.position_cd != 0"
   ENDIF
   IF (islevel2=0)
    SELECT INTO "nl:"
     FROM view_prefs vp,
      name_value_prefs nvp,
      code_value cv
     PLAN (vp
      WHERE (vp.application_number=request->app_num)
       AND vp.active_ind=1
       AND vp.prsnl_id=0
       AND parser(locpostioncase)
       AND (vp.frame_type=view_hier->views[2].view_name)
       AND (vp.view_name=view_hier->views[1].view_name))
      JOIN (cv
      WHERE cv.code_value=vp.position_cd
       AND ((vp.position_cd=0) OR (cv.active_ind=1)) )
      JOIN (nvp
      WHERE nvp.parent_entity_id=vp.view_prefs_id
       AND nvp.parent_entity_name="VIEW_PREFS"
       AND nvp.active_ind=1)
     ORDER BY vp.position_cd, nvp.parent_entity_id
     HEAD REPORT
      IF (isglobal=0)
       stat = alterlist(reply->targets,expand_size), targetcount = 0, loctargetsize = 0
      ENDIF
     HEAD vp.position_cd
      locglobalind = 0, locposcd = vp.position_cd, locviewseq = vp.view_seq,
      locposdisplay = cv.display
      IF (isglobal=0)
       IF (size(reply->targets[targetcount].views)=0)
        stat = alterlist(reply->targets[targetcount].views,expand_size)
       ENDIF
       viewscount = 0, locviewsize = 0, locvisitedtarget = 0
      ENDIF
     HEAD nvp.parent_entity_id
      locacceptview = 0
     DETAIL
      IF (nvp.pvc_name="VIEW_CAPTION")
       locviewcap = nvp.pvc_value
      ENDIF
      IF (nvp.pvc_name="DISPLAY_SEQ")
       locdisplayseq = nvp.pvc_value
      ENDIF
      IF (locpvcindicator=1
       AND trim(nvp.pvc_name)=trim(request->pvc_name)
       AND (nvp.pvc_value=request->pvc_value))
       locacceptview = 1
      ENDIF
     FOOT  nvp.parent_entity_id
      IF (((locpvcindicator=0) OR (locacceptview=1)) )
       IF (vp.position_cd=0)
        countglobals = (countglobals+ 1)
        IF (mod(countglobals,expand_size)=1)
         stat = alterlist(global_views->views,(expand_size+ countglobals))
        ENDIF
        global_views->views[countglobals].view_prefs_id = nvp.parent_entity_id, global_views->views[
        countglobals].view_caption = locviewcap, global_views->views[countglobals].display_seq =
        locdisplayseq,
        global_views->views[countglobals].view_seq = locviewseq, locviewcap = "", locdisplayseq = "",
        locviewseq = 0, BREAK
       ELSE
        IF (locvisitedtarget=0)
         locvisitedtarget = 1, targetcount = (targetcount+ 1)
         IF (mod(targetcount,expand_size)=1)
          stat = alterlist(reply->targets,(expand_size+ targetcount))
         ENDIF
         reply->targets[targetcount].global_indicator = locglobalind, reply->targets[targetcount].
         position_code_value = locposcd, reply->targets[targetcount].position_display = locposdisplay,
         loctargetsize = targetcount
        ENDIF
        viewscount = (viewscount+ 1)
        IF (mod(viewscount,expand_size)=1)
         stat = alterlist(reply->targets[targetcount].views,(viewscount+ expand_size))
        ENDIF
        reply->targets[targetcount].views[viewscount].view_prefs_id = nvp.parent_entity_id, reply->
        targets[targetcount].views[viewscount].view_caption = locviewcap, reply->targets[targetcount]
        .views[viewscount].display_seq = locdisplayseq,
        reply->targets[targetcount].views[viewscount].view_seq = locviewseq, locviewcap = "",
        locdisplayseq = "",
        locviewsize = viewscount
       ENDIF
      ENDIF
     FOOT  vp.position_cd
      locviewseq = 0
      IF (isglobal=1)
       IF (countglobals > 0)
        globalexists = 1, stat = alterlist(global_views->views,countglobals)
       ENDIF
      ELSE
       IF (locviewsize > 0)
        stat = alterlist(reply->targets[targetcount].views,locviewsize)
       ENDIF
      ENDIF
     FOOT REPORT
      IF (isglobal=0)
       stat = alterlist(reply->targets,loctargetsize), targetcount = loctargetsize
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM view_prefs vp,
      view_prefs vp2,
      name_value_prefs nvp,
      code_value cv
     PLAN (vp
      WHERE (vp.application_number=request->app_num)
       AND vp.active_ind=1
       AND vp.prsnl_id=0
       AND parser(locpostioncase)
       AND (vp.frame_type=view_hier->views[2].view_name)
       AND (vp.view_name=view_hier->views[1].view_name))
      JOIN (cv
      WHERE cv.code_value=vp.position_cd
       AND ((vp.position_cd=0) OR (cv.active_ind=1)) )
      JOIN (vp2
      WHERE vp2.active_ind=1
       AND vp.prsnl_id=0
       AND (vp2.frame_type=view_hier->views[3].view_name)
       AND (vp2.view_name=view_hier->views[2].view_name)
       AND vp2.position_cd=vp.position_cd)
      JOIN (nvp
      WHERE nvp.parent_entity_id=vp.view_prefs_id
       AND nvp.parent_entity_name="VIEW_PREFS"
       AND nvp.active_ind=1)
     ORDER BY vp.position_cd, nvp.parent_entity_id
     HEAD REPORT
      IF (isglobal=0)
       stat = alterlist(reply->targets,expand_size), targetcount = 0, loctargetsize = 0
      ENDIF
     HEAD vp.position_cd
      locglobalind = 0, locposcd = vp.position_cd, locviewseq = vp.view_seq,
      locposdisplay = cv.display
      IF (isglobal=0)
       IF (size(reply->targets[targetcount].views)=0)
        stat = alterlist(reply->targets[targetcount].views,expand_size)
       ENDIF
       viewscount = 0, locviewsize = 0, locvisitedtarget = 0
      ENDIF
     HEAD nvp.parent_entity_id
      locacceptview = 0
     DETAIL
      IF (nvp.pvc_name="VIEW_CAPTION")
       locviewcap = nvp.pvc_value
      ENDIF
      IF (nvp.pvc_name="DISPLAY_SEQ")
       locdisplayseq = nvp.pvc_value
      ENDIF
      IF (locpvcindicator=1
       AND trim(nvp.pvc_name)=trim(request->pvc_name)
       AND (nvp.pvc_value=request->pvc_value))
       locacceptview = 1
      ENDIF
     FOOT  nvp.parent_entity_id
      IF (((locpvcindicator=0) OR (locacceptview=1)) )
       IF (vp.position_cd=0)
        countglobals = (countglobals+ 1)
        IF (mod(countglobals,expand_size)=1)
         stat = alterlist(global_views->views,(expand_size+ countglobals))
        ENDIF
        global_views->views[countglobals].view_prefs_id = nvp.parent_entity_id, global_views->views[
        countglobals].view_caption = locviewcap, global_views->views[countglobals].display_seq =
        locdisplayseq,
        global_views->views[countglobals].view_seq = locviewseq, locviewcap = "", locdisplayseq = "",
        locviewseq = 0, BREAK
       ELSE
        IF (locvisitedtarget=0)
         locvisitedtarget = 1, targetcount = (targetcount+ 1)
         IF (mod(targetcount,expand_size)=1)
          stat = alterlist(reply->targets,(expand_size+ targetcount))
         ENDIF
         reply->targets[targetcount].global_indicator = locglobalind, reply->targets[targetcount].
         position_code_value = locposcd, reply->targets[targetcount].position_display = locposdisplay,
         loctargetsize = targetcount
        ENDIF
        viewscount = (viewscount+ 1)
        IF (mod(viewscount,expand_size)=1)
         stat = alterlist(reply->targets[targetcount].views,(viewscount+ expand_size))
        ENDIF
        reply->targets[targetcount].views[viewscount].view_prefs_id = nvp.parent_entity_id, reply->
        targets[targetcount].views[viewscount].view_caption = locviewcap, reply->targets[targetcount]
        .views[viewscount].display_seq = locdisplayseq,
        reply->targets[targetcount].views[viewscount].view_seq = locviewseq, locviewcap = "",
        locdisplayseq = "",
        locviewsize = viewscount
       ENDIF
      ENDIF
     FOOT  vp.position_cd
      locviewseq = 0
      IF (isglobal=1)
       IF (countglobals > 0)
        globalexists = 1, stat = alterlist(global_views->views,countglobals)
       ENDIF
      ELSE
       IF (locviewsize > 0)
        stat = alterlist(reply->targets[targetcount].views,locviewsize)
       ENDIF
      ENDIF
     FOOT REPORT
      IF (isglobal=0)
       stat = alterlist(reply->targets,loctargetsize), targetcount = loctargetsize
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
#exit_program
END GO
