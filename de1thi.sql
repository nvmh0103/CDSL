CREATE DATABASE DE1THI
USE DE1THI
DROP DATABASE DE1THI
CREATE TABLE TACGIA(
    MATG CHAR(5) PRIMARY KEY,
    HOTEN VARCHAR(20),
    DIACHI VARCHAR(50),
    NGSINH SMALLDATETIME,
    SODT VARCHAR(15),
)
CREATE TABLE SACH(
    MASACH CHAR(5) PRIMARY KEY,
    TENSACH VARCHAR(25),
    THELOAI VARCHAR(25),
)
CREATE TABLE TACGIA_SACH(
    MATG CHAR(5),
    MASACH CHAR(5),
    CONSTRAINT PK_TACGIA_SACH PRIMARY KEY (MATG,MASACH),
    CONSTRAINT FK_MATG FOREIGN KEY (MATG) REFERENCES TACGIA(MATG),
    CONSTRAINT FK_MASACH FOREIGN KEY (MASACH) REFERENCES SACH(MASACH),
)
CREATE TABLE PHATHANH(
    MAPH CHAR(5) PRIMARY KEY,
    MASACH CHAR(5),
    NGAYPH SMALLDATETIME,
    SOLUONG INT,
    NHAXUATBAN VARCHAR(20),
    CONSTRAINT FK_MASACH1 FOREIGN KEY (MASACH) REFERENCES SACH(MASACH),
)

-- TRIGGER
-- 1/
USE DE1THI
DROP TRIGGER PHATHANH_NGAYPH
GO
CREATE TRIGGER PHATHANH_NGAYPH ON PHATHANH
FOR UPDATE,INSERT
AS
BEGIN
    DECLARE @NGAYPH SMALLDATETIME,@NGSINH SMALLDATETIME,@MASACH CHAR(5)
    SELECT @NGAYPH=NGAYPH,@MASACH=MASACH
    FROM INSERTED 
    DECLARE CUR_PHATHANH CURSOR
    FOR  
        SELECT NGSINH
        FROM TACGIA TG,TACGIA_SACH TGS
        WHERE TG.MATG=TGS.MATG AND TGS.MASACH=@MASACH
    OPEN CUR_PHATHANH
    FETCH NEXT FROM CUR_PHATHANH
    INTO @NGSINH
    WHILE (@@FETCH_STATUS=0)
    BEGIN
        SELECT NGSINH
        FROM TACGIA TG,TACGIA_SACH TGS
        WHERE TG.MATG=TGS.MATG AND TGS.MASACH=@MASACH
        IF (@NGSINH>@NGAYPH)
            BEGIN
                PRINT 'LOI:NGAY PHAT HANH KHONG HOP LE!'
                ROLLBACK TRANSACTION
            END
        ELSE
            PRINT 'THEM PHAT HANH SACH THANH CONG!'
        FETCH NEXT FROM CUR_PHATHANH
        INTO @NGSINH
    END
    CLOSE CUR_PHATHANH
    DEALLOCATE CUR_PHATHANH
END
DROP TRIGGER TACGIA_NGAYPH

GO
CREATE TRIGGER TACGIA_NGAYPH ON TACGIA
FOR UPDATE
AS
BEGIN
    DECLARE @NGAYPH SMALLDATETIME,@NGSINH SMALLDATETIME,@MATG CHAR(5)
    SELECT @NGSINH=NGSINH,@MATG=MATG
    FROM INSERTED 
    DECLARE CUR_TACGIA CURSOR
    FOR  
        SELECT NGAYPH
        FROM PHATHANH PH,TACGIA_SACH TGS
        WHERE TGS.MATG=@MATG AND TGS.MASACH=PH.MASACH
    OPEN CUR_TACGIA
    FETCH NEXT FROM CUR_TACGIA
    INTO @NGAYPH
    WHILE (@@FETCH_STATUS=0)
    BEGIN
        SELECT NGAYPH
        FROM PHATHANH PH,TACGIA_SACH TGS
        WHERE TGS.MATG=@MATG AND TGS.MASACH=PH.MASACH
        IF (@NGSINH>@NGAYPH)
            BEGIN
                PRINT 'LOI:NGAY SINH KHONG HOP LE!'
                ROLLBACK TRANSACTION
            END
        ELSE
            PRINT 'THEM TAC GIA THANH CONG!'
        FETCH NEXT FROM CUR_TACGIA
        INTO @NGAYPH
    END
    CLOSE CUR_TACGIA
    DEALLOCATE CUR_TACGIA
END

-- IF EXISTS
GO
CREATE TRIGGER NGAYPH ON PHATHANH
FOR UPDATE,INSERT
AS 
BEGIN
    DECLARE @NGAYPH SMALLDATETIME,@NGSINH SMALLDATETIME,@MASACH CHAR(5)
    SELECT @NGAYPH=NGAYPH,@MASACH=MASACH
    FROM INSERTED
    IF EXISTS(
        SELECT NGSINH
        FROM TACGIA TG,TACGIA_SACH TGS
        WHERE TGS.MASACH=@MASACH AND TGS.MATG=TG.MATG AND (NGSINH > @NGAYPH)
    ) 
    BEGIN
        PRINT 'LOI: NGAY PHAT HANH PHAI LON HON NGAY SINH'
        ROLLBACK TRANSACTION
    END
    ELSE
        PRINT 'THEM PHAT HANH THANH CONG'
END



