CREATE PROGRAM dba_mod7_db_ver
 SET old_dbver = request->old_dbver
 SET core_size = 0
 SET desc = fillstring(70," ")
 CALL clear(1,1)
 CALL video(r)
 CALL box(1,1,15,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,12,"-  V 5 0 0    D B V E R S I O N    S U B R O U T I N E  -")
 CALL clear(3,2,78)
 CALL text(03,12,"          M O D I F Y   D B   V E R S I O N ")
 CALL video(n)
 CALL text(7,05,"DB Version      :  ")
 CALL text(9,05,"Core Size       :  ")
 CALL text(11,05,"Description    : ")
 SELECT INTO "nl:"
  FROM dm_size_db_version d
  WHERE d.db_version=old_dbver
  DETAIL
   core_size = d.core_size, desc = d.description
  WITH nocounter
 ;end select
 CALL text(7,22,cnvtstring(old_dbver))
 CALL text(9,22,cnvtstring(core_size))
 CALL accept(12,5,"p(70);c",desc)
 SET desc = curaccept
 UPDATE  FROM dm_size_db_version d
  SET d.description = desc
  WHERE d.db_version=old_dbver
  WITH nocounter
 ;end update
 COMMIT
END GO
