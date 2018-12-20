create user SIMPLEAC identified by 123456;
--================================
grant dba to SIMPLEAC with admin option;
grant create session, create any context, create procedure,
    create trigger, administer database trigger to SIMPLEAC;
grant execute on dbms_session to SIMPLEAC;
grant execute on dbms_rls to SIMPLEAC;
--================================
CONN SIMPLEAC/123456
CREATE TABLE NHANVIEN
(
    USERNAME NVARCHAR2(30),
    NAME NVARCHAR2(30),
    SALARY REAL,
    EMAIL NVARCHAR2(30),
    PRIMARY KEY (USERNAME)
);
INSERT INTO NHANVIEN VALUES ('NV01', 'PHAN THANH SANG', 1, 'PTSANG@GMAIL.COM');
INSERT INTO NHANVIEN VALUES ('NV02', 'HAI HONG', 10, 'HHONG@GMAIL.COM');
INSERT INTO NHANVIEN VALUES ('NV03', 'BA DUY', 100, 'BDUY@GMAIL.COM');
INSERT INTO NHANVIEN VALUES ('NV04', 'NGUYEN THE HIEN', 1000, 'NTHIEN@GMAIL.COM');
CREATE TABLE NHANVIEN_VAITRO
(
    USERNAME NVARCHAR2(30),
    VAITRO NVARCHAR2(30),
    PRIMARY KEY (USERNAME, VAITRO)
);
INSERT INTO NHANVIEN_VAITRO VALUES ('NV01', 'NVKETOAN');
INSERT INTO NHANVIEN_VAITRO VALUES ('NV02', 'BACSI');
INSERT INTO NHANVIEN_VAITRO VALUES ('NV03', 'BACSI');
INSERT INTO NHANVIEN_VAITRO VALUES ('NV04', 'BACSI');
CREATE TABLE BENHNHAN
(
    ID_BENHNHAN NVARCHAR2(30),
    EMAIL_BACSI NVARCHAR2(30),
    BENH NVARCHAR2(30),
    PRIMARY KEY (ID_BENHNHAN)
);
INSERT INTO BENHNHAN VALUES ('BN0001', 'HHONG@GMAIL.COM', 'SOI THAN');
INSERT INTO BENHNHAN VALUES ('BN0002', 'BDUY@GMAIL.COM', 'HIV');
INSERT INTO BENHNHAN VALUES ('BN0003', 'NTHIEN@GMAIL.COM', 'UNG THU');
--================================
grant select on SIMPLEAC.NHANVIEN to NV01;
grant select on SIMPLEAC.NHANVIEN to NV02;
grant select on SIMPLEAC.NHANVIEN to NV03;
grant select on SIMPLEAC.NHANVIEN to NV04;
grant select on SIMPLEAC.NHANVIEN_VAITRO to NV01;
grant select on SIMPLEAC.NHANVIEN_VAITRO to NV02;
grant select on SIMPLEAC.NHANVIEN_VAITRO to NV03;
grant select on SIMPLEAC.NHANVIEN_VAITRO to NV04;
grant select on SIMPLEAC.BENHNHAN to NV01;
grant select on SIMPLEAC.BENHNHAN to NV02;
grant select on SIMPLEAC.BENHNHAN to NV03;
grant select on SIMPLEAC.BENHNHAN to NV04;
--================================

/*
DELETE NHANVIEN;
DELETE NHANVIEN_VAITRO;
DELETE BENHNHAN;
DROP TABLE NHANVIEN;
DROP TABLE NHANVIEN_VAITRO;
DROP TABLE BENHNHAN;
*/

-- CHÍNH SÁCH: VPD_NHÂN VIÊN: MỖI NHÂN VIÊN CHỈ ĐƯỢC XEM LƯƠNG CỦA CHÍNH MÌNH CÒN SIMPLEAC VÀ NHỮNG
-- NHÂN VIÊN KẾ TOÁN ĐƯỢC XEM LƯƠNG CỦA MỌI NGƯỜI
--================================
Create or replace function VPD_NHANVIEN(schema varchar2,object varchar2)
    return varchar2
as 
    user varchar2(100);
