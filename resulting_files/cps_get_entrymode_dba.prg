CREATE PROGRAM cps_get_entrymode:dba
 RECORD reply(
   1 qual_count = i4
   1 qual[*]
     2 pattern_id = f8
     2 entry_mode_cd = f8
     2 entry_mode_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_id_rows = size(request->patterns,5)
 SET stat = alterlist(reply->qual,nbr_id_rows)
 SELECT INTO "nl:"
  FROM scr_pattern pat,
   (dummyt d  WITH seq = value(nbr_id_rows))
  PLAN (d)
   JOIN (pat
   WHERE (pat.scr_pattern_id=request->patterns[d.seq].scr_pattern_id))
  DETAIL
   count1 = (count1+ 1), reply->qual[count1].pattern_id = pat.scr_pattern_id, reply->qual[count1].
   entry_mode_cd = pat.entry_mode_cd
   IF (pat.entry_mode_cd)
    reply->qual[count1].entry_mode_mean = uar_get_code_meaning(pat.entry_mode_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (count1 != nbr_id_rows)
  SET stat = alterlist(reply->qual,count1)
 ENDIF
 SET reply->qual_count = count1
END GO
