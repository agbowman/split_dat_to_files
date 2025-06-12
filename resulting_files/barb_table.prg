CREATE PROGRAM barb_table
 SELECT INTO TABLE barb_table
  p.person_id
  FROM person p
  ORDER BY p.person_id
  WITH maxrec = 10, organization = i
 ;end select
END GO
