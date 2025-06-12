CREATE PROGRAM clip_get_portal_api:dba
 RECORD reply(
   1 clipboard_type_url = vc
   1 clipboard_activation_url = vc
   1 locale = vc
   1 healtheintent_base_url = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE t_base_url = vc WITH protect
 DECLARE t_healtheintent_url = vc WITH protect
 DECLARE t_clipboard_type_full_url = vc WITH protect, noconstant("")
 DECLARE t_clipboard_type_relative_url = vc WITH protect, constant("/api/clipboards/types")
 DECLARE t_clipboard_activation_full_url = vc WITH protect, noconstant("")
 DECLARE t_clipboard_activation_relative_url = vc WITH protect, constant(
  "/api/clipboards/activations")
 DECLARE t_locale = vc WITH protect, noconstant("")
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE patient_portal_url = vc WITH protect, constant("PATIENT PORTAL URL")
 DECLARE healthe_intent_url = vc WITH protect, constant("HEALTHE INTENT URL")
 SELECT INTO "nl:"
  d.info_name
  FROM dm_info d,
   prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (d
   WHERE d.info_domain IN (patient_portal_url, healthe_intent_url)
    AND d.info_domain_id=p.logical_domain_id)
  DETAIL
   IF (d.info_domain=patient_portal_url)
    t_base_url = d.info_name
   ENDIF
   IF (d.info_domain=healthe_intent_url)
    t_healtheintent_url = d.info_name
   ENDIF
  WITH nocounter
 ;end select
 IF (size(t_base_url,1) < 1
  AND size(t_healtheintent_url,1) < 1)
  SET failed = true
  CALL echo("Failed to retrieve Portal Base URL!")
  GO TO exit_script
 ENDIF
 SET t_clipboard_type_full_url = build(t_base_url,t_clipboard_type_relative_url)
 SET reply->clipboard_type_url = t_clipboard_type_full_url
 SET t_clipboard_activation_full_url = build(t_base_url,t_clipboard_activation_relative_url)
 SET reply->clipboard_activation_url = t_clipboard_activation_full_url
 SET reply->healtheintent_base_url = t_healtheintent_url
 SET t_locale = cnvtupper(logical("CCL_LANG"))
 IF (t_locale="")
  SET t_locale = cnvtupper(logical("LANG"))
 ENDIF
 SET reply->locale = t_locale
 CALL echo(reply->locale)
 CALL echorecord(reply)
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
