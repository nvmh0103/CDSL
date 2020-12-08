CREATE DATABASE DE2THI
USE DE2THI
CREATE TABLE NHANVIEN(
    MANV CHAR(5) PRIMARY KEY,
    HOTEN VARCHAR(20),
    NGAYVL SMALLDATETIME,
    HSLUONG NUMERIC(4,2),
    MAPHONG CHAR(5),
)
CREATE TABLE PHONGBAN(
    MAPHONG CHAR(5) PRIMARY KEY,
    TENPHONG VARCHAR(25),
    TRUONGPHONG CHAR(5),
)
CREATE TABLE XE(
    MAXE CHAR(5) PRIMARY KEY,
    LOAIXE VARCHAR(20),
    SOCHONGOI INT,
    NAMSX INT,
)
CREATE TABLE PHANCONG(
    MAPC CHAR(5) PRIMARY KEY,
    MANV CHAR(5),
    MAXE CHAR(5),
    NGAYDI SMALLDATETIME,
    NGAYVE SMALLDATETIME,
    NOIDEN VARCHAR(25),
    CONSTRAINT FK_MANV FOREIGN KEY (MANV) REFERENCES NHANVIEN(MANV),
    CONSTRAINT FK_MAXE FOREIGN KEY (MAXE) REFERENCES XE(MAXE),
)
DROP TRIGGER XE_NAMSX
CREATE TRIGGER XE_NAMSX ON XE 
FOR UPDATE, INSERT 
AS 
BEGIN 
    DECLARE @LOAIXE VARCHAR(20), @NAMSX INT
    SELECT @LOAIXE=LOAIXE, @NAMSX=NAMSX
    FROM inserted
    IF (@LOAIXE='TOYOTA') 
        IF (@NAMSX>=2006)
            BEGIN
                PRINT ' XE DU DIEU KIEN'
            END
        ELSE
            BEGIN
                PRINT 'LOI: XE KHONG DU DIEU KIEN'
                ROLLBACK TRANSACTION
            END
    ELSE 
        BEGIN
            PRINT 'THEM XE THANH CONG!'
        END
END

-- CAU 2
USE DE2THI
DROP TRIGGER NV_XE
CREATE TRIGGER NV_XE ON NHANVIEN
FOR INSERT,UPDATE
AS
BEGIN
    DECLARE @MANV CHAR(5),@TENPHONG VARCHAR(25),@LOAIXE VARCHAR(20),@MAPHONG CHAR(5)
    SELECT @MANV=MANV,@MAPHONG=MAPHONG
    FROM INSERTED
    SELECT @TENPHONG=TENPHONG
    FROM PHONGBAN
    WHERE MAPHONG=@MAPHONG
    SELECT @LOAIXE=LOAIXE
    FROM XE,PHANCONG
    WHERE XE.MAXE=PHANCONG.MAXE AND MANV=@MANV
    IF (@LOAIXE='TOYOTA')
        IF (@TENPHONG='NGOAI THANH')
            BEGIN
                PRINT 'NHAP NHAN VIEN THANH CONG!'
            END
        ELSE
            BEGIN
                PRINT 'NHAP NHAN VIEN BI LOI'
                ROLLBACK TRANSACTION
            END
    ELSE
        PRINT 'NHAP NHAN VIEN THANH CONG!'
