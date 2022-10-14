/* ---------------------------------------------------- */
/*  Generated by Enterprise Architect Version 15.2 		*/
/*  Created On : 09-Aug-2022 4:59:52 PM 				*/
/*  DBMS       : MySql 						*/
/* ---------------------------------------------------- */

-- SET FOREIGN_KEY_CHECKS=0; 
/* Create Database xface_sysgtem */
-- drop database if EXISTS xface_system;
CREATE DATABASE IF NOT EXISTS xface_system;
use xface_system;
/* Create Account Tables */
DROP TABLE IF EXISTS `account` CASCADE;
CREATE TABLE `account`
(
	`username` VARCHAR(100) NOT NULL,
	`password` VARCHAR(250) NOT NULL,
	`email` VARCHAR(100) NULL,
	`cellphone` VARCHAR(15) NULL,
	`note` TEXT NULL,
    `is_root` BOOL NOT NULL DEFAULT false,
	CONSTRAINT `PK_Account` PRIMARY KEY (`username` ASC)
);

/* Insert into account table*/
insert into `account` (`username`, `password`, `email`, `cellphone`, `note`, `is_root`) values ('root', '$argon2id$v=19$m=65536,t=3,p=1$fkrnJ5pEaFLswsYR5y5PsA$Rx4Hvw+yFzU5s5rjBedPGN6pLR3aq/ZkFTAEUibivHk', 'root@root', '0965397777', 'root is super account', true);

/* Create ACL Tables */
DROP TABLE IF EXISTS `acl` CASCADE;
CREATE TABLE `acl`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`username` VARCHAR(100) NOT NULL,
	`tag_type` VARCHAR(200) NOT NULL,
	`tag_qualifier` VARCHAR(50) NULL,
	`permissions` VARCHAR(20) NOT NULL,
	CONSTRAINT `PK_Account` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints acl -> account */
ALTER TABLE `acl` 
 ADD CONSTRAINT `FK_acl_account`
	FOREIGN KEY (`username`) REFERENCES `account` (`username`) ON DELETE Cascade ON UPDATE Cascade;


/* Create Tables */
DROP TABLE IF EXISTS `enterprise` CASCADE;
CREATE TABLE `enterprise`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`enterprise_code` VARCHAR(100) NULL,
	`name` VARCHAR(100) NULL,
	`email` VARCHAR(100) NULL,
	`about` TEXT NULL,
	`address` TEXT NULL,
	`phone` TEXT NULL,
	`official_page` TEXT NULL,
	`note` TEXT NULL,
	CONSTRAINT `PK_Enterprise` PRIMARY KEY (`id` ASC)
);

/* Insert into enterprise*/
insert into `enterprise` (`enterprise_code`, `name`, `email`, `about`, `address`, `phone`, `official_page`) values ('vtx', 'Viettel Aerospace Institute/Viện Hàng không Vũ trụ Viettel', 'vtx.hr@viettel.com.vn','Viện Hàng không Vũ trụ Viettel (VTX) - trực thuộc Tập đoàn Viễn thông Quân đội, là đơn vị nghiên cứu, thiết kế, sản xuất các sản phẩm thuộc lĩnh vực hàng không vũ trụ. Viện được thành lập từ năm 2015 với mục tiêu đánh thức sức mạnh, đưa Việt Nam trở thành một trong các quốc gia chinh phục được lĩnh vực hàng không vũ trụ.', 'Toà nhà Viettel 20 Tầng, Khu CNC Hoà Lạc, Thạch Thất, Hà Nội Hanoi, Vietnam 100000', '046.281.6666', 'https://www.facebook.com/ViettelX');

/* Create Staff Table */
DROP TABLE IF EXISTS `staff` CASCADE
;
CREATE TABLE `staff`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`staff_code` VARCHAR(20) NULL,
	`email_code` VARCHAR(100) NULL,
	`unit` VARCHAR(300) NULL,
	`title` VARCHAR(200) NULL,
	`fullname` VARCHAR(100) NULL,
	`nickname` VARCHAR(100) NULL,
	`cellphone` VARCHAR(15) NULL,
	`date_of_birth` DATE NULL,
	`sex` VARCHAR(10) NULL,
	`state` INT NULL,
	`notify_enable` BOOL NULL,
	`note` TEXT NULL,
	CONSTRAINT `PK_Staff` PRIMARY KEY (`id` ASC)
);

