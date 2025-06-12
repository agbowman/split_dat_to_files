CREATE PROGRAM dm_drop_ref_tables:dba
 RDB drop table dm_ref_domain cascade constraints
 END ;Rdb
 RDB drop table dm_ref_domain_r cascade constraints
 END ;Rdb
 RDB drop table dm_ref_domain_group cascade constraints
 END ;Rdb
END GO