-- DU LIEU TEST
SET DATEFORMAT DMY
UPDATE PHATHANH
SET NGAYPH='1/1/1930'
WHERE MAPH='PH01'
INSERT INTO TACGIA(MATG,HOTEN,DIACHI,NGSINH,SODT) VALUES('TG01','NGUYEN VAN A','255 TRUC CHINH 1','16/01/1993','0902644137')
INSERT INTO SACH(MASACH,TENSACH,THELOAI) VALUES('S01','HOW TO BE BETTER','LIFESTYLE')
INSERT INTO SACH(MASACH,TENSACH,THELOAI) VALUES('S03','HOW TO BE BETTER1','LIFESTYLE')
INSERT INTO SACH(MASACH,TENSACH,THELOAI) VALUES('S04','HOW TO BE BETTER2','LIFESTYLE')

INSERT INTO TACGIA_SACH(MATG,MASACH) VALUES('TG01','S01')
INSERT INTO TACGIA_SACH(MATG,MASACH) VALUES('TG01','S03')
INSERT INTO TACGIA_SACH(MATG,MASACH) VALUES('TG01','S04')
INSERT INTO PHATHANH(MAPH,MASACH,NGAYPH,SOLUONG,NHAXUATBAN) VALUES('PH01','S01','01/01/2020',100,'KIM DONG')
INSERT INTO PHATHANH(MAPH,MASACH,NGAYPH,SOLUONG,NHAXUATBAN) VALUES('PH03','S02','01/01/2020',100,'KIM DONG')
INSERT INTO PHATHANH(MAPH,MASACH,NGAYPH,SOLUONG,NHAXUATBAN) VALUES('PH04','S03','01/01/1990',100,'KIM DONG')

GO
USE DE1THI
UPDATE TACGIA
SET NGSINH='01/01/2030'
WHERE MATG='TG01'

-- CAU 2
GO
CREATE TRIGGER NXB_THELOAI_PHATHANH ON PHATHANH
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @NXB VARCHAR(20),@THELOAI VARCHAR(25),@MASACH CHAR(5)
    SELECT @NXB=NHAXUATBAN,@MASACH=MASACH
    FROM INSERTED
    SELECT @THELOAI=THELOAI
    FROM SACH
    WHERE MASACH=@MASACH
    IF (@THELOAI='GIAO KHOA')
        IF (@NXB='GIAO DUC')
            BEGIN
                PRINT 'NHAP MA PHAT HANH THANH CONG!'
            END
        ELSE
            BEGIN
                PRINT 'LOI: NHAP NHA XUAT BAN KHONG DUNG!'
                ROLLBACK TRANSACTION
            END
    ELSE
        PRINT 'NHAP MA PHAT HANH THANH CONG'
END

DROP TRIGGER NXB_THELOAI_SACH
USE DE1THI
GO
CREATE TRIGGER NXB_THELOAI_SACH ON SACH
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @NXB VARCHAR(20),@THELOAI VARCHAR(25),@MASACH CHAR(5)
    SELECT @THELOAI=THELOAI,@MASACH=MASACH
    FROM INSERTED
    SELECT @NXB=NHAXUATBAN
    FROM PHATHANH
    WHERE MASACH=@MASACH
    IF (@NXB='GIAO DUC')
        IF (@THELOAI='GIAO KHOA')
            BEGIN
                PRINT 'NHAP SACH THANH CONG!'
            END
        ELSE
            BEGIN
                PRINT 'LOI: NHAP THE LOAI SACH KHONG DUNG!'
                ROLLBACK TRANSACTION
            END
    ELSE
        PRINT 'NHAP SACH THANH CONG'
END
-- IF EXISTS

GO
ALTER TRIGGER SACH_THELOAI ON SACH
FOR UPDATE
AS
BEGIN
     DECLARE @NXB VARCHAR(20),@THELOAI VARCHAR(25),@MASACH CHAR(5)
     SELECT @THELOAI=THELOAI,@MASACH=MASACH
    FROM INSERTED
    IF EXISTS(
        SELECT NHAXUATBAN
        FROM PHATHANH
        WHERE PHATHANH.MASACH=@MASACH AND (@THELOAI!='GIAO KHOA') AND (NHAXUATBAN = 'GIAO DUC')
    )
    BEGIN
        PRINT 'NHAP SAI THE LOAI'
        ROLLBACK TRANSACTION
    END
    ELSE
        PRINT 'NHAP THE LOAI THANH CONG'
END
-- DU LIEU TEST

INSERT INTO SACH(MASACH,TENSACH,THELOAI) VALUES ('S02','TIENG VIET','GIAO KHOA')
INSERT INTO PHATHANH(MAPH,MASACH,NGAYPH,SOLUONG,NHAXUATBAN) VALUES ('PH02','S02','01/01/2020',100,'GIAO DUC')
INSERT INTO PHATHANH(MAPH,MASACH,NGAYPH,SOLUONG,NHAXUATBAN) VALUES ('PH05','S05','01/01/2020',100,'GIAO DUC')

UPDATE SACH
SET THELOAI='GIAO '
WHERE MASACH='S02'


SELECT *
FROM SACH
SELECT * 
FROM PHATHANH
SELECT *
FROM TACGIA_SACH


UPDATE PHATHANH
SET NHAXUATBAN='GIAO DUC'
WHERE MAPH='PH02'
SELECT *
FROM SACH

SELECT *
FROM PHATHANH

SELECT*
FROM SACH