/* Create FaceID Tables */
DROP TABLE IF EXISTS `faceid` CASCADE
;
CREATE TABLE `faceid`
(
	`int` INT NOT NULL AUTO_INCREMENT,
	`staff_id` INT NULL,
	`avatar` BLOB NULL,
	`milvus_collection` VARCHAR(200) NULL,
	`description` TEXT NULL,
	CONSTRAINT `PK_FaceID` PRIMARY KEY (`int` ASC)
);
/* Create Foreign Key Constraints */
ALTER TABLE `faceid` 
 ADD CONSTRAINT `FK_FaceID_Staff`
	FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE Cascade ON UPDATE Cascade;

/* Create Shift_Time Tables */
DROP TABLE IF EXISTS `shift_time` CASCADE;
CREATE TABLE `shift_time`
(
	`shift_type` VARCHAR(20) NOT NULL,
	`weekday` INT NOT NULL,
	`start_time` DATETIME NOT NULL,
	`work_hour` INT NOT NULL,
	CONSTRAINT `PK_Shift_Time` PRIMARY KEY (`shift_type` ASC, `weekday` ASC)
);

/* Create Shift_Register Tables */
DROP TABLE IF EXISTS `shift_register` CASCADE;
CREATE TABLE `shift_register`
(
	`staff_id` INT NOT NULL,
	`shift_type` VARCHAR(20) NOT NULL,
	`weekday` INT NOT NULL
);
/* Create Foreign Key Constraints */
ALTER TABLE `shift_register` 
 ADD CONSTRAINT `FK_Shift_Register_Shift_Time`
	FOREIGN KEY (`shift_type`, `weekday`) REFERENCES `shift_time` (`shift_type`,`weekday`) ON DELETE No Action ON UPDATE No Action;

ALTER TABLE `shift_register` 
 ADD CONSTRAINT `FK_Shift_Register_Staff`
	FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE Cascade ON UPDATE Cascade;

/* Create Site Tables */
DROP TABLE IF EXISTS `site` CASCADE;
CREATE TABLE `site`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(200) NULL,
	`description` TEXT NULL COMMENT 'ote',
	`note` TEXT NULL,
	CONSTRAINT `PK_Site` PRIMARY KEY (`id` ASC)
);