begin
    if ((SYS_CONTEXT('userenv', 'SESSION_USER'))='SIMPLEAC') then
        return '';
    else
        user:= SYS_CONTEXT('userenv', 'SESSION_USER');
        return 'USERNAME = user     OR (''NVKETOAN'' IN (SELECT NVVT.VAITRO FROM SIMPLEAC.NHANVIEN_VAITRO NVVT
                                WHERE NVVT.USERNAME = USER))';
    end if;
end;
/
--================================
BEGIN
    DBMS_RLS.ADD_POLICY
    (
        OBJECT_SCHEMA         => 'SIMPLEAC',
        OBJECT_NAME           => 'NHANVIEN',
        POLICY_NAME           => 'VPD_NHANVIEN_POLICY',
        POLICY_FUNCTION       => 'VPD_NHANVIEN',
        SEC_RELEVANT_COLS     => 'SALARY',
        SEC_RELEVANT_COLS_OPT => DBMS_RLS.ALL_ROWS
    );
END;
/
--================================
-- HÀM GỠ CHÍNH SÁCH
BEGIN
   DBMS_RLS.DROP_POLICY (
       OBJECT_SCHEMA => 'SIMPLEAC',
       OBJECT_NAME   => 'NHANVIEN',
       POLICY_NAME   => 'VPD_NHANVIEN_POLICY'
   );
END;
/

-- HÀM VPD_BENHNHAN: MỖI BÁC SĨ CHỈ XEM ĐƯỢC BỆNH NHÂN CỦA MÌNH (EMAIL = EMAIL_BACSI)
-- CÒN SIMPLEAC XEM ĐƯỢC HẾT
--================================
Create or replace function VPD_BENHNHAN(schema varchar2,object varchar2)
    return varchar2
as 
    user varchar2(100);
begin
    if ((SYS_CONTEXT('userenv', 'SESSION_USER'))='SIMPLEAC') then
        return '';
    else
        user:= SYS_CONTEXT('userenv', 'SESSION_USER');
        return 'EMAIL_BACSI IN (SELECT EMAIL FROM SIMPLEAC.NHANVIEN WHERE USER = USERNAME) 
                                AND (''BACSI'' IN (SELECT NVVT.VAITRO FROM SIMPLEAC.NHANVIEN_VAITRO NVVT
                                WHERE NVVT.USERNAME = USER))';
    end if;
end;
/
--================================
BEGIN
    DBMS_RLS.ADD_POLICY
    (
        OBJECT_SCHEMA   => 'SIMPLEAC',
        OBJECT_NAME     => 'BENHNHAN',
        POLICY_NAME     => 'VPD_BENHNHAN_POLICY',
        POLICY_FUNCTION => 'VPD_BENHNHAN'
    );
END;
/
--================================
BEGIN
   DBMS_RLS.DROP_POLICY (
       OBJECT_SCHEMA => 'SIMPLEAC',
       OBJECT_NAME   => 'BENHNHAN',
       POLICY_NAME   => 'VPD_BENHNHAN_POLICY'
   );
END;
/

--================================
BEGIN
    DBMS_RLS.ADD_POLICY
    (
        OBJECT_SCHEMA         => 'SIMPLEAC',
        OBJECT_NAME           => 'NHANVIEN',
        POLICY_NAME           => 'VPD_NHANVIEN_POLICY',
        POLICY_FUNCTION       => 'VPD_NHANVIEN',
        SEC_RELEVANT_COLS     => 'SALARY',
        SEC_RELEVANT_COLS_OPT => DBMS_RLS.ALL_ROWS
    );
END;
/
BEGIN
    DBMS_RLS.ADD_POLICY
    (
        OBJECT_SCHEMA   => 'SIMPLEAC',
        OBJECT_NAME     => 'BENHNHAN',
        POLICY_NAME     => 'VPD_BENHNHAN_POLICY',
        POLICY_FUNCTION => 'VPD_BENHNHAN'
    );
END;
/
--================================
BEGIN
   DBMS_RLS.DROP_POLICY (
       OBJECT_SCHEMA=> 'SIMPLEAC',
       OBJECT_NAME  => 'NHANVIEN',
       POLICY_NAME  => 'VPD_NHANVIEN_POLICY'
   );
END;
/
BEGIN
   DBMS_RLS.DROP_POLICY (
       OBJECT_SCHEMA=> 'SIMPLEAC',
       OBJECT_NAME  => 'BENHNHAN',
       POLICY_NAME  => 'VPD_BENHNHAN_POLICY'
   );
