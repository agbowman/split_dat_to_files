CREATE PROGRAM dcp_del_dcp_sect:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 dir_list[*]
     2 dcp_input_ref_id = f8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  dir.dcp_input_ref_id
  FROM dcp_input_ref dir
  PLAN (dir
   WHERE (dir.dcp_section_ref_id=request->dcp_section_ref_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(temp->dir_list,5))
    stat = alterlist(temp->dir_list,(count1+ 5))
   ENDIF
   temp->dir_list[count1].dcp_input_ref_id = dir.dcp_input_ref_id
  FOOT REPORT
   stat = alterlist(temp->dir_list,count1)
  WITH nocounter
 ;end select
 FOR (x = 1 TO count1)
   DELETE  FROM name_value_prefs nvp
    WHERE (nvp.parent_entity_id=temp->dir_list[x].dcp_input_ref_id)
     AND nvp.parent_entity_name="DCP_INPUT_REF"
    WITH nocounter
   ;end delete
 ENDFOR
 DELETE  FROM dcp_input_ref dir
  WHERE (dir.dcp_section_ref_id=request->dcp_section_ref_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_forms_def dfd
  WHERE (dfd.dcp_section_ref_id=request->dcp_section_ref_id)
  WITH nocounter
 ;end delete
 DELETE  FROM dcp_section_ref dsr
  WHERE (dsr.dcp_section_ref_id=request->dcp_section_ref_id)
  WITH nocounter
 ;end delete
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
