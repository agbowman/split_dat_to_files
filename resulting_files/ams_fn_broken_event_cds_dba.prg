CREATE PROGRAM ams_fn_broken_event_cds:dba
 DECLARE getclient(null) = vc WITH protect
 DECLARE checkemail(null) = i2 WITH protect
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE clientstr = vc WITH constant(getclient(null)), protect
 DECLARE sectioncnt = i4 WITH protect
 DECLARE trackcnt = i4 WITH protect
 DECLARE filename = vc WITH protect, noconstant(concat("_broken_event_cds_",cnvtlower(format(
     cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".csv"))
 DECLARE last_mod = vc WITH protect
 DECLARE emailind = i2 WITH protect
 DECLARE vcsubject = vc WITH noconstant(build2("AMS FN Broken Event Codes ",clientstr,": ",curdomain)
  ), protect
 DECLARE cfrom = c34 WITH protect, constant("ams_fn_broken_event_cds@cerner.com")
 RECORD event_hire(
   1 track_groups[*]
     2 track_group_id = vc
     2 sections[*]
       3 section_name = vc
       3 parent_cd = f8
       3 child_cd = f8
       3 bad_reason = vc
 ) WITH protect
 IF (validate(request->batch_selection,"-1")="-1")
  IF (validate(reply->ops_event,"-1")="-1")
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH persistscript
  ENDIF
 ELSE
  SET stat = checkemail(null)
  IF (stat=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = "Output distribution incorrect. It must be an email address."
   GO TO exit_script
  ENDIF
 ENDIF
 SET filename = cnvtlower(concat(getclient(null),filename))
 SET reply->status_data.status = "F"
 SET reply->ops_event = "Script failed for unknown reason"
 SELECT INTO "nl:"
  tg = build(evaluate2(
    IF (isnumeric(trim(piece(piece(pd.dist_name,",",4,"Not Found"),"=",2,"Not Found"),3)) > 0) build(
      trim(piece(piece(pd.dist_name,",",4,"Not Found"),"=",2,"Not Found"),3))
    ELSEIF (isnumeric(trim(piece(piece(pd.dist_name,",",5,"Not Found"),"=",2,"Not Found"),3)) > 0)
     build(trim(piece(piece(pd.dist_name,",",5,"Not Found"),"=",2,"Not Found"),3))
    ENDIF
    ),"                                                                         "), section = build(
   evaluate2(
    IF (((trim(piece(trim(piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),3)," ",1,""),
     3)="clinical") OR (trim(piece(trim(piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"
        ),3)," ",1,""),3)="patient")) ) build(trim(piece(piece(pd.dist_name,",",2,"Not Found"),"=",2,
        "Not Found"),3),":",piece(trim(piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),
        3)," ",1,""))
    ELSEIF (trim(piece(trim(piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),3)," ",1,
      ""),3) != "clinical"
     AND trim(piece(trim(piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),3)," ",1,""),
     3) != "patient") build(trim(piece(piece(pd.dist_name,",",2,"Not Found"),"=",2,"Not Found"),3))
    ENDIF
    ),"                                                                         "), entry = trim(
   piece(piece(pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),3),
  temp = build(evaluate2(
    IF (isnumeric(trim(piece(piece(pd.dist_name,",",4,"Not Found"),"=",2,"Not Found"),3)) > 0) build(
      trim(piece(piece(pd.dist_name,",",4,"Not Found"),"=",2,"Not Found"),3))
    ELSEIF (isnumeric(trim(piece(piece(pd.dist_name,",",5,"Not Found"),"=",2,"Not Found"),3)) > 0)
     build(trim(piece(piece(pd.dist_name,",",5,"Not Found"),"=",2,"Not Found"),3))
    ENDIF
    ),":",trim(piece(piece(pd.dist_name,",",2,"Not Found"),"=",2,"Not Found"),3),":",trim(piece(piece
     (pd.dist_name,",",1,"Not Found"),"=",2,"Not Found"),3)), event = pv.value
  FROM prefdir_value pv,
   prefdir_entrydata pd
  PLAN (pd
   WHERE ((pd.dist_name="*prefentry=pa_note_eventset_code,prefgroup=prearrival*") OR (((pd.dist_name=
   "*prefentry=pa_note_event_code,prefgroup=prearrival*") OR (((pd.dist_name=
   "*prefentry=event_cd,prefgroup=patienteducation*") OR (((pd.dist_name=
   "*prefentry=parent event_cd,prefgroup=patienteducation*") OR (((pd.dist_name=
   "*prefentry=patient code child,prefgroup=depart tab section*") OR (((pd.dist_name=
   "*prefentry=patient code parent,prefgroup=depart tab section*") OR (((pd.dist_name=
   "*prefentry=clinical code child,prefgroup=depart tab section*") OR (pd.dist_name=
   "*prefentry=clinical code parent,prefgroup=depart tab section*")) )) )) )) )) )) )) )
   JOIN (pv
   WHERE pd.entry_id=pv.entry_id)
  ORDER BY temp
  HEAD tg
   trackcnt = (trackcnt+ 1), stat = alterlist(event_hire->track_groups,trackcnt), event_hire->
   track_groups[trackcnt].track_group_id = build(uar_get_code_display(cnvtreal(piece(temp,":",1,
       "Not Found"))),":",piece(temp,":",1,"Not Found"))
  HEAD section
   sectioncnt = (size(event_hire->track_groups[trackcnt].sections,5)+ 1), stat = alterlist(event_hire
    ->track_groups[trackcnt].sections,sectioncnt), event_hire->track_groups[trackcnt].sections[
   sectioncnt].section_name = build(piece(temp,":",2,"Not Found"),evaluate2(
     IF (((trim(piece(piece(temp,":",3,"Not Found")," ",1,"Not Found"),3)="clinical") OR (trim(piece(
       piece(temp,":",3,"Not Found")," ",1,"Not Found"),3)="patient")) ) build(":",trim(piece(piece(
          temp,":",3,"Not Found")," ",1,"Not Found"),3))
     ELSEIF (((trim(piece(piece(temp,":",3,"Not Found")," ",1,"Not Found"),3) != "clinical") OR (trim
     (piece(piece(temp,":",3,"Not Found")," ",1,"Not Found"),3) != "patient")) ) build(trim(" ",3))
     ENDIF
     ))
  DETAIL
   CASE (entry)
    OF "event_cd":
     event_hire->track_groups[trackcnt].sections[sectioncnt].child_cd = cnvtreal(event)
    OF "parent event_cd":
     event_hire->track_groups[trackcnt].sections[sectioncnt].parent_cd = cnvtreal(event)
    OF "pa_note_event_code":
     event_hire->track_groups[trackcnt].sections[sectioncnt].child_cd = cnvtreal(event)
    OF "pa_note_eventset_code":
     event_hire->track_groups[trackcnt].sections[sectioncnt].parent_cd = cnvtreal(event)
    OF "patient code child":
     event_hire->track_groups[trackcnt].sections[sectioncnt].child_cd = cnvtreal(event)
    OF "patient code parent":
     event_hire->track_groups[trackcnt].sections[sectioncnt].parent_cd = cnvtreal(event)
    OF "clinical code child":
     event_hire->track_groups[trackcnt].sections[sectioncnt].child_cd = cnvtreal(event)
    OF "clinical code parent":
     event_hire->track_groups[trackcnt].sections[sectioncnt].parent_cd = cnvtreal(event)
   ENDCASE
   event_hire->track_groups[trackcnt].sections[sectioncnt].bad_reason = "BAD"
  WITH nocounter
 ;end select
 SET xx = 0
 SET yy = 0
 FOR (xx = 1 TO size(event_hire->track_groups,5))
   FOR (yy = 1 TO size(event_hire->track_groups[xx].sections,5))
     SELECT INTO "nl:"
      FROM v500_event_set_explode v
      WHERE v.event_cd=cnvtreal(event_hire->track_groups[xx].sections[yy].child_cd)
       AND v.event_cd > 0
       AND v.event_set_cd=cnvtreal(event_hire->track_groups[xx].sections[yy].parent_cd)
       AND v.event_set_cd > 0
      DETAIL
       event_hire->track_groups[xx].sections[yy].bad_reason = "GOOD"
      WITH nocounter
     ;end select
   ENDFOR
 ENDFOR
 SET xx = 0
 SET yy = 0
 FOR (xx = 1 TO size(event_hire->track_groups,5))
   FOR (yy = 1 TO size(event_hire->track_groups[xx].sections,5))
     IF ((event_hire->track_groups[xx].sections[yy].parent_cd=0)
      AND (event_hire->track_groups[xx].sections[yy].child_cd=0))
      SET event_hire->track_groups[xx].sections[yy].bad_reason = "NOT BUILT"
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO value(filename)
  tracking_group = substring(1,1000,event_hire->track_groups[d1.seq].track_group_id), section_name =
  substring(1,100,event_hire->track_groups[d1.seq].sections[d2.seq].section_name), parent_cd_disp =
  substring(1,40,uar_get_code_display(event_hire->track_groups[d1.seq].sections[d2.seq].parent_cd)),
  child_cd_disp = substring(1,40,uar_get_code_display(event_hire->track_groups[d1.seq].sections[d2
    .seq].child_cd)), parent_cd = event_hire->track_groups[d1.seq].sections[d2.seq].parent_cd,
  child_cd = event_hire->track_groups[d1.seq].sections[d2.seq].child_cd,
  bad_reason = substring(1,100,event_hire->track_groups[d1.seq].sections[d2.seq].bad_reason)
  FROM (dummyt d1  WITH seq = value(size(event_hire->track_groups,5))),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(event_hire->track_groups[d1.seq].sections,5)))
   JOIN (d2)
  WITH format = stream, pcformat('"',",",1), format
 ;end select
 IF (emailind=1)
  IF (emailfile(trim(request->output_dist),cfrom,vcsubject,"",filename)=0)
   SET statusstr = "Sending email failed. Contact AMS FirstNet team to investigate."
   SET reply->status_data.status = "F"
   SET reply->ops_event = statusstr
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->ops_event = build2("Successfully created file ",filename)
#exit_script
 CALL echo(build2("Script completed with status: ",reply->status_data.status))
 CALL echo(build2("File created: ",filename))
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE checkemail(null)
   DECLARE retval = i2 WITH protect
   DECLARE outputdiststr = vc WITH protect
   DECLARE iatpos = i2 WITH protect
   IF ("-1" != validate(request->output_dist,"-1"))
    IF ((request->output_dist > ""))
     SET outputdiststr = trim(request->output_dist)
     SET iatpos = findstring("@",outputdiststr)
     IF (iatpos=0)
      SET retval = 0
     ELSE
      SET retval = 1
      SET emailind = 1
     ENDIF
    ELSE
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SET last_mod = "000"
END GO
