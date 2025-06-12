CREATE PROGRAM doc_get_all_system_phrases:dba
 RECORD request(
   1 user_id = f8
 )
 RECORD reply(
   1 note_phrases[*]
     2 note_phrase_id = f8
     2 user_id = f8
     2 abbreviation = vc
     2 description = vc
     2 updt_dt_tm = dq8
     2 note_phrase_comps[*]
       3 note_phrase_comp_id = f8
       3 fkey_id = f8
       3 fkey_name = vc
       3 sequence = i4
       3 template_name = vc
       3 template_cki = vc
       3 formatted_text_chunks[*]
         4 chunk = vgc
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
 SET request->user_id = 0.0
 EXECUTE doc_get_all_user_phrases
END GO