END
USE DE2THI
DROP TRIGGER NV_XE1
CREATE TRIGGER NV_XE1 ON XE 
FOR UPDATE 
AS
BEGIN
    DECLARE @MANV CHAR(5),@TENPHONG VARCHAR(25),@LOAIXE VARCHAR(20),@MAXE CHAR(5)
    SELECT @LOAIXE=LOAIXE,@MAXE=MAXE
    FROM inserted
    DECLARE CUR_NHANVIEN CURSOR
    FOR
        SELECT TENPHONG
        FROM  PHANCONG,NHANVIEN,PHONGBAN
        WHERE  PHANCONG.MAXE=@MAXE AND PHANCONG.MANV=NHANVIEN.MANV AND NHANVIEN.MAPHONG=PHONGBAN.MAPHONG
    OPEN CUR_NHANVIEN 
    FETCH NEXT FROM CUR_NHANVIEN
    INTO @TENPHONG
    WHILE (@@FETCH_STATUS=0)
    BEGIN 
        SELECT TENPHONG
        FROM  PHANCONG,NHANVIEN,PHONGBAN
        WHERE  PHANCONG.MAXE=@MAXE AND PHANCONG.MANV=NHANVIEN.MANV AND NHANVIEN.MAPHONG=PHONGBAN.MAPHONG
        IF (@TENPHONG='NGOAI THANH')
            IF (@LOAIXE='TOYOTA')
                BEGIN
                    PRINT 'NHAP LOAI XE THANH CONG!'
                END
            ELSE
                BEGIN
                    PRINT 'NHAP LOAI XE BI LOI!'
                    ROLLBACK TRANSACTION
                END
        ELSE
            PRINT 'NHAP LOAI XE THANH CONG'
        FETCH NEXT FROM CUR_NHANVIEN
        INTO @TENPHONG
    END
    CLOSE CUR_NHANVIEN
    DEALLOCATE CUR_NHANVIEN
END
--DATA TEST
INSERT INTO XE(MAXE,LOAIXE,SOCHONGOI,NAMSX) VALUES ('XE05','PUDAUBUOI',10,'2004')
INSERT INTO NHANVIEN(MANV,HOTEN,NGAYVL,HSLUONG,MAPHONG) VALUES ('NV01','NVA','1/1/2001',0.5,'PH01')
INSERT INTO PHONGBAN(MAPHONG,TENPHONG,TRUONGPHONG) VALUES ('PH01','TRONG NUOC','NV02')
INSERT INTO PHANCONG(MAPC,MANV,MAXE,NGAYDI,NGAYVE,NOIDEN) VALUES ('PC01','NV01','XE05','1/1/2020','3/1/2020','TPHCM')

UPDATE XE
SET LOAIXE='XEGA'
WHERE MAXE='XE05'

UPDATE PHONGBAN
SET TENPHONG='NGOAI THANH'
WHERE MAPHONG='PH01'

UPDATE XE
SET NAMSX=2010
WHERE MAXE='XE05'

--SQL
--cau1
SELECT NHANVIEN.MANV, HOTEN 
FROM NHANVIEN, PHONGBAN, XE, PHANCONG
WHERE NHANVIEN.MAPHONG=PHONGBAN.MAPHONG AND NHANVIEN.MANV=PHANCONG.MANV AND 
PHANCONG.MAXE = XE.MAXE AND TENPHONG='Ngoai thanh' AND LOAIXE='TOYOTA' AND SOCHONGOI=4

--cau2
SELECT NV.MANV,HOTEN
FROM NHANVIEN NV
WHERE NOT EXISTS (
    SELECT *
    FROM PHONGBAN
    WHERE TRUONGPHONG=NV.MANV AND NOT EXISTS(
        SELECT *
        FROM XE,PHANCONG
        WHERE NV.MANV=PHANCONG.MANV AND NV.MAPHONG=PHONGBAN.MAPHONG
        AND PHANCONG.MAXE=XE.MAXE 
    )
)

--CAU3
SELECT PB1.TENPHONG,NV.MANV,HOTEN,COUNT(MAPC) AS SOLANPC
FROM NHANVIEN NV,PHONGBAN PB1,XE,PHANCONG PC
WHERE PB1.MAPHONG=NV.MAPHONG AND PC.MANV=NV.MANV 
    AND PC.MAXE=XE.MAXE AND LOAIXE='TOYOTA'
GROUP BY PB1.TENPHONG,NV.MANV,HOTEN
HAVING COUNT(MAPC) <= ALL(
    SELECT COUNT(MAPC)
    FROM PHONGBAN PB2,NHANVIEN NV,PHANCONG PC,XE
    WHERE PB2.MAPHONG=NV.MAPHONG AND NV.MANV=PC.MANV AND PC.MAXE=XE.MAXE AND
    LOAIXE='TOYOTA'
    GROUP BY PB2.TENPHONG,NV.MANV
    HAVING PB1.TENPHONG=PB2.TENPHONG
)
