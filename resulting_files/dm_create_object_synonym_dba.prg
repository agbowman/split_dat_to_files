CREATE PROGRAM dm_create_object_synonym:dba
 FREE RECORD so
 RECORD so(
   1 str = vc
   1 obj_name = vc
   1 obj_type = vc
   1 obj_type2 = vc
 )
 SET so->obj_name = cnvtupper( $1)
 SET so->obj_type = cnvtupper( $2)
 SET so->str = concat("rdb create public synonym ",trim(so->obj_name))
 CALL echo(so->str)
 CALL parser(so->str)
 SET so->str = concat(" for v500.",trim(so->obj_name)," go")
 CALL echo(so->str)
 CALL parser(so->str,1)
END GO