END;
/
--================================
SELECT * FROM SIMPLEAC.NHANVIEN;
SELECT * FROM SIMPLEAC.NHANVIEN_VAITRO;
---------------------------------------------------------------------------
create or replace context nhanvien_context using nhanvien_context_pack;
/
create or replace package nhanvien_context_pack
is
    procedure initialize;
end;
/
create or replace package body nhanvien_context_pack
is
    procedure initialize
    is
        t_vaitro nvarchar2(30);
        t_email nvarchar2(30);
        t_username nvarchar2(30);
    begin
        select NVVT.VAITRO, NV.EMAIL, NV.USERNAME
        into t_vaitro, t_email, t_username
        from SIMPLEAC.NHANVIEN NV, SIMPLEAC.NHANVIEN_VAITRO NVVT 
        where NV.USERNAME = sys_context('USERENV', 'SESSION_USER') AND NV.USERNAME = NVVT.USERNAME;
        DBMS_SESSION.set_context('nhanvien_context', 'nv_vaitro', t_vaitro);
        DBMS_SESSION.set_context('nhanvien_context', 'nv_email', t_email);
        DBMS_SESSION.set_context('nhanvien_context', 'nv_username', t_username);
    end;
end;
/
CONN SIMPLEAC/123456
create or replace trigger emp_logon
after logon on database
begin
    nhanvien_context_pack.initialize;
end;
/
/*
    CONN SIMPLEAC/123456
    DROP TRIGGER emp_logon;
*/

conn NV01/PWNV01
select sys_context('nhanvien_context', 'nv_vaitro') from dual;
select sys_context('nhanvien_context', 'nv_email') from dual;
select sys_context('nhanvien_context', 'nv_username') from dual;
conn NV02/PWNV02
select sys_context('nhanvien_context', 'nv_vaitro') from dual;
select sys_context('nhanvien_context', 'nv_email') from dual;
select sys_context('nhanvien_context', 'nv_username') from dual;
conn NV03/PWNV03
select sys_context('nhanvien_context', 'nv_vaitro') from dual;
select sys_context('nhanvien_context', 'nv_email') from dual;
select sys_context('nhanvien_context', 'nv_username') from dual;
conn NV04/PWNV04
select sys_context('nhanvien_context', 'nv_vaitro') from dual;
select sys_context('nhanvien_context', 'nv_email') from dual;
select sys_context('nhanvien_context', 'nv_username') from dual;

conn NV01/PWNV01
SELECT * FROM SIMPLEAC.NHANVIEN;
conn NV02/PWNV02
SELECT * FROM SIMPLEAC.NHANVIEN;
SELECT * FROM SIMPLEAC.BENHNHAN;
conn NV03/PWNV03
SELECT * FROM SIMPLEAC.NHANVIEN;
SELECT * FROM SIMPLEAC.BENHNHAN;
conn NV04/PWNV04
SELECT * FROM SIMPLEAC.NHANVIEN;
SELECT * FROM SIMPLEAC.BENHNHAN;

--================================
Create or replace function VPD_NHANVIEN(schema varchar2,object varchar2)
    return varchar2
as 
begin
    if ((SYS_CONTEXT('userenv', 'SESSION_USER'))='SIMPLEAC') then
        return '';
    else
        return '(USERNAME = sys_context(''nhanvien_context'', ''nv_username'')) 
        OR ''NVKETOAN'' = sys_context(''nhanvien_context'', ''nv_vaitro'')';
    end if;
end;
/
Create or replace function VPD_BENHNHAN(schema varchar2,object varchar2)
    return varchar2
as 
    nv_vaitro nvarchar2(100);
    nv_email nvarchar2(100);
begin
    if ((SYS_CONTEXT('userenv', 'SESSION_USER'))='SIMPLEAC') then
        return '';
    else
        return 'EMAIL_BACSI = sys_context(''nhanvien_context'', ''nv_email'')
                    AND ''BACSI'' = sys_context(''nhanvien_context'', ''nv_vaitro'')';
    end if;
