CREATE PROGRAM dcp_del_td_r:dba
 DELETE  FROM task_discrete_r tdr
  WHERE tdr.reference_task_id=temp_reference_task_id
  WITH nocounter
 ;end delete
 UPDATE  FROM order_task_xref otx
  SET otx.order_task_type_flag = 0
  WHERE otx.reference_task_id=temp_reference_task_id
  WITH nocounter
 ;end update
END GO
