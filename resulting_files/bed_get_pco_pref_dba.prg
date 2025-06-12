CREATE PROGRAM bed_get_pco_pref:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 name_value_prefs_id = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 parent_entity_name = vc
     2 application_number = i4
     2 position_code_value = f8
     2 prsnl_id = f8
     2 detail_pref
       3 person_id = f8
       3 view_name = vc
       3 comp_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET ncount = 0
 SET stat = alterlist(reply->nlist,50)
 DECLARE aplistparse = vc
 DECLARE nvplistparse = vc
 DECLARE dlistparse = vc
 SET listcount = size(request->nlist,5)
 FOR (x = 1 TO listcount)
   CASE (request->nlist[x].parent_entity_name)
    OF "APP_PREFS":
     SET aplistparse = "ap.active_ind = 1 "
     SET nvplistparse = "nvp.active_ind = 1 and nvp.parent_entity_id = ap.app_prefs_id "
     SET aplistparse = build(aplistparse," and ap.application_number = ",request->nlist[x].
      application_number)
     IF ((request->nlist[x].all_position_ind=1))
      SET aplistparse = concat(aplistparse," and ap.position_cd > 0")
     ELSE
      SET aplistparse = build(aplistparse," and ap.position_cd = ",request->nlist[x].
       position_code_value)
     ENDIF
     IF ((request->nlist[x].all_prsnl_ind=1))
      SET aplistparse = concat(aplistparse," and ap.prsnl_id > 0")
     ELSE
      SET aplistparse = build(aplistparse," and ap.prsnl_id = ",request->nlist[x].prsnl_id)
     ENDIF
     SET nvplistparse = concat(nvplistparse," and nvp.parent_entity_name = ","'",request->nlist[x].
      parent_entity_name,"'",
      " and nvp.pvc_name = '",request->nlist[x].pvc_name,"'")
     CALL echo(build("aplistparse = ",aplistparse))
     CALL echo(build("nvplistparse = ",nvplistparse))
     SELECT INTO "NL:"
      FROM app_prefs ap,
       name_value_prefs nvp
      PLAN (ap
       WHERE parser(aplistparse))
       JOIN (nvp
       WHERE parser(nvplistparse))
      DETAIL
       tot_count = (tot_count+ 1), ncount = (ncount+ 1)
       IF (ncount > 50)
        stat = alterlist(reply->nlist,(tot_count+ 50)), nomen_cnt = 0
       ENDIF
       reply->nlist[tot_count].name_value_prefs_id = nvp.name_value_prefs_id, reply->nlist[tot_count]
       .pvc_value = nvp.pvc_value, reply->nlist[tot_count].pvc_name = request->nlist[x].pvc_name,
       reply->nlist[tot_count].parent_entity_name = nvp.parent_entity_name, reply->nlist[tot_count].
       application_number = ap.application_number, reply->nlist[tot_count].position_code_value = ap
       .position_cd,
       reply->nlist[tot_count].prsnl_id = ap.prsnl_id
      WITH nocounter
     ;end select
    OF "DETAIL_PREFS":
     SET dlistparse = "d.active_ind = 1 "
     SET nvplistparse = "nvp.active_ind = 1 and nvp.parent_entity_id = d.detail_prefs_id "
     SET dlistparse = build(dlistparse," and d.application_number = ",request->nlist[x].
      application_number," and d.view_name = '",request->nlist[x].detail_pref.view_name,
      "'"," and d.comp_name = '",request->nlist[x].detail_pref.comp_name,"'")
     IF ((request->nlist[x].all_position_ind=1))
      SET dlistparse = concat(dlistparse," and d.position_cd >= 0")
     ELSE
      SET dlistparse = build(dlistparse," and d.position_cd = ",request->nlist[x].position_code_value
       )
     ENDIF
     IF ((request->nlist[x].all_prsnl_ind=1))
      SET dlistparse = concat(dlistparse," and d.prsnl_id >= 0")
      SET dlistparse = concat(dlistparse," and d.person_id >= 0")
     ELSE
      SET dlistparse = build(dlistparse," and d.prsnl_id = ",request->nlist[x].prsnl_id)
      SET dlistparse = build(dlistparse," and d.person_id = ",request->nlist[x].person_id)
     ENDIF
     SET nvplistparse = concat(nvplistparse," and nvp.parent_entity_name = ","'",request->nlist[x].
      parent_entity_name,"'",
      " and nvp.pvc_name = '",request->nlist[x].pvc_name,"'")
     CALL echo(nvplistparse)
     CALL echo(dlistparse)
     SELECT INTO "NL:"
      FROM detail_prefs d,
       name_value_prefs nvp
      PLAN (d
       WHERE parser(dlistparse))
       JOIN (nvp
       WHERE parser(nvplistparse))
      ORDER BY d.position_cd
      DETAIL
       tot_count = (tot_count+ 1), ncount = (ncount+ 1)
       IF (ncount > 50)
        stat = alterlist(reply->nlist,(tot_count+ 50)), nomen_cnt = 0
       ENDIF
       reply->nlist[tot_count].name_value_prefs_id = nvp.name_value_prefs_id, reply->nlist[tot_count]
       .pvc_value = nvp.pvc_value, reply->nlist[tot_count].pvc_name = request->nlist[x].pvc_name,
       reply->nlist[tot_count].parent_entity_name = nvp.parent_entity_name, reply->nlist[tot_count].
       application_number = d.application_number, reply->nlist[tot_count].position_code_value = d
       .position_cd,
       reply->nlist[tot_count].prsnl_id = d.prsnl_id, reply->nlist[tot_count].detail_pref.person_id
        = d.person_id, reply->nlist[tot_count].detail_pref.view_name = d.view_name,
       reply->nlist[tot_count].detail_pref.comp_name = d.comp_name
      WITH nocounter
     ;end select
   ENDCASE
 ENDFOR
 SET stat = alterlist(reply->nlist,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
