CREATE PROGRAM del_dm_info_row:dba
 SET del_row =  $1
 CALL parser(del_row)
END GO
