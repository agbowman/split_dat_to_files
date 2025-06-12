CREATE PROGRAM edattendingprovider
 IF (validate(reply->text)=0)
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  )
 ENDIF
 DECLARE csbegin = vc
 DECLARE csend = vc
 DECLARE attendingphysician = vc WITH protect, noconstant(" ")
 DECLARE finalattending = vc
 SELECT DISTINCT
  p.name_full_formatted
  FROM tracking_prv_reln tpr,
   tracking_prsnl tp,
   track_reference tr,
   prsnl p,
   tracking_item ti,
   encounter e,
   person per
  WHERE (per.person_id=request->person_id)
   AND per.person_id=ti.person_id
   AND e.encntr_id=ti.encntr_id
   AND ti.tracking_id=tpr.tracking_id
   AND p.person_id=tpr.tracking_provider_id
   AND tp.person_id=tpr.tracking_provider_id
   AND tr.tracking_ref_id=tp.tracking_prsnl_task_id
   AND e.active_ind=1
   AND ti.active_ind=1
   AND e.end_effective_dt_tm > sysdate
   AND tp.def_encntr_prsnl_r_cd=219833429
   AND (tpr.assign_dt_tm=
  (SELECT
   max(assign_dt_tm)
   FROM tracking_prv_reln ttr,
    tracking_item tii,
    tracking_prsnl trpr
   WHERE trpr.person_id=ttr.tracking_provider_id
    AND tii.tracking_id=ttr.tracking_id
    AND tii.person_id=per.person_id
    AND trpr.def_encntr_prsnl_r_cd=219833429
    AND tii.active_ind=1))
  ORDER BY p.name_full_formatted
  HEAD p.name_full_formatted
   attendingphysician = trim(p.name_full_formatted)
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 300, maxrow = 1
 ;end select
 SET csbegin = concat("<html><body>","<span style='font-size:12.0pt;font-family:Arial'>")
 SET csend = "</span>"
 SET finalattending = concat(csbegin,"<u>",attendingphysician,"</u>",csend,
  "</body></html>")
 SET reply->text = finalattending
 SET reply->format = 1
 CALL echorecord(reply)
END GO