/* Create Site_IO_Register Tables */
DROP TABLE IF EXISTS `site_io_register` CASCADE;
CREATE TABLE `site_io_register`
(
	`id` BIGINT NOT NULL AUTO_INCREMENT,
	`site_id` INT NOT NULL,
	`staff_id` INT NOT NULL,
	`start_time` DATETIME NOT NULL,
	`end_time` DATETIME NOT NULL,
	`effective` BOOL NOT NULL DEFAULT false,
	CONSTRAINT `PK_Site_IO_Register` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints */
ALTER TABLE `site_io_register` 
 ADD CONSTRAINT `FK_Site_IO_Register_Site`
	FOREIGN KEY (`site_id`) REFERENCES `site` (`id`) ON DELETE No Action ON UPDATE No Action;

ALTER TABLE `site_io_register` 
 ADD CONSTRAINT `FK_Site_IO_Register_Staff`
	FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE No Action ON UPDATE No Action;

/* Create Session_Service Tables */
-- DROP TABLE IF EXISTS `session_service` CASCADE;
-- CREATE TABLE `session_service`
-- (
-- 	`id` INT NOT NULL AUTO_INCREMENT,
-- 	`site_id` INT NOT NULL,
-- 	`type` VARCHAR(100) NOT NULL,
-- 	`is_registered` BOOL NOT NULL DEFAULT false,
-- 	`name` VARCHAR(100) NULL,
-- 	`state` INT NOT NULL DEFAULT 0,
-- 	`start_time` DATETIME NOT NULL,
-- 	`description` TEXT NULL,
-- 	CONSTRAINT `PK_Session_Service` PRIMARY KEY (`id` ASC)
-- );
-- /* Create Foreign Key Constraints */
-- ALTER TABLE `session_service` 
--  ADD CONSTRAINT `FK_Session_Service_Site`
-- 	FOREIGN KEY (`site_id`) REFERENCES `site` (`id`) ON DELETE Cascade ON UPDATE Cascade;

/* Create Camera Tables */
DROP TABLE IF EXISTS `camera` CASCADE;
CREATE TABLE `camera`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`site_id` INT NULL,
	`ip` VARCHAR(20) NOT NULL,
	`name` VARCHAR(100) NULL,
	`description` TEXT NULL,
	`rtsp_uri` TEXT NULL,
	`stream` TEXT NULL,
	CONSTRAINT `PK_Camera` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints */
-- ALTER TABLE `camera` 
--  ADD CONSTRAINT `FK_Camera_Session_Service`
-- 	FOREIGN KEY (`session_service_id`) REFERENCES `session_service` (`id`) ON DELETE No Action ON UPDATE No Action;

-- ALTER TABLE `camera` 
--  ADD CONSTRAINT `FK_Camera_Site`
-- 	FOREIGN KEY (`site_id`) REFERENCES `site` (`id`) ON DELETE Cascade ON UPDATE Cascade;

/* Create Restricted_ROI Tables */
DROP TABLE IF EXISTS `restricted_roi` CASCADE;
CREATE TABLE `restricted_roi`
(
	`id` INT NOT NULL AUTO_INCREMENT,
	`cam_id` INT NOT NULL,
	`x` FLOAT(0,0) NULL,
	`y` FLOAT(0,0) NULL,
	`width` FLOAT(0,0) NULL,
	`height` FLOAT(0,0) NULL,
	CONSTRAINT `PK_Restricted_ROI` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints */
ALTER TABLE `restricted_roi` 
 ADD CONSTRAINT `FK_Restricted_ROI_Camera`
	FOREIGN KEY (`cam_id`) REFERENCES `camera` (`id`) ON DELETE Cascade ON UPDATE Cascade;

/* Create Detection Tables */
DROP TABLE IF EXISTS `detection` CASCADE;
CREATE TABLE `detection`
(
	`id` BIGINT NOT NULL AUTO_INCREMENT,
	`staff_id` INT NOT NULL,
	`cam_id` INT NOT NULL,
	`session_id` VARCHAR(300) NULL,
	`frame_id` BIGINT NOT NULL,
	`detection_time` DATETIME(3) NOT NULL,
	`detection_score` FLOAT(0,0) NOT NULL,
	`blur_score` FLOAT(0,0) NULL,
	`box_x` FLOAT(0,0) NOT NULL,
	`box_y` FLOAT(0,0) NOT NULL,
	`box_width` FLOAT(0,0) NOT NULL,
	`box_height` FLOAT(0,0) NOT NULL,
	`has_mask` BOOL NULL,
	`has_pose` BOOL NULL,
	`feature` TEXT NULL,
	`uri_image` VARCHAR(200) NULL,
	CONSTRAINT `PK_Detection` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints */
ALTER TABLE `detection` 
 ADD CONSTRAINT `FK_Detection_Camera`
	FOREIGN KEY (`cam_id`) REFERENCES `camera` (`id`) ON DELETE No Action ON UPDATE No Action;

ALTER TABLE `detection` 
 ADD CONSTRAINT `FK_Detection_Staff`
	FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE No Action ON UPDATE No Action;
/* Create detection time index for detection table */
alter table detection add index Detection_Time (detection_time);

/* Create MOT Tables */
DROP TABLE IF EXISTS `mot` CASCADE;
CREATE TABLE `mot`
(
	`id` BIGINT NOT NULL AUTO_INCREMENT,
	`cam_id` INT NOT NULL,
	`session_id` VARCHAR(300) NULL,
	`frame_id` BIGINT NOT NULL,
	`track_time` DATETIME(3) NOT NULL,
	`track_id` INT NOT NULL,
	`box_x` FLOAT(0,0) NOT NULL,
	`box_y` FLOAT(0,0) NOT NULL,
	`box_width` FLOAT(0,0) NOT NULL,
	`box_height` FLOAT(0,0) NOT NULL,
	CONSTRAINT `PK_MOT` PRIMARY KEY (`id` ASC)
);
/* Create Foreign Key Constraints */
ALTER TABLE `mot` 
 ADD CONSTRAINT `FK_MOT_Camera`
	FOREIGN KEY (`cam_id`) REFERENCES `camera` (`id`) ON DELETE No Action ON UPDATE No Action;

/* Create MTaD Tables */
DROP TABLE IF EXISTS `mtar` CASCADE;
CREATE TABLE `mtar`
(
	`detection_id` BIGINT NOT NULL,
	`mot_id` BIGINT NOT NULL,
	CONSTRAINT `PK_MTaD` PRIMARY KEY (`detection_id` ASC, `mot_id` ASC)
);

SET FOREIGN_KEY_CHECKS=1
; 
