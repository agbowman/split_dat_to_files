CREATE PROGRAM dm_create_db_view:dba
 SET req_tbl = trim(request->tbl_name)
 SET req_owner = trim(request->owner)
 FREE SET request
 RECORD request(
   1 owner = c30
   1 table_name = c30
   1 view_name = c100
 )
 SET request->owner = req_owner
 SET request->table_name = req_tbl
 SET request->view_name = fillstring(100," ")
 FREE SET reply
 RECORD reply(
   1 attrib_qual = i4
   1 attrib[10]
     2 column_name = c30
     2 data_type = c9
     2 data_length = i4
     2 data_precision = i4
     2 data_scale = i4
     2 nullable = c1
     2 column_id = f8
     2 default_length = i4
     2 data_default = c500
     2 num_distinct = i4
     2 low_value = c32
     2 high_value = c32
     2 density = i4
     2 code_set = f8
     2 primary_key_ind = i4
     2 show_ind = i4
     2 code_show_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 EXECUTE assist_get_attribute
 FREE SET request
 RECORD request(
   1 action_type = c3
   1 owner = c30
   1 table_name = c30
   1 view_name = c100
   1 view_description = c100
   1 view_seq_qual = i4
   1 view_seq[reply->attrib_qual]
     2 column_name = c30
     2 sequence = i4
     2 code_show_ind = i4
 )
 SET request->action_type = "ADD"
 SET request->owner = trim(req_owner)
 SET request->table_name = trim(req_tbl)
 SET request->view_name = trim(concat(trim(req_tbl)," default"))
 SET request->view_description = trim(concat("Default view for ",trim(req_tbl)))
 SET request->view_seq_qual = reply->attrib_qual
 SET kount = 0
 SET endloop = reply->attrib_qual
 FOR (kount = 1 TO endloop)
   SET request->view_seq[kount].column_name = reply->attrib[kount].column_name
   SET request->view_seq[kount].sequence = (kount - 1)
   SET request->view_seq[kount].code_show_ind = 1
 ENDFOR
 FREE SET reply
 RECORD reply(
   1 owner = c30
   1 table_name = c30
   1 view_name = c100
   1 view_description = c100
   1 view_seq_qual = i4
   1 view_seq[10]
     2 column_name = c30
     2 sequence = i4
     2 code_show_ind = i4
     2 success_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 EXECUTE assist_ens_view
 COMMIT
END GO
