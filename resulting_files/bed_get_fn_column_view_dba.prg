CREATE PROGRAM bed_get_fn_column_view:dba
 FREE SET reply
 RECORD reply(
   1 column_views[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET pref
 RECORD pref(
   1 plist[*]
     2 id = f8
     2 name = vc
 )
 SET reply->status_data.status = "F"
 SET vcount = 0
 SET tot_vcount = 0
 SET pcount = 0
 SET tot_pcount = 0
 DECLARE list_type = vc
 CASE (request->list_type)
  OF "TRKBEDLIST":
   SET list_type = "TRKBEDTYPE"
  OF "TRKGROUP":
   SET list_type = "TRKGRPTYPE"
  OF "TRKPRVLIST":
   SET list_type = "TRKPRVTYPE"
  OF "LOCATION":
   SET list_type = "TRKPATTYPE"
 ENDCASE
 IF ((request->trk_group_code_value=0))
  SELECT INTO "NL:"
   FROM predefined_prefs pp
   WHERE pp.active_ind=1
    AND pp.predefined_type_meaning=trim(list_type)
   ORDER BY pp.name
   HEAD REPORT
    stat = alterlist(reply->column_views,50)
   DETAIL
    vcount = (vcount+ 1), tot_vcount = (tot_vcount+ 1)
    IF (vcount > 50)
     stat = alterlist(reply->column_views,(tot_vcount+ 50)), vcount = 1
    ENDIF
    reply->column_views[tot_vcount].id = pp.predefined_prefs_id, reply->column_views[tot_vcount].name
     = pp.name
   FOOT REPORT
    stat = alterlist(reply->column_views,tot_vcount)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM predefined_prefs pp
   PLAN (pp
    WHERE pp.active_ind=1
     AND pp.predefined_type_meaning=trim(list_type))
   ORDER BY pp.name
   HEAD REPORT
    stat = alterlist(pref->plist,50)
   HEAD pp.name
    pcount = (pcount+ 1), tot_pcount = (tot_pcount+ 1)
    IF (pcount > 50)
     stat = alterlist(pref->plist,(tot_pcount+ 50)), pcount = 1
    ENDIF
    pref->plist[tot_pcount].id = pp.predefined_prefs_id, pref->plist[tot_pcount].name = pp.name
   FOOT REPORT
    stat = alterlist(pref->plist,tot_pcount)
   WITH nocounter
  ;end select
  FOR (i = 1 TO tot_pcount)
    DECLARE pvc_value = vc
    SET pvc_value = build('"*',trim(cnvtstring(pref->plist[i].id,20,0)),"*",trim(cnvtstring(request->
       trk_group_code_value,20,0)),'*"')
    DECLARE nvp_parser = vc
    SET nvp_parser = concat('nvp.active_ind = 1 and nvp.pvc_name = "TABINFO" and ',
     'nvp.parent_entity_name = "DETAIL_PREFS" and ',"nvp.pvc_value = ",pvc_value)
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     PLAN (nvp
      WHERE parser(nvp_parser))
     HEAD REPORT
      stat = alterlist(reply->column_views,50)
     DETAIL
      found = 0
      FOR (x = 1 TO tot_vcount)
        IF ((reply->column_views[x].id=pref->plist[i].id))
         found = 1
        ENDIF
      ENDFOR
      IF (found=0)
       vcount = (vcount+ 1), tot_vcount = (tot_vcount+ 1)
       IF (vcount > 50)
        stat = alterlist(reply->column_views,(tot_vcount+ 50)), vcount = 1
       ENDIF
       reply->column_views[tot_vcount].id = pref->plist[i].id, reply->column_views[tot_vcount].name
        = pref->plist[i].name
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->column_views,tot_vcount)
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 IF (tot_vcount > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
