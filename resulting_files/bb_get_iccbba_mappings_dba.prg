CREATE PROGRAM bb_get_iccbba_mappings:dba
 RECORD reply(
   1 mapping_list[*]
     2 mapping_id = f8
     2 version_nbr = i4
     2 table_type = c12
     2 table_name = vc
     2 column_type = c12
     2 column_name = vc
     2 unique_version_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  b.bb_iccbba_mapping_id, b.version_nbr, b.table_type_desc,
  b.table_name, b.column_type_desc, b.column_name,
  b.unique_version_ind
  FROM bb_iccbba_mapping b
  PLAN (b
   WHERE b.bb_iccbba_mapping_id > 0)
  HEAD REPORT
   ncount1 = 0
  DETAIL
   ncount1 = (ncount1+ 1)
   IF (ncount1 > size(reply->mapping_list,5))
    stat = alterlist(reply->mapping_list,(ncount1+ 9))
   ENDIF
   reply->mapping_list[ncount1].mapping_id = b.bb_iccbba_mapping_id, reply->mapping_list[ncount1].
   version_nbr = b.version_nbr, reply->mapping_list[ncount1].table_type = b.table_type_desc,
   reply->mapping_list[ncount1].table_name = b.table_name, reply->mapping_list[ncount1].column_type
    = b.column_type_desc, reply->mapping_list[ncount1].column_name = b.column_name,
   reply->mapping_list[ncount1].unique_version_ind = b.unique_version_ind
  FOOT REPORT
   stat = alterlist(reply->mapping_list,ncount1)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_iccbba_mappings",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(reply->mapping_list,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","bb_get_iccbba_mappings","No ICCBBA database mappings found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
