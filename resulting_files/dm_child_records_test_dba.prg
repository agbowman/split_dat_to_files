CREATE PROGRAM dm_child_records_test:dba
 SET dm_cmb_parent = cnvtupper( $1)
 SET dm_cmb_from_id =  $2
 SET dm_cmb_to_id =  $3
 SET dm_cmb_encntr_id =  $4
 FREE SET request
 RECORD request(
   1 parent_table = c50
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
 )
 SET stat = alterlist(request->xxx_combine,1)
 SET request->parent_table = dm_cmb_parent
 SET request->xxx_combine[1].from_xxx_id = dm_cmb_from_id
 SET request->xxx_combine[1].to_xxx_id = dm_cmb_to_id
 SET request->xxx_combine[1].encntr_id = dm_cmb_encntr_id
 EXECUTE dm_child_records
END GO
