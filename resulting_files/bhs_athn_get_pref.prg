CREATE PROGRAM bhs_athn_get_pref
 RECORD out_rec(
   1 pref_name = vc
   1 pref_value = vc
   1 position = vc
   1 prnsl = vc
 )
 IF (( $2 > 0))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap,
    prsnl pr
   PLAN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name= $4)
     AND nvp.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.application_number=600005
     AND ap.active_ind=1
     AND (ap.prsnl_id= $2))
    JOIN (pr
    WHERE pr.person_id=ap.prsnl_id)
   DETAIL
    out_rec->pref_name = nvp.pvc_name, out_rec->pref_value = nvp.pvc_value, out_rec->prnsl = pr
    .name_full_formatted
   WITH nocounter, time = 20
  ;end select
 ENDIF
 IF ((out_rec->pref_value=" ")
  AND ( $3 > 0))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap
   PLAN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name= $4)
     AND nvp.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.application_number=600005
     AND ap.active_ind=1
     AND (ap.position_cd= $3))
   DETAIL
    out_rec->pref_name = nvp.pvc_name, out_rec->pref_value = nvp.pvc_value, out_rec->position =
    uar_get_code_display(ap.position_cd)
   WITH nocounter, time = 20
  ;end select
 ENDIF
 IF ((out_rec->pref_value=" "))
  SELECT INTO "nl:"
   FROM name_value_prefs nvp,
    app_prefs ap
   PLAN (nvp
    WHERE nvp.parent_entity_name="APP_PREFS"
     AND (nvp.pvc_name= $4)
     AND nvp.active_ind=1)
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.application_number=600005
     AND ap.active_ind=1
     AND ap.position_cd=0
     AND ap.prsnl_id=0)
   DETAIL
    out_rec->pref_name = nvp.pvc_name, out_rec->pref_value = nvp.pvc_value
   WITH nocounter, time = 20
  ;end select
 ENDIF
 CALL echojson(out_rec, $1)
END GO