end;
/
--================================
BEGIN
    DBMS_RLS.ADD_POLICY
    (
        OBJECT_SCHEMA         => 'SIMPLEAC',
        OBJECT_NAME           => 'EMP',
        POLICY_NAME           => 'VPD_EMP_POLICY',
        POLICY_FUNCTION       => 'VPD_EMP',
        SEC_RELEVANT_COLS     => 'salary',
        SEC_RELEVANT_COLS_OPT => DBMS_RLS.ALL_ROWS
    );
END;
/

DROP FUNCTION VPD_NHANVIEN;
BEGIN
   DBMS_RLS.DROP_POLICY (
        OBJECT_SCHEMA => 'SIMPLEAC',
        OBJECT_NAME   => 'NHANVIEN',
        POLICY_NAME   => 'VPD_NHANVIEN_POLICY'
   );
END;
/
--================================
BEGIN
   DBMS_RLS.DROP_POLICY (
        OBJECT_SCHEMA => 'SIMPLEAC',
        OBJECT_NAME   => 'NHANVIEN',
        POLICY_NAME   => 'VPD_NHANVIEN_POLICY'
   );
END;
/
BEGIN
   DBMS_RLS.DROP_POLICY (
        OBJECT_SCHEMA => 'SIMPLEAC',
        OBJECT_NAME   => 'BENHNHAN',
        POLICY_NAME   => 'VPD_BENHNHAN_POLICY'
   );
END;
/
--================================ NGOẠI LỆ
GRANT EXEMPT ACCESS POLICY TO NV03;
REVOKE EXEMPT ACCESS POLICY FROM NV03;




CREATE OR REPLACE FUNCTION VPD_EMP(SCHEMA VARCHAR2,OBJECT VARCHAR2)
    RETURN VARCHAR2
AS 
    USER VARCHAR2(100);
BEGIN
    USER := SYS_CONTEXT('USERENV', 'SESSION_USER');
    if (SYS_CONTEXT('nhanvien_context', 'e_pos') = 'MANAGER' OR
        SYS_CONTEXT('nhanvien_context', 'e_pos') = 'ADMIN') then
        RETURN '1 = 1';
    else
        RETURN 'id =' || ' SYS_CONTEXT('nhanvien_context', 'e_id')';
    end if;
END;
/


SELECT * FROM SIMPLEAC.NHANVIEN;
SELECT * FROM SIMPLEAC.NHANVIEN_VAITRO;
SELECT * FROM SIMPLEAC.BENHNHAN;


SELECT * FROM SIMPLEAC.NHANVIEN WHERE 
    USERNAME = SYS_CONTEXT('USERENV', 'SESSION_USER') OR ('NVKETOAN' IN (SELECT NVVT.VAITRO FROM SIMPLEAC.NHANVIEN_VAITRO NVVT
                                WHERE NVVT.USERNAME = SYS_CONTEXT('USERENV', 'SESSION_USER')));


SELECT * FROM SIMPLEAC.BENHNHAN WHERE 
    EMAIL_BACSI IN (SELECT NV.EMAIL FROM SIMPLEAC.NHANVIEN NV WHERE SYS_CONTEXT('USERENV', 'SESSION_USER') = USERNAME) 
        AND ('BACSI' IN (SELECT NVVT.VAITRO FROM SIMPLEAC.NHANVIEN_VAITRO NVVT
        WHERE NVVT.USERNAME = SYS_CONTEXT('USERENV', 'SESSION_USER')));

SELECT * FROM SIMPLEAC.NHANVIEN WHERE
    (USERNAME = sys_context('nhanvien_context', 'nv_username')) OR 'NVKETOAN' = sys_context('nhanvien_context', 'nv_vaitro');
        nv_username := sys_context('nhanvien_context', 'nv_username');
        nv_vaitro := sys_context('nhanvien_context', 'nv_vaitro');
        return '(USERNAME = nv_username) OR (''NVKETOAN'' = nv_vaitro)';

SELECT * FROM SIMPLEAC.BENHNHAN WHERE 
    EMAIL_BACSI = sys_context('nhanvien_context', 'nv_email')
    AND 'BACSI' = sys_context('nhanvien_context', 'nv_vaitro');


SELECT OBJECT_OWNER, OBJECT_NAME, POLICY, PREDICATE
FROM V$VPD_POLICY;
SELECT * FROM V$VPD_POLICY;