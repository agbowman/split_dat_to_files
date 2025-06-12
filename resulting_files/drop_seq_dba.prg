CREATE PROGRAM drop_seq:dba
 SELECT INTO "drop_seq"
  u.sequence_name
  FROM user_sequences u
  DETAIL
   row + 1, "rdb drop sequence ", u.sequence_name,
   " go"
  WITH nocounter
 ;end select
END GO
