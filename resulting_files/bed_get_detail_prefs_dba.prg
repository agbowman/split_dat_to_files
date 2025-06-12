CREATE PROGRAM bed_get_detail_prefs:dba
 FREE SET reply
 RECORD reply(
   1 dplist[*]
     2 detail_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->dplist,5)
 SET stat = alterlist(reply->dplist,listcount)
 FOR (lvar = 1 TO listcount)
  SET reply->dplist[lvar].detail_prefs_id = 0.0
  SELECT INTO "NL:"
   FROM detail_prefs dp
   WHERE (dp.application_number=request->dplist[lvar].application_number)
    AND (dp.position_cd=request->dplist[lvar].position_cd)
    AND (dp.prsnl_id=request->dplist[lvar].prsnl_id)
    AND (dp.person_id=request->dplist[lvar].person_id)
    AND (dp.view_name=request->dplist[lvar].view_name)
    AND (dp.view_seq=request->dplist[lvar].view_seq)
    AND (dp.comp_name=request->dplist[lvar].comp_name)
    AND (dp.comp_seq=request->dplist[lvar].comp_seq)
    AND dp.active_ind=1
   DETAIL
    reply->dplist[lvar].detail_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ENDFOR
END GO
