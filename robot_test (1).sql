-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 02, 2021 at 09:48 AM
-- Server version: 10.1.9-MariaDB
-- PHP Version: 5.5.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `robot_test`
--

-- --------------------------------------------------------

--
-- Table structure for table `m01_servers`
--

CREATE TABLE `m01_servers` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `server_id` varchar(4) NOT NULL COMMENT 'サーバID',
  `server_name` varchar(64) DEFAULT NULL COMMENT 'サーバ名',
  `server_type` varchar(1) DEFAULT NULL COMMENT 'サーバ種類	 0 : inbound, 1 : outbound',
  `server_ip` varchar(20) DEFAULT NULL COMMENT 'サーバIP',
  `server_port` varchar(20) DEFAULT NULL COMMENT 'サーバポート',
  `call_module_port` varchar(10) DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL COMMENT 'ユーザー',
  `password` varchar(128) DEFAULT NULL COMMENT 'パスワード',
  `root_user` varchar(64) DEFAULT NULL,
  `root_pass` varchar(128) DEFAULT NULL,
  `local_path` varchar(64) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT NULL,
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m01サーバ';

--
-- Dumping data for table `m01_servers`
--

INSERT INTO `m01_servers` (`id`, `server_id`, `server_name`, `server_type`, `server_ip`, `server_port`, `call_module_port`, `username`, `password`, `root_user`, `root_pass`, `local_path`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(2, '0001', 'devrc-outsv001', '1', '10.1.1.01', '22', '17000', 'robo', 'xxxxxxxx', 'root', NULL, '/home/ftpuser/robo/', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, '0002', 'devrc-insv001', '0', '10.1.1.02', '22', '17000', 'robo', 'xxxxxxxx', 'root', 'gsrc20!6QWERdemo', '/home/ftpuser/robo/inbound/', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(5, '0003', 'dev_outdummy', '1', '10.1.1.03', '22', '17119', 'robo', 'xxxxxxxx', 'root', NULL, '/home/ftpuser/robo/', 'Y', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m02_companies`
--

CREATE TABLE `m02_companies` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `company_code` varchar(128) NOT NULL,
  `company_name` varchar(128) NOT NULL COMMENT '会社名',
  `ch_num` varchar(4) NOT NULL COMMENT 'チャネル数',
  `dial_interval` int(5) DEFAULT '1010',
  `audio_mix_flag` varchar(45) DEFAULT '0' COMMENT '0：なし、1:あり',
  `max_redial` int(5) DEFAULT '0',
  `tel_num` varchar(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザ',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザ',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `accept_consent_flag` varchar(1) DEFAULT '0' COMMENT '0：SMS履歴判定利用不可、1：SMS履歴判定利用可能'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m02 会社マスター';

--
-- Dumping data for table `m02_companies`
--

INSERT INTO `m02_companies` (`id`, `company_id`, `company_code`, `company_name`, `ch_num`, `dial_interval`, `audio_mix_flag`, `max_redial`, `tel_num`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `accept_consent_flag`) VALUES
(1, '002', 'companyA', '株式会社A', '30', 1010, '1', 4, NULL, 'N', '2016-01-22 15:03:01', 'ascadmin', 'ManageAccount_add_edit_account', '2020-03-03 16:32:34', 'ascend', 'ManageAccount_add_edit_account', '0'),
(2, '003', 'companyB', 'companyB', '30', 1010, '1', 1, NULL, '', '2021-06-30 10:51:31', 'fabbi', 'ManageAccount_add_edit_account', '2021-06-30 10:51:31', 'ascend', 'ManageAccount_add_edit_account', '0'),
(3, '004', 'companyC', 'companyC', '', 1010, '1', 1, NULL, 'Y', '2021-06-30 10:51:31', 'fabbi', 'ManageAccount_add_edit_account', '2021-06-30 10:51:31', NULL, NULL, '0'),
(4, '005', 'companyD', 'companyD', '', 1010, '1', 1, NULL, 'Y', '2021-06-30 10:51:31', 'fabbi', 'ManageAccount_add_edit_account', '2021-06-30 10:51:31', NULL, NULL, '0'),
(5, '006', 'companyE', 'companyE', '', 1010, '1', 4, NULL, 'Y', '2016-01-22 15:03:01', 'fabbi', NULL, NULL, NULL, NULL, '0');

-- --------------------------------------------------------

--
-- Table structure for table `m03_auths`
--

CREATE TABLE `m03_auths` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `post_code` varchar(4) NOT NULL COMMENT '権限コード',
  `rank` int(2) DEFAULT NULL,
  `order_num` int(2) DEFAULT NULL,
  `post_name` varchar(64) DEFAULT NULL COMMENT '権限名	 G10,G20,G30,U10,U20,U30',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m03ユーザ権限';

--
-- Dumping data for table `m03_auths`
--

INSERT INTO `m03_auths` (`id`, `post_code`, `rank`, `order_num`, `post_name`, `del_flag`, `entry_user`, `entry_program`, `created`, `modified`, `update_user`, `update_program`) VALUES
(1, 'U10', 4, 4, '管理者', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'U20', 5, 5, '作成閲覧', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'U30', 5, 7, '閲覧のみ', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'G10', 1, 1, 'GS管理者', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'G20', 2, 2, 'GS作成閲覧', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'G30', 3, 3, 'GS閲覧のみ', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 'U25', 5, 6, '発信NG', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 'U25', 5, 6, '発信NG', 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'U25', 5, 6, '発信NG', 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'U25', 5, 6, '発信NG', 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 'A10', 99, 99, 'API利用のみ', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m04_controller_actions`
--

CREATE TABLE `m04_controller_actions` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `post_code` varchar(4) NOT NULL COMMENT '権限コード',
  `controller_name` varchar(64) DEFAULT NULL COMMENT 'コントローラ名',
  `function_name` varchar(64) DEFAULT NULL COMMENT 'フンクション名',
  `memo` text COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m04機能リスト';

--
-- Dumping data for table `m04_controller_actions`
--

INSERT INTO `m04_controller_actions` (`id`, `post_code`, `controller_name`, `function_name`, `memo`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(1, 'G20', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'G20', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'G20', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'G20', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'G20', 'CallListNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'G20', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 'G20', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 'G30', 'Template', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'G30', 'Template', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'G30', 'Template', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 'G30', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 'G30', 'Template', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 'G30', 'CallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 'G30', 'CallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 'G30', 'CallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 'G30', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 'G30', 'DetailCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 'G30', 'DetailCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 'G30', 'DetailCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 'G30', 'DetailCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 'G30', 'RDD', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(22, 'G30', 'Schedule', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(23, 'G30', 'Schedule', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(24, 'G30', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(25, 'G30', 'Schedule', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(26, 'G30', 'Schedule', 'status', NULL, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 'G30', 'Schedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 'G30', 'Schedule', 'call_right_away', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 'G30', 'StatusSchedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(30, 'G30', 'StatusSchedule', 'reopen', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 'G30', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 'G30', 'CallListNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 'G30', 'CallListNg', 'upload', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 'G30', 'CallListNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 'G30', 'CallListNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 'G30', 'CallListNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 'G30', 'DetailCallListNg', 'update', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(38, 'G30', 'DetailCallListNg', 'record', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(39, 'G30', 'DetailCallListNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 'G30', 'DetailCallListNg', 'add', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 'G30', 'InboundTemplate', 'setting_call_tell', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(42, 'G30', 'InboundTemplate', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 'G30', 'InboundTemplate', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 'G30', 'InboundTemplate', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(45, 'G30', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 'G30', 'InboundTemplate', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(47, 'G30', 'CallListReject', 'record', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(48, 'G30', 'CallListReject', 'upload', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(49, 'G30', 'CallListReject', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 'G30', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(51, 'G30', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 'G30', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 'G30', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 'G30', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(55, 'G30', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 'G30', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 'G30', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 'G30', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 'U10', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 'U10', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 'U10', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 'U20', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 'U20', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 'U20', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 'U20', 'ManageUser', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 'U20', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 'U20', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 'U20', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 'U20', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 'U20', 'ManagerNew', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 'U20', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 'U20', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 'U20', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 'U30', 'Template', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 'U30', 'Template', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 'U30', 'Template', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 'U30', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 'U30', 'Template', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 'U30', 'CallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 'U30', 'CallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 'U30', 'CallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 'U30', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 'U30', 'DetailCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 'U30', 'DetailCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 'U30', 'DetailCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 'U30', 'DetailCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 'U30', 'RDD', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 'U30', 'Schedule', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 'U30', 'Schedule', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 'U30', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 'U30', 'Schedule', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 'U30', 'Schedule', 'status', NULL, 'Y', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 'U30', 'Schedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 'U30', 'Schedule', 'call_right_away', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 'U30', 'StatusSchedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 'U30', 'StatusSchedule', 'reopen', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 'U30', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 'U30', 'CallListNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 'U30', 'CallListNg', 'upload', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 'U30', 'CallListNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 'U30', 'CallListNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 'U30', 'CallListNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(103, 'U30', 'DetailCallListNg', 'update', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 'U30', 'DetailCallListNg', 'record', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 'U30', 'DetailCallListNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(106, 'U30', 'DetailCallListNg', 'add', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 'U30', 'InboundTemplate', 'setting_call_tell', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 'U30', 'InboundTemplate', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 'U30', 'InboundTemplate', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 'U30', 'InboundTemplate', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 'U30', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 'U30', 'InboundTemplate', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 'U30', 'CallListReject', 'record', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 'U30', 'CallListReject', 'upload', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(115, 'U30', 'CallListReject', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(116, 'U30', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(117, 'U30', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(118, 'U30', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(119, 'U30', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(120, 'U30', 'ManageUser', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(121, 'U30', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(122, 'U30', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 'U30', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 'U30', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(125, 'U30', 'ManagerNew', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(126, 'U30', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(127, 'U30', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 'U30', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(129, 'G30', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(130, 'G30', 'ManagerAccount', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(131, 'U25', 'ManageUser', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(132, 'U25', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(133, 'U25', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(134, 'U25', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(135, 'U25', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(136, 'U25', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 'U25', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 'U25', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(139, 'U25', 'RDD', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(140, 'U25', 'Template', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 'U25', 'Template', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(142, 'U25', 'Template', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(143, 'U25', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(144, 'U25', 'Template', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(145, 'U25', 'CallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(146, 'U25', 'CallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(147, 'U25', 'CallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(148, 'U25', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(149, 'U25', 'DetailCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(150, 'U25', 'DetailCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(151, 'U25', 'DetailCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 'U25', 'DetailCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(153, 'U25', 'InboundTemplate', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(154, 'U25', 'InboundTemplate', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 'U25', 'InboundTemplate', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 'U25', 'InboundTemplate', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 'U25', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 'U25', 'InboundTemplate', 'setting_call_tell', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 'U25', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(160, 'U25', 'Schedule', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(161, 'U25', 'Schedule', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(162, 'U25', 'Schedule', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(163, 'U25', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(164, 'U25', 'Schedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(165, 'U25', 'Schedule', 'call_right_away', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(166, 'U25', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(167, 'U25', 'StatusSchedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(168, 'U25', 'StatusSchedule', 'reopen', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(169, 'U25', 'ManagerNew', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(170, 'U25', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(171, 'U25', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(172, 'U25', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(173, 'G30', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(174, 'G30', 'ManagerAccount', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(175, 'U25', 'ManageUser', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(176, 'U25', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(177, 'U25', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(178, 'U25', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(179, 'U25', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(180, 'U25', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(181, 'U25', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(182, 'U25', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(183, 'U25', 'RDD', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(184, 'U25', 'Template', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(185, 'U25', 'Template', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(186, 'U25', 'Template', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(187, 'U25', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(188, 'U25', 'Template', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(189, 'U25', 'CallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(190, 'U25', 'CallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(191, 'U25', 'CallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(192, 'U25', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(193, 'U25', 'DetailCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(194, 'U25', 'DetailCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(195, 'U25', 'DetailCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(196, 'U25', 'DetailCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(197, 'U25', 'InboundTemplate', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(198, 'U25', 'InboundTemplate', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(199, 'U25', 'InboundTemplate', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(200, 'U25', 'InboundTemplate', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(201, 'U25', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(202, 'U25', 'InboundTemplate', 'setting_call_tell', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(203, 'U25', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(204, 'U25', 'Schedule', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(205, 'U25', 'Schedule', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(206, 'U25', 'Schedule', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(207, 'U25', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(208, 'U25', 'Schedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(209, 'U25', 'Schedule', 'call_right_away', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(210, 'U25', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(211, 'U25', 'StatusSchedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(212, 'U25', 'StatusSchedule', 'reopen', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(213, 'U25', 'ManagerNew', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(214, 'U25', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(215, 'U25', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(216, 'U25', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(217, 'U25', 'ManageUser', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(218, 'U25', 'ManageUser', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(219, 'U25', 'ManageUser', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(220, 'U25', 'ManageUser', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(221, 'U25', 'ManageUser', 'unlock', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(222, 'U25', 'ManagerAccount', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(223, 'U25', 'ManagerAccount', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(224, 'U25', 'ManagerAccount', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(225, 'U25', 'RDD', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(226, 'U25', 'Template', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(227, 'U25', 'Template', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(228, 'U25', 'Template', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(229, 'U25', 'Template', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(230, 'U25', 'Template', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(231, 'U25', 'CallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(232, 'U25', 'CallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(233, 'U25', 'CallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(234, 'U25', 'CallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 'U25', 'DetailCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(236, 'U25', 'DetailCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(237, 'U25', 'DetailCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(238, 'U25', 'DetailCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(239, 'U25', 'InboundTemplate', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(240, 'U25', 'InboundTemplate', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(241, 'U25', 'InboundTemplate', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(242, 'U25', 'InboundTemplate', 'import', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(243, 'U25', 'InboundTemplate', 'export', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(244, 'U25', 'InboundTemplate', 'setting_call_tell', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(245, 'U25', 'IncomingCallHistory', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(246, 'U25', 'Schedule', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(247, 'U25', 'Schedule', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(248, 'U25', 'Schedule', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(249, 'U25', 'Schedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(250, 'U25', 'Schedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(251, 'U25', 'Schedule', 'call_right_away', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(252, 'U25', 'StatusSchedule', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(253, 'U25', 'StatusSchedule', 'stop_call', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(254, 'U25', 'StatusSchedule', 'reopen', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(255, 'U25', 'ManagerNew', 'list', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(256, 'U25', 'ManagerNew', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(257, 'U25', 'ManagerNew', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(258, 'U25', 'ManagerNew', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(259, 'U30', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(260, 'U30', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(261, 'U30', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(262, 'U30', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(263, 'U25', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(264, 'U25', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(265, 'U25', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(266, 'U25', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(267, 'G30', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(268, 'G30', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(269, 'G30', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(270, 'G30', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(271, 'G20', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(272, 'U30', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(273, 'U30', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(274, 'U30', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(275, 'U30', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(276, 'U25', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(277, 'U25', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(278, 'U25', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(279, 'U25', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(280, 'G30', 'IncomingNg', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(281, 'G30', 'IncomingNg', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(282, 'G30', 'IncomingNg', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(283, 'G30', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(284, 'G20', 'IncomingNg', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(285, 'U30', 'InboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(286, 'U30', 'InboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(287, 'U30', 'InboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(288, 'U30', 'InboundCallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(289, 'U25', 'InboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(290, 'U25', 'InboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(291, 'U25', 'InboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(292, 'U25', 'InboundCallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(293, 'G30', 'InboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(294, 'G30', 'InboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(295, 'G30', 'InboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(296, 'G30', 'InboundCallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(297, 'G20', 'InboundCallList', 'download', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(298, 'G30', 'DetailInboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(299, 'G30', 'DetailInboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(300, 'G30', 'DetailInboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(301, 'G30', 'DetailInboundCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(302, 'U30', 'DetailInboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(303, 'U30', 'DetailInboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(304, 'U30', 'DetailInboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(305, 'U30', 'DetailInboundCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(306, 'U25', 'DetailInboundCallList', 'create', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(307, 'U25', 'DetailInboundCallList', 'delete', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(308, 'U25', 'DetailInboundCallList', 'edit', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(309, 'U25', 'DetailInboundCallList', 'report_not_effective', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(310, 'G20', 'SettingInbound', 'download', NULL, 'N', NULL, NULL, '2016-04-12 19:54:45', NULL, NULL, NULL),
(311, 'G30', 'SettingInbound', 'create', NULL, 'N', NULL, NULL, '2016-04-12 19:54:48', NULL, NULL, NULL),
(312, 'G30', 'SettingInbound', 'delete', NULL, 'N', NULL, NULL, '2016-04-12 19:54:48', NULL, NULL, NULL),
(313, 'G30', 'SettingInbound', 'download', NULL, 'N', NULL, NULL, '2016-04-12 19:54:48', NULL, NULL, NULL),
(314, 'U30', 'SettingInbound', 'create', NULL, 'N', NULL, NULL, '2016-04-12 19:54:48', NULL, NULL, NULL),
(315, 'U30', 'SettingInbound', 'delete', NULL, 'N', NULL, NULL, '2016-04-12 19:54:48', NULL, NULL, NULL),
(316, 'U30', 'SettingInbound', 'download', NULL, 'N', NULL, NULL, '2016-04-12 19:54:49', NULL, NULL, NULL),
(317, 'U25', 'SettingInbound', 'create', NULL, 'N', NULL, NULL, '2016-04-12 19:54:49', NULL, NULL, NULL),
(318, 'U25', 'SettingInbound', 'delete', NULL, 'N', NULL, NULL, '2016-04-12 19:54:49', NULL, NULL, NULL),
(319, 'U25', 'SettingInbound', 'download', NULL, 'N', NULL, NULL, '2016-04-12 19:54:49', NULL, NULL, NULL),
(404, 'G20', 'SmsSendList', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(405, 'G30', 'SmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(406, 'G30', 'SmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(407, 'G30', 'SmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(408, 'G30', 'SmsSendList', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(409, 'U25', 'SmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(410, 'U25', 'SmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(411, 'U25', 'SmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(412, 'U25', 'SmsSendList', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(413, 'U30', 'SmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(414, 'U30', 'SmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(415, 'U30', 'SmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(416, 'U30', 'SmsSendList', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(417, 'G30', 'DetailSmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(418, 'G30', 'DetailSmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(419, 'G30', 'DetailSmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(420, 'G30', 'DetailSmsSendList', 'report_not_effective', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(421, 'U25', 'DetailSmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(422, 'U25', 'DetailSmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(423, 'U25', 'DetailSmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(424, 'U25', 'DetailSmsSendList', 'report_not_effective', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(425, 'U30', 'DetailSmsSendList', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(426, 'U30', 'DetailSmsSendList', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(427, 'U30', 'DetailSmsSendList', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(428, 'U30', 'DetailSmsSendList', 'report_not_effective', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(429, 'G20', 'SmsSendListNG', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(430, 'G30', 'SmsSendListNG', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(431, 'G30', 'SmsSendListNG', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(432, 'G30', 'SmsSendListNG', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(433, 'G30', 'SmsSendListNG', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(434, 'U25', 'SmsSendListNG', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(435, 'U25', 'SmsSendListNG', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(436, 'U25', 'SmsSendListNG', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(437, 'U25', 'SmsSendListNG', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(438, 'U30', 'SmsSendListNG', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(439, 'U30', 'SmsSendListNG', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(440, 'U30', 'SmsSendListNG', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(441, 'U30', 'SmsSendListNG', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(442, 'G30', 'SmsTemplate', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(443, 'G30', 'SmsTemplate', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(444, 'G30', 'SmsTemplate', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(445, 'U25', 'SmsTemplate', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(446, 'U25', 'SmsTemplate', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(447, 'U25', 'SmsTemplate', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(448, 'U30', 'SmsTemplate', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(449, 'U30', 'SmsTemplate', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(450, 'U30', 'SmsTemplate', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(451, 'G20', 'SmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(452, 'G30', 'SmsSchedule', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(453, 'G30', 'SmsSchedule', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(454, 'G30', 'SmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(455, 'G30', 'SmsSchedule', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(456, 'G30', 'SmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(457, 'G30', 'SmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(458, 'U25', 'SmsSchedule', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(459, 'U25', 'SmsSchedule', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(460, 'U25', 'SmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(461, 'U25', 'SmsSchedule', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(462, 'U25', 'SmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(463, 'U25', 'SmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(464, 'U30', 'SmsSchedule', 'create', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(465, 'U30', 'SmsSchedule', 'delete', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(466, 'U30', 'SmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(467, 'U30', 'SmsSchedule', 'edit', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(468, 'U30', 'SmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(469, 'U30', 'SmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(470, 'G20', 'StatusSmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(471, 'G30', 'StatusSmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(472, 'G30', 'StatusSmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(473, 'G30', 'StatusSmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(474, 'G30', 'StatusSmsSchedule', 'finish', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(475, 'U25', 'StatusSmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(476, 'U25', 'StatusSmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(477, 'U25', 'StatusSmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(478, 'U25', 'StatusSmsSchedule', 'finish', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(479, 'U30', 'StatusSmsSchedule', 'stop_send', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(480, 'U30', 'StatusSmsSchedule', 'resend', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(481, 'U30', 'StatusSmsSchedule', 'download', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(482, 'U30', 'StatusSmsSchedule', 'finish', NULL, 'N', NULL, NULL, '2016-05-30 13:45:23', NULL, NULL, NULL),
(483, 'G30', 'ManageMenu', 'edit', NULL, 'N', NULL, NULL, '2016-08-26 15:50:28', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m05_users`
--

CREATE TABLE `m05_users` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `user_no` int(20) DEFAULT NULL,
  `user_id` varchar(20) NOT NULL COMMENT 'ユーザーID',
  `user_name` varchar(64) DEFAULT NULL COMMENT 'ユーザー名',
  `user_pass` varchar(128) NOT NULL COMMENT 'パスワード',
  `password_change_date` datetime NOT NULL COMMENT 'パスワード変更日',
  `post_code` varchar(4) NOT NULL COMMENT '権限コード',
  `login_flag` varchar(1) NOT NULL DEFAULT 'N',
  `lock_flag` varchar(1) DEFAULT 'N' COMMENT 'ロックフラグ',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m05ユーザーマスター';

--
-- Dumping data for table `m05_users`
--

INSERT INTO `m05_users` (`id`, `company_id`, `user_no`, `user_id`, `user_name`, `user_pass`, `password_change_date`, `post_code`, `login_flag`, `lock_flag`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 7, 'fabbi', 'fabbi', 'f417a4882abea1774315f4577bd9eb3e853baae6c7cffa85086666cae4f0020b', '2021-10-18 19:05:11', 'G10', 'Y', 'N', 'N', '2021-02-09 17:35:47', 's_kamo', 'ManageUser_add_and_edit_user', '2021-07-30 15:55:23', 'fabbi', 'PasswordChange_change_password'),
(2, '002', 8, 'fabbi01', 'fabbi01', 'f417a4882abea1774315f4577bd9eb3e853baae6c7cffa85086666cae4f0020b', '2021-09-28 10:57:25', 'G10', 'N', 'N', 'N', '2021-06-30 10:57:25', 'fabbi', 'ManageUser_add_and_edit_user', '2021-07-28 11:17:34', NULL, NULL),
(3, '003', 1, 'fabbi02', 'fabbi02', 'f417a4882abea1774315f4577bd9eb3e853baae6c7cffa85086666cae4f0020b', '2021-09-28 10:58:04', 'U10', 'Y', 'N', 'N', '2021-06-30 10:58:04', 'fabbi', 'ManageUser_add_and_edit_user', '2021-07-28 12:22:04', NULL, NULL),
(4, '003', 1, 'fabbi03', 'fabbi03', '123456789', '2021-09-28 10:58:04', 'U10', 'N', 'N', 'N', '2021-06-30 10:58:04', 'fabbi', 'ManageUser_add_and_edit_user', '2021-07-20 19:07:36', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m06_company_externals`
--

CREATE TABLE `m06_company_externals` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `external_number` varchar(20) NOT NULL COMMENT 'サーバID',
  `out_system` varchar(20) DEFAULT NULL,
  `out_price` varchar(20) DEFAULT NULL,
  `out_unit` varchar(20) DEFAULT NULL,
  `out_phone` varchar(20) DEFAULT NULL,
  `out_mobile` varchar(20) DEFAULT NULL,
  `out_voice` varchar(20) DEFAULT NULL,
  `in_system` varchar(20) DEFAULT NULL,
  `in_price` varchar(20) DEFAULT NULL,
  `in_unit` varchar(20) DEFAULT NULL,
  `in_phone` varchar(20) DEFAULT NULL,
  `in_mobile` varchar(20) DEFAULT NULL,
  `in_voice` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m06会社・サーバマスタ';

--
-- Dumping data for table `m06_company_externals`
--

INSERT INTO `m06_company_externals` (`id`, `company_id`, `external_number`, `out_system`, `out_price`, `out_unit`, `out_phone`, `out_mobile`, `out_voice`, `in_system`, `in_price`, `in_unit`, `in_phone`, `in_mobile`, `in_voice`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', '0363863696', '接続', '3', '1秒', '3', '10', 'あり', '接続', '3', '1秒', '3', '10', 'あり', 'N', '2016-01-22 15:03:01', 'ascend', 'ManageAccount_add_edit_account', '2016-09-07 11:41:20', 'ascend', 'ManageAccount_delete_account'),
(2, '003', '0734523453', '1', '22', '1', '23', '3', NULL, '3', '2', '1', '2', '2', NULL, 'N', '2021-06-30 10:51:31', 'fabbi', 'ManageAccount_add_edit_account', '2021-06-30 10:51:31', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m07_server_externals`
--

CREATE TABLE `m07_server_externals` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `server_id` varchar(4) NOT NULL COMMENT 'サーバID',
  `in_server_id` varchar(4) NOT NULL COMMENT 'インバウンドサーバID',
  `external_prefix` varchar(6) NOT NULL COMMENT '外線番号prefix	 Aサーバ紐づけ',
  `external_number` varchar(20) NOT NULL COMMENT '外線番号',
  `kaisen_code` varchar(64) DEFAULT NULL,
  `in_proc_num` int(5) DEFAULT NULL,
  `enosip_port` varchar(64) DEFAULT NULL,
  `bukken_company_id` varchar(64) DEFAULT NULL,
  `bukken_shop_id` varchar(64) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m07サーバ・外線番号';

--
-- Dumping data for table `m07_server_externals`
--

INSERT INTO `m07_server_externals` (`id`, `server_id`, `in_server_id`, `external_prefix`, `external_number`, `kaisen_code`, `in_proc_num`, `enosip_port`, `bukken_company_id`, `bukken_shop_id`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '0001', '0002', '001902', '0363863695', 'GS1', 3, '1 12-13', NULL, NULL, 'N', NULL, NULL, NULL, '2017-11-06 19:12:39', NULL, NULL),
(2, '0001', '0002', '002902', '0363863696', 'GS1', 3, '2-4', NULL, NULL, 'N', NULL, NULL, NULL, '2017-11-06 19:12:39', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m08_sms_api_infos`
--

CREATE TABLE `m08_sms_api_infos` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL,
  `service_id` varchar(20) NOT NULL COMMENT 'SMSサービスID・企画ID',
  `url` varchar(128) DEFAULT NULL COMMENT 'APIのURL',
  `group_id` varchar(20) DEFAULT NULL COMMENT 'グループID',
  `user` varchar(128) DEFAULT NULL COMMENT '送信ユーザーID',
  `pass` varchar(128) DEFAULT NULL COMMENT 'パスワード',
  `max_parallel_session` varchar(20) DEFAULT NULL COMMENT '最大同時セッション数',
  `max_send_in_minute` varchar(20) DEFAULT NULL COMMENT '分間送信要求受付数',
  `proxy_host` varchar(128) DEFAULT NULL COMMENT 'プロキシサーバー',
  `proxy_port` varchar(128) DEFAULT NULL COMMENT 'プロキシポート番号',
  `proxy_user` varchar(128) DEFAULT NULL COMMENT 'プロキシユーザー名',
  `proxy_pass` varchar(128) DEFAULT NULL COMMENT 'プロキシパスワード',
  `display_number` varchar(20) DEFAULT NULL COMMENT '通知番号',
  `role_code` varchar(20) DEFAULT NULL COMMENT '10:運用管理ユーザー, 20:運用ユーザー, 30:送信ユーザー',
  `memo` varchar(128) DEFAULT NULL COMMENT 'メモ',
  `batch_sleep_time` int(11) DEFAULT '0' COMMENT '連続送信間にのスリップタイム.単位:ミリ秒',
  `api_id` varchar(1) NOT NULL,
  `sms_short_url_allow_flag` varchar(1) NOT NULL DEFAULT '0' COMMENT '0:利用不可、1:利用可',
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m08 SMS API接続情報';

--
-- Dumping data for table `m08_sms_api_infos`
--

INSERT INTO `m08_sms_api_infos` (`id`, `company_id`, `service_id`, `url`, `group_id`, `user`, `pass`, `max_parallel_session`, `max_send_in_minute`, `proxy_host`, `proxy_port`, `proxy_user`, `proxy_pass`, `display_number`, `role_code`, `memo`, `batch_sleep_time`, `api_id`, `sms_short_url_allow_flag`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 'CDgyo3MyOac128', 'https://push.karaden.jp/v2/', NULL, '', '9AUeAaonm52EvyUJ', '2', '120', NULL, NULL, NULL, NULL, '0120558656(試験用.)', NULL, NULL, 500, '2', '1', 'N', '2020-01-16 14:48:05', 'kato', NULL, NULL, NULL, NULL),
(2, '003', 'CDgyo3MyOac128', 'https://push.karaden.jp/v2/', NULL, '', '9AUeAaonm52EvyUJ', '2', '120', NULL, NULL, NULL, NULL, '0120551111(試験用.)', NULL, NULL, 500, '2', '1', 'N', '2020-01-16 14:48:05', 'kato', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m09_kaisen_infos`
--

CREATE TABLE `m09_kaisen_infos` (
  `id` int(11) NOT NULL,
  `kaisen_code` varchar(64) NOT NULL,
  `max_schedule` int(11) NOT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `m09_kaisen_infos`
--

INSERT INTO `m09_kaisen_infos` (`id`, `kaisen_code`, `max_schedule`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 'GS1', 20, 'N', '2017-11-08 17:58:31', 'ascend', NULL, NULL, NULL, NULL),
(2, 'GS2', 3, 'N', '2017-11-08 17:58:31', 'ascend', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m10_api_users`
--

CREATE TABLE `m10_api_users` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `user_name` varchar(64) NOT NULL,
  `user_pass` varchar(128) NOT NULL,
  `ip_address` varchar(30) DEFAULT NULL,
  `api_key` varchar(30) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `m90_pulldown_codes`
--

CREATE TABLE `m90_pulldown_codes` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `type_code` varchar(40) DEFAULT NULL,
  `item_code` varchar(20) DEFAULT NULL COMMENT '値	 value値',
  `item_name` varchar(64) DEFAULT NULL COMMENT '表示名称	 表示名',
  `order_num` int(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ	 1:削除。過去選択済みの場合は表示だけする',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m90 プルダウンコード';

--
-- Dumping data for table `m90_pulldown_codes`
--

INSERT INTO `m90_pulldown_codes` (`id`, `type_code`, `item_code`, `item_name`, `order_num`, `del_flag`, `created`, `modified`) VALUES
(1, 'call_type', '0', '番号通知', 1, 'N', '2015-08-20 15:49:07', NULL),
(2, 'call_type', '1', '非通知', 2, 'N', '2015-08-20 15:49:07', NULL),
(3, 'proc_num', '1', '1ch', 1, 'N', '2015-08-20 15:49:07', NULL),
(4, 'proc_num', '5', '5ch', 6, 'N', '2015-08-20 15:49:07', NULL),
(5, 'proc_num', '10', '10ch', 11, 'N', '2015-08-20 15:49:07', NULL),
(6, 'proc_num', '15', '15ch', 16, 'N', '2015-08-20 15:49:07', NULL),
(7, 'proc_num', '20', '20ch', 21, 'N', '2015-08-20 15:49:07', NULL),
(8, 'proc_num', '25', '25ch', 26, 'N', '2015-08-20 15:49:07', NULL),
(9, 'dial_interval', '1010', '10秒', 1, 'N', '2015-08-20 15:49:07', NULL),
(10, 'dial_interval', '2010', '20秒', 2, 'N', '2015-08-20 15:49:07', NULL),
(11, 'dial_interval', '3010', '30秒', 3, 'N', '2015-08-20 15:49:07', NULL),
(12, 'dial_interval', '4010', '4秒', 5, 'N', '2015-08-20 15:49:07', NULL),
(13, 'dial_wait_time', '60', '60秒', 5, 'N', '2015-08-20 15:49:07', NULL),
(14, 'dial_wait_time', '30', '30秒', 2, 'N', '2015-08-20 15:49:07', NULL),
(15, 'dial_wait_time', '40', '40秒', 3, 'N', '2015-08-20 15:49:07', NULL),
(16, 'dial_wait_time', '50', '50秒', 4, 'N', '2015-08-20 15:49:07', NULL),
(17, 'ans_timeout', '10000', '10秒', 1, 'N', '2015-08-20 15:49:07', NULL),
(18, 'ans_timeout', '20000', '20秒', 2, 'N', '2015-08-20 15:49:07', NULL),
(19, 'ans_timeout', '30000', '30秒', 2, 'N', '2015-08-20 15:49:07', NULL),
(20, 'ans_timeout', '40000', '40秒', 3, 'N', '2015-08-20 15:49:07', NULL),
(21, 'ans_timeout', '50000', '50秒', 5, 'N', '2015-08-20 15:49:07', NULL),
(22, 'ans_timeout', '60000', '60秒', 6, 'N', '2015-08-20 15:49:07', NULL),
(23, 'ans_timeout_count', '0', 'なし', 1, 'N', '2015-08-20 15:49:07', NULL),
(24, 'ans_timeout_count', '1', '1回', 2, 'N', '2015-08-20 15:49:07', NULL),
(51, 'proc_num', '30', '30ch', 31, 'N', '2015-08-20 15:49:07', NULL),
(64, 'proc_num', '35', '35ch', 36, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(65, 'proc_num', '40', '40ch', 41, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(66, 'proc_num', '45', '45ch', 46, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(67, 'proc_num', '50', '50ch', 51, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(68, 'proc_num', '55', '55ch', 56, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(69, 'proc_num', '60', '60ch', 61, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(70, 'proc_num', '65', '65ch', 66, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(71, 'proc_num', '70', '70ch', 71, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(72, 'proc_num', '75', '75ch', 76, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(73, 'proc_num', '80', '80ch', 81, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(74, 'proc_num', '85', '85ch', 86, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(75, 'proc_num', '90', '90ch', 91, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(76, 'proc_num', '95', '95ch', 96, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(77, 'proc_num', '100', '100ch', 101, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(78, 'proc_num', '105', '105ch', 106, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(79, 'proc_num', '110', '110ch', 111, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(80, 'proc_num', '115', '115ch', 116, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(81, 'proc_num', '120', '120ch', 121, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(82, 'proc_num', '125', '125ch', 126, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(83, 'proc_num', '130', '130ch', 131, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(84, 'proc_num', '135', '135ch', 136, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(85, 'proc_num', '140', '140ch', 141, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(86, 'proc_num', '145', '145ch', 146, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(87, 'proc_num', '150', '150ch', 151, 'N', '2015-08-20 15:49:07', '0000-00-00 00:00:00'),
(88, 'trans_cancel_time', '5', '5秒', 1, 'N', '2015-09-10 18:21:29', NULL),
(89, 'trans_cancel_time', '10', '10秒', 2, 'N', '2015-09-10 18:21:29', NULL),
(90, 'trans_cancel_time', '15', '15秒', 3, 'N', '2015-09-10 18:21:29', NULL),
(91, 'trans_cancel_time', '20', '20秒', 5, 'N', '2015-09-10 18:21:29', NULL),
(92, 'trans_cancel_time', '25', '25秒', 6, 'N', '2015-09-10 18:21:29', NULL),
(93, 'callback_flag', '0', 'BUSY', 1, 'N', '2015-09-10 18:21:29', NULL),
(94, 'callback_flag', '1', '音声再生', 2, 'N', '2015-09-10 18:21:29', NULL),
(96, 'proc_num', '3', '3ch', 3, 'N', '2015-08-20 15:49:07', NULL),
(97, 'schedule_time_reload', '0', '---', 1, 'N', '2015-09-28 17:01:33', NULL),
(98, 'schedule_time_reload', '1', '1分', 2, 'N', '2015-09-28 17:01:33', NULL),
(99, 'schedule_time_reload', '2', '2分', 3, 'N', '2015-09-28 17:01:33', NULL),
(100, 'schedule_time_reload', '5', '5分', 5, 'N', '2015-09-28 17:01:33', NULL),
(101, 'schedule_time_reload', '10', '10分', 6, 'N', '2015-09-28 17:01:33', NULL),
(102, 'schedule_time_reload', '15', '15分', 7, 'N', '2015-09-28 17:01:33', NULL),
(103, 'schedule_time_reload', '20', '20分', 8, 'N', '2015-09-28 17:01:33', NULL),
(129, 'list_item', '---', '---', 0, 'Y', NULL, NULL),
(130, 'list_item', 'tel_no', '電話番号', 1, 'N', NULL, NULL),
(131, 'list_item', 'customer_name', '名前', 2, 'N', NULL, NULL),
(132, 'list_item', 'address', '住所', 3, 'N', NULL, NULL),
(133, 'list_item', 'birthday', '生年月日', 5, 'N', NULL, NULL),
(134, 'list_item', 'money', '金額', 6, 'N', NULL, NULL),
(135, 'list_item', 'customize1', '備考1', 7, 'N', NULL, NULL),
(136, 'list_item', 'customize2', '備考2', 8, 'N', NULL, NULL),
(137, 'list_item', 'customize3', '備考3', 9, 'N', NULL, NULL),
(138, 'list_item', 'customize4', '備考4', 10, 'N', NULL, NULL),
(139, 'list_item', 'customize5', '備考5', 11, 'N', NULL, NULL),
(140, 'list_item', 'customize6', '備考6', 12, 'Y', NULL, NULL),
(141, 'list_item', 'customize7', '備考7', 13, 'Y', NULL, NULL),
(142, 'template_ques', '1', '再生', 1, 'N', NULL, NULL),
(143, 'template_ques', '2', '質問', 2, 'N', NULL, NULL),
(144, 'template_ques', '3', '数値認証', 3, 'N', NULL, NULL),
(145, 'template_ques', '4', '番号入力', 5, 'N', NULL, NULL),
(146, 'template_ques', '5', '転送', 6, 'N', NULL, NULL),
(147, 'template_ques', '6', '録音', 7, 'N', NULL, NULL),
(148, 'template_ques', '7', 'カウント', 8, 'N', NULL, NULL),
(149, 'template_ques', '8', '切断', 11, 'N', NULL, NULL),
(151, 'template_answ_loop', '1', '1回', 1, 'N', NULL, NULL),
(152, 'template_answ_loop', '2', '2回', 2, 'N', NULL, NULL),
(153, 'template_answ_loop', '3', '3回', 3, 'N', NULL, NULL),
(154, 'template_answ_loop', '4', '4回', 5, 'N', NULL, NULL),
(155, 'template_answ_loop', '5', '5回', 6, 'N', NULL, NULL),
(157, 'schedule_redial_flag', '0', '0回', 1, 'N', NULL, NULL),
(158, 'schedule_redial_flag', '1', '1回', 2, 'N', NULL, NULL),
(159, 'schedule_redial_time', '10', '10分後', 1, 'N', NULL, NULL),
(160, 'schedule_redial_time', '30', '30分後', 2, 'N', NULL, NULL),
(161, 'schedule_redial_time', '60', '1時間後', 3, 'N', NULL, NULL),
(162, 'schedule_redial_time', '120', '2時間後', 5, 'N', NULL, NULL),
(164, 'out_setup_sys', '1', '発信', 1, 'N', NULL, NULL),
(165, 'out_setup_sys', '3', '接続', 2, 'N', NULL, NULL),
(166, 'in_setup_sys', '0', '---', 0, 'N', NULL, NULL),
(167, 'in_setup_sys', '2', '着信', 1, 'N', NULL, NULL),
(168, 'in_setup_sys', '3', '接続', 2, 'N', NULL, NULL),
(169, 'in_unit', '0', '---', 0, 'N', NULL, NULL),
(170, 'in_unit', '1', '1秒', 1, 'N', NULL, NULL),
(171, 'in_unit', '60', '1分', 2, 'N', NULL, NULL),
(172, 'out_unit', '0', '---', 0, 'N', NULL, NULL),
(173, 'out_unit', '1', '1秒', 1, 'N', NULL, NULL),
(174, 'out_unit', '60', '1分', 2, 'N', NULL, NULL),
(176, 'out_voice', '1', 'あり', 1, 'N', NULL, NULL),
(177, 'out_voice', '0', 'なし', 2, 'N', NULL, NULL),
(178, 'in_voice', '0', '---', 0, 'N', NULL, NULL),
(179, 'in_voice', '1', 'あり', 1, 'N', NULL, NULL),
(180, 'in_voice', '2', 'なし', 2, 'N', NULL, NULL),
(181, 'audio_mix', 'tel_no', '電話番号', 1, 'N', NULL, NULL),
(182, 'audio_mix', 'customer_name', '名前', 2, 'N', NULL, NULL),
(183, 'audio_mix', 'address', '住所', 3, 'N', NULL, NULL),
(184, 'audio_mix', 'birthday', '生年月日', 5, 'N', NULL, NULL),
(185, 'audio_mix', 'money', '金額', 6, 'N', NULL, NULL),
(186, 'out_setup_sys', '0', '---', 0, 'N', NULL, NULL),
(187, 'question_repeat', '0', 'なし', 1, 'N', NULL, NULL),
(188, 'question_repeat', '1', '1回', 2, 'N', NULL, NULL),
(189, 'question_repeat', '2', '2回', 3, 'Y', NULL, NULL),
(190, 'question_repeat', '3', '3回', 5, 'Y', NULL, NULL),
(191, 'question_repeat', '4', '4回', 6, 'Y', NULL, NULL),
(192, 'answer_no', '1', '1', 1, 'N', NULL, NULL),
(193, 'answer_no', '2', '2', 2, 'N', NULL, NULL),
(194, 'answer_no', '3', '3', 3, 'N', NULL, NULL),
(195, 'answer_no', '4', '4', 5, 'N', NULL, NULL),
(196, 'answer_no', '5', '5', 6, 'N', NULL, NULL),
(197, 'answer_no', '6', '6', 7, 'N', NULL, NULL),
(198, 'answer_no', '7', '7', 8, 'N', NULL, NULL),
(199, 'answer_no', '8', '8', 9, 'N', NULL, NULL),
(200, 'answer_no', '9', '9', 10, 'N', NULL, NULL),
(201, 'answer_no', '0', '0', 11, 'N', NULL, NULL),
(202, 'answer_no', '51', '*', 12, 'N', NULL, NULL),
(203, 'answer_no', '52', '#', 13, 'N', NULL, NULL),
(204, 'template_ques', '9', 'タイムアウト', 12, 'N', NULL, NULL),
(205, 'auth_item', 'birthday', '生年月日', 1, 'N', NULL, NULL),
(206, 'auth_item', 'money', '金額', 2, 'N', NULL, NULL),
(207, 'in_unit', '180', '3分', 3, 'N', NULL, NULL),
(208, 'out_unit', '180', '3分', 3, 'N', NULL, NULL),
(209, 'proc_num', '2', '2ch', 2, 'N', NULL, NULL),
(210, 'sync_voice', '1', 'あり', 1, 'N', NULL, NULL),
(211, 'sync_voice', '0', 'なし', 2, 'N', NULL, NULL),
(212, 'outgoing_time', '6', '06', 7, 'N', NULL, NULL),
(213, 'outgoing_time', '7', '07', 8, 'N', NULL, NULL),
(214, 'outgoing_time', '8', '08', 9, 'N', NULL, NULL),
(215, 'outgoing_time', '9', '09', 10, 'N', NULL, NULL),
(216, 'outgoing_time', '10', '10', 11, 'N', NULL, NULL),
(217, 'outgoing_time', '11', '11', 12, 'N', NULL, NULL),
(218, 'outgoing_time', '12', '12', 13, 'N', NULL, NULL),
(219, 'outgoing_time', '13', '13', 14, 'N', NULL, NULL),
(220, 'outgoing_time', '14', '14', 15, 'N', NULL, NULL),
(221, 'outgoing_time', '15', '15', 16, 'N', NULL, NULL),
(222, 'outgoing_time', '16', '16', 17, 'N', NULL, NULL),
(223, 'outgoing_time', '17', '17', 18, 'N', NULL, NULL),
(224, 'outgoing_time', '18', '18', 19, 'N', NULL, NULL),
(225, 'outgoing_time', '19', '19', 20, 'N', NULL, NULL),
(226, 'outgoing_time', '20', '20', 21, 'N', NULL, NULL),
(228, 'schedule_redial_flag', '2', '2回', 3, 'N', NULL, NULL),
(229, 'schedule_redial_flag', '3', '3回', 5, 'N', NULL, NULL),
(230, 'schedule_redial_flag', '4', '4回', 6, 'N', NULL, NULL),
(231, 'schedule_redial_flag', '5', '5回', 7, 'N', NULL, NULL),
(232, 'proc_num', '4', '4ch', 5, 'N', '2016-02-08 18:14:00', '0000-00-00 00:00:00'),
(233, 'proc_num', '6', '6ch', 7, 'N', '2016-02-08 18:14:00', '0000-00-00 00:00:00'),
(234, 'proc_num', '7', '7ch', 8, 'N', '2016-02-08 18:14:00', '0000-00-00 00:00:00'),
(235, 'proc_num', '8', '8ch', 9, 'N', '2016-02-08 18:14:00', '0000-00-00 00:00:00'),
(236, 'proc_num', '9', '9ch', 10, 'N', '2016-02-08 18:14:00', '0000-00-00 00:00:00'),
(237, 'outgoing_time', '21', '21', 22, 'N', NULL, NULL),
(238, 'outgoing_time', '22', '22', 23, 'N', NULL, NULL),
(239, 'outgoing_time', '23', '23', 24, 'N', NULL, NULL),
(240, 'inbound_template_busy', '0', 'busy', 0, 'N', '2016-04-12 19:54:42', NULL),
(241, 'template_ques', '10', '文字列認証', 4, 'N', '2016-04-25 17:55:31', NULL),
(242, 'list_item', 'consentday', '利用承諾日', 14, 'N', NULL, NULL),
(243, 'template_ques', '11', '物件番号入力', 9, 'Y', NULL, NULL),
(244, 'template_ques', '12', 'FAX番号入力', 10, 'Y', NULL, NULL),
(245, 'template_ques', '11', '物件番号入力', 9, 'N', NULL, NULL),
(246, 'template_ques', '12', '物件FAX送信', 10, 'N', NULL, NULL),
(247, 'dial_wait_time', '25', '25秒', 1, 'N', NULL, NULL),
(248, 'dial_wait_time', '20', '20秒', 6, 'N', NULL, NULL),
(249, 'template_ques', '13', 'SMS', 13, 'N', '2017-01-13 15:10:53', NULL),
(251, 'template_ques', '14', '物件入力(賃料、平米) ', 14, 'N', NULL, NULL),
(252, 'template_ques', '16', '通知番号SMS送信', 16, 'N', '2017-10-04 14:42:29', NULL),
(253, 'proc_num', '21', '21ch', 22, 'N', '2017-02-23 11:40:00', NULL),
(254, 'proc_num', '22', '22ch', 23, 'N', '2017-02-23 11:40:00', NULL),
(255, 'proc_num', '23', '23ch', 24, 'N', '2017-02-23 11:40:00', NULL),
(256, 'proc_num', '24', '24ch', 25, 'N', '2017-02-23 11:40:00', NULL),
(257, 'proc_num', '11', '11ch', 12, 'N', '2017-02-23 11:40:00', NULL),
(258, 'proc_num', '12', '12ch', 13, 'N', '2017-02-23 11:40:00', NULL),
(259, 'proc_num', '13', '13ch', 14, 'N', '2017-02-23 11:40:00', NULL),
(260, 'proc_num', '14', '14ch', 15, 'N', '2017-02-23 11:40:00', NULL),
(261, 'proc_num', '16', '16ch', 17, 'N', '2017-02-23 11:40:00', NULL),
(262, 'proc_num', '17', '17ch', 18, 'N', '2017-02-23 11:40:00', NULL),
(263, 'proc_num', '18', '18ch', 19, 'N', '2017-02-23 11:40:00', NULL),
(264, 'proc_num', '19', '19ch', 20, 'N', '2017-02-23 11:40:00', NULL),
(265, 'template_ques', '17', '着信番号照合', 17, 'N', '2019-05-31 14:00:00', NULL),
(266, 'dial_wait_time', '15', '15秒', 7, 'N', '2020-03-06 11:51:22', NULL),
(267, 'template_ques', '18', '番号指定SMS送信', 18, 'N', '2020-04-08 17:19:53', NULL),
(268, 'proc_num', '26', '26ch', 27, 'N', '2020-07-01 10:30:00', '0000-00-00 00:00:00'),
(269, 'proc_num', '27', '27ch', 28, 'N', '2020-07-01 10:30:00', '0000-00-00 00:00:00'),
(270, 'proc_num', '28', '28ch', 29, 'N', '2020-07-01 10:30:00', '0000-00-00 00:00:00'),
(271, 'proc_num', '29', '29ch', 30, 'N', '2020-07-01 10:30:00', '0000-00-00 00:00:00'),
(273, 'template_ques', '19', '番号指定SMS送信', 19, 'N', '2021-06-21 00:00:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m91_menu_manage_items`
--

CREATE TABLE `m91_menu_manage_items` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `menu_item_code` varchar(20) DEFAULT NULL,
  `menu_item_name` varchar(64) DEFAULT NULL,
  `order_num` int(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `m91_menu_manage_items`
--

INSERT INTO `m91_menu_manage_items` (`id`, `menu_item_code`, `menu_item_name`, `order_num`, `del_flag`, `created`, `modified`) VALUES
(1, 'outbound', 'アウトバウンド', 1, 'N', '2016-08-26 15:50:29', NULL),
(2, 'inbound', 'インバウンド', 2, 'N', '2016-08-26 15:50:29', NULL),
(3, 'sms', 'SMS', 3, 'N', '2016-08-26 15:50:29', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m92_limit_functions`
--

CREATE TABLE `m92_limit_functions` (
  `id` int(11) NOT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `template_type` int(11) DEFAULT '0' COMMENT '0： インバウンド. １： アウトバウンド',
  `function_name` varchar(64) DEFAULT NULL,
  `value` varchar(64) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `m92_limit_functions`
--

INSERT INTO `m92_limit_functions` (`id`, `company_id`, `template_type`, `function_name`, `value`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 0, 'template_section', '14', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `m99_system_parameters`
--

CREATE TABLE `m99_system_parameters` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `function_id` varchar(64) NOT NULL COMMENT '機能ID',
  `parameter_id` varchar(64) NOT NULL COMMENT 'パラメータ',
  `parameter_value` varchar(64) DEFAULT NULL COMMENT 'パラメータ値',
  `memo` text COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m99パラメータ';

--
-- Dumping data for table `m99_system_parameters`
--

INSERT INTO `m99_system_parameters` (`id`, `function_id`, `parameter_id`, `parameter_value`, `memo`, `del_flag`, `created`, `modified`) VALUES
(1, 'LIST', 'MAX_TEL', '120000', 'リストの最大件数', 'N', NULL, NULL),
(2, 'RDD', 'MAX_LIST', '50', NULL, 'N', NULL, NULL),
(3, 'CHANGE_PASS', 'TIME_TO_CHANGE_PASS', '7776000', NULL, 'N', NULL, NULL),
(4, 'SCRIPT', 'MAX_QUES', '50', NULL, 'N', NULL, NULL),
(5, 'SCHEDULE', 'MAX_SCHEDULE', '15', '間隔でスケジュール。', 'N', NULL, NULL),
(6, 'SCHEDULE', 'TIME_PREPARE_PROCNUM', '900', 'second', 'N', NULL, NULL),
(7, 'SCHEDULE', 'MIN_TIME_CALL', '900', 'second', 'N', NULL, NULL),
(8, 'SCHEDULE', 'PATH_QUESTION_RECORD', '/home/ftpuser/robo/schedule/', NULL, 'N', NULL, NULL),
(9, 'LIST', 'MAX_LIST_ITEM', '10000', NULL, 'N', NULL, NULL),
(10, 'COMPANY', 'GS_COMPANY_ID', '002', 'GS会社ID固定', 'N', NULL, NULL),
(11, 'LIST', 'MAX_TEL_NG', '20000', NULL, 'N', NULL, NULL),
(12, 'LIST', 'MAX_TEL_NG', '10000', NULL, 'N', NULL, NULL),
(13, 'LIST', 'MAX_INCOMING_NG_TEL', '10000', NULL, 'N', NULL, NULL),
(15, 'LIST', 'MAX_INBOUND_TEL', '120000', NULL, 'N', NULL, NULL),
(16, 'LIST', 'MAX_SMS_TEL', '120000', 'SMSリストの最大件数', 'N', NULL, NULL),
(17, 'LIST_SMS', 'MAX_SMS_TEL', '10000', '', 'N', '2016-05-10 10:10:16', NULL),
(18, 'SMS_SCHEDULE', 'MIN_TIME_SEND', '900', 'seconds', 'N', '2016-05-12 10:33:13', NULL),
(19, 'SMS_SCHEDULE', 'MAX_SCHEDULE', '15', '間隔でスケジュール。', 'N', '2016-05-12 10:33:13', NULL),
(20, 'SMS_BATCH', 'LOCAL_PATH', '/home/ftpuser/robo/sms/', NULL, 'N', '2016-05-20 16:06:30', NULL),
(21, 'INBOUND', 'PATH_QUESTION_RECORD', '/home/ftpuser/robo/inbound/schedule/', NULL, 'N', '2016-05-24 16:06:30', NULL),
(22, 'SMS_BATCH', 'FORCE_STOP_TIME', '600', 'seconds', 'N', '0000-00-00 00:00:00', NULL),
(23, 'HIDDEN_CALL_LIST', 'HIDDEN_CALL_LIST', '生年月日', NULL, 'N', '2019-04-04 14:52:34', NULL),
(24, 'HIDDEN_CALL_LIST', 'HIDDEN_CALL_LIST', '誕生日', NULL, 'N', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t10_call_lists`
--

CREATE TABLE `t10_call_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `list_no` int(11) DEFAULT NULL,
  `list_name` varchar(128) DEFAULT NULL COMMENT '発信リスト名',
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `tel_total` int(12) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t10発信リスト';

--
-- Dumping data for table `t10_call_lists`
--

INSERT INTO `t10_call_lists` (`id`, `company_id`, `list_no`, `list_name`, `list_test_flag`, `tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 1, 'ダミー番号1', '1', 2, 'N', '2021-02-26 16:27:46', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46', NULL, NULL),
(2, '002', 2, 'ダミー番号2', '1', 3, 'N', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50', NULL, NULL),
(3, '002', 3, 'ダミー番号3', '1', 1, 'N', '2021-03-01 12:11:23', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t11_tel_lists`
--

CREATE TABLE `t11_tel_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `list_id` bigint(20) NOT NULL,
  `tel_no` int(11) DEFAULT NULL,
  `customer_name` varchar(20) DEFAULT NULL,
  `address` varchar(64) DEFAULT NULL,
  `birthday` datetime DEFAULT NULL,
  `fee` varchar(64) DEFAULT NULL,
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL,
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ N:有効、Y：無効',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t11 発信電話番号リスト';

--
-- Dumping data for table `t11_tel_lists`
--

INSERT INTO `t11_tel_lists` (`id`, `list_id`, `tel_no`, `customer_name`, `address`, `birthday`, `fee`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 1, NULL, NULL, NULL, NULL, '09000000000', 'ダミー1', '1000', '1234', '1990年03月21日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:27:46', 'kamo_s', 'CallList_upload_file', NULL, NULL, NULL),
(2, 1, 2, NULL, NULL, NULL, NULL, '09000000001', 'ダミー2', '2000', '5678', '1985年12月01日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:27:46', 'kamo_s', 'CallList_upload_file', NULL, NULL, NULL),
(3, 2, 1, NULL, NULL, NULL, NULL, '09000000002', 'ダミー3', '3000', '1234', '88888', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file', NULL, NULL, NULL),
(4, 2, 2, NULL, NULL, NULL, NULL, '09000000003', 'ダミー4', '4000', '5678', '77777', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file', NULL, NULL, NULL),
(5, 2, 3, NULL, NULL, NULL, NULL, '09000000004', 'ダミー5', '5000', '0123', '66666', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file', '2021-06-24 13:46:39', 'fabbi', 'CallList_recover_tel_info'),
(6, 3, 1, NULL, NULL, NULL, NULL, '09000000005', 'ダミー6', '4000', '5678', '12345', '20001112', '2000年11月12日', '', '', '', '', 'N', NULL, 'N', '2021-03-01 12:11:23', 'kamo_s', 'CallList_upload_file', '2021-06-23 16:50:05', 'fabbi', 'CallList_recover_tel_info'),
(7, 3, 2, NULL, NULL, NULL, NULL, '09000000033', 'ダミー6', '4000', '5678', '12345', '20001112', '2021年02月02日', NULL, NULL, NULL, NULL, 'N', NULL, 'Y', '2021-06-24 12:27:26', 'fabbi', 'CallList_add_and_edit_tel', '2021-06-24 12:27:26', 'fabbi', 'CallList_recover_del_flag_tel');

-- --------------------------------------------------------

--
-- Table structure for table `t12_list_items`
--

CREATE TABLE `t12_list_items` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) NOT NULL,
  `list_id` varchar(20) NOT NULL,
  `order_num` int(6) DEFAULT NULL,
  `item_name` varchar(64) DEFAULT NULL,
  `item_code` varchar(64) DEFAULT NULL,
  `column` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `t12_list_items`
--

INSERT INTO `t12_list_items` (`id`, `company_id`, `list_id`, `order_num`, `item_name`, `item_code`, `column`, `del_flag`, `entry_user`, `entry_program`, `created`) VALUES
(1, '002', '1', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46'),
(2, '002', '1', 2, '名前', 'customer_name', 'customize2', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46'),
(3, '002', '1', 3, '金額', 'money', 'customize3', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46'),
(4, '002', '1', 4, '認証番号', '', 'customize4', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46'),
(5, '002', '1', 5, '生年月日', 'birthday', 'customize5', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:27:46'),
(6, '002', '2', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(7, '002', '2', 2, '名前', 'customer_name', 'customize2', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(8, '002', '2', 3, '金額', 'money', 'customize3', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(9, '002', '2', 4, '認証番号', '', 'customize4', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(10, '002', '2', 5, '顧客番号', '', 'customize5', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(11, '002', '3', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(12, '002', '3', 2, '名前', 'customer_name', 'customize2', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(13, '002', '3', 3, '金額', 'money', 'customize3', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(14, '002', '3', 4, '認証番号', '', 'customize4', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(15, '002', '3', 5, '顧客番号', '', 'customize5', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(16, '002', '3', 6, '誕生日', '', 'customize6', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(17, '002', '3', 7, '生年月日', 'birthday', 'customize7', 'N', 'kamo_s', 'CallList_upload_file', '2021-03-01 12:11:23'),
(18, '003', '2', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50'),
(19, '004', '3', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'CallList_upload_file', '2021-02-26 16:29:50');

-- --------------------------------------------------------

--
-- Table structure for table `t13_inbound_list_items`
--

CREATE TABLE `t13_inbound_list_items` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) NOT NULL,
  `list_id` varchar(20) NOT NULL,
  `order_num` int(6) DEFAULT NULL,
  `item_name` varchar(64) DEFAULT NULL,
  `item_code` varchar(64) DEFAULT NULL,
  `column` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `t13_inbound_list_items`
--

INSERT INTO `t13_inbound_list_items` (`id`, `company_id`, `list_id`, `order_num`, `item_name`, `item_code`, `column`, `del_flag`, `entry_user`, `entry_program`, `created`) VALUES
(1, '002', '1', 1, '認証番号', '認証番号', 'customize1', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(2, '002', '1', 2, '電話番号', 'tel_no', 'customize2', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(3, '002', '1', 3, '名前', 'customer_name', 'customize3', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(4, '002', '1', 4, '金額', 'money', 'customize4', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(5, '002', '1', 5, '生年月日', 'birthday', 'customize5', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(6, '002', '2', 1, '金額', 'money', 'customize1', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:54'),
(7, '002', '3', 2, '電話番号', 'tel_no', 'customize2', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:54'),
(8, '002', '2', 3, '名前', 'customer_name', 'customize3', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:54'),
(9, '002', '2', 4, '認証番号', '認証番号', 'customize4', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:54'),
(10, '002', '2', 5, '顧客番号', '顧客番号', 'customize5', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:54'),
(11, '003', '2', 2, '電話番号', 'tel_no', 'customize2', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18'),
(12, '004', '1', 2, '電話番号', 'tel_no', 'customize2', 'N', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18');

-- --------------------------------------------------------

--
-- Table structure for table `t14_outgoing_ng_lists`
--

CREATE TABLE `t14_outgoing_ng_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `list_ng_no` int(10) NOT NULL,
  `list_name` varchar(128) DEFAULT NULL COMMENT 'リスト名',
  `total` int(11) DEFAULT NULL COMMENT '総件数',
  `expired_date_from` date DEFAULT NULL COMMENT '有効期限開始',
  `expired_date_to` date DEFAULT NULL COMMENT '有効期限終了',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t14発信NGリスト';

--
-- Dumping data for table `t14_outgoing_ng_lists`
--

INSERT INTO `t14_outgoing_ng_lists` (`id`, `company_id`, `list_ng_no`, `list_name`, `total`, `expired_date_from`, `expired_date_to`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(1, '002', 1, 'ダミーNGリスト', 7, NULL, NULL, 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, '2021-02-26 16:37:38');

-- --------------------------------------------------------

--
-- Table structure for table `t15_outgoing_ng_tels`
--

CREATE TABLE `t15_outgoing_ng_tels` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `list_ng_id` varchar(20) NOT NULL COMMENT '発信NGリストID',
  `no` int(20) NOT NULL,
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `memo` varchar(128) DEFAULT NULL COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t15発信NG番号';

--
-- Dumping data for table `t15_outgoing_ng_tels`
--

INSERT INTO `t15_outgoing_ng_tels` (`id`, `list_ng_id`, `no`, `tel_no`, `memo`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(1, '1', 1, '09000000000', 'ダミー０', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(2, '1', 2, '09000000001', 'ダミー１', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(3, '1', 3, '09000000002', 'ダミー２', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(4, '1', 4, '09000000003', 'ダミー３', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(5, '1', 5, '09000000004', 'ダミー４', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(6, '1', 6, '09000000005', 'ダミー５', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL),
(7, '1', 7, '09000000006', 'ダミー６', 'N', 'kamo_s', 'CallListNg_upload_file', '2021-02-26 16:37:38', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t16_inbound_call_lists`
--

CREATE TABLE `t16_inbound_call_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `list_no` int(11) DEFAULT NULL,
  `list_name` varchar(128) DEFAULT NULL COMMENT '発信リスト名',
  `item_main` varchar(128) DEFAULT NULL,
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `tel_total` int(12) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t16インバウンド発信リスト';

--
-- Dumping data for table `t16_inbound_call_lists`
--

INSERT INTO `t16_inbound_call_lists` (`id`, `company_id`, `list_no`, `list_name`, `item_main`, `list_test_flag`, `tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 1, 'ダミーリスト1', '認証番号', '1', 2, 'N', '2021-02-26 16:50:18', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 16:50:18', NULL, NULL),
(2, '002', 2, 'ダミーリスト2', '金額', '1', 3, 'N', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file', '2021-02-26 17:08:53', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t17_inbound_tel_lists`
--

CREATE TABLE `t17_inbound_tel_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `list_id` bigint(20) NOT NULL,
  `tel_no` int(11) DEFAULT NULL,
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL COMMENT '項目11',
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ N:有効、Y：無効',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t17インバウンド発信電話番号リスト';

--
-- Dumping data for table `t17_inbound_tel_lists`
--

INSERT INTO `t17_inbound_tel_lists` (`id`, `list_id`, `tel_no`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 1, '1234', '09000000000', 'ダミー1', '1000', '1990年03月21日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:50:18', 'kamo_s', 'InboundCallList_upload_file', NULL, NULL, NULL),
(2, 1, 2, '5678', '09000000001', 'ダミー2', '2000', '1985年12月01日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 16:50:18', 'kamo_s', 'InboundCallList_upload_file', NULL, NULL, NULL),
(3, 2, 1, '3000', '09000000002', 'ダミー3', '1234', '88888', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file', NULL, NULL, NULL),
(4, 2, 2, '4000', '09000000003', 'ダミー4', '5678', '77777', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file', NULL, NULL, NULL),
(5, 2, 3, '5000', '09000000004', 'ダミー5', '0123', '66666', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t18_incoming_ng_lists`
--

CREATE TABLE `t18_incoming_ng_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `list_ng_no` int(10) NOT NULL,
  `list_name` varchar(128) DEFAULT NULL COMMENT 'リスト名',
  `total` int(11) DEFAULT NULL COMMENT '総件数',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t17着信拒否リスト';

--
-- Dumping data for table `t18_incoming_ng_lists`
--

INSERT INTO `t18_incoming_ng_lists` (`id`, `company_id`, `list_ng_no`, `list_name`, `total`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(1, '002', 1, 'ダミー拒否リスト', 7, 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, '2021-02-26 17:12:52');

-- --------------------------------------------------------

--
-- Table structure for table `t19_incoming_ng_tels`
--

CREATE TABLE `t19_incoming_ng_tels` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `list_ng_id` varchar(20) NOT NULL COMMENT '発信NGリストID',
  `no` int(20) DEFAULT NULL,
  `tel_no` varchar(20) NOT NULL COMMENT '着信拒否番号',
  `memo` varchar(128) DEFAULT NULL COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t18着信拒否情報';

--
-- Dumping data for table `t19_incoming_ng_tels`
--

INSERT INTO `t19_incoming_ng_tels` (`id`, `list_ng_id`, `no`, `tel_no`, `memo`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(1, '1', 1, '09000000000', 'ダミー０', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(2, '1', 2, '09000000001', 'ダミー１', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(3, '1', 3, '09000000002', 'ダミー２', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(4, '1', 4, '09000000003', 'ダミー３', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(5, '1', 5, '09000000004', 'ダミー４', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(6, '1', 6, '09000000005', 'ダミー５', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL),
(7, '1', 7, '09000000006', 'ダミー６', 'N', 'kamo_s', 'InboundRestrict_upload_file', '2021-02-26 17:12:52', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t20_out_schedules`
--

CREATE TABLE `t20_out_schedules` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_no` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `company_id` varchar(20) NOT NULL COMMENT 'サーバID',
  `schedule_name` varchar(64) NOT NULL,
  `status` varchar(1) NOT NULL DEFAULT '0' COMMENT '０：まだ、１：実行中、２：停止、３：一旦終了、4：終了、５：停止中、６：終了中、7：リダイヤル待ち',
  `call_type` varchar(1) NOT NULL COMMENT '番号通知	 0 : 通知、1 : 未通知',
  `external_number` varchar(20) NOT NULL COMMENT '外線番号',
  `list_ng_id` varchar(20) DEFAULT NULL COMMENT '発信NGリスト',
  `list_id` varchar(20) NOT NULL COMMENT '発信リストID',
  `template_id` varchar(20) NOT NULL COMMENT 'スクリプトID',
  `proc_num` varchar(20) DEFAULT NULL COMMENT '起動プロセス数',
  `dial_wait_time` varchar(20) DEFAULT NULL COMMENT '呼び出し時間設定',
  `ans_timeout` varchar(20) DEFAULT NULL COMMENT '回答待ち時間設定',
  `term_valid_count` varchar(20) DEFAULT NULL COMMENT '自動停止有効回答数',
  `term_connect_count` varchar(20) DEFAULT NULL COMMENT '自動停止接続数',
  `recall` int(1) DEFAULT '0' COMMENT '*0:なし、1:あり',
  `recall_time` varchar(20) DEFAULT NULL COMMENT 'リダイヤル間隔',
  `recall_flag` int(1) DEFAULT '0' COMMENT '実行回数',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `cron_flag` varchar(1) DEFAULT 'Y',
  `cron_record_flag` varchar(1) DEFAULT 'Y' COMMENT 'N-取得した,Y-まだ取得しない',
  `called_total` int(12) DEFAULT NULL,
  `yuko_total` int(12) DEFAULT NULL,
  `tel_total` int(7) DEFAULT NULL,
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t20 スケジュール';

--
-- Dumping data for table `t20_out_schedules`
--

INSERT INTO `t20_out_schedules` (`id`, `schedule_no`, `company_id`, `schedule_name`, `status`, `call_type`, `external_number`, `list_ng_id`, `list_id`, `template_id`, `proc_num`, `dial_wait_time`, `ans_timeout`, `term_valid_count`, `term_connect_count`, `recall`, `recall_time`, `recall_flag`, `del_flag`, `cron_flag`, `cron_record_flag`, `called_total`, `yuko_total`, `tel_total`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, '002', 'サンプルスケジュール1', '5', '0', '0363863696', '', '3', '', '1', '25', '10000', '', '', 0, NULL, 0, 'N', 'N', 'Y', 1, NULL, NULL, '2021-03-01 11:51:20', 's_kamo', 'OutSchedule_Create_Schedule', '2021-07-02 17:22:47', 'fabbi', 'OutSchedule_StopSchedule'),
(2, 2, '002', 'サンプルスケジュール', '5', '0', '0363863696', '', '2', '', '1', '25', '10000', '', '', 0, NULL, 0, 'N', 'N', 'Y', 1, NULL, NULL, '2021-03-01 11:51:20', 's_kamo', 'OutSchedule_Create_Schedule', '2021-06-24 17:22:52', 'fabbi', 'OutSchedule_StopSchedule'),
(3, 3, '003', 'サンプルスケジュール 2', '0', '0', '0363863696', '', '3', '6', '8', '25', '10000', '', '', 0, NULL, 0, 'N', 'Y', 'Y', NULL, NULL, NULL, '2021-06-23 19:11:28', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-23 19:11:28', NULL, NULL),
(4, 4, '004', 'サンプルスケジュール 3', '0', '0', '0363863696', '1', '3', '2', '2', '25', '10000', '', '', 0, NULL, 0, 'N', 'Y', 'Y', NULL, NULL, NULL, '2021-06-24 11:54:25', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 11:54:26', NULL, NULL),
(5, 5, '002', 'werewr', '0', '0', '0363863696', '', '2', '1', '6', '25', '10000', '', '', 0, NULL, 0, 'N', 'Y', 'Y', NULL, NULL, NULL, '2021-06-24 12:23:43', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 12:23:43', NULL, NULL),
(6, 6, '002', 'テスト３fsdef', '0', '0', '0363863696', '', '3', '8', '4', '25', '10000', '', '', 0, NULL, 0, 'Y', 'Y', 'Y', NULL, NULL, NULL, '2021-06-24 14:03:27', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 14:03:27', NULL, NULL),
(7, 7, '002', 'テスト３fsdef', '0', '0', '0363863696', '', '3', '8', '4', '25', '10000', '', '', 0, NULL, 0, 'Y', 'Y', 'Y', NULL, NULL, NULL, '2021-06-24 14:04:41', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 14:04:41', NULL, NULL),
(8, 8, '002', 'rêtrtertre', '0', '0', '0363863696', '1', '2', '6', '14', '25', '10000', '', '', 0, NULL, 0, 'Y', 'Y', 'Y', NULL, NULL, NULL, '2021-06-24 17:10:58', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:10:58', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t21_out_times`
--

CREATE TABLE `t21_out_times` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュールID',
  `time_start` datetime NOT NULL COMMENT '開始時間',
  `time_end` datetime NOT NULL COMMENT '終了時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t21スケジュール詳細';

--
-- Dumping data for table `t21_out_times`
--

INSERT INTO `t21_out_times` (`id`, `schedule_id`, `time_start`, `time_end`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', '2021-03-01 11:55:00', '2021-03-01 13:40:00', 'N', '2021-03-01 11:51:20', 's_kamo', 'OutSchedule_Create_Schedule', '2021-03-01 11:51:20', NULL, NULL),
(2, '2', '2021-03-01 11:55:00', '2021-03-01 13:40:00', 'N', '2021-03-01 11:51:20', 's_kamo', 'OutSchedule_Create_Schedule', '2021-03-01 11:51:20', NULL, NULL),
(3, '3', '2021-06-23 17:30:00', '2021-06-23 19:30:00', 'N', '2021-06-23 19:11:28', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-23 19:11:28', 'fabbi', 'OutSchedule_Update_Schedule'),
(4, '4', '2021-06-25 16:50:00', '2021-06-25 18:20:00', 'N', '2021-06-24 11:54:26', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 11:54:25', 'fabbi', 'OutSchedule_Update_Schedule'),
(5, '5', '2021-06-25 12:10:00', '2021-06-25 15:55:00', 'N', '2021-06-24 12:23:43', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 12:23:43', 'fabbi', 'OutSchedule_Update_Schedule'),
(6, '4', '2021-06-25 16:50:00', '2021-06-25 18:20:00', 'Y', '2021-06-24 13:00:55', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:00:55', 'fabbi', 'OutSchedule_Update_Schedule'),
(7, '4', '2021-06-25 16:50:00', '2021-06-25 18:20:00', 'Y', '2021-06-24 13:03:01', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:03:01', 'fabbi', 'OutSchedule_Update_Schedule'),
(8, '5', '2021-06-25 12:10:00', '2021-06-25 15:55:00', 'Y', '2021-06-24 13:56:55', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:56:55', 'fabbi', 'OutSchedule_Update_Schedule'),
(9, '4', '2021-06-25 16:50:00', '2021-06-25 18:20:00', 'Y', '2021-06-24 13:57:13', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:57:13', 'fabbi', 'OutSchedule_Update_Schedule'),
(10, '6', '2021-06-25 10:30:00', '2021-06-25 15:10:00', 'Y', '2021-06-24 14:03:27', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 14:03:27', 'fabbi', 'OutSchedule_Update_Schedule'),
(11, '7', '2021-06-25 10:30:00', '2021-06-25 19:15:00', 'Y', '2021-06-24 14:04:41', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 14:04:41', 'fabbi', 'OutSchedule_Update_Schedule'),
(12, '8', '2021-06-25 13:15:00', '2021-06-25 17:15:00', 'Y', '2021-06-24 17:10:58', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:10:58', 'fabbi', 'OutSchedule_Update_Schedule'),
(13, '4', '2021-06-24 15:11:00', '2021-06-24 17:29:00', 'Y', '2021-06-24 17:11:57', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:11:57', 'fabbi', 'OutSchedule_Update_Schedule'),
(14, '4', '2021-06-24 18:00:00', '2021-06-24 21:40:00', 'Y', '2021-06-24 17:11:57', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:11:57', 'fabbi', 'OutSchedule_Update_Schedule'),
(15, '4', '2021-06-24 15:12:00', '2021-06-24 16:07:00', 'Y', '2021-06-24 17:12:14', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:14', 'fabbi', 'OutSchedule_Update_Schedule'),
(16, '4', '2021-06-24 17:10:00', '2021-06-24 19:30:00', 'Y', '2021-06-24 17:12:14', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:14', 'fabbi', 'OutSchedule_Update_Schedule'),
(17, '4', '2021-06-24 15:12:00', '2021-06-24 16:07:00', 'Y', '2021-06-24 17:12:29', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:29', 'fabbi', 'OutSchedule_Update_Schedule'),
(18, '4', '2021-06-24 17:10:00', '2021-06-24 19:30:00', 'Y', '2021-06-24 17:12:29', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:29', 'fabbi', 'OutSchedule_Update_Schedule'),
(19, '4', '2021-06-24 15:12:00', '2021-06-24 16:07:00', 'Y', '2021-06-24 17:12:59', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:59', 'fabbi', 'OutSchedule_Update_Schedule'),
(20, '4', '2021-06-24 17:10:00', '2021-06-24 19:30:00', 'Y', '2021-06-24 17:12:59', 'fabbi', 'OutSchedule_Create_Schedule', '2021-06-24 17:12:59', 'fabbi', 'OutSchedule_Update_Schedule');

-- --------------------------------------------------------

--
-- Table structure for table `t22_out_logs`
--

CREATE TABLE `t22_out_logs` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュールID',
  `time_start` datetime NOT NULL COMMENT '開始時間',
  `time_end` datetime DEFAULT NULL COMMENT '終了時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t21スケジュール詳細';

--
-- Dumping data for table `t22_out_logs`
--

INSERT INTO `t22_out_logs` (`id`, `schedule_id`, `time_start`, `time_end`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', '2021-06-01 01:00:00', '2021-06-30 10:00:00', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(2, '2', '2021-06-01 01:00:00', '2021-06-30 10:00:00', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, '3', '2021-06-02 01:00:00', '2021-06-30 10:00:00', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(4, '4', '2021-06-01 01:00:00', '2021-06-30 10:00:00', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t25_inbounds`
--

CREATE TABLE `t25_inbounds` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL,
  `inbound_no` bigint(20) NOT NULL,
  `external_number` varchar(20) NOT NULL COMMENT '外線番号',
  `status` int(1) NOT NULL DEFAULT '0' COMMENT '０：メッセージ、１：busy、２：終了',
  `template_id` varchar(20) NOT NULL COMMENT 'スクリプトID',
  `list_ng_id` varchar(20) DEFAULT NULL,
  `list_id` varchar(20) DEFAULT NULL,
  `time_start` datetime DEFAULT NULL,
  `time_end` datetime DEFAULT NULL,
  `cron_record_flag` varchar(1) DEFAULT 'N',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `bukken_fax_flag` varchar(1) DEFAULT '0' COMMENT '0: Faxなし。またはFAX送信済み。1: 送信中'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t25 着信設定';

--
-- Dumping data for table `t25_inbounds`
--

INSERT INTO `t25_inbounds` (`id`, `company_id`, `inbound_no`, `external_number`, `status`, `template_id`, `list_ng_id`, `list_id`, `time_start`, `time_end`, `cron_record_flag`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `bukken_fax_flag`) VALUES
(3, '002', 3, '0363863696', 0, '3', '1', '3', '2021-06-30 11:01:40', NULL, 'N', 'N', '2021-06-30 11:01:40', 'fabbi', 'InboundIncomingHistory_Create_SettingInbound', '2021-06-30 11:01:40', NULL, NULL, '0'),
(4, '003', 4, '0363863754', 0, '3', '2', '2', '2021-06-17 11:01:40', NULL, 'N', 'N', '2021-06-30 11:01:40', 'fabbi', 'InboundIncomingHistory_Create_SettingInbound', '2021-06-30 11:01:40', NULL, NULL, '0'),
(5, '004', 5, '0363824213', 0, '3', '1', '1', '2021-06-09 11:01:40', NULL, 'N', 'N', '2021-06-30 11:01:40', 'fabbi', 'InboundIncomingHistory_Create_SettingInbound', '2021-06-30 11:01:40', NULL, NULL, '0');

-- --------------------------------------------------------

--
-- Table structure for table `t30_templates`
--

CREATE TABLE `t30_templates` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `template_no` int(20) NOT NULL COMMENT 'スクリプトID	 会社毎発番',
  `template_name` varchar(128) NOT NULL COMMENT 'スクリプト名',
  `template_type` int(1) DEFAULT NULL,
  `question_total` int(4) NOT NULL COMMENT '質問総件数',
  `description` text COMMENT '説明',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t30 テンプレート';

--
-- Dumping data for table `t30_templates`
--

INSERT INTO `t30_templates` (`id`, `company_id`, `template_no`, `template_name`, `template_type`, `question_total`, `description`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 1, 'サンプルテンプレート33', 1, 7, '再生、質問', 'N', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(2, '002', 2, 'サンプルテンプレート233', 1, 6, '再生、数値認証', 'N', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(3, '002', 1, 'サンプルテンプレート(インバウンド)1', 0, 6, '再生、質問', 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL),
(4, '002', 2, 'サンプルテンプレート(インバウンド)2', 0, 8, '再生、着信番号照合、文字列認証', 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:26', 'kamo_s', 'InboundTemplate_save_template'),
(5, '002', 3, 'test number sms', 1, 7, '再生、質問　１', 'N', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template'),
(6, '002', 4, '34534', 1, 2, '43534', 'N', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template'),
(7, '002', 3, 'ưr5w3t', 0, 3, 'ưet', 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL),
(8, '002', 5, 'サンプルテンプレート1111', 1, 7, '再生、質問', 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(9, '002', 4, 'ưdqwe', 0, 4, 'sdadas', 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL),
(10, '003', 1, 'tamplate 1', 1, 2, '再生、質問　１', 'N', '2021-06-30 10:59:54', 'fabbi', 'Template_save_template', '2021-06-30 10:59:54', NULL, NULL),
(11, '002', 6, '4', 1, 1, '4', 'Y', '2021-07-12 12:56:03', 'fabbi', 'Template_save_template', '2021-07-12 12:56:09', 'fabbi', 'Template_delete');

-- --------------------------------------------------------

--
-- Table structure for table `t31_template_questions`
--

CREATE TABLE `t31_template_questions` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `template_id` varchar(20) NOT NULL COMMENT 'スクリプトID	 会社毎発番',
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `question_type` varchar(2) DEFAULT NULL,
  `question_title` varchar(64) DEFAULT NULL COMMENT '質問タイトル',
  `question_yuko` int(1) DEFAULT '0',
  `jump_question` int(4) DEFAULT NULL,
  `audio_type` varchar(1) DEFAULT NULL COMMENT '０：音声ファイル,１：音声合成',
  `audio_id` int(11) DEFAULT NULL,
  `audio_name` varchar(64) DEFAULT NULL,
  `audio_content` text COMMENT '音声内容',
  `question_repeat` varchar(4) DEFAULT NULL COMMENT '繰り返し',
  `auth_match_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `auth_item` varchar(20) DEFAULT NULL COMMENT '認証項目',
  `second_record` int(11) DEFAULT NULL,
  `yuko_button_record` varchar(1) DEFAULT '0' COMMENT '1:有効',
  `digit` varchar(4) DEFAULT NULL COMMENT '桁数',
  `trans_tel` varchar(20) DEFAULT NULL COMMENT '転送先',
  `trans_seat_num` varchar(4) DEFAULT NULL COMMENT '席数',
  `trans_empty_seat_flag` varchar(1) DEFAULT '0' COMMENT '空き',
  `trans_timeout_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `trans_timeout_audio_id` int(11) DEFAULT NULL,
  `trans_timeout_audio_name` varchar(64) DEFAULT NULL,
  `trans_timeout_audio_content` text COMMENT '音声内容',
  `trans_timeout` varchar(4) DEFAULT NULL,
  `trans_playback_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `recheck_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `recheck_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `recheck_audio_id` int(11) DEFAULT NULL,
  `recheck_audio_name` varchar(64) DEFAULT NULL,
  `recheck_audio_content` text COMMENT '音声内容',
  `recheck_button_next` int(4) DEFAULT NULL,
  `recheck_button_prev` int(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `bukken_audio_type` varchar(1) DEFAULT NULL,
  `bukken_audio_id` int(11) DEFAULT NULL,
  `bukken_audio_name` varchar(64) DEFAULT NULL,
  `bukken_audio_content` text,
  `bukken_answer_no` int(4) DEFAULT NULL,
  `bukken_diagram_audio_type` varchar(1) DEFAULT NULL,
  `bukken_diagram_audio_id` int(11) DEFAULT NULL,
  `bukken_diagram_audio_name` varchar(64) DEFAULT NULL,
  `bukken_diagram_audio_content` text,
  `bukken_diagram_answer_no` int(4) DEFAULT NULL,
  `bukken_cont_audio_type` varchar(1) DEFAULT NULL,
  `bukken_cont_audio_id` int(11) DEFAULT NULL,
  `bukken_cont_audio_name` varchar(64) DEFAULT NULL,
  `bukken_cont_audio_content` text,
  `square_audio_type` varchar(1) DEFAULT NULL,
  `square_audio_id` int(11) DEFAULT NULL,
  `square_audio_name` varchar(64) DEFAULT NULL,
  `square_audio_content` text,
  `square_digit` varchar(4) DEFAULT NULL,
  `sms_display_number` varchar(20) DEFAULT NULL,
  `sms_content` varchar(1000) DEFAULT NULL,
  `sms_error_audio_type` varchar(1) DEFAULT NULL,
  `sms_error_audio_id` int(11) DEFAULT NULL,
  `sms_error_audio_name` varchar(64) DEFAULT NULL,
  `sms_error_audio_content` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t31テンプレート質問';

--
-- Dumping data for table `t31_template_questions`
--

INSERT INTO `t31_template_questions` (`id`, `template_id`, `question_no`, `question_type`, `question_title`, `question_yuko`, `jump_question`, `audio_type`, `audio_id`, `audio_name`, `audio_content`, `question_repeat`, `auth_match_flag`, `auth_item`, `second_record`, `yuko_button_record`, `digit`, `trans_tel`, `trans_seat_num`, `trans_empty_seat_flag`, `trans_timeout_audio_type`, `trans_timeout_audio_id`, `trans_timeout_audio_name`, `trans_timeout_audio_content`, `trans_timeout`, `trans_playback_flag`, `recheck_flag`, `recheck_audio_type`, `recheck_audio_id`, `recheck_audio_name`, `recheck_audio_content`, `recheck_button_next`, `recheck_button_prev`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `bukken_audio_type`, `bukken_audio_id`, `bukken_audio_name`, `bukken_audio_content`, `bukken_answer_no`, `bukken_diagram_audio_type`, `bukken_diagram_audio_id`, `bukken_diagram_audio_name`, `bukken_diagram_audio_content`, `bukken_diagram_answer_no`, `bukken_cont_audio_type`, `bukken_cont_audio_id`, `bukken_cont_audio_name`, `bukken_cont_audio_content`, `square_audio_type`, `square_audio_id`, `square_audio_name`, `square_audio_content`, `square_digit`, `sms_display_number`, `sms_content`, `sms_error_audio_type`, `sms_error_audio_id`, `sms_error_audio_name`, `sms_error_audio_content`) VALUES
(1, '1', 1, '1', '', 0, 2, '1', NULL, '', 'こんにちは。こちらはサンプルテンプレートです。', '0', '0', '', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, '1', 2, '2', '', 1, 5, '1', NULL, '', '0から9のなかで、好きな番号を選んでください。', '1', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, '1', 3, '1', '数値', 0, 5, '1', NULL, '', '数値が選択されました。ご回答ありがとうございました。', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:20', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, '1', 4, '1', '日本食', 0, 6, '1', NULL, '', '日本食が選択されました。ご回答ありがとうございました。', '0', '0', '', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-02-26 16:13:20', 'kamo_s', 'Template_save_template', '2021-03-01 11:49:04', 'kamo_s', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, '1', 4, '1', '数値以外', 0, 2, '1', NULL, '', 'もう一度、選びなおしてください。', '0', '0', '', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:20', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, '1', 5, '8', '', 0, NULL, '0', NULL, '', '', '0', '0', '', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:20', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, '1', 7, '9', '', 0, NULL, '1', NULL, '', 'タイムアウトしました。', '0', '0', '', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:13:20', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, '2', 1, '1', '', 0, 2, '2', NULL, '', 'こちらはサンプルテンプレートその２です。\r\nお名前は{名前}さんですね。', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, '2', 2, '3', '', 1, 4, '2', NULL, '', '数値認証を行います。金額を4桁で入力してください。', '0', '0', '金額', NULL, '0', '4', '', '', '0', '0', NULL, '', '', '', '0', '1', '2', NULL, '', 'でよろしいですか。よろしければ1を、間違っていれば1以外を押してください。', 1, NULL, 'N', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, '2', 3, '1', '認証成功', 0, 5, '2', NULL, '', '認証に成功しました。', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(11, '2', 4, '1', '認証失敗', 0, 5, '2', NULL, '', '認証に失敗しました。', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, '2', 5, '8', '', 0, NULL, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:34:47', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(13, '2', 6, '9', '', 0, NULL, '2', NULL, '', 'タイムアウトになりました。', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:34:47', 'kamo_s', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(14, '3', 1, '1', '', 0, 2, '1', NULL, '', 'こちらは、インバウンドのサンプルテンプレートです。', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(15, '3', 2, '2', '', 1, NULL, '1', NULL, '', '0から9で、好きな番号を入力してください。', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(16, '3', 3, '1', '', 0, 5, '1', NULL, '', '数値が入力されました。ご回答ありがとうございました。', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(17, '3', 4, '1', '', 0, 5, '1', NULL, '', '数値以外が入力されました。ご回答ありがとうございました。', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(18, '3', 5, '8', '', 0, NULL, '0', NULL, '', '', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(19, '3', 6, '9', '', 0, NULL, '1', NULL, '', 'タイムアウトになりました。', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(20, '4', 1, '17', '', 0, NULL, '0', NULL, '', '', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:29', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(21, '4', 2, '1', '着信番号照合成功', 0, 4, '2', NULL, '', '着信番号照合に成功しました。お名前は{名前}さんですね。', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:29', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(22, '4', 3, '1', '着信番号照合失敗', 0, 7, '2', NULL, '', '着信番号照合に失敗しました。切断します。', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(23, '4', 4, '10', '', 1, NULL, '2', NULL, '', '文字列認証を行います。認証番号を、4桁で入力してください。', '0', '1', '認証番号', NULL, '0', '4', '', '', '0', '0', NULL, '', '', '', '0', '1', '2', NULL, '', 'でよろしいですか。よろしければ1を、間違っていれば1以外を押してください。', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(24, '4', 5, '1', '文字列認証成功', 0, 5, '2', NULL, '', '文字列認証に成功しました。', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(25, '4', 6, '1', '文字列認証失敗', 0, 5, '2', NULL, '', '文字列認証に失敗しました。', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:31', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(26, '4', 7, '8', '', 0, NULL, '0', NULL, '', '', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-02-26 17:00:13', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:31', 'kamo_s', 'InboundTemplate_save_template', '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(27, '4', 8, '9', '', 0, NULL, '2', NULL, '', 'タイムアウトしました。', '0', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-02-26 17:00:13', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:32', 'kamo_s', 'InboundTemplate_save_template', '', NULL, '', '', NULL, '', NULL, '', '', NULL, '', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(28, '2', 6, '19', '54643', 0, 2, '2', NULL, '', '4344', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '2', NULL, '', '4543', 1, NULL, 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'hgfgajfhakfgjashgflkjasgfljkashgfljahsgfljahsgfjlhasgfjahsgfkjsagfasuifgeiugfjkhwegfjhgvdjsahfgasjhgfjahsgfjhasgfjhasgf', '2', NULL, '', '45435'),
(29, '2', 7, '13', '435345', 0, 2, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'hgfgajfhakfgjashgflkjasgfljkashgfljahsgfljahsgfjlhasgfjahsgfkjsagfasuifgeiugfjkhwegfjhgvdjsahfgasjhgfjahsgfjhasgfjhasgf', '2', NULL, '', '45435'),
(30, '5', 1, '8', 'dsfsdfd', 0, NULL, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(31, '5', 2, '19', 'dsfdsfdsf34324', 0, 1, '1', NULL, '', 'adffdsf', '0', '0', '電話番号', NULL, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'dfdfdf', 6, NULL, 'N', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'hgfgajfhakfgjashgflkjasgfljkashgfljahsgfljahsgfjlhasgfjahsgfkjsagfasuifgeiugfjkhwegfjhgvdjsahfgasjhgfjahsgfjhasgfjhasgf', '1', NULL, '', 'oooo'),
(32, '5', 7, '9', 'dsdsfd', 0, NULL, '1', NULL, '', 'dsfdfdsf', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(33, '5', 3, '19', 'test 1', 0, 1, '1', NULL, '', 'test 1test 1', '0', '0', '電話番号', NULL, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'test 1test 1test 1', 2, NULL, 'N', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'rtytry', '1', NULL, '', 'oooo'),
(34, '5', 4, '19', 'ｙｔｒｙｔｙ', 0, 1, '1', NULL, '', 'etretrt', '0', '0', '電話番号', NULL, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'rtret', 1, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'retret', '1', NULL, '', 'oooo'),
(35, '5', 5, '19', '4', 0, 3, '1', NULL, '', 'rtret', '0', '0', '電話番号', NULL, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'retret', 1, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'retre', '1', NULL, '', 'oooo'),
(36, '5', 6, '19', '5', 0, 4, '1', NULL, '', 'retert', '0', '0', '電話番号', NULL, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'ertret', 1, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'retret', '1', NULL, '', 'oooo'),
(37, '6', 1, '8', 'ewrewr', 0, NULL, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(38, '6', 2, '19', '', 0, 1, '1', NULL, '', 'dfdsf', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '1', NULL, '', 'dsfdsf', 1, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120551111(試験用.)', 'dsfdsf', '1', NULL, '', 'sdgsdgds tétghuihtegyioetruyuytuiyi'),
(39, '6', 3, '13', '5435', 0, 2, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120551111(試験用.)', '45435345uiyuiuy', '1', NULL, NULL, 'sdgsdgds tétghuihtegyioetruyuytuiyi'),
(40, '6', 6, '9', 'ẻtrt', 0, NULL, '1', NULL, '', 'retret', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(41, '6', 4, '13', '', 0, 2, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120551111(試験用.)', 'ểwrwe', '1', NULL, NULL, 'sdgsdgds tétghuihtegyioetruyuytuiyi'),
(42, '6', 5, '19', '', 0, 4, '1', NULL, '', '32545', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '1', NULL, '', '435435', 1, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '435435', '', NULL, '', ''),
(43, '6', 2, '19', '324234', 0, NULL, '1', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '1', NULL, '', '34234', 1, NULL, 'Y', '2021-06-22 15:50:17', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '23423', '', NULL, '', ''),
(44, '6', 3, '9', 'g5645', 0, NULL, '1', NULL, '', '456456', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-06-22 15:50:17', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(45, '6', 2, '13', '32432', 0, 1, '0', NULL, '', '', '0', '0', '電話番号', NULL, NULL, NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'fhdfhdfhfdh', '1', NULL, '', '34324'),
(46, '7', 1, '18', '4543634', 0, 1, '1', NULL, '', '34634', '0', '0', '認証番号', NULL, NULL, NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', '34634', 1, NULL, 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', '34634', '1', NULL, '', '346346'),
(47, '7', 2, '8', 'ưetw', 0, NULL, '0', NULL, '', '', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(48, '7', 3, '9', 'ểwr', 0, NULL, '1', NULL, '', 'erưe', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(49, '8', 1, '1', '', 0, 2, '1', NULL, '', 'こんにちは。こちらはサンプルテンプレートです。', '', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(50, '8', 2, '2', '', 1, 5, '1', NULL, '', '0から9のなかで、好きな番号を選んでください。', '1', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(51, '8', 3, '1', '数値', 0, 5, '1', NULL, '', '数値が選択されました。ご回答ありがとうございました。', '', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(52, '8', 4, '1', '数値以外', 0, 2, '1', NULL, '', 'もう一度、選びなおしてください。', '', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(53, '8', 5, '8', '', 0, NULL, '', NULL, '', '', '', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(54, '8', 7, '9', '', 0, NULL, '1', NULL, '', 'タイムアウトしました。', '', '0', '', NULL, '0', NULL, '', '', '0', '', NULL, '', '', '', '0', '0', '', NULL, '', '', NULL, NULL, 'N', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(55, '1', 6, '19', '4365436', 0, 2, '1', NULL, '', '34634', '0', '0', '電話番号', NULL, NULL, NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', '346436', 1, NULL, 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', '346346sjhfgouweqgrflkiasbvfjhasgfudwegturgieuwrgweiugtriweugtiuwegtiuwegtriuwegtiuwegrtiluwegtiluergtuier', '1', NULL, '', '436346'),
(56, '9', 1, '16', 'ewqdrewr', 0, 1, '0', NULL, '', '', '0', '0', '認証番号', NULL, NULL, NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'ewrwer', '1', NULL, '', 'ẻwerwer'),
(57, '9', 2, '18', 'gểtr', 0, 2, '1', NULL, '', 'dgfd', '0', '0', '認証番号', NULL, NULL, NULL, '', '', '0', '0', NULL, '', '', '', '0', '1', '1', NULL, '', 'fdgdfg', 1, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, '0120558656(試験用.)', 'gdfgdf', '1', NULL, '', 'ẻwerwer'),
(58, '9', 3, '8', 'fdgdfg', 0, NULL, '0', NULL, '', '', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(59, '9', 4, '9', 'rgfdg', 0, NULL, '1', NULL, '', 'dfgdfgfd', '0', '0', '認証番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL, '0', NULL, '', '', 1, '0', NULL, '', '', 1, '0', NULL, '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(60, '8', 6, '6', 'ewtert', 0, 2, '1', NULL, '', 'retret', '0', '0', '電話番号', 4, '1', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(61, '10', 1, '8', 'ưưưưưư', 0, NULL, '0', NULL, '', '', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-30 10:59:54', 'fabbi', 'Template_save_template', '2021-06-30 10:59:54', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(62, '10', 2, '9', 'ưưw', 0, NULL, '1', NULL, '', 'wưưưưư', '0', '0', NULL, NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'N', '2021-06-30 10:59:54', 'fabbi', 'Template_save_template', '2021-06-30 10:59:54', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, '11', 1, '8', 'rrr', 0, NULL, '0', NULL, '', '', '0', '0', '電話番号', NULL, '0', NULL, '', '', '0', '0', NULL, '', '', '', '0', '0', '0', NULL, '', '', 1, NULL, 'Y', '2021-07-12 12:56:03', 'fabbi', 'Template_save_template', '2021-07-12 12:56:09', 'fabbi', 'Template_delete', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t32_template_buttons`
--

CREATE TABLE `t32_template_buttons` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `template_id` varchar(20) NOT NULL COMMENT 'スクリプトID',
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `answer_no` int(4) NOT NULL COMMENT '回答番号（ボタン） 認証質問場合 1  < ,2 =, 3 > ',
  `yuko_flag` varchar(1) DEFAULT '0' COMMENT '0:無効、１：有効',
  `jump_question` int(4) DEFAULT NULL COMMENT 'ジャンプ先質問番号',
  `answer_content` varchar(128) DEFAULT NULL COMMENT 'テキスト',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t32 回答ボタン設定';

--
-- Dumping data for table `t32_template_buttons`
--

INSERT INTO `t32_template_buttons` (`id`, `template_id`, `question_no`, `answer_no`, `yuko_flag`, `jump_question`, `answer_content`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', 2, 1, '0', 3, 'フォー', 'Y', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:05', 'kamo_s', 'Template_save_template'),
(2, '1', 2, 2, '0', 3, 'バインミー', 'Y', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:05', 'kamo_s', 'Template_save_template'),
(3, '1', 2, 3, '0', 4, 'おにぎり', 'Y', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:05', 'kamo_s', 'Template_save_template'),
(4, '1', 2, 4, '0', 4, '焼きそば', 'Y', '2021-02-26 16:13:19', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:05', 'kamo_s', 'Template_save_template'),
(5, '2', 2, 1, '0', 4, '', 'Y', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:35', 'kamo_s', 'Template_save_template'),
(6, '2', 2, 2, '0', 3, '', 'Y', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template'),
(7, '2', 2, 3, '0', 4, '', 'Y', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template'),
(8, '2', 2, 99, '0', NULL, '', 'Y', '2021-02-26 16:34:46', 'kamo_s', 'Template_save_template', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template'),
(9, '1', 2, 1, '0', 3, 'フォー', 'Y', '2021-02-26 16:36:06', 'kamo_s', 'Template_save_template', '2021-03-01 11:49:04', 'kamo_s', 'Template_save_template'),
(10, '1', 2, 2, '0', 3, 'バインミー', 'Y', '2021-02-26 16:36:06', 'kamo_s', 'Template_save_template', '2021-03-01 11:49:04', 'kamo_s', 'Template_save_template'),
(11, '1', 2, 3, '0', 4, 'おにぎり', 'Y', '2021-02-26 16:36:06', 'kamo_s', 'Template_save_template', '2021-03-01 11:49:04', 'kamo_s', 'Template_save_template'),
(12, '1', 2, 4, '0', 4, '焼きそば', 'Y', '2021-02-26 16:36:06', 'kamo_s', 'Template_save_template', '2021-03-01 11:49:04', 'kamo_s', 'Template_save_template'),
(13, '2', 2, 1, '0', 4, '', 'Y', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template'),
(14, '2', 2, 2, '0', 3, '', 'Y', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template'),
(15, '2', 2, 3, '0', 4, '', 'Y', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template'),
(16, '2', 2, 99, '0', NULL, '', 'Y', '2021-02-26 16:36:36', 'kamo_s', 'Template_save_template', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template'),
(17, '3', 2, 0, '1', 3, '', 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL),
(18, '3', 2, 1, '1', 3, '', 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL),
(19, '3', 2, 2, '1', 3, '', 'N', '2021-02-26 16:46:47', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:47', NULL, NULL),
(20, '3', 2, 3, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(21, '3', 2, 4, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(22, '3', 2, 5, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(23, '3', 2, 6, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(24, '3', 2, 7, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(25, '3', 2, 8, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(26, '3', 2, 9, '1', 3, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(27, '3', 2, 51, '1', 4, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(28, '3', 2, 52, '1', 4, '', 'N', '2021-02-26 16:46:48', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 16:46:48', NULL, NULL),
(29, '4', 1, 1, '0', 2, NULL, 'Y', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:27', 'kamo_s', 'InboundTemplate_save_template'),
(30, '4', 1, 2, '0', 3, NULL, 'Y', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:28', 'kamo_s', 'InboundTemplate_save_template'),
(31, '4', 4, 1, '0', 5, '', 'Y', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:28', 'kamo_s', 'InboundTemplate_save_template'),
(32, '4', 4, 2, '0', 6, '', 'Y', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:28', 'kamo_s', 'InboundTemplate_save_template'),
(33, '4', 4, 99, '0', NULL, '', 'Y', '2021-02-26 17:00:12', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:29', 'kamo_s', 'InboundTemplate_save_template'),
(34, '4', 1, 1, '0', 2, NULL, 'N', '2021-02-26 17:07:29', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:29', NULL, NULL),
(35, '4', 1, 2, '0', 3, NULL, 'N', '2021-02-26 17:07:29', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:29', NULL, NULL),
(36, '4', 4, 1, '1', 5, '', 'N', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', NULL, NULL),
(37, '4', 4, 2, '0', 6, '', 'N', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', NULL, NULL),
(38, '4', 4, 99, '0', NULL, '', 'N', '2021-02-26 17:07:30', 'kamo_s', 'InboundTemplate_save_template', '2021-02-26 17:07:30', NULL, NULL),
(39, '1', 2, 0, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(40, '1', 2, 1, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(41, '1', 2, 2, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(42, '1', 2, 3, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(43, '1', 2, 4, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(44, '1', 2, 5, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(45, '1', 2, 6, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(46, '1', 2, 7, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(47, '1', 2, 8, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(48, '1', 2, 9, '0', 3, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(49, '1', 2, 51, '0', 4, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(50, '1', 2, 52, '0', 4, '', 'Y', '2021-03-01 11:49:05', 'kamo_s', 'Template_save_template', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template'),
(51, '2', 2, 1, '0', 4, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(52, '2', 2, 2, '0', 3, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(53, '2', 2, 3, '0', 4, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(54, '2', 2, 99, '0', NULL, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(55, '2', 6, 98, '0', 4, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(56, '2', 6, 99, '0', 4, '', 'Y', '2021-06-21 15:35:49', 'fabbi', 'Template_save_template', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template'),
(57, '2', 2, 1, '0', 4, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(58, '2', 2, 2, '0', 3, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(59, '2', 2, 3, '0', 4, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(60, '2', 2, 99, '0', NULL, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(61, '2', 6, 98, '0', 4, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(62, '2', 6, 99, '0', 4, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(63, '2', 7, 99, '0', 5, '', 'Y', '2021-06-21 15:41:07', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template'),
(64, '5', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:29:53', 'fabbi', 'Template_save_template'),
(65, '5', 2, 99, '0', 2, NULL, 'Y', '2021-06-21 16:27:00', 'fabbi', 'Template_save_template', '2021-06-21 16:29:53', 'fabbi', 'Template_save_template'),
(66, '5', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 16:29:53', 'fabbi', 'Template_save_template', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template'),
(67, '5', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 16:29:53', 'fabbi', 'Template_save_template', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template'),
(68, '5', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template'),
(69, '5', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template'),
(70, '5', 3, 98, '0', 2, NULL, 'Y', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template'),
(71, '5', 3, 99, '0', 1, NULL, 'Y', '2021-06-21 16:31:45', 'fabbi', 'Template_save_template', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template'),
(72, '5', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template'),
(73, '5', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template'),
(74, '5', 3, 98, '0', 2, NULL, 'Y', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template'),
(75, '5', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 16:32:46', 'fabbi', 'Template_save_template', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template'),
(76, '5', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template', '2021-06-21 16:39:58', 'fabbi', 'Template_save_template'),
(77, '5', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template', '2021-06-21 16:39:58', 'fabbi', 'Template_save_template'),
(78, '5', 3, 98, '0', 2, NULL, 'Y', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template', '2021-06-21 16:39:59', 'fabbi', 'Template_save_template'),
(79, '5', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 16:39:16', 'fabbi', 'Template_save_template', '2021-06-21 16:39:59', 'fabbi', 'Template_save_template'),
(80, '5', 2, 99, '0', 3, NULL, 'Y', '2021-06-21 16:39:59', 'fabbi', 'Template_save_template', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template'),
(81, '5', 3, 98, '0', 2, NULL, 'Y', '2021-06-21 16:39:59', 'fabbi', 'Template_save_template', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template'),
(82, '5', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 16:39:59', 'fabbi', 'Template_save_template', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template'),
(83, '5', 2, 99, '0', 3, NULL, 'Y', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template'),
(84, '5', 3, 98, '0', 2, NULL, 'Y', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template'),
(85, '5', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 16:41:44', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template'),
(86, '5', 2, 99, '0', 3, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(87, '5', 3, 98, '0', 2, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(88, '5', 3, 99, '0', 2, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(89, '5', 4, 99, '0', 4, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(90, '5', 5, 99, '0', 5, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(91, '5', 6, 99, '0', 4, NULL, 'N', '2021-06-21 16:44:09', 'fabbi', 'Template_save_template', '2021-06-21 16:44:09', NULL, NULL),
(92, '6', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template'),
(93, '6', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template'),
(94, '6', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 17:03:26', 'fabbi', 'Template_save_template', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template'),
(95, '6', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(96, '6', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(97, '6', 3, 99, '0', 2, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(98, '6', 4, 99, '0', 3, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(99, '6', 5, 98, '0', 2, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(100, '6', 5, 99, '0', 4, NULL, 'Y', '2021-06-21 17:05:21', 'fabbi', 'Template_save_template', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template'),
(101, '6', 2, 98, '0', 1, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(102, '6', 2, 99, '0', 1, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(103, '6', 3, 99, '0', 3, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(104, '6', 4, 99, '0', 3, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(105, '6', 5, 98, '0', 2, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(106, '6', 5, 99, '0', 4, NULL, 'Y', '2021-06-21 17:52:54', 'fabbi', 'Template_save_template', '2021-06-22 15:40:11', 'fabbi', 'Template_save_template'),
(107, '6', 2, 98, '0', 2, NULL, 'Y', '2021-06-22 15:50:17', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template'),
(108, '6', 2, 99, '0', 2, NULL, 'Y', '2021-06-22 15:50:17', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template'),
(109, '6', 2, 99, '0', 2, NULL, 'N', '2021-06-22 17:06:40', 'fabbi', 'Template_save_template', '2021-06-22 17:06:40', NULL, NULL),
(110, '2', 2, 1, '0', 4, '', 'N', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', NULL, NULL),
(111, '2', 2, 2, '1', 3, '', 'N', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', NULL, NULL),
(112, '2', 2, 3, '0', 4, '', 'N', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', NULL, NULL),
(113, '2', 2, 99, '0', NULL, '', 'N', '2021-06-24 11:10:11', 'fabbi', 'Template_save_template', '2021-06-24 11:10:11', NULL, NULL),
(114, '7', 1, 98, '0', 1, NULL, 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL),
(115, '7', 1, 99, '0', 1, NULL, 'N', '2021-06-24 12:34:42', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 12:34:42', NULL, NULL),
(116, '8', 2, 0, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(117, '8', 2, 1, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(118, '8', 2, 2, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(119, '8', 2, 3, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(120, '8', 2, 4, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(121, '8', 2, 5, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(122, '8', 2, 6, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(123, '8', 2, 7, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(124, '8', 2, 8, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(125, '8', 2, 9, '0', 3, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(126, '8', 2, 51, '0', 4, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(127, '8', 2, 52, '0', 4, '', 'Y', '2021-06-24 13:29:12', 'fabbi', 'Template_import', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template'),
(128, '8', 2, 0, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(129, '8', 2, 1, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(130, '8', 2, 2, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(131, '8', 2, 3, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(132, '8', 2, 4, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(133, '8', 2, 5, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(134, '8', 2, 6, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(135, '8', 2, 7, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(136, '8', 2, 8, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(137, '8', 2, 9, '0', 3, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(138, '8', 2, 51, '0', 4, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(139, '8', 2, 52, '0', 4, '', 'Y', '2021-06-24 13:32:55', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template'),
(140, '1', 2, 0, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(141, '1', 2, 1, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(142, '1', 2, 2, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(143, '1', 2, 3, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(144, '1', 2, 4, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(145, '1', 2, 5, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(146, '1', 2, 6, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(147, '1', 2, 7, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(148, '1', 2, 8, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(149, '1', 2, 9, '1', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(150, '1', 2, 51, '1', 4, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(151, '1', 2, 52, '1', 4, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(152, '1', 6, 98, '0', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(153, '1', 6, 99, '0', 3, '', 'N', '2021-06-24 13:54:49', 'fabbi', 'Template_save_template', '2021-06-24 13:54:49', NULL, NULL),
(154, '9', 1, 99, '0', 2, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL),
(155, '9', 2, 99, '0', 3, NULL, 'N', '2021-06-24 16:56:11', 'fabbi', 'InboundTemplate_save_template', '2021-06-24 16:56:11', NULL, NULL),
(156, '8', 2, 0, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(157, '8', 2, 1, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(158, '8', 2, 2, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(159, '8', 2, 3, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(160, '8', 2, 4, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(161, '8', 2, 5, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(162, '8', 2, 6, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(163, '8', 2, 7, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(164, '8', 2, 8, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(165, '8', 2, 9, '1', 3, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(166, '8', 2, 51, '1', 4, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL),
(167, '8', 2, 52, '1', 4, '', 'N', '2021-06-24 17:07:47', 'fabbi', 'Template_save_template', '2021-06-24 17:07:47', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t40_news`
--

CREATE TABLE `t40_news` (
  `ID` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `title` varchar(128) DEFAULT NULL COMMENT 'タイトル',
  `content` text COMMENT '内容',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t40ニュース';

-- --------------------------------------------------------

--
-- Table structure for table `t50_list_histories`
--

CREATE TABLE `t50_list_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `list_id` bigint(20) NOT NULL COMMENT '発信リストID',
  `list_name` varchar(128) DEFAULT NULL COMMENT '発信リスト名',
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `tel_total` varchar(6) DEFAULT NULL COMMENT '総件数',
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t50発信リスト';

--
-- Dumping data for table `t50_list_histories`
--

INSERT INTO `t50_list_histories` (`id`, `schedule_id`, `list_id`, `list_name`, `list_test_flag`, `tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 3, 'ダミー番号3', '1', '1', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t51_tel_histories`
--

CREATE TABLE `t51_tel_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL,
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t51 発信電話番号リスト';

--
-- Dumping data for table `t51_tel_histories`
--

INSERT INTO `t51_tel_histories` (`id`, `schedule_id`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, '09757343433', 'かも', '4000', '5678', '12345', '20001112', '2000年11月12日', 'dfddfdgfh', 'rrrr', 'vxcv', 'xvdfv', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 3, '09235560743', 'かも', 'contents', '232313', 'test 1', 'test 2', 'test 3', 'test 4', 'test 5', 'test 6', 'test 7', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 4, '09750003343', 'customize 2', 'customize 3', 'customize 4', 'customize 5', 'customize 6', 'customize 7', 'customize 8', 'customize 9', 'customize 10', 'customize 11', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, '09235560743', 'かも', 'test', '123', '12345', '20001112', 'test test', '234', 'acb', 'vxcv', '345', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, '09757225890', 'customize 2', 'customize 3', 'customize 4', 'customize 5', 'customize 6', 'customize 7', 'customize 8', 'customize 9', 'customize 10', 'customize 11', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 1, '09750003343', 'かも', 'contents', '232313', 'test 1', 'test 2', 'test 3', 'test 4', 'test 5', 'test 6', 'test 7', 'N', NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t52_tel_redials`
--

CREATE TABLE `t52_tel_redials` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `redial_flag` int(20) NOT NULL COMMENT 'リダイアル数',
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t52 発信電話番号リダイヤル';

-- --------------------------------------------------------

--
-- Table structure for table `t54_list_ng_histories`
--

CREATE TABLE `t54_list_ng_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `list_ng_id` bigint(20) NOT NULL COMMENT '発信NGリストID',
  `list_name` varchar(128) DEFAULT NULL COMMENT 'リスト名',
  `total` int(11) DEFAULT NULL COMMENT '総件数',
  `expired_date_from` datetime DEFAULT NULL COMMENT '有効期限開始',
  `expired_date_to` datetime DEFAULT NULL COMMENT '有効期限終了',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t54発信NGリスト';

-- --------------------------------------------------------

--
-- Table structure for table `t55_tel_ng_histories`
--

CREATE TABLE `t55_tel_ng_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `memo` varchar(128) DEFAULT NULL COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t55発信NG番号';

-- --------------------------------------------------------

--
-- Table structure for table `t56_inbound_list_histories`
--

CREATE TABLE `t56_inbound_list_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` varchar(20) NOT NULL COMMENT '着信設定ID',
  `list_id` varchar(20) NOT NULL COMMENT '着信リストID',
  `list_name` varchar(128) DEFAULT NULL COMMENT '着信リスト名',
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `item_main` varchar(128) DEFAULT NULL,
  `tel_total` int(11) DEFAULT NULL COMMENT '総件数',
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t56着信リスト履歴';

--
-- Dumping data for table `t56_inbound_list_histories`
--

INSERT INTO `t56_inbound_list_histories` (`id`, `inbound_id`, `list_id`, `list_name`, `list_test_flag`, `item_main`, `tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '3', '3', '1', '0', '電話番号', 1, 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t57_inbound_tel_histories`
--

CREATE TABLE `t57_inbound_tel_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` varchar(20) NOT NULL COMMENT '着信設定ID',
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL COMMENT '項目10',
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t57着信電話リスト履歴';

--
-- Dumping data for table `t57_inbound_tel_histories`
--

INSERT INTO `t57_inbound_tel_histories` (`id`, `inbound_id`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '3', '34523', '09000000006', '325', '235', '235', '523', '23', '2352', 'abc', 'cbd', '1', 'N', NULL, 'N', NULL, NULL, NULL, NULL, 'fabbi', NULL),
(2, '3', 'test 1', '09000087006', 'test 3', 'test 4', 'test 65', 'test 6', 'test 7', 'test 8', 'test 9', 'test 10', 'test 11', 'N', NULL, 'N', NULL, NULL, NULL, NULL, 'fabbi', NULL),
(3, '3', 'インバウンド 1', '09000345006', 'インバウンド 3', 'インバウンド 4', 'インバウンド 65', 'インバウンド 6', 'インバウンド 7', 'インバウンド 8', 'インバウンド 9', 'インバウンド 10', 'test', 'N', NULL, 'N', NULL, NULL, NULL, NULL, 'fabbi', NULL),
(4, '3', 'no 0', '09000345213', 'no 1', 'no 2', 'no 3', 'no 4', 'no 5', 'no 6', 'no 7', 'no 8', '1', 'N', NULL, 'N', NULL, NULL, NULL, NULL, 'fabbi', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t58_inbound_list_ng_histories`
--

CREATE TABLE `t58_inbound_list_ng_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` varchar(20) NOT NULL COMMENT '着信設定ID',
  `list_ng_id` varchar(20) NOT NULL COMMENT '着信拒否リストID',
  `list_name` varchar(128) DEFAULT NULL COMMENT '着信拒否リスト名',
  `total` int(11) DEFAULT NULL COMMENT '総件数',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t58着信拒否履歴';

-- --------------------------------------------------------

--
-- Table structure for table `t59_inbound_tel_ng_histories`
--

CREATE TABLE `t59_inbound_tel_ng_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` varchar(20) NOT NULL COMMENT '着信設定ID',
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `memo` varchar(128) DEFAULT NULL COMMENT '備考',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t59着信拒否番号';

-- --------------------------------------------------------

--
-- Table structure for table `t60_template_histories`
--

CREATE TABLE `t60_template_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `template_id` bigint(20) DEFAULT NULL,
  `template_name` varchar(128) NOT NULL COMMENT 'スクリプト名',
  `question_total` varchar(4) NOT NULL COMMENT '質問総件数',
  `description` text COMMENT '説明',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t60 テンプレート';

--
-- Dumping data for table `t60_template_histories`
--

INSERT INTO `t60_template_histories` (`id`, `schedule_id`, `template_id`, `template_name`, `question_total`, `description`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 1, 'サンプルテンプレート', '6', '再生、質問', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t61_question_histories`
--

CREATE TABLE `t61_question_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL,
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `question_type` varchar(2) DEFAULT NULL,
  `question_title` varchar(64) DEFAULT NULL COMMENT '質問タイトル',
  `question_yuko` int(1) DEFAULT '0' COMMENT '1:有効',
  `audio_type` varchar(1) DEFAULT NULL COMMENT '０：音声ファイル,１：音声合成',
  `audio_id` int(11) DEFAULT NULL,
  `audio_name` varchar(64) DEFAULT NULL,
  `audio_content` text COMMENT '音声内容',
  `question_repeat` varchar(4) DEFAULT NULL COMMENT '繰り返し',
  `auth_match_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `auth_item` varchar(20) DEFAULT NULL COMMENT '認証項目',
  `second_record` int(11) DEFAULT NULL,
  `yuko_button_record` varchar(1) DEFAULT '0' COMMENT '1:有効',
  `digit` varchar(4) DEFAULT NULL COMMENT '桁数',
  `trans_tel` varchar(20) DEFAULT NULL COMMENT '転送先',
  `trans_seat_num` varchar(4) DEFAULT NULL COMMENT '席数',
  `trans_empty_seat_flag` varchar(1) DEFAULT '0' COMMENT '空き',
  `trans_timeout_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `trans_timeout_audio_id` int(11) DEFAULT NULL,
  `trans_timeout_audio_name` varchar(64) DEFAULT NULL,
  `trans_timeout_audio_content` text COMMENT '音声内容',
  `trans_timeout` varchar(4) DEFAULT NULL,
  `recheck_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `recheck_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `recheck_audio_id` int(11) DEFAULT NULL,
  `recheck_audio_name` varchar(64) DEFAULT NULL,
  `recheck_audio_content` text COMMENT '音声内容',
  `recheck_button_next` int(4) DEFAULT NULL,
  `recheck_button_prev` int(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `sms_display_number` varchar(20) DEFAULT NULL,
  `sms_content` varchar(1000) DEFAULT NULL,
  `sms_error_audio_type` varchar(1) NOT NULL,
  `sms_error_audio_id` int(11) NOT NULL,
  `sms_error_audio_name` varchar(64) NOT NULL,
  `sms_error_audio_content` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t61テンプレート質問';

--
-- Dumping data for table `t61_question_histories`
--

INSERT INTO `t61_question_histories` (`id`, `schedule_id`, `question_no`, `question_type`, `question_title`, `question_yuko`, `audio_type`, `audio_id`, `audio_name`, `audio_content`, `question_repeat`, `auth_match_flag`, `auth_item`, `second_record`, `yuko_button_record`, `digit`, `trans_tel`, `trans_seat_num`, `trans_empty_seat_flag`, `trans_timeout_audio_type`, `trans_timeout_audio_id`, `trans_timeout_audio_name`, `trans_timeout_audio_content`, `trans_timeout`, `recheck_flag`, `recheck_audio_type`, `recheck_audio_id`, `recheck_audio_name`, `recheck_audio_content`, `recheck_button_next`, `recheck_button_prev`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `sms_display_number`, `sms_content`, `sms_error_audio_type`, `sms_error_audio_id`, `sms_error_audio_name`, `sms_error_audio_content`) VALUES
(1, 1, 1, '1', '', 0, '1', NULL, NULL, 'こんにちは。こちらはサンプルテンプレートです。', NULL, '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', ''),
(2, 1, 2, '2', '', 1, '1', NULL, NULL, '0から9のなかで、好きな番号を選んでください。', '1', '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', ''),
(3, 1, 3, '1', '数値', 0, '1', NULL, NULL, '数値が選択されました。ご回答ありがとうございました。', NULL, '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', ''),
(4, 1, 4, '1', '数値以外', 0, '1', NULL, NULL, 'もう一度、選びなおしてください。', NULL, '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', ''),
(5, 1, 5, '8', '', 0, NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', ''),
(6, 1, 6, '9', '', 0, '1', NULL, NULL, 'タイムアウトしました。', NULL, '0', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', 0, '', '');

-- --------------------------------------------------------

--
-- Table structure for table `t62_button_histories`
--

CREATE TABLE `t62_button_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `answer_no` int(4) DEFAULT NULL COMMENT '回答番号（ボタン）',
  `yuko_flag` varchar(1) DEFAULT NULL COMMENT '有効チェック',
  `jump_question` varchar(4) DEFAULT NULL COMMENT 'ジャンプ先質問番号',
  `answer_content` varchar(128) DEFAULT NULL COMMENT 'テキスト',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t62 回答ボタン設定';

--
-- Dumping data for table `t62_button_histories`
--

INSERT INTO `t62_button_histories` (`id`, `schedule_id`, `question_no`, `answer_no`, `yuko_flag`, `jump_question`, `answer_content`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 2, 0, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, 2, 1, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 2, 2, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, 2, 3, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 2, 4, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 1, 2, 5, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 1, 2, 6, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 1, 2, 7, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 1, 2, 8, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, 2, 9, '1', '3', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 1, 2, 51, '1', '4', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 1, 2, 52, '1', '4', '', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t63_inbound_template_histories`
--

CREATE TABLE `t63_inbound_template_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` bigint(20) NOT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `template_name` varchar(128) NOT NULL COMMENT 'スクリプト名',
  `question_total` varchar(4) NOT NULL COMMENT '質問総件数',
  `description` text COMMENT '説明',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t63 テンプレート';

-- --------------------------------------------------------

--
-- Table structure for table `t64_inbound_question_histories`
--

CREATE TABLE `t64_inbound_question_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` bigint(20) NOT NULL,
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `question_type` varchar(2) NOT NULL COMMENT '質問種類',
  `question_title` varchar(64) DEFAULT NULL COMMENT '質問タイトル',
  `question_yuko` int(1) DEFAULT '0' COMMENT '1:有効',
  `jump_question` int(4) DEFAULT NULL,
  `audio_type` varchar(1) DEFAULT NULL COMMENT '０：音声ファイル,１：音声合成',
  `audio_id` int(11) DEFAULT NULL,
  `audio_name` varchar(64) DEFAULT NULL,
  `audio_content` text COMMENT '音声内容',
  `question_repeat` varchar(4) DEFAULT NULL COMMENT '繰り返し',
  `auth_match_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `auth_item` varchar(20) DEFAULT NULL COMMENT '認証項目',
  `second_record` int(11) DEFAULT NULL,
  `yuko_button_record` varchar(1) DEFAULT '0' COMMENT '1:有効',
  `digit` varchar(4) DEFAULT NULL COMMENT '桁数',
  `trans_tel` varchar(20) DEFAULT NULL COMMENT '転送先',
  `trans_seat_num` varchar(4) DEFAULT NULL COMMENT '席数',
  `trans_empty_seat_flag` varchar(1) DEFAULT '0' COMMENT '空き',
  `trans_timeout_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `trans_timeout_audio_id` int(11) DEFAULT NULL,
  `trans_timeout_audio_name` varchar(64) DEFAULT NULL,
  `trans_timeout_audio_content` text COMMENT '音声内容',
  `trans_timeout` varchar(4) DEFAULT NULL,
  `recheck_flag` varchar(1) DEFAULT '0' COMMENT '0:なし,1:あり',
  `recheck_audio_type` varchar(1) DEFAULT NULL COMMENT '音声種類',
  `recheck_audio_id` int(11) DEFAULT NULL,
  `recheck_audio_name` varchar(64) DEFAULT NULL,
  `recheck_audio_content` text COMMENT '音声内容',
  `recheck_button_next` int(4) DEFAULT NULL,
  `recheck_button_prev` int(4) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `bukken_audio_type` varchar(1) DEFAULT NULL,
  `bukken_audio_id` varchar(11) DEFAULT NULL,
  `bukken_audio_name` varchar(64) DEFAULT NULL,
  `bukken_audio_content` text,
  `bukken_answer_no` int(11) DEFAULT NULL,
  `bukken_diagram_audio_type` varchar(1) DEFAULT NULL,
  `bukken_diagram_audio_id` varchar(11) DEFAULT NULL,
  `bukken_diagram_audio_name` varchar(64) DEFAULT NULL,
  `bukken_diagram_audio_content` text,
  `bukken_diagram_answer_no` int(11) DEFAULT NULL,
  `bukken_cont_audio_type` varchar(1) DEFAULT NULL,
  `bukken_cont_audio_id` int(11) DEFAULT NULL,
  `bukken_cont_audio_name` varchar(64) DEFAULT NULL,
  `bukken_cont_audio_content` varchar(64) DEFAULT NULL,
  `sms_display_number` varchar(20) DEFAULT NULL,
  `sms_content` varchar(1000) DEFAULT NULL,
  `sms_error_audio_type` varchar(1) DEFAULT NULL,
  `sms_error_audio_id` int(11) DEFAULT NULL,
  `sms_error_audio_name` varchar(64) DEFAULT NULL,
  `sms_error_audio_content` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t64テンプレート質問';

--
-- Dumping data for table `t64_inbound_question_histories`
--

INSERT INTO `t64_inbound_question_histories` (`id`, `inbound_id`, `question_no`, `question_type`, `question_title`, `question_yuko`, `jump_question`, `audio_type`, `audio_id`, `audio_name`, `audio_content`, `question_repeat`, `auth_match_flag`, `auth_item`, `second_record`, `yuko_button_record`, `digit`, `trans_tel`, `trans_seat_num`, `trans_empty_seat_flag`, `trans_timeout_audio_type`, `trans_timeout_audio_id`, `trans_timeout_audio_name`, `trans_timeout_audio_content`, `trans_timeout`, `recheck_flag`, `recheck_audio_type`, `recheck_audio_id`, `recheck_audio_name`, `recheck_audio_content`, `recheck_button_next`, `recheck_button_prev`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `bukken_audio_type`, `bukken_audio_id`, `bukken_audio_name`, `bukken_audio_content`, `bukken_answer_no`, `bukken_diagram_audio_type`, `bukken_diagram_audio_id`, `bukken_diagram_audio_name`, `bukken_diagram_audio_content`, `bukken_diagram_answer_no`, `bukken_cont_audio_type`, `bukken_cont_audio_id`, `bukken_cont_audio_name`, `bukken_cont_audio_content`, `sms_display_number`, `sms_content`, `sms_error_audio_type`, `sms_error_audio_id`, `sms_error_audio_name`, `sms_error_audio_content`) VALUES
(2, 3, 1, '10', 'test', 0, NULL, NULL, NULL, NULL, NULL, NULL, '1', NULL, NULL, '0', NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t65_inbound_button_histories`
--

CREATE TABLE `t65_inbound_button_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` bigint(20) NOT NULL,
  `question_no` int(4) NOT NULL COMMENT '質問番号',
  `answer_no` int(4) DEFAULT NULL COMMENT '回答番号（ボタン）',
  `yuko_flag` varchar(1) DEFAULT NULL COMMENT '有効チェック',
  `jump_question` varchar(4) DEFAULT NULL COMMENT 'ジャンプ先質問番号',
  `answer_content` varchar(128) DEFAULT NULL COMMENT 'テキスト',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t65 回答ボタン設定';

--
-- Dumping data for table `t65_inbound_button_histories`
--

INSERT INTO `t65_inbound_button_histories` (`id`, `inbound_id`, `question_no`, `answer_no`, `yuko_flag`, `jump_question`, `answer_content`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 3, 1, 1, '1', '1', 'dsd', 'N', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t70_rdd_tels`
--

CREATE TABLE `t70_rdd_tels` (
  `ID` bigint(20) NOT NULL COMMENT 'ID',
  `tel_no` varchar(20) DEFAULT NULL COMMENT '番号',
  `address` varchar(128) DEFAULT NULL COMMENT '地域',
  `keisai_flag` varchar(1) DEFAULT NULL COMMENT '掲載フラグ	 0:未掲載、1：掲載',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t70番号増殖WORK';

-- --------------------------------------------------------

--
-- Table structure for table `t71_prefectures`
--

CREATE TABLE `t71_prefectures` (
  `ID` bigint(20) NOT NULL COMMENT 'ID',
  `prefecture_name` varchar(64) DEFAULT NULL COMMENT '都道府県名',
  `prefecture_name_kana` varchar(64) DEFAULT NULL COMMENT '都道府県名',
  `prefecture_code` varchar(4) DEFAULT NULL COMMENT '都道府県コード',
  `num` int(11) DEFAULT NULL COMMENT '総件数',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t71都道府県';

-- --------------------------------------------------------

--
-- Table structure for table `t72_districts`
--

CREATE TABLE `t72_districts` (
  `ID` bigint(20) NOT NULL COMMENT 'ID',
  `prefecture_code` varchar(4) DEFAULT NULL COMMENT '都道府県コード',
  `district_name` varchar(128) DEFAULT NULL COMMENT '市区名',
  `district_name_kana` varchar(64) DEFAULT NULL COMMENT '市区名カナ',
  `district_code` varchar(4) DEFAULT NULL COMMENT '市区コード',
  `num` int(11) DEFAULT NULL COMMENT '件数',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t72市区';

-- --------------------------------------------------------

--
-- Table structure for table `t80_outgoing_results`
--

CREATE TABLE `t80_outgoing_results` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュール',
  `redial_flag` int(1) NOT NULL DEFAULT '0',
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `memo` text COMMENT 'メモ',
  `tel_type` varchar(64) DEFAULT NULL COMMENT '電話種類',
  `del_flag` varchar(45) DEFAULT 'N',
  `call_datetime` datetime DEFAULT NULL COMMENT '発信日時',
  `connect_datetime` datetime DEFAULT NULL COMMENT '接続日時',
  `cut_datetime` datetime DEFAULT NULL COMMENT '切断日時',
  `trans_call_datetime` datetime DEFAULT NULL COMMENT '発信日時',
  `trans_connect_datetime` datetime DEFAULT NULL COMMENT '接続日時',
  `trans_cut_datetime` datetime DEFAULT NULL COMMENT '切断日時',
  `status` varchar(20) DEFAULT NULL COMMENT 'ステータス',
  `valid_count` varchar(20) DEFAULT NULL COMMENT '有効回答数',
  `ans_accuracy` varchar(20) DEFAULT NULL COMMENT '回答確度',
  `answer1` varchar(84) DEFAULT NULL,
  `answer2` varchar(84) DEFAULT NULL,
  `answer3` varchar(84) DEFAULT NULL,
  `answer4` varchar(84) DEFAULT NULL,
  `answer5` varchar(84) DEFAULT NULL,
  `answer6` varchar(84) DEFAULT NULL,
  `answer7` varchar(84) DEFAULT NULL,
  `answer8` varchar(84) DEFAULT NULL,
  `answer9` varchar(84) DEFAULT NULL,
  `answer10` varchar(84) DEFAULT NULL,
  `answer11` varchar(84) DEFAULT NULL,
  `answer12` varchar(84) DEFAULT NULL,
  `answer13` varchar(84) DEFAULT NULL,
  `answer14` varchar(84) DEFAULT NULL,
  `answer15` varchar(84) DEFAULT NULL,
  `answer16` varchar(84) DEFAULT NULL,
  `answer17` varchar(84) DEFAULT NULL,
  `answer18` varchar(84) DEFAULT NULL,
  `answer19` varchar(84) DEFAULT NULL,
  `answer20` varchar(84) DEFAULT NULL,
  `answer21` varchar(84) DEFAULT NULL,
  `answer22` varchar(84) DEFAULT NULL,
  `answer23` varchar(84) DEFAULT NULL,
  `answer24` varchar(84) DEFAULT NULL,
  `answer25` varchar(84) DEFAULT NULL,
  `answer26` varchar(84) DEFAULT NULL,
  `answer27` varchar(84) DEFAULT NULL,
  `answer28` varchar(84) DEFAULT NULL,
  `answer29` varchar(84) DEFAULT NULL,
  `answer30` varchar(84) DEFAULT NULL,
  `answer31` varchar(84) DEFAULT NULL,
  `answer32` varchar(84) DEFAULT NULL,
  `answer33` varchar(84) DEFAULT NULL,
  `answer34` varchar(84) DEFAULT NULL,
  `answer35` varchar(84) DEFAULT NULL,
  `answer36` varchar(84) DEFAULT NULL,
  `answer37` varchar(84) DEFAULT NULL,
  `answer38` varchar(84) DEFAULT NULL,
  `answer39` varchar(84) DEFAULT NULL,
  `answer40` varchar(84) DEFAULT NULL,
  `answer41` varchar(84) DEFAULT NULL,
  `answer42` varchar(84) DEFAULT NULL,
  `answer43` varchar(84) DEFAULT NULL,
  `answer44` varchar(84) DEFAULT NULL,
  `answer45` varchar(84) DEFAULT NULL,
  `answer46` varchar(84) DEFAULT NULL,
  `answer47` varchar(84) DEFAULT NULL,
  `answer48` varchar(84) DEFAULT NULL,
  `answer49` varchar(84) DEFAULT NULL,
  `answer50` varchar(84) DEFAULT NULL,
  `answer51` varchar(84) DEFAULT NULL,
  `answer52` varchar(84) DEFAULT NULL,
  `answer53` varchar(84) DEFAULT NULL,
  `answer54` varchar(84) DEFAULT NULL,
  `answer55` varchar(84) DEFAULT NULL,
  `answer56` varchar(84) DEFAULT NULL,
  `answer57` varchar(84) DEFAULT NULL,
  `answer58` varchar(84) DEFAULT NULL,
  `answer59` varchar(84) DEFAULT NULL,
  `answer60` varchar(84) DEFAULT NULL,
  `answer61` varchar(84) DEFAULT NULL,
  `answer62` varchar(84) DEFAULT NULL,
  `answer63` varchar(84) DEFAULT NULL,
  `answer64` varchar(84) DEFAULT NULL,
  `answer65` varchar(84) DEFAULT NULL,
  `answer66` varchar(84) DEFAULT NULL,
  `answer67` varchar(84) DEFAULT NULL,
  `answer68` varchar(84) DEFAULT NULL,
  `answer69` varchar(84) DEFAULT NULL,
  `answer70` varchar(84) DEFAULT NULL,
  `answer71` varchar(84) DEFAULT NULL,
  `answer72` varchar(84) DEFAULT NULL,
  `answer73` varchar(84) DEFAULT NULL,
  `answer74` varchar(84) DEFAULT NULL,
  `answer75` varchar(84) DEFAULT NULL,
  `answer76` varchar(84) DEFAULT NULL,
  `answer77` varchar(84) DEFAULT NULL,
  `answer78` varchar(84) DEFAULT NULL,
  `answer79` varchar(84) DEFAULT NULL,
  `answer80` varchar(84) DEFAULT NULL,
  `answer81` varchar(84) DEFAULT NULL,
  `answer82` varchar(84) DEFAULT NULL,
  `answer83` varchar(84) DEFAULT NULL,
  `answer84` varchar(84) DEFAULT NULL,
  `answer85` varchar(84) DEFAULT NULL,
  `answer86` varchar(84) DEFAULT NULL,
  `answer87` varchar(84) DEFAULT NULL,
  `answer88` varchar(84) DEFAULT NULL,
  `answer89` varchar(84) DEFAULT NULL,
  `answer90` varchar(84) DEFAULT NULL,
  `answer91` varchar(84) DEFAULT NULL,
  `answer92` varchar(84) DEFAULT NULL,
  `answer93` varchar(84) DEFAULT NULL,
  `answer94` varchar(84) DEFAULT NULL,
  `answer95` varchar(84) DEFAULT NULL,
  `answer96` varchar(84) DEFAULT NULL,
  `answer97` varchar(84) DEFAULT NULL,
  `answer98` varchar(84) DEFAULT NULL,
  `answer99` varchar(84) DEFAULT NULL,
  `answer100` varchar(84) DEFAULT NULL,
  `answer101` varchar(84) DEFAULT NULL,
  `answer102` varchar(84) DEFAULT NULL,
  `answer103` varchar(84) DEFAULT NULL,
  `answer104` varchar(84) DEFAULT NULL,
  `answer105` varchar(84) DEFAULT NULL,
  `answer106` varchar(84) DEFAULT NULL,
  `answer107` varchar(84) DEFAULT NULL,
  `answer108` varchar(84) DEFAULT NULL,
  `answer109` varchar(84) DEFAULT NULL,
  `answer110` varchar(84) DEFAULT NULL,
  `answer111` varchar(84) DEFAULT NULL,
  `answer112` varchar(84) DEFAULT NULL,
  `answer113` varchar(84) DEFAULT NULL,
  `answer114` varchar(84) DEFAULT NULL,
  `answer115` varchar(84) DEFAULT NULL,
  `answer116` varchar(84) DEFAULT NULL,
  `answer117` varchar(84) DEFAULT NULL,
  `answer118` varchar(84) DEFAULT NULL,
  `answer119` varchar(84) DEFAULT NULL,
  `answer120` varchar(84) DEFAULT NULL,
  `answer121` varchar(84) DEFAULT NULL,
  `answer122` varchar(84) DEFAULT NULL,
  `answer123` varchar(84) DEFAULT NULL,
  `answer124` varchar(84) DEFAULT NULL,
  `answer125` varchar(84) DEFAULT NULL,
  `answer126` varchar(84) DEFAULT NULL,
  `answer127` varchar(84) DEFAULT NULL,
  `answer128` varchar(84) DEFAULT NULL,
  `answer129` varchar(84) DEFAULT NULL,
  `answer130` varchar(84) DEFAULT NULL,
  `answer131` varchar(84) DEFAULT NULL,
  `answer132` varchar(84) DEFAULT NULL,
  `answer133` varchar(84) DEFAULT NULL,
  `answer134` varchar(84) DEFAULT NULL,
  `answer135` varchar(84) DEFAULT NULL,
  `answer136` varchar(84) DEFAULT NULL,
  `answer137` varchar(84) DEFAULT NULL,
  `answer138` varchar(84) DEFAULT NULL,
  `answer139` varchar(84) DEFAULT NULL,
  `answer140` varchar(84) DEFAULT NULL,
  `answer141` varchar(84) DEFAULT NULL,
  `answer142` varchar(84) DEFAULT NULL,
  `answer143` varchar(84) DEFAULT NULL,
  `answer144` varchar(84) DEFAULT NULL,
  `answer145` varchar(84) DEFAULT NULL,
  `answer146` varchar(84) DEFAULT NULL,
  `answer147` varchar(84) DEFAULT NULL,
  `answer148` varchar(84) DEFAULT NULL,
  `answer149` varchar(84) DEFAULT NULL,
  `answer150` varchar(84) DEFAULT NULL,
  `answer151` varchar(84) DEFAULT NULL,
  `answer152` varchar(84) DEFAULT NULL,
  `answer153` varchar(84) DEFAULT NULL,
  `answer154` varchar(84) DEFAULT NULL,
  `answer155` varchar(84) DEFAULT NULL,
  `answer156` varchar(84) DEFAULT NULL,
  `answer157` varchar(84) DEFAULT NULL,
  `answer158` varchar(84) DEFAULT NULL,
  `answer159` varchar(84) DEFAULT NULL,
  `answer160` varchar(84) DEFAULT NULL,
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t80 発信結果';

--
-- Dumping data for table `t80_outgoing_results`
--

INSERT INTO `t80_outgoing_results` (`id`, `schedule_id`, `redial_flag`, `tel_no`, `memo`, `tel_type`, `del_flag`, `call_datetime`, `connect_datetime`, `cut_datetime`, `trans_call_datetime`, `trans_connect_datetime`, `trans_cut_datetime`, `status`, `valid_count`, `ans_accuracy`, `answer1`, `answer2`, `answer3`, `answer4`, `answer5`, `answer6`, `answer7`, `answer8`, `answer9`, `answer10`, `answer11`, `answer12`, `answer13`, `answer14`, `answer15`, `answer16`, `answer17`, `answer18`, `answer19`, `answer20`, `answer21`, `answer22`, `answer23`, `answer24`, `answer25`, `answer26`, `answer27`, `answer28`, `answer29`, `answer30`, `answer31`, `answer32`, `answer33`, `answer34`, `answer35`, `answer36`, `answer37`, `answer38`, `answer39`, `answer40`, `answer41`, `answer42`, `answer43`, `answer44`, `answer45`, `answer46`, `answer47`, `answer48`, `answer49`, `answer50`, `answer51`, `answer52`, `answer53`, `answer54`, `answer55`, `answer56`, `answer57`, `answer58`, `answer59`, `answer60`, `answer61`, `answer62`, `answer63`, `answer64`, `answer65`, `answer66`, `answer67`, `answer68`, `answer69`, `answer70`, `answer71`, `answer72`, `answer73`, `answer74`, `answer75`, `answer76`, `answer77`, `answer78`, `answer79`, `answer80`, `answer81`, `answer82`, `answer83`, `answer84`, `answer85`, `answer86`, `answer87`, `answer88`, `answer89`, `answer90`, `answer91`, `answer92`, `answer93`, `answer94`, `answer95`, `answer96`, `answer97`, `answer98`, `answer99`, `answer100`, `answer101`, `answer102`, `answer103`, `answer104`, `answer105`, `answer106`, `answer107`, `answer108`, `answer109`, `answer110`, `answer111`, `answer112`, `answer113`, `answer114`, `answer115`, `answer116`, `answer117`, `answer118`, `answer119`, `answer120`, `answer121`, `answer122`, `answer123`, `answer124`, `answer125`, `answer126`, `answer127`, `answer128`, `answer129`, `answer130`, `answer131`, `answer132`, `answer133`, `answer134`, `answer135`, `answer136`, `answer137`, `answer138`, `answer139`, `answer140`, `answer141`, `answer142`, `answer143`, `answer144`, `answer145`, `answer146`, `answer147`, `answer148`, `answer149`, `answer150`, `answer151`, `answer152`, `answer153`, `answer154`, `answer155`, `answer156`, `answer157`, `answer158`, `answer159`, `answer160`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(81931, '1', 0, '09757343433', NULL, 'tone', 'N', '2021-06-03 11:55:16', '2021-07-01 00:00:00', '2021-07-19 00:00:00', '2021-07-13 00:00:00', '2021-07-08 00:00:00', '2021-07-20 00:00:00', 'transfer', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81932, '1', 0, '09757225890', NULL, 'tone', 'N', '2021-06-04 11:55:16', '2021-06-08 00:00:00', '2021-06-17 00:00:00', '2021-09-15 00:00:00', '2021-09-28 00:00:00', '2021-07-12 00:00:00', 'transferfull', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81933, '1', 0, '09235560743', NULL, 'tone', 'N', '2021-06-02 11:55:16', '2021-06-15 00:00:00', '2021-06-17 00:00:00', '2021-09-17 00:00:00', '2021-09-16 00:00:00', '2021-07-12 00:00:00', 'connect', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81934, '1', 0, '09750003343', NULL, 'tone', 'N', '2021-06-09 11:55:16', '2021-06-17 00:00:00', '2021-06-15 00:00:00', '2021-09-01 00:00:00', '2021-09-15 00:00:00', '2021-07-12 00:00:00', 'transfertimeout', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81936, '1', 0, '09750003322', NULL, 'tone', 'N', '2021-06-11 11:55:16', '2021-06-09 00:00:00', '2021-06-02 00:00:00', '2021-08-18 00:00:00', '2021-10-08 00:00:00', '2021-07-17 00:00:00', 'transferreject', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81937, '1', 0, '09750000787', NULL, 'tone', 'N', '2021-06-15 11:55:16', '2021-06-09 00:00:00', '2021-07-22 00:00:00', '2021-08-06 00:00:00', '2021-09-21 00:00:00', '2021-07-19 00:00:00', 'transfercancel', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81938, '1', 0, '09234000755', NULL, 'tone', 'N', '2021-06-02 11:55:16', '2021-06-12 00:00:00', '2021-06-02 00:00:00', '2021-08-18 00:00:00', '2021-10-08 00:00:00', '2021-06-28 00:00:00', 'transferdisconnect', 'e', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t81_incoming_results`
--

CREATE TABLE `t81_incoming_results` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `inbound_id` bigint(20) NOT NULL COMMENT '外線番号',
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `prefix` varchar(20) DEFAULT NULL,
  `memo` text COMMENT 'メモ',
  `tel_type` varchar(64) DEFAULT NULL COMMENT '電話種類',
  `del_flag` varchar(45) DEFAULT 'N',
  `call_datetime` datetime DEFAULT NULL COMMENT '発信日時',
  `connect_datetime` datetime DEFAULT NULL COMMENT '接続日時',
  `cut_datetime` datetime DEFAULT NULL COMMENT '切断日時',
  `trans_call_datetime` datetime DEFAULT NULL COMMENT '発信日時',
  `trans_connect_datetime` datetime DEFAULT NULL COMMENT '接続日時',
  `trans_cut_datetime` datetime DEFAULT NULL COMMENT '切断日時',
  `status` varchar(20) DEFAULT NULL COMMENT 'ステータス',
  `valid_count` varchar(20) DEFAULT NULL COMMENT '有効回答数',
  `ans_accuracy` varchar(20) DEFAULT NULL COMMENT '回答確度',
  `answer1` varchar(84) DEFAULT NULL,
  `answer2` varchar(84) DEFAULT NULL,
  `answer3` varchar(84) DEFAULT NULL,
  `answer4` varchar(84) DEFAULT NULL,
  `answer5` varchar(84) DEFAULT NULL,
  `answer6` varchar(84) DEFAULT NULL,
  `answer7` varchar(84) DEFAULT NULL,
  `answer8` varchar(84) DEFAULT NULL,
  `answer9` varchar(84) DEFAULT NULL,
  `answer10` varchar(84) DEFAULT NULL,
  `answer11` varchar(84) DEFAULT NULL,
  `answer12` varchar(84) DEFAULT NULL,
  `answer13` varchar(84) DEFAULT NULL,
  `answer14` varchar(84) DEFAULT NULL,
  `answer15` varchar(84) DEFAULT NULL,
  `answer16` varchar(84) DEFAULT NULL,
  `answer17` varchar(84) DEFAULT NULL,
  `answer18` varchar(84) DEFAULT NULL,
  `answer19` varchar(84) DEFAULT NULL,
  `answer20` varchar(84) DEFAULT NULL,
  `answer21` varchar(84) DEFAULT NULL,
  `answer22` varchar(84) DEFAULT NULL,
  `answer23` varchar(84) DEFAULT NULL,
  `answer24` varchar(84) DEFAULT NULL,
  `answer25` varchar(84) DEFAULT NULL,
  `answer26` varchar(84) DEFAULT NULL,
  `answer27` varchar(84) DEFAULT NULL,
  `answer28` varchar(84) DEFAULT NULL,
  `answer29` varchar(84) DEFAULT NULL,
  `answer30` varchar(84) DEFAULT NULL,
  `answer31` varchar(84) DEFAULT NULL,
  `answer32` varchar(84) DEFAULT NULL,
  `answer33` varchar(84) DEFAULT NULL,
  `answer34` varchar(84) DEFAULT NULL,
  `answer35` varchar(84) DEFAULT NULL,
  `answer36` varchar(84) DEFAULT NULL,
  `answer37` varchar(84) DEFAULT NULL,
  `answer38` varchar(84) DEFAULT NULL,
  `answer39` varchar(84) DEFAULT NULL,
  `answer40` varchar(84) DEFAULT NULL,
  `answer41` varchar(84) DEFAULT NULL,
  `answer42` varchar(84) DEFAULT NULL,
  `answer43` varchar(84) DEFAULT NULL,
  `answer44` varchar(84) DEFAULT NULL,
  `answer45` varchar(84) DEFAULT NULL,
  `answer46` varchar(84) DEFAULT NULL,
  `answer47` varchar(84) DEFAULT NULL,
  `answer48` varchar(84) DEFAULT NULL,
  `answer49` varchar(84) DEFAULT NULL,
  `answer50` varchar(84) DEFAULT NULL,
  `answer51` varchar(84) DEFAULT NULL,
  `answer52` varchar(84) DEFAULT NULL,
  `answer53` varchar(84) DEFAULT NULL,
  `answer54` varchar(84) DEFAULT NULL,
  `answer55` varchar(84) DEFAULT NULL,
  `answer56` varchar(84) DEFAULT NULL,
  `answer57` varchar(84) DEFAULT NULL,
  `answer58` varchar(84) DEFAULT NULL,
  `answer59` varchar(84) DEFAULT NULL,
  `answer60` varchar(84) DEFAULT NULL,
  `answer61` varchar(84) DEFAULT NULL,
  `answer62` varchar(84) DEFAULT NULL,
  `answer63` varchar(84) DEFAULT NULL,
  `answer64` varchar(84) DEFAULT NULL,
  `answer65` varchar(84) DEFAULT NULL,
  `answer66` varchar(84) DEFAULT NULL,
  `answer67` varchar(84) DEFAULT NULL,
  `answer68` varchar(84) DEFAULT NULL,
  `answer69` varchar(84) DEFAULT NULL,
  `answer70` varchar(84) DEFAULT NULL,
  `answer71` varchar(84) DEFAULT NULL,
  `answer72` varchar(84) DEFAULT NULL,
  `answer73` varchar(84) DEFAULT NULL,
  `answer74` varchar(84) DEFAULT NULL,
  `answer75` varchar(84) DEFAULT NULL,
  `answer76` varchar(84) DEFAULT NULL,
  `answer77` varchar(84) DEFAULT NULL,
  `answer78` varchar(84) DEFAULT NULL,
  `answer79` varchar(84) DEFAULT NULL,
  `answer80` varchar(84) DEFAULT NULL,
  `answer81` varchar(84) DEFAULT NULL,
  `answer82` varchar(84) DEFAULT NULL,
  `answer83` varchar(84) DEFAULT NULL,
  `answer84` varchar(84) DEFAULT NULL,
  `answer85` varchar(84) DEFAULT NULL,
  `answer86` varchar(84) DEFAULT NULL,
  `answer87` varchar(84) DEFAULT NULL,
  `answer88` varchar(84) DEFAULT NULL,
  `answer89` varchar(84) DEFAULT NULL,
  `answer90` varchar(84) DEFAULT NULL,
  `answer91` varchar(84) DEFAULT NULL,
  `answer92` varchar(84) DEFAULT NULL,
  `answer93` varchar(84) DEFAULT NULL,
  `answer94` varchar(84) DEFAULT NULL,
  `answer95` varchar(84) DEFAULT NULL,
  `answer96` varchar(84) DEFAULT NULL,
  `answer97` varchar(84) DEFAULT NULL,
  `answer98` varchar(84) DEFAULT NULL,
  `answer99` varchar(84) DEFAULT NULL,
  `answer100` varchar(84) DEFAULT NULL,
  `answer101` varchar(84) DEFAULT NULL,
  `answer102` varchar(84) DEFAULT NULL,
  `answer103` varchar(84) DEFAULT NULL,
  `answer104` varchar(84) DEFAULT NULL,
  `answer105` varchar(84) DEFAULT NULL,
  `answer106` varchar(84) DEFAULT NULL,
  `answer107` varchar(84) DEFAULT NULL,
  `answer108` varchar(84) DEFAULT NULL,
  `answer109` varchar(84) DEFAULT NULL,
  `answer110` varchar(84) DEFAULT NULL,
  `answer111` varchar(84) DEFAULT NULL,
  `answer112` varchar(84) DEFAULT NULL,
  `answer113` varchar(84) DEFAULT NULL,
  `answer114` varchar(84) DEFAULT NULL,
  `answer115` varchar(84) DEFAULT NULL,
  `answer116` varchar(84) DEFAULT NULL,
  `answer117` varchar(84) DEFAULT NULL,
  `answer118` varchar(84) DEFAULT NULL,
  `answer119` varchar(84) DEFAULT NULL,
  `answer120` varchar(84) DEFAULT NULL,
  `answer121` varchar(84) DEFAULT NULL,
  `answer122` varchar(84) DEFAULT NULL,
  `answer123` varchar(84) DEFAULT NULL,
  `answer124` varchar(84) DEFAULT NULL,
  `answer125` varchar(84) DEFAULT NULL,
  `answer126` varchar(84) DEFAULT NULL,
  `answer127` varchar(84) DEFAULT NULL,
  `answer128` varchar(84) DEFAULT NULL,
  `answer129` varchar(84) DEFAULT NULL,
  `answer130` varchar(84) DEFAULT NULL,
  `answer131` varchar(84) DEFAULT NULL,
  `answer132` varchar(84) DEFAULT NULL,
  `answer133` varchar(84) DEFAULT NULL,
  `answer134` varchar(84) DEFAULT NULL,
  `answer135` varchar(84) DEFAULT NULL,
  `answer136` varchar(84) DEFAULT NULL,
  `answer137` varchar(84) DEFAULT NULL,
  `answer138` varchar(84) DEFAULT NULL,
  `answer139` varchar(84) DEFAULT NULL,
  `answer140` varchar(84) DEFAULT NULL,
  `answer141` varchar(84) DEFAULT NULL,
  `answer142` varchar(84) DEFAULT NULL,
  `answer143` varchar(84) DEFAULT NULL,
  `answer144` varchar(84) DEFAULT NULL,
  `answer145` varchar(84) DEFAULT NULL,
  `answer146` varchar(84) DEFAULT NULL,
  `answer147` varchar(84) DEFAULT NULL,
  `answer148` varchar(84) DEFAULT NULL,
  `answer149` varchar(84) DEFAULT NULL,
  `answer150` varchar(84) DEFAULT NULL,
  `answer151` varchar(84) DEFAULT NULL,
  `answer152` varchar(84) DEFAULT NULL,
  `answer153` varchar(84) DEFAULT NULL,
  `answer154` varchar(84) DEFAULT NULL,
  `answer155` varchar(84) DEFAULT NULL,
  `answer156` varchar(84) DEFAULT NULL,
  `answer157` varchar(84) DEFAULT NULL,
  `answer158` varchar(84) DEFAULT NULL,
  `answer159` varchar(84) DEFAULT NULL,
  `answer160` varchar(84) DEFAULT NULL,
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t81 着信結果';

--
-- Dumping data for table `t81_incoming_results`
--

INSERT INTO `t81_incoming_results` (`id`, `inbound_id`, `tel_no`, `prefix`, `memo`, `tel_type`, `del_flag`, `call_datetime`, `connect_datetime`, `cut_datetime`, `trans_call_datetime`, `trans_connect_datetime`, `trans_cut_datetime`, `status`, `valid_count`, `ans_accuracy`, `answer1`, `answer2`, `answer3`, `answer4`, `answer5`, `answer6`, `answer7`, `answer8`, `answer9`, `answer10`, `answer11`, `answer12`, `answer13`, `answer14`, `answer15`, `answer16`, `answer17`, `answer18`, `answer19`, `answer20`, `answer21`, `answer22`, `answer23`, `answer24`, `answer25`, `answer26`, `answer27`, `answer28`, `answer29`, `answer30`, `answer31`, `answer32`, `answer33`, `answer34`, `answer35`, `answer36`, `answer37`, `answer38`, `answer39`, `answer40`, `answer41`, `answer42`, `answer43`, `answer44`, `answer45`, `answer46`, `answer47`, `answer48`, `answer49`, `answer50`, `answer51`, `answer52`, `answer53`, `answer54`, `answer55`, `answer56`, `answer57`, `answer58`, `answer59`, `answer60`, `answer61`, `answer62`, `answer63`, `answer64`, `answer65`, `answer66`, `answer67`, `answer68`, `answer69`, `answer70`, `answer71`, `answer72`, `answer73`, `answer74`, `answer75`, `answer76`, `answer77`, `answer78`, `answer79`, `answer80`, `answer81`, `answer82`, `answer83`, `answer84`, `answer85`, `answer86`, `answer87`, `answer88`, `answer89`, `answer90`, `answer91`, `answer92`, `answer93`, `answer94`, `answer95`, `answer96`, `answer97`, `answer98`, `answer99`, `answer100`, `answer101`, `answer102`, `answer103`, `answer104`, `answer105`, `answer106`, `answer107`, `answer108`, `answer109`, `answer110`, `answer111`, `answer112`, `answer113`, `answer114`, `answer115`, `answer116`, `answer117`, `answer118`, `answer119`, `answer120`, `answer121`, `answer122`, `answer123`, `answer124`, `answer125`, `answer126`, `answer127`, `answer128`, `answer129`, `answer130`, `answer131`, `answer132`, `answer133`, `answer134`, `answer135`, `answer136`, `answer137`, `answer138`, `answer139`, `answer140`, `answer141`, `answer142`, `answer143`, `answer144`, `answer145`, `answer146`, `answer147`, `answer148`, `answer149`, `answer150`, `answer151`, `answer152`, `answer153`, `answer154`, `answer155`, `answer156`, `answer157`, `answer158`, `answer159`, `answer160`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 3, '09000000006', '', '09000000006', 'tone', 'N', '2021-06-03 11:55:16', '2021-02-18 11:55:16', '2021-02-02 11:55:16', '2021-02-01 11:55:16', '2021-02-03 11:55:16', '2021-04-15 11:55:16', 'transfertimeout', 'e', '1/1', '09000000006', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 3, '09000087006', NULL, NULL, 'tone', 'N', '2021-06-02 11:55:16', '2021-02-03 11:55:16', '2021-02-06 11:55:16', '2021-02-03 11:55:16', '2021-02-01 11:55:16', '2021-02-09 11:55:16', 'transferreject', 'e', '1/1', '09000087006', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 3, '', NULL, NULL, 'tone', 'N', '2021-06-01 11:55:16', '2021-02-01 11:55:16', '2021-03-09 11:55:16', '2021-03-17 11:55:16', '2021-03-14 11:55:16', '2021-03-01 11:55:16', 'connect', 'e', '1/1', '2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 3, '09000345213', NULL, NULL, 'tone', 'N', '2021-06-02 11:55:16', '2021-07-02 00:00:00', '2021-07-03 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'transferreject', 'e', '1/1', '2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t82_bukken_fax_statuses`
--

CREATE TABLE `t82_bukken_fax_statuses` (
  `id` bigint(20) NOT NULL,
  `log_id` bigint(20) DEFAULT NULL COMMENT 't81のidと紐づく',
  `inbound_id` bigint(20) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `fax_question_no` int(11) DEFAULT NULL,
  `fax_id` varchar(64) DEFAULT NULL COMMENT 'APIにFAX送信後、返ってくる値',
  `fax_status` varchar(45) DEFAULT '送信中',
  `message` varchar(256) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='物件FAX送信ステータス';

-- --------------------------------------------------------

--
-- Table structure for table `t83_outgoing_sms_statuses`
--

CREATE TABLE `t83_outgoing_sms_statuses` (
  `id` bigint(20) NOT NULL,
  `log_id` bigint(20) DEFAULT NULL COMMENT 't81のidと紐づく',
  `schedule_id` bigint(20) DEFAULT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `display_number` varchar(20) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `tel_no` varchar(20) DEFAULT NULL,
  `sms_question_no` int(11) DEFAULT NULL,
  `sms_entry_id` varchar(64) DEFAULT NULL COMMENT 'APIにSMS送信後、返ってくる値',
  `sms_status` varchar(45) DEFAULT NULL COMMENT 'success:着信済み、outside:圏外、unknown:不明、error:エラー',
  `message` varchar(256) DEFAULT NULL,
  `sms_short_url_key` varchar(256) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='SMS送信ステータス';

-- --------------------------------------------------------

--
-- Table structure for table `t84_outgoing_getsmsstatus_histories`
--

CREATE TABLE `t84_outgoing_getsmsstatus_histories` (
  `id` int(11) NOT NULL,
  `entry_id` varchar(45) DEFAULT NULL,
  `ResStatus` varchar(10) DEFAULT NULL,
  `ResCount` varchar(10) DEFAULT NULL,
  `create_date` varchar(45) DEFAULT NULL,
  `req_stat` varchar(10) DEFAULT NULL,
  `group_id` varchar(10) DEFAULT NULL,
  `service_id` varchar(10) DEFAULT NULL,
  `user` varchar(45) DEFAULT NULL,
  `to_address` varchar(20) DEFAULT NULL,
  `use_cr_find` varchar(1) DEFAULT NULL,
  `carrier_id` varchar(1) DEFAULT NULL,
  `message_no` varchar(20) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `encode` varchar(1) DEFAULT NULL,
  `permit_time` varchar(20) DEFAULT NULL,
  `sent_date` varchar(20) DEFAULT NULL,
  `status` varchar(3) DEFAULT NULL,
  `send_result` varchar(20) DEFAULT NULL,
  `result_status` varchar(20) DEFAULT NULL,
  `command_status` varchar(20) DEFAULT NULL,
  `network_error_code` varchar(20) DEFAULT NULL,
  `tracking_code` varchar(20) DEFAULT NULL,
  `partition_size` varchar(2) DEFAULT NULL,
  `use_jdg_find` varchar(1) DEFAULT NULL,
  `ResErrorCode` varchar(10) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t85_incomming_bukken_histories`
--

CREATE TABLE `t85_incomming_bukken_histories` (
  `id` bigint(20) NOT NULL,
  `bukken_company_id` varchar(20) DEFAULT NULL,
  `bukken_shop_id` varchar(20) DEFAULT NULL,
  `external_number` varchar(20) DEFAULT NULL,
  `tel_no` varchar(20) DEFAULT NULL,
  `call_datetime` datetime DEFAULT NULL,
  `connect_datetime` datetime DEFAULT NULL,
  `cut_datetime` datetime DEFAULT NULL,
  `connected_seconds` int(11) DEFAULT NULL,
  `property_cost` varchar(20) DEFAULT NULL,
  `property_cost_decimal` double DEFAULT NULL,
  `property_square` varchar(20) DEFAULT NULL,
  `property_square_decimal` double DEFAULT NULL,
  `bukken_code` varchar(20) DEFAULT NULL,
  `bukken_name` varchar(64) DEFAULT NULL,
  `bukken_empty_info` varchar(20) DEFAULT NULL,
  `bukken_empty_info_origin` varchar(20) DEFAULT NULL,
  `bukken_diagram_info` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `log_id` bigint(20) DEFAULT NULL,
  `inbound_id` bigint(20) DEFAULT NULL,
  `template_id` varchar(20) DEFAULT NULL,
  `question_no` int(11) DEFAULT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t86_inbound_sms_statuses`
--

CREATE TABLE `t86_inbound_sms_statuses` (
  `id` bigint(20) NOT NULL,
  `log_id` bigint(20) DEFAULT NULL COMMENT 't81のidと紐づく',
  `inbound_id` bigint(20) DEFAULT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `display_number` varchar(20) DEFAULT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `tel_no` varchar(20) DEFAULT NULL,
  `sms_question_no` int(11) DEFAULT NULL,
  `sms_entry_id` varchar(64) DEFAULT NULL COMMENT 'APIにSMS送信後、返ってくる値',
  `sms_status` varchar(45) DEFAULT NULL COMMENT 'success:着信済み、outside:圏外、unknown:不明、error:エラー',
  `message` varchar(256) DEFAULT NULL,
  `sms_short_url_key` varchar(256) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='SMS送信ステータス';

-- --------------------------------------------------------

--
-- Table structure for table `t87_inbound_getsmsstatus_histories`
--

CREATE TABLE `t87_inbound_getsmsstatus_histories` (
  `id` int(11) NOT NULL,
  `entry_id` varchar(45) DEFAULT NULL,
  `ResStatus` varchar(10) DEFAULT NULL,
  `ResCount` varchar(10) DEFAULT NULL,
  `create_date` varchar(45) DEFAULT NULL,
  `req_stat` varchar(10) DEFAULT NULL,
  `group_id` varchar(10) DEFAULT NULL,
  `service_id` varchar(10) DEFAULT NULL,
  `user` varchar(45) DEFAULT NULL,
  `to_address` varchar(20) DEFAULT NULL,
  `use_cr_find` varchar(1) DEFAULT NULL,
  `carrier_id` varchar(1) DEFAULT NULL,
  `message_no` varchar(20) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `encode` varchar(1) DEFAULT NULL,
  `permit_time` varchar(20) DEFAULT NULL,
  `sent_date` varchar(20) DEFAULT NULL,
  `status` varchar(3) DEFAULT NULL,
  `send_result` varchar(20) DEFAULT NULL,
  `result_status` varchar(20) DEFAULT NULL,
  `command_status` varchar(20) DEFAULT NULL,
  `network_error_code` varchar(20) DEFAULT NULL,
  `tracking_code` varchar(20) DEFAULT NULL,
  `partition_size` varchar(2) DEFAULT NULL,
  `use_jdg_find` varchar(1) DEFAULT NULL,
  `ResErrorCode` varchar(10) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t89_manage_files`
--

CREATE TABLE `t89_manage_files` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `file_name` varchar(64) DEFAULT NULL,
  `file_size` varchar(20) DEFAULT NULL COMMENT 'ファイル量',
  `file_contents` mediumblob COMMENT 'ファイル内容',
  `file_mp3_size` varchar(20) DEFAULT NULL,
  `file_mp3_contents` mediumblob COMMENT 'ファイルpcm量',
  `file_pcm_contents` mediumblob COMMENT 'ファイルpcm内容',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t89ファイル管理';

-- --------------------------------------------------------

--
-- Table structure for table `t90_login_histories`
--

CREATE TABLE `t90_login_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `user_id` varchar(64) NOT NULL COMMENT 'ユーザーID',
  `client_ip` varchar(64) DEFAULT NULL COMMENT 'クライアントIP',
  `session_id` varchar(128) DEFAULT NULL COMMENT 'セッションID',
  `login_flag` varchar(1) DEFAULT 'N' COMMENT 'ログインフラグ',
  `logout_time` datetime DEFAULT NULL COMMENT 'ログアウト',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録者',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t90ログイン履歴';

--
-- Dumping data for table `t90_login_histories`
--

INSERT INTO `t90_login_histories` (`id`, `user_id`, `client_ip`, `session_id`, `login_flag`, `logout_time`, `del_flag`, `entry_user`, `entry_program`, `created`, `update_user`, `update_program`, `modified`) VALUES
(55537, 'kamo_s', '::1', '5ljqcto8caofm4o0dte8a8fan2', 'N', '2021-02-26 19:40:36', 'N', 'kamo_s', 'Login_login', '2021-02-26 15:49:24', 'kamo_s', 'Login_logout', '2021-02-26 19:40:36'),
(55538, 'kamo_s', '::1', 'lf2kcsoori7vtbog6n1ldmuim3', 'N', '2021-03-01 11:45:10', 'N', 'kamo_s', 'Login_login', '2021-03-01 10:08:16', 'kamo_s', 'Login_logout', '2021-03-01 11:45:10'),
(55539, 'kamo_s', '::1', 'vicfpcsl84ajugg8ao24pu37e7', 'N', '2021-03-01 12:19:18', 'N', 'kamo_s', 'Login_login', '2021-03-01 11:45:13', 'kamo_s', 'Login_logout', '2021-03-01 12:19:19'),
(55540, 'kamo_s', '::1', '7cmn7prguj48vprq7p16h65rl1', 'N', '2021-03-01 12:58:32', 'N', 'kamo_s', 'Login_login', '2021-03-01 12:19:34', 'kamo_s', 'Login_logout', '2021-03-01 12:58:32'),
(55541, 'kamo_s', '::1', 'itifaftr0viio82o68fl0r2bg6', 'N', '2021-03-01 14:16:18', 'N', 'kamo_s', 'Login_login', '2021-03-01 13:49:16', 'kamo_s', 'Login_logout', '2021-03-01 14:16:18'),
(55542, 's_kamo', '::1', 'vfud0pee6iac2f4jqdnnqglc71', 'N', '2021-03-01 14:18:21', 'N', 's_kamo', 'Login_login', '2021-03-01 14:16:22', 's_kamo', 'Login_logout', '2021-03-01 14:18:21'),
(55543, 'kamo_s', '::1', 'qe7bma0jpiakn30lndq7hvlt55', 'N', '2021-03-01 14:20:53', 'N', 'kamo_s', 'Login_login', '2021-03-01 14:20:25', 'kamo_s', 'Login_logout', '2021-03-01 14:20:53'),
(55544, 'kamo_s', '::1', 'lsb5aj65jjnd5gru1kcr0d9ra5', 'N', '2021-03-01 14:23:28', 'N', 'kamo_s', 'Login_login', '2021-03-01 14:20:59', 'kamo_s', 'Login_logout', '2021-03-01 14:23:28'),
(55545, 'fabbi', '::1', 'bcjksenk0tmffampc9qsg3glh7', 'N', '2021-03-01 14:40:46', 'N', 'fabbi', 'Login_login', '2021-03-01 14:23:51', 'fabbi', 'Login_logout', '2021-03-01 14:40:46'),
(55546, 'fabbi', '::1', 'bmr5m340ot9fcqhcs3feu54io5', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-03-01 14:41:31', 'fabbi', 'Login_login', '2021-03-01 14:41:31'),
(55547, 'fabbi', '::1', 'lguvu8t53ddqjnajfl54ims713', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-03-30 15:50:55', 'fabbi', 'Login_login', '2021-03-30 15:50:55'),
(55548, 'fabbi', '::1', 'lguvu8t53ddqjnajfl54ims713', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-03-30 15:51:27', 'fabbi', 'Login_login', '2021-03-30 15:51:27'),
(55549, 'fabbi', '::1', '2fa10b47d1j5lmj5lmnd3oehv3', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-03-31 15:49:06', 'fabbi', 'Login_login', '2021-03-31 15:49:06'),
(55550, 'fabbi', '::1', '594ohg8c2mmdebkk2u72r4i2n7', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-22 15:35:03', 'fabbi', 'Login_login', '2021-06-22 15:35:03'),
(55551, 'fabbi', '::1', '1sfe017sti7vu845j9mdt94t94', 'N', '2021-06-23 15:40:59', 'N', 'fabbi', 'Login_login', '2021-06-23 10:53:34', 'fabbi', 'Login_logout', '2021-06-23 15:40:59'),
(55552, 'fabbi', '::1', 'as38qudq9f67ggs46f8jg06pg2', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-23 15:41:10', 'fabbi', 'Login_login', '2021-06-23 15:41:10'),
(55553, 'fabbi', '::1', 'n31opl54pi7v3ei2ddmr0hdjr3', 'N', '2021-06-24 11:16:22', 'N', 'fabbi', 'Login_login', '2021-06-24 10:46:05', 'fabbi', 'Login_logout', '2021-06-24 11:16:23'),
(55554, 'fabbi', '::1', '95qtmmooh813knir1o3h9r0l64', 'N', '2021-06-24 11:19:23', 'N', 'fabbi', 'Login_login', '2021-06-24 11:16:29', 'fabbi', 'Login_logout', '2021-06-24 11:19:23'),
(55555, 'fabbi', '::1', '6pqn6q72jh1f5at9dm6aull6u6', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-24 11:19:25', 'fabbi', 'Login_login', '2021-06-24 11:19:25'),
(55556, 'fabbi', '::1', '5tk2p0m3rng9296a2k9csp6840', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-28 16:30:14', 'fabbi', 'Login_login', '2021-06-28 16:30:14'),
(55557, 'fabbi', '::1', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-29 12:38:12', 'fabbi', 'Login_login', '2021-06-29 12:38:12'),
(55558, 'fabbi', '::1', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-29 12:38:38', 'fabbi', 'Login_login', '2021-06-29 12:38:38'),
(55559, 'fabbi', '::1', 'kq7cef8a2uhqc21frd56tulkg7', 'N', '2021-06-30 10:46:16', 'N', 'fabbi', 'Login_login', '2021-06-30 10:33:42', 'fabbi', 'Login_logout', '2021-06-30 10:46:16'),
(55560, 'fabbi', '::1', '0ak5octd0l1q5gua9os65u8pi6', 'N', '2021-06-30 10:53:38', 'N', 'fabbi', 'Login_login', '2021-06-30 10:46:31', 'fabbi', 'Login_logout', '2021-06-30 10:53:38'),
(55561, 'fabbi', '::1', 'emi4hf5ujtfl9d3p808oq4na92', 'N', '2021-06-30 10:56:52', 'N', 'fabbi', 'Login_login', '2021-06-30 10:55:48', 'fabbi', 'Login_logout', '2021-06-30 10:56:52'),
(55562, 'fabbi', '::1', 'emi4hf5ujtfl9d3p808oq4na92', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-30 10:56:02', 'fabbi', 'Login_login', '2021-06-30 10:56:02'),
(55563, 'fabbi', '::1', 'sbmscn4r5n80rfaq2mg3k1hs14', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-06-30 10:56:57', 'fabbi', 'Login_login', '2021-06-30 10:56:57'),
(55564, 'fabbi', '::1', '7edc9et842jn6gb6eg5hrcm9m7', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-01 10:48:36', 'fabbi', 'Login_login', '2021-07-01 10:48:36'),
(55565, 'fabbi', '::1', '75f4mhqhhn15ur934lgtkdm045', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-02 10:40:20', 'fabbi', 'Login_login', '2021-07-02 10:40:20'),
(55566, 'fabbi', '::1', 'hstd144uq3d3l0moj1c4ml86m6', 'N', '2021-07-05 18:12:10', 'N', 'fabbi', 'Login_login', '2021-07-05 11:19:57', 'fabbi', 'Login_logout', '2021-07-05 18:12:10'),
(55567, '1221978', '::1', '53gvtfta8k5l1b919d7gab18o1', 'N', NULL, 'N', '1221978', 'Login_login', '2021-07-05 18:12:13', '1221978', 'Login_login', '2021-07-05 18:12:13'),
(55568, 'fabbi', '::1', 'didcj4oedosa23bum4kp7lccq1', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-06 17:24:37', 'fabbi', 'Login_login', '2021-07-06 17:24:37'),
(55569, 'fabbi', '::1', 'nl9mou3u127v748vlupv491td5', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-07 10:59:57', 'fabbi', 'Login_login', '2021-07-07 10:59:57'),
(55570, 'fabbi', '::1', 'nl9mou3u127v748vlupv491td5', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-07 11:00:37', 'fabbi', 'Login_login', '2021-07-07 11:00:37'),
(55571, 'fabbi', '::1', 'j1609lui3dlfkb1seoeoicdph6', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-08 11:34:23', 'fabbi', 'Login_login', '2021-07-08 11:34:23'),
(55572, 'fabbi', '::1', 'tmn3dssb8qlhp0p67mls6b5o84', 'N', '2021-07-09 16:26:36', 'N', 'fabbi', 'Login_login', '2021-07-09 11:01:02', 'fabbi', 'Login_logout', '2021-07-09 16:26:36'),
(55573, 'fabbi', '::1', 'hh87s3l1sjg7s0buena44ncha7', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-09 16:27:08', 'fabbi', 'Login_login', '2021-07-09 16:27:08'),
(55574, 'fabbi', '::1', 'k3t6lu4djiohnns2c23ucq2e83', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-12 10:54:14', 'fabbi', 'Login_login', '2021-07-12 10:54:14'),
(55575, 'fabbi', '::1', 'b16d5a1coi1mdamufqt3mudl05', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-13 18:24:36', 'fabbi', 'Login_login', '2021-07-13 18:24:36'),
(55576, 'fabbi', '::1', '3rcp7aisfcn64db1id110crj75', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-15 11:04:19', 'fabbi', 'Login_login', '2021-07-15 11:04:19'),
(55577, 'fabbi', '::1', '41lrr03oju3k4cdqrk1se478r3', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-16 12:01:08', 'fabbi', 'Login_login', '2021-07-16 12:01:08'),
(55578, 'fabbi', '::1', '41lrr03oju3k4cdqrk1se478r3', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-16 12:01:50', 'fabbi', 'Login_login', '2021-07-16 12:01:50'),
(55579, 'fabbi', '::1', '0rhhffqjdh5u4qnsjk4g9koeg1', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-19 16:16:04', 'fabbi', 'Login_login', '2021-07-19 16:16:04'),
(55580, 'fabbi', '::1', 'v0i5ib7titc7j2unk976s3ogm0', 'N', '2021-07-20 19:06:02', 'N', 'fabbi', 'Login_login', '2021-07-20 15:52:38', 'fabbi', 'Login_logout', '2021-07-20 19:06:02'),
(55581, 'fabbi', '::1', 'v0i5ib7titc7j2unk976s3ogm0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-20 15:53:08', 'fabbi', 'Login_login', '2021-07-20 15:53:08'),
(55582, 'fabbi01', '::1', '28nr486a05709oioe9rvamphp1', 'N', NULL, 'N', 'fabbi01', 'Login_login', '2021-07-20 19:06:40', 'fabbi01', 'Login_login', '2021-07-20 19:06:40'),
(55583, 'fabbi01', '::1', '28nr486a05709oioe9rvamphp1', 'N', NULL, 'N', 'fabbi01', 'Login_login', '2021-07-20 19:06:52', 'fabbi01', 'Login_login', '2021-07-20 19:06:52'),
(55584, 'fabbi01', '::1', '28nr486a05709oioe9rvamphp1', 'N', NULL, 'N', 'fabbi01', 'Login_login', '2021-07-20 19:06:57', 'fabbi01', 'Login_login', '2021-07-20 19:06:57'),
(55585, 'fabbi02', '::1', '28nr486a05709oioe9rvamphp1', 'N', '2021-07-20 19:08:20', 'N', 'fabbi02', 'Login_login', '2021-07-20 19:07:36', 'fabbi02', 'Login_logout', '2021-07-20 19:08:20'),
(55586, 'fabbi', '::1', 'c3l34lh8ie95escgnhqcdpjcp0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-20 19:08:37', 'fabbi', 'Login_login', '2021-07-20 19:08:37'),
(55587, 'fabbi', '::1', 'gmi1h82d5r1u3rdvudt899ics5', 'N', '2021-07-21 11:06:31', 'N', 'fabbi', 'Login_login', '2021-07-21 10:49:54', 'fabbi', 'Login_logout', '2021-07-21 11:06:31'),
(55588, 'fabbi', '::1', 'fh298u3gpqf1qgpcot5mfmru26', 'N', '2021-07-21 12:50:13', 'N', 'fabbi', 'Login_login', '2021-07-21 11:06:43', 'fabbi', 'Login_logout', '2021-07-21 12:50:13'),
(55589, 'fabbi', '::1', '3k74erspdk2mmin8h20hio6ge6', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-21 12:50:15', 'fabbi', 'Login_login', '2021-07-21 12:50:15'),
(55590, 'fabbi', '::1', 'o1oq1si7n22rmqofcvogskl577', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-22 10:37:11', 'fabbi', 'Login_login', '2021-07-22 10:37:11'),
(55591, 'fabbi', '::1', 'o1oq1si7n22rmqofcvogskl577', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-22 10:37:20', 'fabbi', 'Login_login', '2021-07-22 10:37:20'),
(55592, 'fabbi', '::1', 'ckvt473gpbcid9nnqp5250v2g7', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-23 10:20:12', 'fabbi', 'Login_login', '2021-07-23 10:20:12'),
(55593, 'fabbi', '::1', '8i9porvia9d04b66dj7egve9s0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-26 11:36:12', 'fabbi', 'Login_login', '2021-07-26 11:36:12'),
(55594, 'fabbi', '::1', 'gmt2kvs7l8mud50pgfg8j90pc5', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-27 10:33:33', 'fabbi', 'Login_login', '2021-07-27 10:33:33'),
(55595, 'fabbi', '::1', 'rmi1o6a817ld9unaruntdi6j25', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-28 10:48:01', 'fabbi', 'Login_login', '2021-07-28 10:48:01'),
(55596, 'fabbi', '::1', 'rmi1o6a817ld9unaruntdi6j25', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-28 10:48:30', 'fabbi', 'Login_login', '2021-07-28 10:48:30'),
(55597, 'fabbi01', '::1', 'gdmj02h7tr5ka3cc58bc0f9h25', 'N', '2021-07-28 12:16:43', 'N', 'fabbi01', 'Login_login', '2021-07-28 11:17:34', 'fabbi01', 'Login_logout', '2021-07-28 12:16:43'),
(55598, 'fabbi02', '::1', '61resc8o2ssk73mj796l93p0h5', 'N', '2021-07-28 12:21:57', 'N', 'fabbi02', 'Login_login', '2021-07-28 12:16:50', 'fabbi02', 'Login_logout', '2021-07-28 12:21:57'),
(55599, 'fabbi02', '::1', 'o841nggsnb4f4j5cufmvgncrk6', 'N', NULL, 'N', 'fabbi02', 'Login_login', '2021-07-28 12:22:04', 'fabbi02', 'Login_login', '2021-07-28 12:22:04'),
(55600, 'fabbi', '::1', 'io5tqppk7594lbrdiavcoma4f0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-29 10:09:55', 'fabbi', 'Login_login', '2021-07-29 10:09:55'),
(55601, 'fabbi', '::1', 'kr4ig41430007detb3gp4pn5k0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-30 15:49:39', 'fabbi', 'Login_login', '2021-07-30 15:49:39'),
(55602, 'fabbi', '::1', 'kr4ig41430007detb3gp4pn5k0', 'N', NULL, 'N', 'fabbi', 'Login_login', '2021-07-30 15:55:23', 'fabbi', 'Login_login', '2021-07-30 15:55:23');

-- --------------------------------------------------------

--
-- Table structure for table `t91_action_histories`
--

CREATE TABLE `t91_action_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `client_ip` varchar(20) DEFAULT NULL COMMENT 'クライアントIPアドレス',
  `mac_addr` varchar(20) DEFAULT NULL COMMENT 'マックアドレス',
  `user_id` varchar(20) DEFAULT NULL COMMENT 'ユーザーID',
  `session_id` varchar(128) DEFAULT NULL,
  `operation` varchar(128) DEFAULT NULL COMMENT '操作内容',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `modified` datetime DEFAULT NULL COMMENT '更新日時'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t91作業ログテーブル';

--
-- Dumping data for table `t91_action_histories`
--

INSERT INTO `t91_action_histories` (`id`, `client_ip`, `mac_addr`, `user_id`, `session_id`, `operation`, `created`, `modified`) VALUES
(89583, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ログイン__login/login', '2021-02-26 15:49:27', '2021-02-26 15:49:27'),
(89584, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__outschedule/index', '2021-02-26 15:49:42', '2021-02-26 15:49:42'),
(89585, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 発信リスト__template/index', '2021-02-26 15:49:47', '2021-02-26 15:49:47'),
(89586, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 発信NGリスト__calllist/index', '2021-02-26 15:49:51', '2021-02-26 15:49:51'),
(89587, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__calllistng/index', '2021-02-26 15:49:56', '2021-02-26 15:49:56'),
(89588, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信リスト__inboundtemplate/index', '2021-02-26 15:50:01', '2021-02-26 15:50:01'),
(89589, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信設定__inboundcalllist/index', '2021-02-26 15:50:07', '2021-02-26 15:50:07'),
(89590, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信拒否リスト__inboundincominghistory/index', '2021-02-26 15:50:12', '2021-02-26 15:50:12'),
(89591, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__inboundrestrict/index', '2021-02-26 15:50:16', '2021-02-26 15:50:16'),
(89592, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 送信リスト__smstemplate/index', '2021-02-26 15:50:21', '2021-02-26 15:50:21'),
(89593, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' スケジュール__smssendlist/index', '2021-02-26 15:50:27', '2021-02-26 15:50:27'),
(89594, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' ユーザー管理__smsschedule/index', '2021-02-26 15:50:32', '2021-02-26 15:50:32'),
(89595, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 操作マニュアル__manageuser/index', '2021-02-26 15:50:36', '2021-02-26 15:50:36'),
(89596, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' キャッシュ削除マニュアル__manageuser/index', '2021-02-26 15:50:41', '2021-02-26 15:50:41'),
(89597, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__manageuser/index', '2021-02-26 15:50:46', '2021-02-26 15:50:46'),
(89598, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__template/index', '2021-02-26 15:53:48', '2021-02-26 15:53:48'),
(89599, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 15:54:04', '2021-02-26 15:54:04'),
(89600, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '挿入__template/template', '2021-02-26 15:54:53', '2021-02-26 15:54:53'),
(89601, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '挿入__template/template', '2021-02-26 15:55:05', '2021-02-26 15:55:05'),
(89602, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 15:55:13', '2021-02-26 15:55:13'),
(89603, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 15:55:15', '2021-02-26 15:55:15'),
(89604, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 15:58:09', '2021-02-26 15:58:09'),
(89605, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 15:58:15', '2021-02-26 15:58:15'),
(89606, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 15:59:17', '2021-02-26 15:59:17'),
(89607, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 15:59:20', '2021-02-26 15:59:20'),
(89608, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 15:59:32', '2021-02-26 15:59:32'),
(89609, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 15:59:42', '2021-02-26 15:59:42'),
(89610, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__template/template', '2021-02-26 15:59:48', '2021-02-26 15:59:48'),
(89611, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:00:01', '2021-02-26 16:00:01'),
(89612, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:00:18', '2021-02-26 16:00:18'),
(89613, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:00:27', '2021-02-26 16:00:27'),
(89614, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:00:46', '2021-02-26 16:00:46'),
(89615, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:00:57', '2021-02-26 16:00:57'),
(89616, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:01:00', '2021-02-26 16:01:00'),
(89617, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:01:02', '2021-02-26 16:01:02'),
(89618, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:01:13', '2021-02-26 16:01:13'),
(89619, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:01:49', '2021-02-26 16:01:49'),
(89620, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__template/template', '2021-02-26 16:01:51', '2021-02-26 16:01:51'),
(89621, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:01:52', '2021-02-26 16:01:52'),
(89622, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:02:03', '2021-02-26 16:02:03'),
(89623, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:02:15', '2021-02-26 16:02:15'),
(89624, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:02:58', '2021-02-26 16:02:58'),
(89625, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:03:02', '2021-02-26 16:03:02'),
(89626, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__template/index', '2021-02-26 16:08:43', '2021-02-26 16:08:43'),
(89627, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__template/index', '2021-02-26 16:09:53', '2021-02-26 16:09:53'),
(89628, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:10:29', '2021-02-26 16:10:29'),
(89629, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:10:42', '2021-02-26 16:10:42'),
(89630, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:10:45', '2021-02-26 16:10:45'),
(89631, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:11:33', '2021-02-26 16:11:33'),
(89632, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:11:34', '2021-02-26 16:11:34'),
(89633, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:11:50', '2021-02-26 16:11:50'),
(89634, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:11:54', '2021-02-26 16:11:54'),
(89635, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:12:13', '2021-02-26 16:12:13'),
(89636, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:12:15', '2021-02-26 16:12:15'),
(89637, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:12:28', '2021-02-26 16:12:28'),
(89638, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:12:31', '2021-02-26 16:12:31'),
(89639, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:12:34', '2021-02-26 16:12:34'),
(89640, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:12:35', '2021-02-26 16:12:35'),
(89641, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:12:42', '2021-02-26 16:12:42'),
(89642, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:13:16', '2021-02-26 16:13:16'),
(89643, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 発信リスト__template/index', '2021-02-26 16:22:25', '2021-02-26 16:22:25'),
(89644, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__calllist/index', '2021-02-26 16:22:50', '2021-02-26 16:22:50'),
(89645, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__calllist/index', '2021-02-26 16:25:15', '2021-02-26 16:25:15'),
(89646, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__calllist/index', '2021-02-26 16:25:30', '2021-02-26 16:25:30'),
(89647, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__calllist/index', '2021-02-26 16:27:44', '2021-02-26 16:27:44'),
(89648, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__calllist/index', '2021-02-26 16:29:33', '2021-02-26 16:29:33'),
(89649, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__calllist/index', '2021-02-26 16:29:41', '2021-02-26 16:29:41'),
(89650, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__calllist/index', '2021-02-26 16:29:49', '2021-02-26 16:29:49'),
(89651, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 発信NGリスト__calllist/index', '2021-02-26 16:30:35', '2021-02-26 16:30:35'),
(89652, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__calllistng/index', '2021-02-26 16:31:08', '2021-02-26 16:31:08'),
(89653, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__template/index', '2021-02-26 16:31:11', '2021-02-26 16:31:11'),
(89654, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:31:19', '2021-02-26 16:31:19'),
(89655, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '挿入__template/template', '2021-02-26 16:31:39', '2021-02-26 16:31:39'),
(89656, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:31:45', '2021-02-26 16:31:45'),
(89657, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:31:48', '2021-02-26 16:31:48'),
(89658, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:32:43', '2021-02-26 16:32:43'),
(89659, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:32:47', '2021-02-26 16:32:47'),
(89660, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:33:14', '2021-02-26 16:33:14'),
(89661, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:33:14', '2021-02-26 16:33:14'),
(89662, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:33:27', '2021-02-26 16:33:27'),
(89663, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:33:28', '2021-02-26 16:33:28'),
(89664, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:33:31', '2021-02-26 16:33:31'),
(89665, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__template/template', '2021-02-26 16:33:32', '2021-02-26 16:33:32'),
(89666, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:33:42', '2021-02-26 16:33:42'),
(89667, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:34:13', '2021-02-26 16:34:13'),
(89668, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__template/template', '2021-02-26 16:34:17', '2021-02-26 16:34:17'),
(89669, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:34:22', '2021-02-26 16:34:22'),
(89670, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:34:42', '2021-02-26 16:34:42'),
(89671, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '__template/template', '2021-02-26 16:35:44', '2021-02-26 16:35:44'),
(89672, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__template/template', '2021-02-26 16:35:48', '2021-02-26 16:35:48'),
(89673, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '更新__template/template', '2021-02-26 16:36:02', '2021-02-26 16:36:02'),
(89674, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '更新__template/template', '2021-02-26 16:36:31', '2021-02-26 16:36:31'),
(89675, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 発信NGリスト__template/index', '2021-02-26 16:36:43', '2021-02-26 16:36:43'),
(89676, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__calllistng/index', '2021-02-26 16:37:00', '2021-02-26 16:37:00'),
(89677, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__calllistng/index', '2021-02-26 16:37:22', '2021-02-26 16:37:22'),
(89678, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__calllistng/index', '2021-02-26 16:37:34', '2021-02-26 16:37:34'),
(89679, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__calllistng/index', '2021-02-26 16:38:25', '2021-02-26 16:38:25'),
(89680, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__inboundtemplate/index', '2021-02-26 16:38:30', '2021-02-26 16:38:30'),
(89681, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:38:56', '2021-02-26 16:38:56'),
(89682, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:39:14', '2021-02-26 16:39:14'),
(89683, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:39:15', '2021-02-26 16:39:15'),
(89684, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:42:58', '2021-02-26 16:42:58'),
(89685, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:43:02', '2021-02-26 16:43:02'),
(89686, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:43:11', '2021-02-26 16:43:11'),
(89687, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:43:12', '2021-02-26 16:43:12'),
(89688, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:43:23', '2021-02-26 16:43:23'),
(89689, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:43:26', '2021-02-26 16:43:26'),
(89690, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:43:30', '2021-02-26 16:43:30'),
(89691, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:43:31', '2021-02-26 16:43:31'),
(89692, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:43:40', '2021-02-26 16:43:40'),
(89693, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:44:09', '2021-02-26 16:44:09'),
(89694, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:44:42', '2021-02-26 16:44:42'),
(89695, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:45:01', '2021-02-26 16:45:01'),
(89696, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:45:13', '2021-02-26 16:45:13'),
(89697, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/template', '2021-02-26 16:46:45', '2021-02-26 16:46:45'),
(89698, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信リスト__inboundtemplate/index', '2021-02-26 16:46:56', '2021-02-26 16:46:56'),
(89699, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__inboundcalllist/index', '2021-02-26 16:48:12', '2021-02-26 16:48:12'),
(89700, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__inboundcalllist/index', '2021-02-26 16:48:34', '2021-02-26 16:48:34'),
(89701, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__inboundcalllist/index', '2021-02-26 16:49:41', '2021-02-26 16:49:41'),
(89702, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundcalllist/index', '2021-02-26 16:50:15', '2021-02-26 16:50:15'),
(89703, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__inboundcalllist/index', '2021-02-26 16:50:35', '2021-02-26 16:50:35'),
(89704, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__inboundtemplate/index', '2021-02-26 16:50:44', '2021-02-26 16:50:44'),
(89705, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:51:02', '2021-02-26 16:51:02'),
(89706, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '挿入__inboundtemplate/inboundtemplate', '2021-02-26 16:51:34', '2021-02-26 16:51:34'),
(89707, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:51:38', '2021-02-26 16:51:38'),
(89708, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:51:42', '2021-02-26 16:51:42'),
(89709, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:53:04', '2021-02-26 16:53:04'),
(89710, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:53:12', '2021-02-26 16:53:12'),
(89711, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:53:31', '2021-02-26 16:53:31'),
(89712, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:53:33', '2021-02-26 16:53:33'),
(89713, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:53:51', '2021-02-26 16:53:51'),
(89714, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:53:57', '2021-02-26 16:53:57'),
(89715, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:53:59', '2021-02-26 16:53:59'),
(89716, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:54:04', '2021-02-26 16:54:04'),
(89717, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:54:05', '2021-02-26 16:54:05'),
(89718, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:54:13', '2021-02-26 16:54:13'),
(89719, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/template', '2021-02-26 16:54:33', '2021-02-26 16:54:33'),
(89720, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:54:43', '2021-02-26 16:54:43'),
(89721, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:54:48', '2021-02-26 16:54:48'),
(89722, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:54:57', '2021-02-26 16:54:57'),
(89723, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:55:11', '2021-02-26 16:55:11'),
(89724, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:55:25', '2021-02-26 16:55:25'),
(89725, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'セクションの追加__inboundtemplate/template', '2021-02-26 16:56:07', '2021-02-26 16:56:07'),
(89726, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:56:23', '2021-02-26 16:56:23'),
(89727, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:57:07', '2021-02-26 16:57:07'),
(89728, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 16:58:13', '2021-02-26 16:58:13'),
(89729, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/template', '2021-02-26 16:58:38', '2021-02-26 16:58:38'),
(89730, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:58:43', '2021-02-26 16:58:43'),
(89731, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:58:47', '2021-02-26 16:58:47'),
(89732, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:58:51', '2021-02-26 16:58:51'),
(89733, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:58:55', '2021-02-26 16:58:55'),
(89734, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:58:58', '2021-02-26 16:58:58'),
(89735, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '閉じる__inboundtemplate/inboundtemplate', '2021-02-26 16:59:02', '2021-02-26 16:59:02'),
(89736, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/template', '2021-02-26 16:59:05', '2021-02-26 16:59:05'),
(89737, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/inboundtemplate', '2021-02-26 17:00:05', '2021-02-26 17:00:05'),
(89738, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundtemplate/template', '2021-02-26 17:00:07', '2021-02-26 17:00:07'),
(89739, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__inboundtemplate/template', '2021-02-26 17:06:45', '2021-02-26 17:06:45'),
(89740, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '更新__inboundtemplate/template', '2021-02-26 17:07:22', '2021-02-26 17:07:22'),
(89741, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信リスト__inboundtemplate/index', '2021-02-26 17:07:39', '2021-02-26 17:07:39'),
(89742, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__inboundcalllist/index', '2021-02-26 17:07:57', '2021-02-26 17:07:57'),
(89743, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__inboundcalllist/index', '2021-02-26 17:08:27', '2021-02-26 17:08:27'),
(89744, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundcalllist/index', '2021-02-26 17:08:50', '2021-02-26 17:08:50'),
(89745, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信設定__inboundcalllist/index', '2021-02-26 17:09:00', '2021-02-26 17:09:00'),
(89746, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 着信拒否リスト__inboundincominghistory/index', '2021-02-26 17:09:28', '2021-02-26 17:09:28'),
(89747, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__inboundrestrict/index', '2021-02-26 17:09:51', '2021-02-26 17:09:51'),
(89748, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__inboundrestrict/index', '2021-02-26 17:12:12', '2021-02-26 17:12:12'),
(89749, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__inboundrestrict/index', '2021-02-26 17:12:50', '2021-02-26 17:12:50'),
(89750, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__inboundrestrict/index', '2021-02-26 17:13:38', '2021-02-26 17:13:38'),
(89751, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規作成__smstemplate/index', '2021-02-26 17:14:38', '2021-02-26 17:14:38'),
(89752, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__smstemplate/index', '2021-02-26 17:15:54', '2021-02-26 17:15:54'),
(89753, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 送信リスト__smstemplate/index', '2021-02-26 17:16:16', '2021-02-26 17:16:16'),
(89754, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__smssendlist/index', '2021-02-26 17:16:24', '2021-02-26 17:16:24'),
(89755, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__smssendlist/index', '2021-02-26 17:16:26', '2021-02-26 17:16:26'),
(89756, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__smssendlist/index', '2021-02-26 17:17:37', '2021-02-26 17:17:37'),
(89757, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規登録__smssendlist/index', '2021-02-26 17:18:20', '2021-02-26 17:18:20'),
(89758, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ファイルを選択__smssendlist/index', '2021-02-26 17:18:22', '2021-02-26 17:18:22'),
(89759, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__smssendlist/index', '2021-02-26 17:18:45', '2021-02-26 17:18:45'),
(89760, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' テンプレート__smssendlist/index', '2021-02-26 17:18:53', '2021-02-26 17:18:53'),
(89761, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '新規作成__smstemplate/index', '2021-02-26 17:19:05', '2021-02-26 17:19:05'),
(89762, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '挿入__smstemplate/smstemplate', '2021-02-26 17:19:33', '2021-02-26 17:19:33'),
(89763, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', '保存__smstemplate/index', '2021-02-26 17:20:01', '2021-02-26 17:20:01'),
(89764, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' 送信リスト__smstemplate/index', '2021-02-26 17:20:07', '2021-02-26 17:20:07'),
(89765, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', ' スケジュール__smssendlist/index', '2021-02-26 17:20:12', '2021-02-26 17:20:12'),
(89766, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'kamo__smsschedule/smsschedule', '2021-02-26 19:40:20', '2021-02-26 19:40:20'),
(89767, '::1', NULL, 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'ログアウト__smsschedule/index', '2021-02-26 19:40:21', '2021-02-26 19:40:21'),
(89768, '::1', NULL, 'kamo_s', 'koteon76qpv5fo3bcpe5292g47', '\n			kamo\n			\n		__outschedule/outschedule', '2021-02-26 19:40:33', '2021-02-26 19:40:33'),
(89769, '::1', NULL, 'kamo_s', 'koteon76qpv5fo3bcpe5292g47', 'ログアウト__outschedule/index', '2021-02-26 19:40:35', '2021-02-26 19:40:35'),
(89770, '127.0.0.1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', 'ログイン__login/login', '2021-03-01 10:08:17', '2021-03-01 10:08:17'),
(89771, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', '新規登録__outschedule/index', '2021-03-01 11:18:01', '2021-03-01 11:18:01'),
(89772, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' 発信リスト__outschedule/index', '2021-03-01 11:19:05', '2021-03-01 11:19:05'),
(89773, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' テンプレート__calllist/index', '2021-03-01 11:19:12', '2021-03-01 11:19:12'),
(89774, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__template/index', '2021-03-01 11:19:21', '2021-03-01 11:19:21'),
(89775, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', '新規登録__outschedule/index', '2021-03-01 11:19:28', '2021-03-01 11:19:28'),
(89776, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__outschedule/index', '2021-03-01 11:21:47', '2021-03-01 11:21:47'),
(89777, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__outschedule/index', '2021-03-01 11:26:18', '2021-03-01 11:26:18'),
(89778, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' テンプレート__outschedule/index', '2021-03-01 11:27:57', '2021-03-01 11:27:57'),
(89779, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' 発信リスト__template/index', '2021-03-01 11:28:42', '2021-03-01 11:28:42'),
(89780, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' テンプレート__calllist/index', '2021-03-01 11:41:32', '2021-03-01 11:41:32'),
(89781, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' テンプレート__template/template', '2021-03-01 11:44:01', '2021-03-01 11:44:01'),
(89782, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__template/index', '2021-03-01 11:44:05', '2021-03-01 11:44:05'),
(89783, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__outschedule/index', '2021-03-01 11:44:22', '2021-03-01 11:44:22'),
(89784, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' テンプレート__outschedule/index', '2021-03-01 11:44:42', '2021-03-01 11:44:42'),
(89785, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', ' スケジュール__template/template', '2021-03-01 11:44:50', '2021-03-01 11:44:50'),
(89786, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', 'kamo__outschedule/outschedule', '2021-03-01 11:45:07', '2021-03-01 11:45:07'),
(89787, '::1', NULL, 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', 'ログアウト__outschedule/index', '2021-03-01 11:45:09', '2021-03-01 11:45:09'),
(89788, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/index', '2021-03-01 11:46:23', '2021-03-01 11:46:23'),
(89789, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' テンプレート__outschedule/index', '2021-03-01 11:46:26', '2021-03-01 11:46:26'),
(89790, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '__template/template', '2021-03-01 11:46:45', '2021-03-01 11:46:45'),
(89791, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:47:14', '2021-03-01 11:47:14'),
(89792, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '__template/template', '2021-03-01 11:47:34', '2021-03-01 11:47:34'),
(89793, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '__template/template', '2021-03-01 11:47:39', '2021-03-01 11:47:39'),
(89794, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:47:44', '2021-03-01 11:47:44'),
(89795, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:47:48', '2021-03-01 11:47:48'),
(89796, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '\n										\n									__template/template', '2021-03-01 11:47:51', '2021-03-01 11:47:51'),
(89797, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:47:58', '2021-03-01 11:47:58'),
(89798, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:48:12', '2021-03-01 11:48:12'),
(89799, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__template/template', '2021-03-01 11:48:29', '2021-03-01 11:48:29'),
(89800, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '更新__template/template', '2021-03-01 11:49:02', '2021-03-01 11:49:02'),
(89801, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', 'インポート__template/index', '2021-03-01 11:50:06', '2021-03-01 11:50:06'),
(89802, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', 'インポート__template/index', '2021-03-01 11:50:09', '2021-03-01 11:50:09'),
(89803, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '×__template/template', '2021-03-01 11:50:15', '2021-03-01 11:50:15'),
(89804, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__template/index', '2021-03-01 12:01:07', '2021-03-01 12:01:07'),
(89805, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' 発信リスト__outschedule/index', '2021-03-01 12:05:40', '2021-03-01 12:05:40'),
(89806, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__calllist/index', '2021-03-01 12:08:22', '2021-03-01 12:08:22'),
(89807, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/status', '2021-03-01 12:08:33', '2021-03-01 12:08:33'),
(89808, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' 発信リスト__outschedule/index', '2021-03-01 12:08:41', '2021-03-01 12:08:41'),
(89809, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' 発信リスト__calllist/detail', '2021-03-01 12:10:56', '2021-03-01 12:10:56'),
(89810, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '新規登録__calllist/index', '2021-03-01 12:10:59', '2021-03-01 12:10:59'),
(89811, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', 'ファイルを選択__calllist/index', '2021-03-01 12:11:06', '2021-03-01 12:11:06'),
(89812, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '保存__calllist/index', '2021-03-01 12:11:21', '2021-03-01 12:11:21'),
(89813, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__calllist/index', '2021-03-01 12:12:29', '2021-03-01 12:12:29'),
(89814, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/index', '2021-03-01 12:13:18', '2021-03-01 12:13:18'),
(89815, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/index', '2021-03-01 12:14:06', '2021-03-01 12:14:06'),
(89816, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/index', '2021-03-01 12:15:47', '2021-03-01 12:15:47'),
(89817, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '詳細__outschedule/outschedule', '2021-03-01 12:16:39', '2021-03-01 12:16:39'),
(89818, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '×__outschedule/outschedule', '2021-03-01 12:16:40', '2021-03-01 12:16:40'),
(89819, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', ' スケジュール__outschedule/status', '2021-03-01 12:16:42', '2021-03-01 12:16:42'),
(89820, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', '__outschedule/outschedule', '2021-03-01 12:19:16', '2021-03-01 12:19:16'),
(89821, '::1', NULL, 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', 'ログアウト__outschedule/index', '2021-03-01 12:19:18', '2021-03-01 12:19:18'),
(89822, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/index', '2021-03-01 12:26:30', '2021-03-01 12:26:30'),
(89823, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/index', '2021-03-01 12:31:35', '2021-03-01 12:31:35'),
(89824, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/index', '2021-03-01 12:32:19', '2021-03-01 12:32:19'),
(89825, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:32:31', '2021-03-01 12:32:31'),
(89826, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '×__outschedule/outschedule', '2021-03-01 12:32:34', '2021-03-01 12:32:34'),
(89827, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:32:54', '2021-03-01 12:32:54'),
(89828, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '×__outschedule/outschedule', '2021-03-01 12:33:06', '2021-03-01 12:33:06'),
(89829, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:34:14', '2021-03-01 12:34:14'),
(89830, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '×__outschedule/outschedule', '2021-03-01 12:34:17', '2021-03-01 12:34:17'),
(89831, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:37:09', '2021-03-01 12:37:09'),
(89832, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:37:22', '2021-03-01 12:37:22'),
(89833, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '×__outschedule/outschedule', '2021-03-01 12:37:23', '2021-03-01 12:37:23'),
(89834, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:40:14', '2021-03-01 12:40:14'),
(89835, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:40:43', '2021-03-01 12:40:43'),
(89836, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:40:48', '2021-03-01 12:40:48'),
(89837, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:41:39', '2021-03-01 12:41:39'),
(89838, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:41:54', '2021-03-01 12:41:54'),
(89839, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:42:50', '2021-03-01 12:42:50'),
(89840, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '詳細__outschedule/outschedule', '2021-03-01 12:43:04', '2021-03-01 12:43:04'),
(89841, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '×__outschedule/outschedule', '2021-03-01 12:43:05', '2021-03-01 12:43:05'),
(89842, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:43:56', '2021-03-01 12:43:56'),
(89843, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/status', '2021-03-01 12:44:18', '2021-03-01 12:44:18'),
(89844, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__outschedule/index', '2021-03-01 12:49:05', '2021-03-01 12:49:05'),
(89845, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' 送信リスト__smsschedule/index', '2021-03-01 12:49:14', '2021-03-01 12:49:14'),
(89846, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' 着信設定__smssendlist/index', '2021-03-01 12:49:22', '2021-03-01 12:49:22'),
(89847, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '新規登録__inboundincominghistory/index', '2021-03-01 12:49:25', '2021-03-01 12:49:25'),
(89848, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' 着信設定__inboundincominghistory/index', '2021-03-01 12:53:10', '2021-03-01 12:53:10'),
(89849, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '新規登録__inboundincominghistory/index', '2021-03-01 12:54:09', '2021-03-01 12:54:09'),
(89850, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__inboundincominghistory/index', '2021-03-01 12:56:02', '2021-03-01 12:56:02'),
(89851, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__smsschedule/index', '2021-03-01 12:57:30', '2021-03-01 12:57:30'),
(89852, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' テンプレート__smsschedule/index', '2021-03-01 12:57:38', '2021-03-01 12:57:38'),
(89853, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' 送信リスト__smstemplate/index', '2021-03-01 12:57:43', '2021-03-01 12:57:43'),
(89854, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', ' スケジュール__smssendlist/index', '2021-03-01 12:57:48', '2021-03-01 12:57:48'),
(89855, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', '__smsschedule/smsschedule', '2021-03-01 12:58:31', '2021-03-01 12:58:31'),
(89856, '::1', NULL, 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', 'ログアウト__smsschedule/index', '2021-03-01 12:58:31', '2021-03-01 12:58:31'),
(89857, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' テンプレート__outschedule/index', '2021-03-01 13:49:40', '2021-03-01 13:49:40'),
(89858, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '閉じる__smstemplate/index', '2021-03-01 13:51:35', '2021-03-01 13:51:35'),
(89859, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smstemplate/index', '2021-03-01 13:51:37', '2021-03-01 13:51:37'),
(89860, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '新規登録__smsschedule/index', '2021-03-01 13:51:42', '2021-03-01 13:51:42'),
(89861, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' 送信リスト__smsschedule/index', '2021-03-01 14:05:38', '2021-03-01 14:05:38'),
(89862, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '新規登録__smssendlist/index', '2021-03-01 14:06:47', '2021-03-01 14:06:47'),
(89863, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', 'ファイルを選択__smssendlist/index', '2021-03-01 14:06:55', '2021-03-01 14:06:55'),
(89864, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '保存__smssendlist/index', '2021-03-01 14:07:03', '2021-03-01 14:07:03'),
(89865, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smssendlist/index', '2021-03-01 14:09:51', '2021-03-01 14:09:51'),
(89866, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smsschedule/index', '2021-03-01 14:10:23', '2021-03-01 14:10:23'),
(89867, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smsschedule/index', '2021-03-01 14:11:06', '2021-03-01 14:11:06'),
(89868, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smsschedule/status', '2021-03-01 14:13:00', '2021-03-01 14:13:00'),
(89869, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '詳細__smsschedule/smsschedule', '2021-03-01 14:13:14', '2021-03-01 14:13:14'),
(89870, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', '×__smsschedule/smsschedule', '2021-03-01 14:13:16', '2021-03-01 14:13:16'),
(89871, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' スケジュール__smsschedule/status', '2021-03-01 14:13:27', '2021-03-01 14:13:27'),
(89872, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', ' テンプレート__outschedule/index', '2021-03-01 14:13:32', '2021-03-01 14:13:32'),
(89873, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', 'kamo__template/template', '2021-03-01 14:16:17', '2021-03-01 14:16:17'),
(89874, '::1', NULL, 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', 'ログアウト__template/index', '2021-03-01 14:16:17', '2021-03-01 14:16:17'),
(89875, '::1', NULL, 's_kamo', 'vfud0pee6iac2f4jqdnnqglc71', ' アカウント管理__outschedule/index', '2021-03-01 14:16:45', '2021-03-01 14:16:45'),
(89876, '::1', NULL, 's_kamo', 'vfud0pee6iac2f4jqdnnqglc71', ' スケジュール__manageaccount/index', '2021-03-01 14:17:04', '2021-03-01 14:17:04'),
(89877, '::1', NULL, 's_kamo', 'vfud0pee6iac2f4jqdnnqglc71', ' アカウント管理__outschedule/index', '2021-03-01 14:17:14', '2021-03-01 14:17:14'),
(89878, '::1', NULL, 's_kamo', 'vfud0pee6iac2f4jqdnnqglc71', '選択項目を削除__manageaccount/index', '2021-03-01 14:17:46', '2021-03-01 14:17:46'),
(89879, '::1', NULL, 'kamo_s', 'qe7bma0jpiakn30lndq7hvlt55', 'kamo__outschedule/outschedule', '2021-03-01 14:20:50', '2021-03-01 14:20:50'),
(89880, '::1', NULL, 'kamo_s', 'qe7bma0jpiakn30lndq7hvlt55', 'ログアウト__outschedule/index', '2021-03-01 14:20:51', '2021-03-01 14:20:51'),
(89881, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' アカウント管理__outschedule/index', '2021-03-01 14:21:22', '2021-03-01 14:21:22'),
(89882, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' ユーザー管理__manageaccount/index', '2021-03-01 14:21:32', '2021-03-01 14:21:32'),
(89883, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', '選択項目を削除__manageuser/index', '2021-03-01 14:22:00', '2021-03-01 14:22:00'),
(89884, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' アカウント管理__manageuser/index', '2021-03-01 14:22:22', '2021-03-01 14:22:22'),
(89885, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' ユーザー管理__manageaccount/index', '2021-03-01 14:22:33', '2021-03-01 14:22:33'),
(89886, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' アカウント管理__manageuser/index', '2021-03-01 14:22:38', '2021-03-01 14:22:38'),
(89887, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', ' ユーザー管理__manageaccount/index', '2021-03-01 14:22:45', '2021-03-01 14:22:45'),
(89888, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', '閉じる__manageuser/index', '2021-03-01 14:22:57', '2021-03-01 14:22:57'),
(89889, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', '\n			kamo\n			\n		__manageuser/manageuser', '2021-03-01 14:23:26', '2021-03-01 14:23:26'),
(89890, '::1', NULL, 'kamo_s', 'lsb5aj65jjnd5gru1kcr0d9ra5', 'ログアウト__manageuser/index', '2021-03-01 14:23:27', '2021-03-01 14:23:27'),
(89891, '::1', NULL, 'fabbi', 'bcjksenk0tmffampc9qsg3glh7', ' アカウント管理__outschedule/index', '2021-03-01 14:24:10', '2021-03-01 14:24:10'),
(89892, '::1', NULL, 'fabbi', 'bcjksenk0tmffampc9qsg3glh7', ' ユーザー管理__manageaccount/index', '2021-03-01 14:24:17', '2021-03-01 14:24:17'),
(89893, '::1', NULL, 'fabbi', 'bcjksenk0tmffampc9qsg3glh7', 'fabbi__manageuser/manageuser', '2021-03-01 14:40:45', '2021-03-01 14:40:45'),
(89894, '::1', NULL, 'fabbi', 'bcjksenk0tmffampc9qsg3glh7', 'ログアウト__manageuser/index', '2021-03-01 14:40:45', '2021-03-01 14:40:45'),
(89895, '::1', NULL, 'fabbi', 'bmr5m340ot9fcqhcs3feu54io5', ' スケジュール__outschedule/index', '2021-03-01 14:41:42', '2021-03-01 14:41:42'),
(89896, '::1', NULL, 'fabbi', 'bmr5m340ot9fcqhcs3feu54io5', ' 着信設定__smsschedule/index', '2021-03-01 15:16:26', '2021-03-01 15:16:26'),
(89897, '::1', NULL, 'fabbi', 'bmr5m340ot9fcqhcs3feu54io5', ' スケジュール__inboundincominghistory/index', '2021-03-01 16:29:43', '2021-03-01 16:29:43'),
(89898, '::1', NULL, 'fabbi', 'bmr5m340ot9fcqhcs3feu54io5', '新規登録__outschedule/index', '2021-03-01 16:29:48', '2021-03-01 16:29:48'),
(89899, '::1', NULL, 'fabbi', 'bmr5m340ot9fcqhcs3feu54io5', ' テンプレート__outschedule/index', '2021-03-01 16:47:19', '2021-03-01 16:47:19'),
(89900, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:01:32', '2021-03-30 16:01:32'),
(89901, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:01:39', '2021-03-30 16:01:39'),
(89902, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:03:48', '2021-03-30 16:03:48'),
(89903, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__downloadresult/index', '2021-03-30 16:04:07', '2021-03-30 16:04:07'),
(89904, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__outschedule/index', '2021-03-30 16:04:17', '2021-03-30 16:04:17'),
(89905, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:04:40', '2021-03-30 16:04:40'),
(89906, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:05:04', '2021-03-30 16:05:04'),
(89907, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:06:37', '2021-03-30 16:06:37'),
(89908, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:15:54', '2021-03-30 16:15:54'),
(89909, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:20:43', '2021-03-30 16:20:43'),
(89910, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 16:22:15', '2021-03-30 16:22:15'),
(89911, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:02:39', '2021-03-30 17:02:39'),
(89912, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:07:44', '2021-03-30 17:07:44'),
(89913, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__downloadresult/index', '2021-03-30 17:08:06', '2021-03-30 17:08:06'),
(89914, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__outschedule/index', '2021-03-30 17:10:50', '2021-03-30 17:10:50'),
(89915, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__downloadresult/index', '2021-03-30 17:29:56', '2021-03-30 17:29:56'),
(89916, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__inboundrestrict/index', '2021-03-30 17:30:28', '2021-03-30 17:30:28'),
(89917, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__outschedule/index', '2021-03-30 17:31:07', '2021-03-30 17:31:07'),
(89918, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__inboundrestrict/index', '2021-03-30 17:31:22', '2021-03-30 17:31:22'),
(89919, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:31:44', '2021-03-30 17:31:44'),
(89920, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' テンプレート__downloadresult/index', '2021-03-30 17:34:59', '2021-03-30 17:34:59'),
(89921, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__inboundtemplate/index', '2021-03-30 17:35:11', '2021-03-30 17:35:11'),
(89922, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__inboundrestrict/index', '2021-03-30 17:39:36', '2021-03-30 17:39:36'),
(89923, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:39:57', '2021-03-30 17:39:57'),
(89924, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:42:43', '2021-03-30 17:42:43'),
(89925, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:45:24', '2021-03-30 17:45:24'),
(89926, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 17:53:46', '2021-03-30 17:53:46'),
(89927, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__downloadresult/index', '2021-03-30 17:54:53', '2021-03-30 17:54:53'),
(89928, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__smsschedule/index', '2021-03-30 18:02:27', '2021-03-30 18:02:27'),
(89929, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__outschedule/index', '2021-03-30 18:05:43', '2021-03-30 18:05:43'),
(89930, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__smsschedule/index', '2021-03-30 18:25:35', '2021-03-30 18:25:35'),
(89931, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__inboundrestrict/index', '2021-03-30 18:25:39', '2021-03-30 18:25:39'),
(89932, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 18:25:57', '2021-03-30 18:25:57'),
(89933, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 18:35:50', '2021-03-30 18:35:50'),
(89934, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' スケジュール__downloadresult/index', '2021-03-30 18:36:45', '2021-03-30 18:36:45'),
(89935, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__smsschedule/index', '2021-03-30 18:36:47', '2021-03-30 18:36:47'),
(89936, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', '選択項目のDL__inboundrestrict/index', '2021-03-30 18:36:50', '2021-03-30 18:36:50'),
(89937, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', '選択項目のDL__inboundrestrict/index', '2021-03-30 18:38:59', '2021-03-30 18:38:59'),
(89938, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 結果ログ一括DL__inboundrestrict/index', '2021-03-30 18:40:08', '2021-03-30 18:40:08'),
(89939, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', 'ダウンロード__downloadresult/downloadresult', '2021-03-30 18:40:22', '2021-03-30 18:40:22'),
(89940, '::1', NULL, 'fabbi', 'lguvu8t53ddqjnajfl54ims713', ' 着信拒否リスト__downloadresult/index', '2021-03-30 18:44:42', '2021-03-30 18:44:42'),
(89941, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信拒否リスト__outschedule/index', '2021-03-31 15:50:09', '2021-03-31 15:50:09'),
(89942, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__inboundrestrict/index', '2021-03-31 15:50:28', '2021-03-31 15:50:28'),
(89943, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__smsschedule/index', '2021-03-31 16:49:34', '2021-03-31 16:49:34'),
(89944, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' メニュー管理__outschedule/index', '2021-03-31 16:57:00', '2021-03-31 16:57:00'),
(89945, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__managemenu/index', '2021-03-31 16:57:03', '2021-03-31 16:57:03');
INSERT INTO `t91_action_histories` (`id`, `client_ip`, `mac_addr`, `user_id`, `session_id`, `operation`, `created`, `modified`) VALUES
(89946, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信拒否リスト__inboundcalllist/index', '2021-03-31 16:59:18', '2021-03-31 16:59:18'),
(89947, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信リスト__inboundrestrict/index', '2021-03-31 16:59:21', '2021-03-31 16:59:21'),
(89948, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__inboundcalllist/index', '2021-03-31 17:01:18', '2021-03-31 17:01:18'),
(89949, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信リスト__outschedule/index', '2021-03-31 17:13:08', '2021-03-31 17:13:08'),
(89950, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信拒否リスト__inboundcalllist/index', '2021-03-31 17:13:23', '2021-03-31 17:13:23'),
(89951, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信リスト__inboundrestrict/index', '2021-03-31 17:13:25', '2021-03-31 17:13:25'),
(89952, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__inboundcalllist/index', '2021-03-31 17:24:53', '2021-03-31 17:24:53'),
(89953, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__inboundincominghistory/index', '2021-03-31 17:47:40', '2021-03-31 17:47:40'),
(89954, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信設定__outschedule/index', '2021-03-31 17:47:54', '2021-03-31 17:47:54'),
(89955, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' メニュー管理__inboundincominghistory/index', '2021-03-31 17:48:34', '2021-03-31 17:48:34'),
(89956, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' スケジュール__managemenu/index', '2021-03-31 17:48:37', '2021-03-31 17:48:37'),
(89957, '::1', NULL, 'fabbi', '2fa10b47d1j5lmj5lmnd3oehv3', ' 着信設定__smsschedule/index', '2021-03-31 18:08:57', '2021-03-31 18:08:57'),
(89958, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' テンプレート__outschedule/index', '2021-06-21 15:33:37', '2021-06-21 15:33:37'),
(89959, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 15:33:45', '2021-06-21 15:33:45'),
(89960, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 15:35:06', '2021-06-21 15:35:06'),
(89961, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 15:35:25', '2021-06-21 15:35:25'),
(89962, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 15:35:34', '2021-06-21 15:35:34'),
(89963, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 15:35:46', '2021-06-21 15:35:46'),
(89964, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 15:35:48', '2021-06-21 15:35:48'),
(89965, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 15:37:37', '2021-06-21 15:37:37'),
(89966, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 15:40:39', '2021-06-21 15:40:39'),
(89967, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 15:40:45', '2021-06-21 15:40:45'),
(89968, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 15:40:58', '2021-06-21 15:40:58'),
(89969, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 15:41:06', '2021-06-21 15:41:06'),
(89970, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' アカウント管理__template/index', '2021-06-21 15:51:32', '2021-06-21 15:51:32'),
(89971, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' ユーザー管理__manageaccount/index', '2021-06-21 15:51:45', '2021-06-21 15:51:45'),
(89972, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' メニュー管理__manageuser/index', '2021-06-21 15:51:48', '2021-06-21 15:51:48'),
(89973, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' ユーザー管理__managemenu/index', '2021-06-21 15:51:50', '2021-06-21 15:51:50'),
(89974, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' アカウント管理__manageuser/index', '2021-06-21 15:51:51', '2021-06-21 15:51:51'),
(89975, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' メニュー管理__manageaccount/index', '2021-06-21 15:52:21', '2021-06-21 15:52:21'),
(89976, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' ユーザー管理__managemenu/index', '2021-06-21 15:52:23', '2021-06-21 15:52:23'),
(89977, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' アカウント管理__manageuser/index', '2021-06-21 15:52:25', '2021-06-21 15:52:25'),
(89978, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' 操作マニュアル__manageaccount/index', '2021-06-21 15:52:28', '2021-06-21 15:52:28'),
(89979, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '新規登録__manageaccount/index', '2021-06-21 15:58:43', '2021-06-21 15:58:43'),
(89980, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '閉じる__manageaccount/index', '2021-06-21 15:58:45', '2021-06-21 15:58:45'),
(89981, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' テンプレート__manageaccount/index', '2021-06-21 15:58:46', '2021-06-21 15:58:46'),
(89982, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '新規登録__template/index', '2021-06-21 15:58:47', '2021-06-21 15:58:47'),
(89983, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 15:58:48', '2021-06-21 15:58:48'),
(89984, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 16:22:49', '2021-06-21 16:22:49'),
(89985, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' テンプレート__template/template', '2021-06-21 16:23:04', '2021-06-21 16:23:04'),
(89986, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' テンプレート__template/template', '2021-06-21 16:23:07', '2021-06-21 16:23:07'),
(89987, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '新規登録__template/index', '2021-06-21 16:23:08', '2021-06-21 16:23:08'),
(89988, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:23:09', '2021-06-21 16:23:09'),
(89989, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:26:02', '2021-06-21 16:26:02'),
(89990, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:26:08', '2021-06-21 16:26:08'),
(89991, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:26:14', '2021-06-21 16:26:14'),
(89992, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:26:20', '2021-06-21 16:26:20'),
(89993, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:26:21', '2021-06-21 16:26:21'),
(89994, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:26:24', '2021-06-21 16:26:24'),
(89995, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:26:25', '2021-06-21 16:26:25'),
(89996, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:26:43', '2021-06-21 16:26:43'),
(89997, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:26:58', '2021-06-21 16:26:58'),
(89998, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 16:29:04', '2021-06-21 16:29:04'),
(89999, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:29:33', '2021-06-21 16:29:33'),
(90000, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:29:45', '2021-06-21 16:29:45'),
(90001, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 16:29:49', '2021-06-21 16:29:49'),
(90002, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:29:51', '2021-06-21 16:29:51'),
(90003, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:29:52', '2021-06-21 16:29:52'),
(90004, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:30:01', '2021-06-21 16:30:01'),
(90005, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:30:20', '2021-06-21 16:30:20'),
(90006, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:31:34', '2021-06-21 16:31:34'),
(90007, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:31:44', '2021-06-21 16:31:44'),
(90008, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 16:32:01', '2021-06-21 16:32:01'),
(90009, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '挿入__template/template', '2021-06-21 16:32:13', '2021-06-21 16:32:13'),
(90010, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '挿入__template/template', '2021-06-21 16:32:13', '2021-06-21 16:32:13'),
(90011, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '挿入__template/template', '2021-06-21 16:32:13', '2021-06-21 16:32:13'),
(90012, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:32:29', '2021-06-21 16:32:29'),
(90013, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:32:45', '2021-06-21 16:32:45'),
(90014, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n										\n									__template/template', '2021-06-21 16:33:15', '2021-06-21 16:33:15'),
(90015, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:23', '2021-06-21 16:33:23'),
(90016, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:38', '2021-06-21 16:33:38'),
(90017, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:38', '2021-06-21 16:33:38'),
(90018, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:39', '2021-06-21 16:33:39'),
(90019, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:41', '2021-06-21 16:33:41'),
(90020, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:41', '2021-06-21 16:33:41'),
(90021, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:42', '2021-06-21 16:33:42'),
(90022, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:42', '2021-06-21 16:33:42'),
(90023, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:42', '2021-06-21 16:33:42'),
(90024, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:42', '2021-06-21 16:33:42'),
(90025, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:49', '2021-06-21 16:33:49'),
(90026, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:49', '2021-06-21 16:33:49'),
(90027, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:49', '2021-06-21 16:33:49'),
(90028, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:49', '2021-06-21 16:33:49'),
(90029, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:50', '2021-06-21 16:33:50'),
(90030, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:50', '2021-06-21 16:33:50'),
(90031, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:52', '2021-06-21 16:33:52'),
(90032, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:52', '2021-06-21 16:33:52'),
(90033, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:52', '2021-06-21 16:33:52'),
(90034, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:52', '2021-06-21 16:33:52'),
(90035, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:55', '2021-06-21 16:33:55'),
(90036, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:55', '2021-06-21 16:33:55'),
(90037, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:55', '2021-06-21 16:33:55'),
(90038, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:55', '2021-06-21 16:33:55'),
(90039, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:55', '2021-06-21 16:33:55'),
(90040, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:56', '2021-06-21 16:33:56'),
(90041, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:56', '2021-06-21 16:33:56'),
(90042, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:56', '2021-06-21 16:33:56'),
(90043, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:33:56', '2021-06-21 16:33:56'),
(90044, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:34:19', '2021-06-21 16:34:19'),
(90045, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:34:31', '2021-06-21 16:34:31'),
(90046, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:34:43', '2021-06-21 16:34:43'),
(90047, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:34:49', '2021-06-21 16:34:49'),
(90048, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:34:54', '2021-06-21 16:34:54'),
(90049, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:35:19', '2021-06-21 16:35:19'),
(90050, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:35:43', '2021-06-21 16:35:43'),
(90051, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:35:56', '2021-06-21 16:35:56'),
(90052, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:36:03', '2021-06-21 16:36:03'),
(90053, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:36:48', '2021-06-21 16:36:48'),
(90054, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:38:36', '2021-06-21 16:38:36'),
(90055, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:38:59', '2021-06-21 16:38:59'),
(90056, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:04', '2021-06-21 16:39:04'),
(90057, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:39:13', '2021-06-21 16:39:13'),
(90058, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:15', '2021-06-21 16:39:15'),
(90059, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 16:39:25', '2021-06-21 16:39:25'),
(90060, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '閉じる__template/template', '2021-06-21 16:39:34', '2021-06-21 16:39:34'),
(90061, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:43', '2021-06-21 16:39:43'),
(90062, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:48', '2021-06-21 16:39:48'),
(90063, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:52', '2021-06-21 16:39:52'),
(90064, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:55', '2021-06-21 16:39:55'),
(90065, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:39:57', '2021-06-21 16:39:57'),
(90066, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n										\n									__template/template', '2021-06-21 16:40:23', '2021-06-21 16:40:23'),
(90067, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:40:34', '2021-06-21 16:40:34'),
(90068, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:44', '2021-06-21 16:40:44'),
(90069, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:40:50', '2021-06-21 16:40:50'),
(90070, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:54', '2021-06-21 16:40:54'),
(90071, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:54', '2021-06-21 16:40:54'),
(90072, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:54', '2021-06-21 16:40:54'),
(90073, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:54', '2021-06-21 16:40:54'),
(90074, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:40:55', '2021-06-21 16:40:55'),
(90075, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:40:59', '2021-06-21 16:40:59'),
(90076, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:41:02', '2021-06-21 16:41:02'),
(90077, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:41:07', '2021-06-21 16:41:07'),
(90078, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:41:10', '2021-06-21 16:41:10'),
(90079, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:41:26', '2021-06-21 16:41:26'),
(90080, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n										\n									__template/template', '2021-06-21 16:41:29', '2021-06-21 16:41:29'),
(90081, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:41:35', '2021-06-21 16:41:35'),
(90082, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n									\n								__template/template', '2021-06-21 16:41:39', '2021-06-21 16:41:39'),
(90083, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:41:42', '2021-06-21 16:41:42'),
(90084, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:41:43', '2021-06-21 16:41:43'),
(90085, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 16:41:48', '2021-06-21 16:41:48'),
(90086, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:41:50', '2021-06-21 16:41:50'),
(90087, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:41:52', '2021-06-21 16:41:52'),
(90088, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:41:59', '2021-06-21 16:41:59'),
(90089, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n										\n									__template/template', '2021-06-21 16:42:01', '2021-06-21 16:42:01'),
(90090, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:42:04', '2021-06-21 16:42:04'),
(90091, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:05', '2021-06-21 16:42:05'),
(90092, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:08', '2021-06-21 16:42:08'),
(90093, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:09', '2021-06-21 16:42:09'),
(90094, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:09', '2021-06-21 16:42:09'),
(90095, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:10', '2021-06-21 16:42:10'),
(90096, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:10', '2021-06-21 16:42:10'),
(90097, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:10', '2021-06-21 16:42:10'),
(90098, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 16:42:12', '2021-06-21 16:42:12'),
(90099, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:42:18', '2021-06-21 16:42:18'),
(90100, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:42:20', '2021-06-21 16:42:20'),
(90101, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:43:05', '2021-06-21 16:43:05'),
(90102, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:43:19', '2021-06-21 16:43:19'),
(90103, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:43:22', '2021-06-21 16:43:22'),
(90104, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:43:32', '2021-06-21 16:43:32'),
(90105, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:43:34', '2021-06-21 16:43:34'),
(90106, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 16:43:46', '2021-06-21 16:43:46'),
(90107, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:43:48', '2021-06-21 16:43:48'),
(90108, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 16:43:56', '2021-06-21 16:43:56'),
(90109, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 16:44:08', '2021-06-21 16:44:08'),
(90110, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', ' テンプレート__template/template', '2021-06-21 16:59:25', '2021-06-21 16:59:25'),
(90111, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '新規登録__template/index', '2021-06-21 16:59:27', '2021-06-21 16:59:27'),
(90112, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 16:59:28', '2021-06-21 16:59:28'),
(90113, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:00:29', '2021-06-21 17:00:29'),
(90114, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:00:38', '2021-06-21 17:00:38'),
(90115, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:00:43', '2021-06-21 17:00:43'),
(90116, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:00:48', '2021-06-21 17:00:48'),
(90117, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:00:49', '2021-06-21 17:00:49'),
(90118, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:00:52', '2021-06-21 17:00:52'),
(90119, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:01:09', '2021-06-21 17:01:09'),
(90120, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 17:01:26', '2021-06-21 17:01:26'),
(90121, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 17:01:37', '2021-06-21 17:01:37'),
(90122, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:01:45', '2021-06-21 17:01:45'),
(90123, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:01:47', '2021-06-21 17:01:47'),
(90124, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:01:58', '2021-06-21 17:01:58'),
(90125, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '閉じる__template/template', '2021-06-21 17:02:09', '2021-06-21 17:02:09'),
(90126, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:02:13', '2021-06-21 17:02:13'),
(90127, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '閉じる__template/template', '2021-06-21 17:02:21', '2021-06-21 17:02:21'),
(90128, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:02:32', '2021-06-21 17:02:32'),
(90129, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:02:39', '2021-06-21 17:02:39'),
(90130, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '閉じる__template/template', '2021-06-21 17:02:44', '2021-06-21 17:02:44'),
(90131, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:02:45', '2021-06-21 17:02:45'),
(90132, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:03:01', '2021-06-21 17:03:01'),
(90133, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:03:10', '2021-06-21 17:03:10'),
(90134, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 17:03:18', '2021-06-21 17:03:18'),
(90135, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:03:23', '2021-06-21 17:03:23'),
(90136, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:03:25', '2021-06-21 17:03:25'),
(90137, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:03:46', '2021-06-21 17:03:46'),
(90138, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:03:59', '2021-06-21 17:03:59'),
(90139, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '__template/template', '2021-06-21 17:04:15', '2021-06-21 17:04:15'),
(90140, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:04:25', '2021-06-21 17:04:25'),
(90141, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:04:41', '2021-06-21 17:04:41'),
(90142, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '保存__template/template', '2021-06-21 17:04:58', '2021-06-21 17:04:58'),
(90143, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 17:05:20', '2021-06-21 17:05:20'),
(90144, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 17:52:44', '2021-06-21 17:52:44'),
(90145, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 17:52:48', '2021-06-21 17:52:48'),
(90146, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '更新__template/template', '2021-06-21 17:52:53', '2021-06-21 17:52:53'),
(90147, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', 'セクションの追加__template/template', '2021-06-21 17:53:02', '2021-06-21 17:53:02'),
(90148, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 17:53:07', '2021-06-21 17:53:07'),
(90149, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '\n										\n									__template/template', '2021-06-21 17:53:08', '2021-06-21 17:53:08'),
(90150, '::1', NULL, 'fabbi', '15njgf4alqfr18kmeufq1iecm4', '×__template/template', '2021-06-21 17:53:13', '2021-06-21 17:53:13'),
(90151, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', ' テンプレート__outschedule/index', '2021-06-22 15:36:34', '2021-06-22 15:36:34'),
(90152, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 15:36:42', '2021-06-22 15:36:42'),
(90153, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:36:46', '2021-06-22 15:36:46'),
(90154, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:15', '2021-06-22 15:37:15'),
(90155, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:16', '2021-06-22 15:37:16'),
(90156, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:16', '2021-06-22 15:37:16'),
(90157, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:16', '2021-06-22 15:37:16'),
(90158, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:18', '2021-06-22 15:37:18'),
(90159, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:18', '2021-06-22 15:37:18'),
(90160, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:19', '2021-06-22 15:37:19'),
(90161, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '\n									\n								__template/template', '2021-06-22 15:37:37', '2021-06-22 15:37:37'),
(90162, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:37:40', '2021-06-22 15:37:40'),
(90163, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '\n										\n									__template/template', '2021-06-22 15:39:56', '2021-06-22 15:39:56'),
(90164, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '\n										\n									__template/template', '2021-06-22 15:39:59', '2021-06-22 15:39:59'),
(90165, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 15:40:01', '2021-06-22 15:40:01'),
(90166, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 15:40:04', '2021-06-22 15:40:04'),
(90167, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:40:06', '2021-06-22 15:40:06'),
(90168, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', 'セクションの追加__template/template', '2021-06-22 15:42:00', '2021-06-22 15:42:00'),
(90169, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', 'セクションの追加__template/template', '2021-06-22 15:47:55', '2021-06-22 15:47:55'),
(90170, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '保存__template/template', '2021-06-22 15:48:18', '2021-06-22 15:48:18'),
(90171, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:48:23', '2021-06-22 15:48:23'),
(90172, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:49:42', '2021-06-22 15:49:42'),
(90173, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', 'セクションの追加__template/template', '2021-06-22 15:49:49', '2021-06-22 15:49:49'),
(90174, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '保存__template/template', '2021-06-22 15:50:01', '2021-06-22 15:50:01'),
(90175, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:50:07', '2021-06-22 15:50:07'),
(90176, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', 'セクションの追加__template/template', '2021-06-22 15:50:08', '2021-06-22 15:50:08'),
(90177, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '保存__template/template', '2021-06-22 15:50:14', '2021-06-22 15:50:14'),
(90178, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 15:50:16', '2021-06-22 15:50:16'),
(90179, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 16:59:57', '2021-06-22 16:59:57'),
(90180, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:03', '2021-06-22 17:00:03'),
(90181, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:05', '2021-06-22 17:00:05'),
(90182, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:06', '2021-06-22 17:00:06'),
(90183, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:07', '2021-06-22 17:00:07'),
(90184, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:07', '2021-06-22 17:00:07'),
(90185, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:07', '2021-06-22 17:00:07'),
(90186, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:00:07', '2021-06-22 17:00:07'),
(90187, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 17:06:23', '2021-06-22 17:06:23'),
(90188, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '__template/template', '2021-06-22 17:06:25', '2021-06-22 17:06:25'),
(90189, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', 'セクションの追加__template/template', '2021-06-22 17:06:27', '2021-06-22 17:06:27'),
(90190, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '保存__template/template', '2021-06-22 17:06:36', '2021-06-22 17:06:36'),
(90191, '::1', NULL, 'fabbi', '594ohg8c2mmdebkk2u72r4i2n7', '更新__template/template', '2021-06-22 17:06:39', '2021-06-22 17:06:39'),
(90192, '::1', NULL, 'fabbi', '1sfe017sti7vu845j9mdt94t94', ' テンプレート__outschedule/index', '2021-06-23 11:02:40', '2021-06-23 11:02:40'),
(90193, '::1', NULL, 'fabbi', '1sfe017sti7vu845j9mdt94t94', '__template/template', '2021-06-23 15:40:58', '2021-06-23 15:40:58'),
(90194, '::1', NULL, 'fabbi', '1sfe017sti7vu845j9mdt94t94', 'ログアウト__template/template', '2021-06-23 15:40:59', '2021-06-23 15:40:59'),
(90195, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' テンプレート__outschedule/index', '2021-06-23 15:43:22', '2021-06-23 15:43:22'),
(90196, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '新規登録__inboundtemplate/index', '2021-06-23 15:43:24', '2021-06-23 15:43:24'),
(90197, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', 'セクションの追加__inboundtemplate/template', '2021-06-23 15:43:25', '2021-06-23 15:43:25'),
(90198, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '×__inboundtemplate/inboundtemplate', '2021-06-23 15:43:29', '2021-06-23 15:43:29'),
(90199, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', 'セクションの追加__inboundtemplate/template', '2021-06-23 15:43:53', '2021-06-23 15:43:53'),
(90200, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '×__inboundtemplate/inboundtemplate', '2021-06-23 15:44:16', '2021-06-23 15:44:16'),
(90201, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' テンプレート__inboundtemplate/template', '2021-06-23 16:10:22', '2021-06-23 16:10:22'),
(90202, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' テンプレート__template/template', '2021-06-23 16:10:48', '2021-06-23 16:10:48'),
(90203, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' 発信リスト__template/index', '2021-06-23 16:49:48', '2021-06-23 16:49:48'),
(90204, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '保存__calllist/detail', '2021-06-23 16:50:04', '2021-06-23 16:50:04'),
(90205, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' テンプレート__calllist/detail', '2021-06-23 17:18:22', '2021-06-23 17:18:22'),
(90206, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '新規登録__inboundtemplate/index', '2021-06-23 17:18:24', '2021-06-23 17:18:24'),
(90207, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', 'セクションの追加__inboundtemplate/template', '2021-06-23 17:18:25', '2021-06-23 17:18:25'),
(90208, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '×__inboundtemplate/inboundtemplate', '2021-06-23 18:15:34', '2021-06-23 18:15:34'),
(90209, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', ' スケジュール__inboundtemplate/template', '2021-06-23 18:15:36', '2021-06-23 18:15:36'),
(90210, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '新規登録__outschedule/index', '2021-06-23 18:40:01', '2021-06-23 18:40:01'),
(90211, '::1', NULL, 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', '新規登録__outschedule/index', '2021-06-23 19:11:07', '2021-06-23 19:11:07'),
(90212, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', 'ログイン__login/login', '2021-06-24 10:46:06', '2021-06-24 10:46:06'),
(90213, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' スケジュール__outschedule/index', '2021-06-24 10:53:57', '2021-06-24 10:53:57'),
(90214, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '新規登録__outschedule/index', '2021-06-24 10:54:51', '2021-06-24 10:54:51'),
(90215, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '__outschedule/index', '2021-06-24 11:04:37', '2021-06-24 11:04:37'),
(90216, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' テンプレート__template/template', '2021-06-24 11:04:41', '2021-06-24 11:04:41'),
(90217, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', 'インポート__template/index', '2021-06-24 11:08:14', '2021-06-24 11:08:14'),
(90218, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '×__template/template', '2021-06-24 11:08:56', '2021-06-24 11:08:56'),
(90219, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '__template/template', '2021-06-24 11:10:03', '2021-06-24 11:10:03'),
(90220, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '__template/template', '2021-06-24 11:10:06', '2021-06-24 11:10:06'),
(90221, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '更新__template/template', '2021-06-24 11:10:10', '2021-06-24 11:10:10'),
(90222, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' 発信リスト__template/index', '2021-06-24 11:12:09', '2021-06-24 11:12:09'),
(90223, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' 発信NGリスト__calllist/index', '2021-06-24 11:12:12', '2021-06-24 11:12:12'),
(90224, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' テンプレート__calllistng/index', '2021-06-24 11:12:14', '2021-06-24 11:12:14'),
(90225, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '選択項目を削除__template/index', '2021-06-24 11:12:18', '2021-06-24 11:12:18'),
(90226, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' 発信リスト__template/index', '2021-06-24 11:12:25', '2021-06-24 11:12:25'),
(90227, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '選択項目のDL__calllist/index', '2021-06-24 11:12:28', '2021-06-24 11:12:28'),
(90228, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '選択項目を削除__calllist/index', '2021-06-24 11:13:15', '2021-06-24 11:13:15'),
(90229, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', ' テンプレート__calllist/index', '2021-06-24 11:13:17', '2021-06-24 11:13:17'),
(90230, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', 'インポート__template/index', '2021-06-24 11:13:19', '2021-06-24 11:13:19'),
(90231, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '×__template/template', '2021-06-24 11:16:21', '2021-06-24 11:16:21'),
(90232, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', '__template/template', '2021-06-24 11:16:22', '2021-06-24 11:16:22'),
(90233, '::1', NULL, 'fabbi', 'n31opl54pi7v3ei2ddmr0hdjr3', 'ログアウト__template/index', '2021-06-24 11:16:22', '2021-06-24 11:16:22'),
(90234, '::1', NULL, 'fabbi', '95qtmmooh813knir1o3h9r0l64', ' テンプレート__outschedule/index', '2021-06-24 11:16:32', '2021-06-24 11:16:32'),
(90235, '::1', NULL, 'fabbi', '95qtmmooh813knir1o3h9r0l64', '\n			fabbi\n			\n		__template/template', '2021-06-24 11:19:22', '2021-06-24 11:19:22'),
(90236, '::1', NULL, 'fabbi', '95qtmmooh813knir1o3h9r0l64', 'ログアウト__template/index', '2021-06-24 11:19:23', '2021-06-24 11:19:23'),
(90237, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 11:21:41', '2021-06-24 11:21:41'),
(90238, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__inboundtemplate/index', '2021-06-24 11:32:57', '2021-06-24 11:32:57'),
(90239, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__inboundtemplate/index', '2021-06-24 11:45:48', '2021-06-24 11:45:48'),
(90240, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__inboundtemplate/index', '2021-06-24 11:46:02', '2021-06-24 11:46:02'),
(90241, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__inboundtemplate/index', '2021-06-24 11:46:30', '2021-06-24 11:46:30'),
(90242, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '×__inboundtemplate/inboundtemplate', '2021-06-24 11:47:13', '2021-06-24 11:47:13'),
(90243, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__inboundtemplate/index', '2021-06-24 11:47:14', '2021-06-24 11:47:14'),
(90244, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '選択項目を削除__calllist/detail', '2021-06-24 11:47:18', '2021-06-24 11:47:18'),
(90245, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__calllist/detail', '2021-06-24 11:47:20', '2021-06-24 11:47:20'),
(90246, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '×__calllist/calllist', '2021-06-24 11:47:28', '2021-06-24 11:47:28'),
(90247, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 11:47:43', '2021-06-24 11:47:43'),
(90248, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 11:48:29', '2021-06-24 11:48:29'),
(90249, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 11:49:21', '2021-06-24 11:49:21'),
(90250, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__calllist/detail', '2021-06-24 11:50:59', '2021-06-24 11:50:59'),
(90251, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__inboundtemplate/index', '2021-06-24 11:51:00', '2021-06-24 11:51:00'),
(90252, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 11:51:22', '2021-06-24 11:51:22'),
(90253, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 11:52:07', '2021-06-24 11:52:07'),
(90254, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 11:53:43', '2021-06-24 11:53:43'),
(90255, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 11:57:26', '2021-06-24 11:57:26'),
(90256, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:57:27', '2021-06-24 11:57:27'),
(90257, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:57:39', '2021-06-24 11:57:39'),
(90258, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:00', '2021-06-24 11:59:00'),
(90259, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:06', '2021-06-24 11:59:06'),
(90260, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:06', '2021-06-24 11:59:06'),
(90261, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:07', '2021-06-24 11:59:07'),
(90262, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:07', '2021-06-24 11:59:07'),
(90263, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:07', '2021-06-24 11:59:07'),
(90264, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:07', '2021-06-24 11:59:07'),
(90265, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:07', '2021-06-24 11:59:07'),
(90266, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 11:59:25', '2021-06-24 11:59:25'),
(90267, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__template/index', '2021-06-24 12:04:33', '2021-06-24 12:04:33'),
(90268, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 12:04:40', '2021-06-24 12:04:40'),
(90269, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 12:13:59', '2021-06-24 12:13:59'),
(90270, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 12:20:32', '2021-06-24 12:20:32'),
(90271, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信NGリスト__outschedule/index', '2021-06-24 12:26:38', '2021-06-24 12:26:38'),
(90272, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__calllistng/index', '2021-06-24 12:26:39', '2021-06-24 12:26:39'),
(90273, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 12:26:45', '2021-06-24 12:26:45'),
(90274, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__calllist/detail', '2021-06-24 12:26:58', '2021-06-24 12:26:58'),
(90275, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 12:27:25', '2021-06-24 12:27:25'),
(90276, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__calllist/detail', '2021-06-24 12:33:49', '2021-06-24 12:33:49'),
(90277, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__inboundtemplate/index', '2021-06-24 12:33:52', '2021-06-24 12:33:52'),
(90278, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 12:33:53', '2021-06-24 12:33:53'),
(90279, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 12:34:08', '2021-06-24 12:34:08'),
(90280, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 12:34:14', '2021-06-24 12:34:14'),
(90281, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 12:34:15', '2021-06-24 12:34:15'),
(90282, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 12:34:21', '2021-06-24 12:34:21'),
(90283, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/template', '2021-06-24 12:34:27', '2021-06-24 12:34:27'),
(90284, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 12:34:28', '2021-06-24 12:34:28'),
(90285, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 12:34:32', '2021-06-24 12:34:32'),
(90286, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/template', '2021-06-24 12:34:33', '2021-06-24 12:34:33'),
(90287, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__inboundtemplate/index', '2021-06-24 12:34:57', '2021-06-24 12:34:57'),
(90288, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 12:58:36', '2021-06-24 12:58:36'),
(90289, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__template/template', '2021-06-24 12:58:40', '2021-06-24 12:58:40'),
(90290, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__template/index', '2021-06-24 13:00:40', '2021-06-24 13:00:40'),
(90291, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 13:27:15', '2021-06-24 13:27:15'),
(90292, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:27:17', '2021-06-24 13:27:17'),
(90293, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:27:26', '2021-06-24 13:27:26'),
(90294, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:28:52', '2021-06-24 13:28:52'),
(90295, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__template/index', '2021-06-24 13:28:57', '2021-06-24 13:28:57'),
(90296, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__template/template', '2021-06-24 13:28:59', '2021-06-24 13:28:59'),
(90297, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:29:00', '2021-06-24 13:29:00'),
(90298, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:29:12', '2021-06-24 13:29:12'),
(90299, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '更新__template/template', '2021-06-24 13:32:54', '2021-06-24 13:32:54'),
(90300, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'インポート__template/index', '2021-06-24 13:32:57', '2021-06-24 13:32:57'),
(90301, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '×__template/template', '2021-06-24 13:33:05', '2021-06-24 13:33:05'),
(90302, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__template/index', '2021-06-24 13:40:19', '2021-06-24 13:40:19'),
(90303, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__calllist/index', '2021-06-24 13:40:20', '2021-06-24 13:40:20'),
(90304, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:40:29', '2021-06-24 13:40:29'),
(90305, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:40:39', '2021-06-24 13:40:39'),
(90306, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:40:48', '2021-06-24 13:40:48'),
(90307, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__calllist/detail', '2021-06-24 13:42:25', '2021-06-24 13:42:25'),
(90308, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:43:00', '2021-06-24 13:43:00'),
(90309, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:46:38', '2021-06-24 13:46:38'),
(90310, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:53:12', '2021-06-24 13:53:12'),
(90311, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:53:40', '2021-06-24 13:53:40'),
(90312, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__calllist/detail', '2021-06-24 13:53:54', '2021-06-24 13:53:54'),
(90313, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__template/template', '2021-06-24 13:54:00', '2021-06-24 13:54:00'),
(90314, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__template/template', '2021-06-24 13:54:27', '2021-06-24 13:54:27'),
(90315, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__template/template', '2021-06-24 13:54:40', '2021-06-24 13:54:40'),
(90316, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '更新__template/template', '2021-06-24 13:54:48', '2021-06-24 13:54:48'),
(90317, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 発信リスト__template/template', '2021-06-24 13:55:02', '2021-06-24 13:55:02'),
(90318, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:55:09', '2021-06-24 13:55:09'),
(90319, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:55:27', '2021-06-24 13:55:27'),
(90320, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__calllist/detail', '2021-06-24 13:56:10', '2021-06-24 13:56:10'),
(90321, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__calllist/detail', '2021-06-24 13:56:47', '2021-06-24 13:56:47');
INSERT INTO `t91_action_histories` (`id`, `client_ip`, `mac_addr`, `user_id`, `session_id`, `operation`, `created`, `modified`) VALUES
(90322, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 13:57:44', '2021-06-24 13:57:44'),
(90323, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 14:03:07', '2021-06-24 14:03:07'),
(90324, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 16:55:14', '2021-06-24 16:55:14'),
(90325, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__inboundtemplate/index', '2021-06-24 16:55:16', '2021-06-24 16:55:16'),
(90326, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 16:55:21', '2021-06-24 16:55:21'),
(90327, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 16:55:33', '2021-06-24 16:55:33'),
(90328, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 16:55:35', '2021-06-24 16:55:35'),
(90329, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 16:55:47', '2021-06-24 16:55:47'),
(90330, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 16:55:50', '2021-06-24 16:55:50'),
(90331, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 16:55:53', '2021-06-24 16:55:53'),
(90332, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__inboundtemplate/template', '2021-06-24 16:55:54', '2021-06-24 16:55:54'),
(90333, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/inboundtemplate', '2021-06-24 16:55:59', '2021-06-24 16:55:59'),
(90334, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__inboundtemplate/template', '2021-06-24 16:56:10', '2021-06-24 16:56:10'),
(90335, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 着信設定__inboundtemplate/index', '2021-06-24 17:01:34', '2021-06-24 17:01:34'),
(90336, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 着信拒否リスト__inboundincominghistory/index', '2021-06-24 17:01:44', '2021-06-24 17:01:44'),
(90337, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 着信リスト__inboundrestrict/index', '2021-06-24 17:01:48', '2021-06-24 17:01:48'),
(90338, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__inboundcalllist/index', '2021-06-24 17:01:49', '2021-06-24 17:01:49'),
(90339, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 着信設定__inboundtemplate/index', '2021-06-24 17:02:38', '2021-06-24 17:02:38'),
(90340, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__inboundincominghistory/index', '2021-06-24 17:02:39', '2021-06-24 17:02:39'),
(90341, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '__inboundincominghistory/index', '2021-06-24 17:07:18', '2021-06-24 17:07:18'),
(90342, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'セクションの追加__template/template', '2021-06-24 17:07:25', '2021-06-24 17:07:25'),
(90343, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '保存__template/template', '2021-06-24 17:07:36', '2021-06-24 17:07:36'),
(90344, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '更新__template/template', '2021-06-24 17:07:46', '2021-06-24 17:07:46'),
(90345, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__template/template', '2021-06-24 17:08:47', '2021-06-24 17:08:47'),
(90346, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__template/template', '2021-06-24 17:10:25', '2021-06-24 17:10:25'),
(90347, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '新規登録__outschedule/index', '2021-06-24 17:10:30', '2021-06-24 17:10:30'),
(90348, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/index', '2021-06-24 17:23:36', '2021-06-24 17:23:36'),
(90349, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__template/index', '2021-06-24 17:27:42', '2021-06-24 17:27:42'),
(90350, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' 着信設定__outschedule/index', '2021-06-24 17:41:34', '2021-06-24 17:41:34'),
(90351, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__inboundincominghistory/index', '2021-06-24 17:54:37', '2021-06-24 17:54:37'),
(90352, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__template/template', '2021-06-24 17:54:48', '2021-06-24 17:54:48'),
(90353, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__template/index', '2021-06-24 17:54:57', '2021-06-24 17:54:57'),
(90354, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__outschedule/status', '2021-06-24 17:55:14', '2021-06-24 17:55:14'),
(90355, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__outschedule/status', '2021-06-24 17:55:18', '2021-06-24 17:55:18'),
(90356, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' スケジュール__cakeerror/status', '2021-06-24 17:55:24', '2021-06-24 17:55:24'),
(90357, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '詳細__outschedule/outschedule', '2021-06-24 17:55:30', '2021-06-24 17:55:30'),
(90358, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', '×__outschedule/outschedule', '2021-06-24 17:55:31', '2021-06-24 17:55:31'),
(90359, '::1', NULL, 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', ' テンプレート__outschedule/status', '2021-06-24 17:55:35', '2021-06-24 17:55:35'),
(90360, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', ' 結果ログ一括DL__outschedule/index', '2021-06-29 12:39:23', '2021-06-29 12:39:23'),
(90361, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 12:39:29', '2021-06-29 12:39:29'),
(90362, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 12:40:42', '2021-06-29 12:40:42'),
(90363, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 12:44:55', '2021-06-29 12:44:55'),
(90364, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 13:39:18', '2021-06-29 13:39:18'),
(90365, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 13:39:25', '2021-06-29 13:39:25'),
(90366, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', ' スケジュール__downloadresult/index', '2021-06-29 15:58:17', '2021-06-29 15:58:17'),
(90367, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', ' 結果ログ一括DL__outschedule/index', '2021-06-29 16:01:07', '2021-06-29 16:01:07'),
(90368, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 16:46:48', '2021-06-29 16:46:48'),
(90369, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 16:50:06', '2021-06-29 16:50:06'),
(90370, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 16:52:49', '2021-06-29 16:52:49'),
(90371, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 16:54:02', '2021-06-29 16:54:02'),
(90372, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 16:55:33', '2021-06-29 16:55:33'),
(90373, '::1', NULL, 'fabbi', 'jsvqolgq6h5cdo4bfkp2nlhbn2', 'ダウンロード__downloadresult/downloadresult', '2021-06-29 17:52:52', '2021-06-29 17:52:52'),
(90374, '::1', NULL, 'fabbi', 'kq7cef8a2uhqc21frd56tulkg7', ' テンプレート__outschedule/index', '2021-06-30 10:45:45', '2021-06-30 10:45:45'),
(90375, '::1', NULL, 'fabbi', 'kq7cef8a2uhqc21frd56tulkg7', ' 結果ログ一括DL__template/index', '2021-06-30 10:46:10', '2021-06-30 10:46:10'),
(90376, '::1', NULL, 'fabbi', 'kq7cef8a2uhqc21frd56tulkg7', '__downloadresult/downloadresult', '2021-06-30 10:46:15', '2021-06-30 10:46:15'),
(90377, '::1', NULL, 'fabbi', 'kq7cef8a2uhqc21frd56tulkg7', 'ログアウト__downloadresult/index', '2021-06-30 10:46:16', '2021-06-30 10:46:16'),
(90378, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' ユーザー管理__outschedule/index', '2021-06-30 10:49:06', '2021-06-30 10:49:06'),
(90379, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageuser/index', '2021-06-30 10:49:10', '2021-06-30 10:49:10'),
(90380, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:49:36', '2021-06-30 10:49:36'),
(90381, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:50:12', '2021-06-30 10:50:12'),
(90382, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:50:14', '2021-06-30 10:50:14'),
(90383, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:50:14', '2021-06-30 10:50:14'),
(90384, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:50:14', '2021-06-30 10:50:14'),
(90385, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:50:14', '2021-06-30 10:50:14'),
(90386, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '選択項目を削除__manageuser/index', '2021-06-30 10:50:22', '2021-06-30 10:50:22'),
(90387, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageuser/index', '2021-06-30 10:50:24', '2021-06-30 10:50:24'),
(90388, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '×__manageuser/manageuser', '2021-06-30 10:50:32', '2021-06-30 10:50:32'),
(90389, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '×__manageuser/manageuser', '2021-06-30 10:50:42', '2021-06-30 10:50:42'),
(90390, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' アカウント管理__manageuser/index', '2021-06-30 10:50:46', '2021-06-30 10:50:46'),
(90391, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageaccount/index', '2021-06-30 10:50:50', '2021-06-30 10:50:50'),
(90392, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageaccount/index', '2021-06-30 10:51:09', '2021-06-30 10:51:09'),
(90393, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '反映__manageaccount/index', '2021-06-30 10:51:27', '2021-06-30 10:51:27'),
(90394, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageaccount/index', '2021-06-30 10:51:31', '2021-06-30 10:51:31'),
(90395, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' ユーザー管理__manageaccount/index', '2021-06-30 10:51:33', '2021-06-30 10:51:33'),
(90396, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageuser/index', '2021-06-30 10:51:34', '2021-06-30 10:51:34'),
(90397, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '×__manageuser/manageuser', '2021-06-30 10:51:44', '2021-06-30 10:51:44'),
(90398, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' アカウント管理__manageuser/index', '2021-06-30 10:51:51', '2021-06-30 10:51:51'),
(90399, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' テンプレート__manageaccount/index', '2021-06-30 10:51:53', '2021-06-30 10:51:53'),
(90400, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' ユーザー管理__smstemplate/index', '2021-06-30 10:51:59', '2021-06-30 10:51:59'),
(90401, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '新規登録__manageuser/index', '2021-06-30 10:52:01', '2021-06-30 10:52:01'),
(90402, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '×__manageuser/manageuser', '2021-06-30 10:52:05', '2021-06-30 10:52:05'),
(90403, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' アカウント管理__manageuser/index', '2021-06-30 10:52:11', '2021-06-30 10:52:11'),
(90404, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', ' ユーザー管理__manageaccount/index', '2021-06-30 10:52:22', '2021-06-30 10:52:22'),
(90405, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '保存__manageuser/index', '2021-06-30 10:52:30', '2021-06-30 10:52:30'),
(90406, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', '×__manageuser/manageuser', '2021-06-30 10:53:33', '2021-06-30 10:53:33'),
(90407, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', 'fabbi__manageuser/manageuser', '2021-06-30 10:53:36', '2021-06-30 10:53:36'),
(90408, '::1', NULL, 'fabbi', '0ak5octd0l1q5gua9os65u8pi6', 'ログアウト__manageuser/index', '2021-06-30 10:53:37', '2021-06-30 10:53:37'),
(90409, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', ' メニュー管理__outschedule/index', '2021-06-30 10:56:05', '2021-06-30 10:56:05'),
(90410, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', ' ユーザー管理__managemenu/index', '2021-06-30 10:56:12', '2021-06-30 10:56:12'),
(90411, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', '新規登録__manageuser/index', '2021-06-30 10:56:16', '2021-06-30 10:56:16'),
(90412, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', '×__manageuser/manageuser', '2021-06-30 10:56:46', '2021-06-30 10:56:46'),
(90413, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', 'fabbi__manageuser/manageuser', '2021-06-30 10:56:50', '2021-06-30 10:56:50'),
(90414, '::1', NULL, 'fabbi', 'emi4hf5ujtfl9d3p808oq4na92', 'ログアウト__manageuser/index', '2021-06-30 10:56:52', '2021-06-30 10:56:52'),
(90415, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' ユーザー管理__outschedule/index', '2021-06-30 10:57:00', '2021-06-30 10:57:00'),
(90416, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__manageuser/index', '2021-06-30 10:57:02', '2021-06-30 10:57:02'),
(90417, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__manageuser/index', '2021-06-30 10:57:23', '2021-06-30 10:57:23'),
(90418, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' スケジュール__manageuser/index', '2021-06-30 10:57:33', '2021-06-30 10:57:33'),
(90419, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' ユーザー管理__smsschedule/index', '2021-06-30 10:57:38', '2021-06-30 10:57:38'),
(90420, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__manageuser/index', '2021-06-30 10:57:42', '2021-06-30 10:57:42'),
(90421, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__manageuser/index', '2021-06-30 10:58:02', '2021-06-30 10:58:02'),
(90422, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' テンプレート__manageuser/index', '2021-06-30 10:59:15', '2021-06-30 10:59:15'),
(90423, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__template/index', '2021-06-30 10:59:22', '2021-06-30 10:59:22'),
(90424, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'セクションの追加__template/template', '2021-06-30 10:59:34', '2021-06-30 10:59:34'),
(90425, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__template/template', '2021-06-30 10:59:41', '2021-06-30 10:59:41'),
(90426, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'セクションの追加__template/template', '2021-06-30 10:59:42', '2021-06-30 10:59:42'),
(90427, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__template/template', '2021-06-30 10:59:49', '2021-06-30 10:59:49'),
(90428, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'セクションの追加__template/template', '2021-06-30 10:59:51', '2021-06-30 10:59:51'),
(90429, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '×__template/template', '2021-06-30 10:59:53', '2021-06-30 10:59:53'),
(90430, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__template/template', '2021-06-30 10:59:53', '2021-06-30 10:59:53'),
(90431, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' 発信NGリスト__template/index', '2021-06-30 10:59:56', '2021-06-30 10:59:56'),
(90432, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' 発信リスト__calllistng/index', '2021-06-30 10:59:57', '2021-06-30 10:59:57'),
(90433, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__calllist/index', '2021-06-30 10:59:59', '2021-06-30 10:59:59'),
(90434, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ファイルを選択__calllist/index', '2021-06-30 11:00:00', '2021-06-30 11:00:00'),
(90435, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '保存__calllist/index', '2021-06-30 11:00:13', '2021-06-30 11:00:13'),
(90436, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__calllist/index', '2021-06-30 11:00:23', '2021-06-30 11:00:23'),
(90437, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ファイルを選択__calllist/index', '2021-06-30 11:00:24', '2021-06-30 11:00:24'),
(90438, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ファイルを選択__calllist/index', '2021-06-30 11:00:37', '2021-06-30 11:00:37'),
(90439, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '×__calllist/calllist', '2021-06-30 11:00:55', '2021-06-30 11:00:55'),
(90440, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' 結果ログ一括DL__calllist/index', '2021-06-30 11:01:04', '2021-06-30 11:01:04'),
(90441, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' 着信設定__downloadresult/index', '2021-06-30 11:01:27', '2021-06-30 11:01:27'),
(90442, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', '新規登録__inboundincominghistory/index', '2021-06-30 11:01:29', '2021-06-30 11:01:29'),
(90443, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' アカウント管理__inboundincominghistory/index', '2021-06-30 11:02:06', '2021-06-30 11:02:06'),
(90444, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' ユーザー管理__manageaccount/index', '2021-06-30 11:02:10', '2021-06-30 11:02:10'),
(90445, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', ' 結果ログ一括DL__manageuser/index', '2021-06-30 11:02:21', '2021-06-30 11:02:21'),
(90446, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:08:39', '2021-06-30 11:08:39'),
(90447, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:09:29', '2021-06-30 11:09:29'),
(90448, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:10:05', '2021-06-30 11:10:05'),
(90449, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:10:56', '2021-06-30 11:10:56'),
(90450, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:13:44', '2021-06-30 11:13:44'),
(90451, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 11:23:53', '2021-06-30 11:23:53'),
(90452, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:05:15', '2021-06-30 12:05:15'),
(90453, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:28:54', '2021-06-30 12:28:54'),
(90454, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:29:33', '2021-06-30 12:29:33'),
(90455, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:30:21', '2021-06-30 12:30:21'),
(90456, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:30:28', '2021-06-30 12:30:28'),
(90457, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:58:43', '2021-06-30 12:58:43'),
(90458, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 12:58:52', '2021-06-30 12:58:52'),
(90459, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:05:54', '2021-06-30 13:05:54'),
(90460, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:06:26', '2021-06-30 13:06:26'),
(90461, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:07:12', '2021-06-30 13:07:12'),
(90462, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:07:21', '2021-06-30 13:07:21'),
(90463, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:26:08', '2021-06-30 13:26:08'),
(90464, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:27:02', '2021-06-30 13:27:02'),
(90465, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:36:13', '2021-06-30 13:36:13'),
(90466, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 13:42:53', '2021-06-30 13:42:53'),
(90467, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:09:47', '2021-06-30 16:09:47'),
(90468, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:10:10', '2021-06-30 16:10:10'),
(90469, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:15:24', '2021-06-30 16:15:24'),
(90470, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:16:33', '2021-06-30 16:16:33'),
(90471, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:20:07', '2021-06-30 16:20:07'),
(90472, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:21:58', '2021-06-30 16:21:58'),
(90473, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:22:28', '2021-06-30 16:22:28'),
(90474, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:27:56', '2021-06-30 16:27:56'),
(90475, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:29:09', '2021-06-30 16:29:09'),
(90476, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:29:23', '2021-06-30 16:29:23'),
(90477, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:31:21', '2021-06-30 16:31:21'),
(90478, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:32:17', '2021-06-30 16:32:17'),
(90479, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:32:53', '2021-06-30 16:32:53'),
(90480, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:40:42', '2021-06-30 16:40:42'),
(90481, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:41:31', '2021-06-30 16:41:31'),
(90482, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:44:04', '2021-06-30 16:44:04'),
(90483, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:44:46', '2021-06-30 16:44:46'),
(90484, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:51:49', '2021-06-30 16:51:49'),
(90485, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:53:54', '2021-06-30 16:53:54'),
(90486, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 16:57:10', '2021-06-30 16:57:10'),
(90487, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 17:05:46', '2021-06-30 17:05:46'),
(90488, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 17:06:11', '2021-06-30 17:06:11'),
(90489, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 17:07:33', '2021-06-30 17:07:33'),
(90490, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 17:08:27', '2021-06-30 17:08:27'),
(90491, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:06:42', '2021-06-30 18:06:42'),
(90492, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:18:20', '2021-06-30 18:18:20'),
(90493, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:22:11', '2021-06-30 18:22:11'),
(90494, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:22:47', '2021-06-30 18:22:47'),
(90495, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:25:04', '2021-06-30 18:25:04'),
(90496, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:37:01', '2021-06-30 18:37:01'),
(90497, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:39:28', '2021-06-30 18:39:28'),
(90498, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:40:15', '2021-06-30 18:40:15'),
(90499, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:42:10', '2021-06-30 18:42:10'),
(90500, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:46:06', '2021-06-30 18:46:06'),
(90501, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:46:43', '2021-06-30 18:46:43'),
(90502, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:48:30', '2021-06-30 18:48:30'),
(90503, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:48:58', '2021-06-30 18:48:58'),
(90504, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:50:18', '2021-06-30 18:50:18'),
(90505, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:50:42', '2021-06-30 18:50:42'),
(90506, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:52:21', '2021-06-30 18:52:21'),
(90507, '::1', NULL, 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'ダウンロード__downloadresult/downloadresult', '2021-06-30 18:52:34', '2021-06-30 18:52:34'),
(90508, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', ' 結果ログ一括DL__outschedule/index', '2021-07-01 10:48:40', '2021-07-01 10:48:40'),
(90509, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 10:59:08', '2021-07-01 10:59:08'),
(90510, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:06:45', '2021-07-01 11:06:45'),
(90511, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:06:47', '2021-07-01 11:06:47'),
(90512, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:06:47', '2021-07-01 11:06:47'),
(90513, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:06:48', '2021-07-01 11:06:48'),
(90514, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:06:48', '2021-07-01 11:06:48'),
(90515, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', '__', '2021-07-01 11:06:58', '2021-07-01 11:06:58'),
(90516, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:07:09', '2021-07-01 11:07:09'),
(90517, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:07:44', '2021-07-01 11:07:44'),
(90518, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:11:48', '2021-07-01 11:11:48'),
(90519, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:12:43', '2021-07-01 11:12:43'),
(90520, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:31:10', '2021-07-01 11:31:10'),
(90521, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:31:13', '2021-07-01 11:31:13'),
(90522, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:33:47', '2021-07-01 11:33:47'),
(90523, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:33:49', '2021-07-01 11:33:49'),
(90524, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:35:21', '2021-07-01 11:35:21'),
(90525, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:35:41', '2021-07-01 11:35:41'),
(90526, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:37:32', '2021-07-01 11:37:32'),
(90527, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:37:52', '2021-07-01 11:37:52'),
(90528, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:38:39', '2021-07-01 11:38:39'),
(90529, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:39:05', '2021-07-01 11:39:05'),
(90530, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:39:15', '2021-07-01 11:39:15'),
(90531, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:39:52', '2021-07-01 11:39:52'),
(90532, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:40:22', '2021-07-01 11:40:22'),
(90533, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:41:16', '2021-07-01 11:41:16'),
(90534, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:41:59', '2021-07-01 11:41:59'),
(90535, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:55:35', '2021-07-01 11:55:35'),
(90536, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:56:32', '2021-07-01 11:56:32'),
(90537, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:57:37', '2021-07-01 11:57:37'),
(90538, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:58:40', '2021-07-01 11:58:40'),
(90539, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:58:54', '2021-07-01 11:58:54'),
(90540, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 11:59:36', '2021-07-01 11:59:36'),
(90541, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:00:15', '2021-07-01 12:00:15'),
(90542, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:02:52', '2021-07-01 12:02:52'),
(90543, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:11:39', '2021-07-01 12:11:39'),
(90544, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', ' テンプレート__downloadresult/index', '2021-07-01 12:11:57', '2021-07-01 12:11:57'),
(90545, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', ' 結果ログ一括DL__template/index', '2021-07-01 12:15:47', '2021-07-01 12:15:47'),
(90546, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:15:52', '2021-07-01 12:15:52'),
(90547, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:16:47', '2021-07-01 12:16:47'),
(90548, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:19:00', '2021-07-01 12:19:00'),
(90549, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:21:00', '2021-07-01 12:21:00'),
(90550, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:21:19', '2021-07-01 12:21:19'),
(90551, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:39:54', '2021-07-01 12:39:54'),
(90552, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:39:56', '2021-07-01 12:39:56'),
(90553, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:39:58', '2021-07-01 12:39:58'),
(90554, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:52:39', '2021-07-01 12:52:39'),
(90555, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 12:58:54', '2021-07-01 12:58:54'),
(90556, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:13:28', '2021-07-01 13:13:28'),
(90557, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:13:42', '2021-07-01 13:13:42'),
(90558, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:16:31', '2021-07-01 13:16:31'),
(90559, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:16:41', '2021-07-01 13:16:41'),
(90560, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:16:59', '2021-07-01 13:16:59'),
(90561, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:19:53', '2021-07-01 13:19:53'),
(90562, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:20:44', '2021-07-01 13:20:44'),
(90563, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:21:21', '2021-07-01 13:21:21'),
(90564, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:23:02', '2021-07-01 13:23:02'),
(90565, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:23:26', '2021-07-01 13:23:26'),
(90566, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:27:13', '2021-07-01 13:27:13'),
(90567, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:27:45', '2021-07-01 13:27:45'),
(90568, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:28:32', '2021-07-01 13:28:32'),
(90569, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:29:54', '2021-07-01 13:29:54'),
(90570, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:30:43', '2021-07-01 13:30:43'),
(90571, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:31:04', '2021-07-01 13:31:04'),
(90572, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:36:21', '2021-07-01 13:36:21'),
(90573, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:37:54', '2021-07-01 13:37:54'),
(90574, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:38:18', '2021-07-01 13:38:18'),
(90575, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:39:28', '2021-07-01 13:39:28'),
(90576, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:39:41', '2021-07-01 13:39:41'),
(90577, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:39:52', '2021-07-01 13:39:52'),
(90578, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:40:00', '2021-07-01 13:40:00'),
(90579, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 13:40:03', '2021-07-01 13:40:03'),
(90580, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:08:41', '2021-07-01 16:08:41'),
(90581, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:08:47', '2021-07-01 16:08:47'),
(90582, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:09:00', '2021-07-01 16:09:00'),
(90583, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:13:59', '2021-07-01 16:13:59'),
(90584, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:14:12', '2021-07-01 16:14:12'),
(90585, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:14:32', '2021-07-01 16:14:32'),
(90586, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:17:02', '2021-07-01 16:17:02'),
(90587, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:21:39', '2021-07-01 16:21:39'),
(90588, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:30:43', '2021-07-01 16:30:43'),
(90589, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:36:28', '2021-07-01 16:36:28'),
(90590, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:45:44', '2021-07-01 16:45:44'),
(90591, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:51:35', '2021-07-01 16:51:35'),
(90592, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:52:42', '2021-07-01 16:52:42'),
(90593, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 16:55:59', '2021-07-01 16:55:59'),
(90594, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:45:27', '2021-07-01 17:45:27'),
(90595, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:46:12', '2021-07-01 17:46:12'),
(90596, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:46:30', '2021-07-01 17:46:30'),
(90597, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:47:03', '2021-07-01 17:47:03'),
(90598, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:49:42', '2021-07-01 17:49:42'),
(90599, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:50:30', '2021-07-01 17:50:30'),
(90600, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:50:39', '2021-07-01 17:50:39'),
(90601, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:50:47', '2021-07-01 17:50:47'),
(90602, '::1', NULL, 'fabbi', '7edc9et842jn6gb6eg5hrcm9m7', 'ダウンロード__downloadresult/downloadresult', '2021-07-01 17:51:28', '2021-07-01 17:51:28'),
(90603, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', ' 結果ログ一括DL__outschedule/index', '2021-07-02 10:40:29', '2021-07-02 10:40:29'),
(90604, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 10:40:33', '2021-07-02 10:40:33'),
(90605, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 13:25:56', '2021-07-02 13:25:56'),
(90606, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 13:27:02', '2021-07-02 13:27:02'),
(90607, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 13:28:14', '2021-07-02 13:28:14'),
(90608, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:27:21', '2021-07-02 16:27:21'),
(90609, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:28:18', '2021-07-02 16:28:18'),
(90610, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:29:41', '2021-07-02 16:29:41'),
(90611, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:30:26', '2021-07-02 16:30:26'),
(90612, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:41:09', '2021-07-02 16:41:09'),
(90613, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:42:46', '2021-07-02 16:42:46'),
(90614, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:43:49', '2021-07-02 16:43:49'),
(90615, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:44:13', '2021-07-02 16:44:13'),
(90616, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:44:59', '2021-07-02 16:44:59'),
(90617, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:45:36', '2021-07-02 16:45:36'),
(90618, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:46:57', '2021-07-02 16:46:57'),
(90619, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 16:59:31', '2021-07-02 16:59:31'),
(90620, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 17:07:33', '2021-07-02 17:07:33'),
(90621, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 18:10:32', '2021-07-02 18:10:32'),
(90622, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 18:31:57', '2021-07-02 18:31:57'),
(90623, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', ' テンプレート__downloadresult/index', '2021-07-02 18:57:07', '2021-07-02 18:57:07'),
(90624, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', ' メニュー管理__template/index', '2021-07-02 19:03:09', '2021-07-02 19:03:09'),
(90625, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', ' 結果ログ一括DL__managemenu/index', '2021-07-02 19:03:13', '2021-07-02 19:03:13'),
(90626, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 19:03:17', '2021-07-02 19:03:17'),
(90627, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', 'ダウンロード__downloadresult/downloadresult', '2021-07-02 19:07:46', '2021-07-02 19:07:46'),
(90628, '::1', NULL, 'fabbi', '75f4mhqhhn15ur934lgtkdm045', ' テンプレート__downloadresult/index', '2021-07-02 19:33:07', '2021-07-02 19:33:07'),
(90629, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', ' 結果ログ一括DL__outschedule/index', '2021-07-05 11:20:04', '2021-07-05 11:20:04'),
(90630, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 11:20:08', '2021-07-05 11:20:08'),
(90631, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 11:21:10', '2021-07-05 11:21:10'),
(90632, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 11:38:56', '2021-07-05 11:38:56'),
(90633, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:11:34', '2021-07-05 12:11:34'),
(90634, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:12:27', '2021-07-05 12:12:27'),
(90635, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:13:38', '2021-07-05 12:13:38'),
(90636, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:14:28', '2021-07-05 12:14:28'),
(90637, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:15:00', '2021-07-05 12:15:00'),
(90638, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ダウンロード__downloadresult/downloadresult', '2021-07-05 12:15:31', '2021-07-05 12:15:31'),
(90639, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', ' 発信リスト__downloadresult/index', '2021-07-05 16:17:10', '2021-07-05 16:17:10'),
(90640, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', ' テンプレート__calllist/index', '2021-07-05 16:17:12', '2021-07-05 16:17:12'),
(90641, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'fabbi__template/template', '2021-07-05 18:12:09', '2021-07-05 18:12:09'),
(90642, '::1', NULL, 'fabbi', 'hstd144uq3d3l0moj1c4ml86m6', 'ログアウト__template/index', '2021-07-05 18:12:10', '2021-07-05 18:12:10'),
(90643, '::1', NULL, '1221978', '53gvtfta8k5l1b919d7gab18o1', ' テンプレート__outschedule/index', '2021-07-05 22:26:27', '2021-07-05 22:26:27'),
(90644, '::1', NULL, '1221978', '53gvtfta8k5l1b919d7gab18o1', ' 発信リスト__template/index', '2021-07-05 22:26:29', '2021-07-05 22:26:29'),
(90645, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', ' 結果ログ一括DL__outschedule/index', '2021-07-06 17:24:41', '2021-07-06 17:24:41'),
(90646, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 17:24:59', '2021-07-06 17:24:59'),
(90647, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 18:18:15', '2021-07-06 18:18:15'),
(90648, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 18:20:32', '2021-07-06 18:20:32'),
(90649, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 19:03:21', '2021-07-06 19:03:21'),
(90650, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 19:29:44', '2021-07-06 19:29:44'),
(90651, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 19:29:55', '2021-07-06 19:29:55'),
(90652, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 19:30:39', '2021-07-06 19:30:39'),
(90653, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 20:51:42', '2021-07-06 20:51:42'),
(90654, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 20:51:54', '2021-07-06 20:51:54'),
(90655, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 20:52:21', '2021-07-06 20:52:21'),
(90656, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 21:51:23', '2021-07-06 21:51:23'),
(90657, '::1', NULL, 'fabbi', 'didcj4oedosa23bum4kp7lccq1', 'ダウンロード__downloadresult/downloadresult', '2021-07-06 23:10:32', '2021-07-06 23:10:32'),
(90658, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', ' 結果ログ一括DL__outschedule/index', '2021-07-07 16:47:07', '2021-07-07 16:47:07'),
(90659, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 16:47:20', '2021-07-07 16:47:20'),
(90660, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 19:53:19', '2021-07-07 19:53:19'),
(90661, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 19:53:28', '2021-07-07 19:53:28'),
(90662, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 19:56:48', '2021-07-07 19:56:48'),
(90663, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:00:38', '2021-07-07 20:00:38'),
(90664, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:01:30', '2021-07-07 20:01:30'),
(90665, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:02:49', '2021-07-07 20:02:49'),
(90666, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:03:39', '2021-07-07 20:03:39'),
(90667, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:04:48', '2021-07-07 20:04:48'),
(90668, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:05:27', '2021-07-07 20:05:27'),
(90669, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:05:58', '2021-07-07 20:05:58'),
(90670, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:08:50', '2021-07-07 20:08:50'),
(90671, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 20:09:34', '2021-07-07 20:09:34'),
(90672, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:16:39', '2021-07-07 21:16:39');
INSERT INTO `t91_action_histories` (`id`, `client_ip`, `mac_addr`, `user_id`, `session_id`, `operation`, `created`, `modified`) VALUES
(90673, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:16:45', '2021-07-07 21:16:45'),
(90674, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:16:54', '2021-07-07 21:16:54'),
(90675, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:16:57', '2021-07-07 21:16:57'),
(90676, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:23:35', '2021-07-07 21:23:35'),
(90677, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:23:40', '2021-07-07 21:23:40'),
(90678, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:23:50', '2021-07-07 21:23:50'),
(90679, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:23:56', '2021-07-07 21:23:56'),
(90680, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:26:06', '2021-07-07 21:26:06'),
(90681, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:27:13', '2021-07-07 21:27:13'),
(90682, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:28:36', '2021-07-07 21:28:36'),
(90683, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:28:51', '2021-07-07 21:28:51'),
(90684, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:29:13', '2021-07-07 21:29:13'),
(90685, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', ' 結果ログ一括DL__downloadresult/index', '2021-07-07 21:30:03', '2021-07-07 21:30:03'),
(90686, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:30:08', '2021-07-07 21:30:08'),
(90687, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:30:21', '2021-07-07 21:30:21'),
(90688, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:30:47', '2021-07-07 21:30:47'),
(90689, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:30:51', '2021-07-07 21:30:51'),
(90690, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:30:56', '2021-07-07 21:30:56'),
(90691, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:31:45', '2021-07-07 21:31:45'),
(90692, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:32:46', '2021-07-07 21:32:46'),
(90693, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:33:39', '2021-07-07 21:33:39'),
(90694, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:34:50', '2021-07-07 21:34:50'),
(90695, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:35:18', '2021-07-07 21:35:18'),
(90696, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:35:58', '2021-07-07 21:35:58'),
(90697, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:37:05', '2021-07-07 21:37:05'),
(90698, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:38:35', '2021-07-07 21:38:35'),
(90699, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:38:43', '2021-07-07 21:38:43'),
(90700, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:39:20', '2021-07-07 21:39:20'),
(90701, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:39:24', '2021-07-07 21:39:24'),
(90702, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 21:39:28', '2021-07-07 21:39:28'),
(90703, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 22:19:05', '2021-07-07 22:19:05'),
(90704, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 22:19:11', '2021-07-07 22:19:11'),
(90705, '::1', NULL, 'fabbi', 'nl9mou3u127v748vlupv491td5', 'ダウンロード__downloadresult/downloadresult', '2021-07-07 22:19:15', '2021-07-07 22:19:15'),
(90706, '::1', NULL, 'fabbi', 'j1609lui3dlfkb1seoeoicdph6', ' 結果ログ一括DL__outschedule/index', '2021-07-08 11:44:28', '2021-07-08 11:44:28'),
(90707, '::1', NULL, 'fabbi', 'j1609lui3dlfkb1seoeoicdph6', 'ダウンロード__downloadresult/downloadresult', '2021-07-08 12:40:58', '2021-07-08 12:40:58'),
(90708, '::1', NULL, 'fabbi', 'j1609lui3dlfkb1seoeoicdph6', 'ダウンロード__downloadresult/downloadresult', '2021-07-08 17:02:37', '2021-07-08 17:02:37'),
(90709, '::1', NULL, 'fabbi', 'j1609lui3dlfkb1seoeoicdph6', 'ダウンロード__downloadresult/downloadresult', '2021-07-08 17:15:04', '2021-07-08 17:15:04'),
(90710, '::1', NULL, 'fabbi', 'j1609lui3dlfkb1seoeoicdph6', 'ダウンロード__downloadresult/downloadresult', '2021-07-08 17:47:11', '2021-07-08 17:47:11'),
(90711, '::1', NULL, 'fabbi', 'tmn3dssb8qlhp0p67mls6b5o84', ' 結果ログ一括DL__outschedule/index', '2021-07-09 11:01:05', '2021-07-09 11:01:05'),
(90712, '::1', NULL, 'fabbi', 'tmn3dssb8qlhp0p67mls6b5o84', 'ダウンロード__downloadresult/downloadresult', '2021-07-09 11:01:09', '2021-07-09 11:01:09'),
(90713, '::1', NULL, 'fabbi', 'tmn3dssb8qlhp0p67mls6b5o84', 'ダウンロード__downloadresult/downloadresult', '2021-07-09 11:01:36', '2021-07-09 11:01:36'),
(90714, '::1', NULL, 'fabbi', 'tmn3dssb8qlhp0p67mls6b5o84', '\n			fabbi\n			\n		__downloadresult/downloadresult', '2021-07-09 16:26:35', '2021-07-09 16:26:35'),
(90715, '::1', NULL, 'fabbi', 'tmn3dssb8qlhp0p67mls6b5o84', 'ログアウト__downloadresult/index', '2021-07-09 16:26:36', '2021-07-09 16:26:36'),
(90716, '::1', NULL, 'fabbi', 'hh87s3l1sjg7s0buena44ncha7', ' 結果ログ一括DL__outschedule/index', '2021-07-09 16:27:26', '2021-07-09 16:27:26'),
(90717, '::1', NULL, 'fabbi', 'hh87s3l1sjg7s0buena44ncha7', 'ダウンロード__downloadresult/downloadresult', '2021-07-09 16:28:44', '2021-07-09 16:28:44'),
(90718, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', ' テンプレート__outschedule/index', '2021-07-12 12:55:47', '2021-07-12 12:55:47'),
(90719, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', '新規登録__template/index', '2021-07-12 12:55:52', '2021-07-12 12:55:52'),
(90720, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', 'セクションの追加__template/template', '2021-07-12 12:55:53', '2021-07-12 12:55:53'),
(90721, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', '保存__template/template', '2021-07-12 12:55:59', '2021-07-12 12:55:59'),
(90722, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', '保存__template/template', '2021-07-12 12:56:02', '2021-07-12 12:56:02'),
(90723, '::1', NULL, 'fabbi', 'k3t6lu4djiohnns2c23ucq2e83', '選択項目を削除__template/index', '2021-07-12 12:56:07', '2021-07-12 12:56:07'),
(90724, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', ' 結果ログ一括DL__outschedule/index', '2021-07-13 18:24:40', '2021-07-13 18:24:40'),
(90725, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:24:46', '2021-07-13 18:24:46'),
(90726, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:46:30', '2021-07-13 18:46:30'),
(90727, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:49:27', '2021-07-13 18:49:27'),
(90728, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:50:16', '2021-07-13 18:50:16'),
(90729, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:51:38', '2021-07-13 18:51:38'),
(90730, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:53:52', '2021-07-13 18:53:52'),
(90731, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:54:57', '2021-07-13 18:54:57'),
(90732, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:55:26', '2021-07-13 18:55:26'),
(90733, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:57:11', '2021-07-13 18:57:11'),
(90734, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:57:42', '2021-07-13 18:57:42'),
(90735, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:57:43', '2021-07-13 18:57:43'),
(90736, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:57:44', '2021-07-13 18:57:44'),
(90737, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:57:44', '2021-07-13 18:57:44'),
(90738, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:58:34', '2021-07-13 18:58:34'),
(90739, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 18:58:36', '2021-07-13 18:58:36'),
(90740, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:00', '2021-07-13 19:00:00'),
(90741, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:06', '2021-07-13 19:00:06'),
(90742, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:10', '2021-07-13 19:00:10'),
(90743, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:11', '2021-07-13 19:00:11'),
(90744, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:15', '2021-07-13 19:00:15'),
(90745, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:00:17', '2021-07-13 19:00:17'),
(90746, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:03:28', '2021-07-13 19:03:28'),
(90747, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:52:07', '2021-07-13 19:52:07'),
(90748, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:52:27', '2021-07-13 19:52:27'),
(90749, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:52:57', '2021-07-13 19:52:57'),
(90750, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:53:09', '2021-07-13 19:53:09'),
(90751, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 19:53:15', '2021-07-13 19:53:15'),
(90752, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 21:43:30', '2021-07-13 21:43:30'),
(90753, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 21:43:42', '2021-07-13 21:43:42'),
(90754, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 21:43:46', '2021-07-13 21:43:46'),
(90755, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:27:17', '2021-07-13 22:27:17'),
(90756, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:27:19', '2021-07-13 22:27:19'),
(90757, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:28:31', '2021-07-13 22:28:31'),
(90758, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:28:35', '2021-07-13 22:28:35'),
(90759, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:28:39', '2021-07-13 22:28:39'),
(90760, '::1', NULL, 'fabbi', 'b16d5a1coi1mdamufqt3mudl05', 'ダウンロード__downloadresult/downloadresult', '2021-07-13 22:44:08', '2021-07-13 22:44:08'),
(90761, '::1', NULL, 'fabbi', '41lrr03oju3k4cdqrk1se478r3', ' 結果ログ一括DL__outschedule/index', '2021-07-16 12:05:04', '2021-07-16 12:05:04'),
(90762, '::1', NULL, 'fabbi', '41lrr03oju3k4cdqrk1se478r3', 'ダウンロード__downloadresult/downloadresult', '2021-07-16 12:05:08', '2021-07-16 12:05:08'),
(90763, '::1', NULL, 'fabbi', '41lrr03oju3k4cdqrk1se478r3', 'ダウンロード__downloadresult/downloadresult', '2021-07-16 12:05:24', '2021-07-16 12:05:24'),
(90764, '::1', NULL, 'fabbi', '41lrr03oju3k4cdqrk1se478r3', 'ダウンロード__downloadresult/downloadresult', '2021-07-16 12:05:31', '2021-07-16 12:05:31'),
(90765, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', ' 結果ログ一括DL__outschedule/index', '2021-07-19 16:16:17', '2021-07-19 16:16:17'),
(90766, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 16:28:11', '2021-07-19 16:28:11'),
(90767, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 16:28:20', '2021-07-19 16:28:20'),
(90768, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 16:29:30', '2021-07-19 16:29:30'),
(90769, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 17:13:23', '2021-07-19 17:13:23'),
(90770, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 17:13:29', '2021-07-19 17:13:29'),
(90771, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 17:13:31', '2021-07-19 17:13:31'),
(90772, '::1', NULL, 'fabbi', '0rhhffqjdh5u4qnsjk4g9koeg1', 'ダウンロード__downloadresult/downloadresult', '2021-07-19 17:14:41', '2021-07-19 17:14:41'),
(90773, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' メニュー管理__outschedule/index', '2021-07-20 15:53:12', '2021-07-20 15:53:12'),
(90774, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' 結果ログ一括DL__managemenu/index', '2021-07-20 15:53:14', '2021-07-20 15:53:14'),
(90775, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:47:18', '2021-07-20 16:47:18'),
(90776, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:47:55', '2021-07-20 16:47:55'),
(90777, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:48:06', '2021-07-20 16:48:06'),
(90778, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:48:22', '2021-07-20 16:48:22'),
(90779, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:49:25', '2021-07-20 16:49:25'),
(90780, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:49:39', '2021-07-20 16:49:39'),
(90781, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:49:45', '2021-07-20 16:49:45'),
(90782, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:50:06', '2021-07-20 16:50:06'),
(90783, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:53:19', '2021-07-20 16:53:19'),
(90784, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:53:27', '2021-07-20 16:53:27'),
(90785, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:53:41', '2021-07-20 16:53:41'),
(90786, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 16:54:52', '2021-07-20 16:54:52'),
(90787, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:06:10', '2021-07-20 18:06:10'),
(90788, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:06:22', '2021-07-20 18:06:22'),
(90789, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:06:40', '2021-07-20 18:06:40'),
(90790, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:07:27', '2021-07-20 18:07:27'),
(90791, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:29:05', '2021-07-20 18:29:05'),
(90792, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:29:37', '2021-07-20 18:29:37'),
(90793, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:29:51', '2021-07-20 18:29:51'),
(90794, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:29:58', '2021-07-20 18:29:58'),
(90795, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:40:12', '2021-07-20 18:40:12'),
(90796, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:41:38', '2021-07-20 18:41:38'),
(90797, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:41:44', '2021-07-20 18:41:44'),
(90798, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:46:50', '2021-07-20 18:46:50'),
(90799, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' スケジュール__downloadresult/index', '2021-07-20 18:49:56', '2021-07-20 18:49:56'),
(90800, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' 結果ログ一括DL__outschedule/index', '2021-07-20 18:50:35', '2021-07-20 18:50:35'),
(90801, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' スケジュール__downloadresult/index', '2021-07-20 18:50:54', '2021-07-20 18:50:54'),
(90802, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', ' 結果ログ一括DL__outschedule/index', '2021-07-20 18:58:07', '2021-07-20 18:58:07'),
(90803, '::1', NULL, 'fabbi', 'v0i5ib7titc7j2unk976s3ogm0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 18:58:18', '2021-07-20 18:58:18'),
(90804, '::1', NULL, 'fabbi02', '28nr486a05709oioe9rvamphp1', ' スケジュール__outschedule/index', '2021-07-20 19:07:41', '2021-07-20 19:07:41'),
(90805, '::1', NULL, 'fabbi02', '28nr486a05709oioe9rvamphp1', ' テンプレート__smsschedule/index', '2021-07-20 19:07:55', '2021-07-20 19:07:55'),
(90806, '::1', NULL, 'fabbi02', '28nr486a05709oioe9rvamphp1', ' 発信リスト__template/index', '2021-07-20 19:07:59', '2021-07-20 19:07:59'),
(90807, '::1', NULL, 'fabbi02', '28nr486a05709oioe9rvamphp1', 'fabbi02__calllist/calllist', '2021-07-20 19:08:19', '2021-07-20 19:08:19'),
(90808, '::1', NULL, 'fabbi', 'c3l34lh8ie95escgnhqcdpjcp0', ' 結果ログ一括DL__outschedule/index', '2021-07-20 19:08:43', '2021-07-20 19:08:43'),
(90809, '::1', NULL, 'fabbi', 'c3l34lh8ie95escgnhqcdpjcp0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 19:08:54', '2021-07-20 19:08:54'),
(90810, '::1', NULL, 'fabbi', 'c3l34lh8ie95escgnhqcdpjcp0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 19:14:10', '2021-07-20 19:14:10'),
(90811, '::1', NULL, 'fabbi', 'c3l34lh8ie95escgnhqcdpjcp0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 19:18:44', '2021-07-20 19:18:44'),
(90812, '::1', NULL, 'fabbi', 'c3l34lh8ie95escgnhqcdpjcp0', 'ダウンロード__downloadresult/downloadresult', '2021-07-20 19:36:34', '2021-07-20 19:36:34'),
(90813, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', ' 結果ログ一括DL__outschedule/index', '2021-07-21 10:52:02', '2021-07-21 10:52:02'),
(90814, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:52:07', '2021-07-21 10:52:07'),
(90815, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:56:14', '2021-07-21 10:56:14'),
(90816, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:56:40', '2021-07-21 10:56:40'),
(90817, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:57:01', '2021-07-21 10:57:01'),
(90818, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:57:24', '2021-07-21 10:57:24'),
(90819, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:57:47', '2021-07-21 10:57:47'),
(90820, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:58:14', '2021-07-21 10:58:14'),
(90821, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 10:59:04', '2021-07-21 10:59:04'),
(90822, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'fabbi__downloadresult/downloadresult', '2021-07-21 11:06:30', '2021-07-21 11:06:30'),
(90823, '::1', NULL, 'fabbi', 'gmi1h82d5r1u3rdvudt899ics5', 'ログアウト__downloadresult/index', '2021-07-21 11:06:31', '2021-07-21 11:06:31'),
(90824, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', ' 結果ログ一括DL__outschedule/index', '2021-07-21 11:06:47', '2021-07-21 11:06:47'),
(90825, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 11:06:58', '2021-07-21 11:06:58'),
(90826, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 11:07:07', '2021-07-21 11:07:07'),
(90827, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 11:07:13', '2021-07-21 11:07:13'),
(90828, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 11:07:22', '2021-07-21 11:07:22'),
(90829, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 11:09:54', '2021-07-21 11:09:54'),
(90830, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'fabbi__passwordchange/passwordchange', '2021-07-21 12:50:12', '2021-07-21 12:50:12'),
(90831, '::1', NULL, 'fabbi', 'fh298u3gpqf1qgpcot5mfmru26', 'ログアウト__passwordchange/index', '2021-07-21 12:50:13', '2021-07-21 12:50:13'),
(90832, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', ' 結果ログ一括DL__outschedule/index', '2021-07-21 12:50:19', '2021-07-21 12:50:19'),
(90833, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:50:30', '2021-07-21 12:50:30'),
(90834, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:51:16', '2021-07-21 12:51:16'),
(90835, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:51:26', '2021-07-21 12:51:26'),
(90836, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', ' 結果ログ一括DL__outschedule/index', '2021-07-21 12:52:10', '2021-07-21 12:52:10'),
(90837, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:52:21', '2021-07-21 12:52:21'),
(90838, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:52:38', '2021-07-21 12:52:38'),
(90839, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:53:36', '2021-07-21 12:53:36'),
(90840, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:54:28', '2021-07-21 12:54:28'),
(90841, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:55:05', '2021-07-21 12:55:05'),
(90842, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:56:00', '2021-07-21 12:56:00'),
(90843, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 12:56:23', '2021-07-21 12:56:23'),
(90844, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:00:19', '2021-07-21 13:00:19'),
(90845, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:21:56', '2021-07-21 13:21:56'),
(90846, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:22:09', '2021-07-21 13:22:09'),
(90847, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:22:13', '2021-07-21 13:22:13'),
(90848, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:22:19', '2021-07-21 13:22:19'),
(90849, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:23:35', '2021-07-21 13:23:35'),
(90850, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:23:59', '2021-07-21 13:23:59'),
(90851, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:24:35', '2021-07-21 13:24:35'),
(90852, '::1', NULL, 'fabbi', '3k74erspdk2mmin8h20hio6ge6', 'ダウンロード__downloadresult/downloadresult', '2021-07-21 13:25:12', '2021-07-21 13:25:12'),
(90853, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', ' 結果ログ一括DL__outschedule/index', '2021-07-22 10:37:25', '2021-07-22 10:37:25'),
(90854, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 10:37:37', '2021-07-22 10:37:37'),
(90855, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:50:31', '2021-07-22 11:50:31'),
(90856, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:51:46', '2021-07-22 11:51:46'),
(90857, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:51:56', '2021-07-22 11:51:56'),
(90858, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:53:19', '2021-07-22 11:53:19'),
(90859, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:59:04', '2021-07-22 11:59:04'),
(90860, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 11:59:55', '2021-07-22 11:59:55'),
(90861, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:04:26', '2021-07-22 12:04:26'),
(90862, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:04:45', '2021-07-22 12:04:45'),
(90863, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:18:07', '2021-07-22 12:18:07'),
(90864, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:27:40', '2021-07-22 12:27:40'),
(90865, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:44:25', '2021-07-22 12:44:25'),
(90866, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:51:09', '2021-07-22 12:51:09'),
(90867, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 12:55:50', '2021-07-22 12:55:50'),
(90868, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 13:02:00', '2021-07-22 13:02:00'),
(90869, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 13:08:41', '2021-07-22 13:08:41'),
(90870, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 13:43:30', '2021-07-22 13:43:30'),
(90871, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 13:45:33', '2021-07-22 13:45:33'),
(90872, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 13:47:15', '2021-07-22 13:47:15'),
(90873, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 15:46:30', '2021-07-22 15:46:30'),
(90874, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 15:54:49', '2021-07-22 15:54:49'),
(90875, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:15:26', '2021-07-22 16:15:26'),
(90876, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:27:00', '2021-07-22 16:27:00'),
(90877, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:29:52', '2021-07-22 16:29:52'),
(90878, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:46:09', '2021-07-22 16:46:09'),
(90879, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:51:21', '2021-07-22 16:51:21'),
(90880, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 16:57:48', '2021-07-22 16:57:48'),
(90881, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 17:07:42', '2021-07-22 17:07:42'),
(90882, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 17:18:00', '2021-07-22 17:18:00'),
(90883, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 17:39:55', '2021-07-22 17:39:55'),
(90884, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 17:51:26', '2021-07-22 17:51:26'),
(90885, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 18:15:15', '2021-07-22 18:15:15'),
(90886, '::1', NULL, 'fabbi', 'o1oq1si7n22rmqofcvogskl577', 'ダウンロード__downloadresult/downloadresult', '2021-07-22 18:24:26', '2021-07-22 18:24:26'),
(90887, '::1', NULL, 'fabbi', 'ckvt473gpbcid9nnqp5250v2g7', ' 結果ログ一括DL__outschedule/index', '2021-07-23 10:36:51', '2021-07-23 10:36:51'),
(90888, '::1', NULL, 'fabbi', '8i9porvia9d04b66dj7egve9s0', ' 結果ログ一括DL__outschedule/index', '2021-07-26 11:36:16', '2021-07-26 11:36:16'),
(90889, '::1', NULL, 'fabbi', '8i9porvia9d04b66dj7egve9s0', 'ダウンロード__downloadresult/downloadresult', '2021-07-26 13:36:14', '2021-07-26 13:36:14'),
(90890, '::1', NULL, 'fabbi', '8i9porvia9d04b66dj7egve9s0', 'ダウンロード__downloadresult/downloadresult', '2021-07-26 13:48:46', '2021-07-26 13:48:46'),
(90891, '::1', NULL, 'fabbi', '8i9porvia9d04b66dj7egve9s0', 'ダウンロード__downloadresult/downloadresult', '2021-07-26 15:55:57', '2021-07-26 15:55:57'),
(90892, '::1', NULL, 'fabbi', 'gmt2kvs7l8mud50pgfg8j90pc5', ' 結果ログ一括DL__outschedule/index', '2021-07-27 10:33:37', '2021-07-27 10:33:37'),
(90893, '::1', NULL, 'fabbi', 'gmt2kvs7l8mud50pgfg8j90pc5', 'ダウンロード__downloadresult/downloadresult', '2021-07-27 10:33:41', '2021-07-27 10:33:41'),
(90894, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', ' 結果ログ一括DL__outschedule/index', '2021-07-28 10:48:33', '2021-07-28 10:48:33'),
(90895, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', '\n			fabbi\n			\n		__downloadresult/downloadresult', '2021-07-28 11:42:54', '2021-07-28 11:42:54'),
(90896, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', ' メニュー管理__downloadresult/index', '2021-07-28 12:13:13', '2021-07-28 12:13:13'),
(90897, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', '保存__managemenu/index', '2021-07-28 12:13:29', '2021-07-28 12:13:29'),
(90898, '::1', NULL, 'fabbi01', 'gdmj02h7tr5ka3cc58bc0f9h25', 'fabbi01__outschedule/outschedule', '2021-07-28 12:16:42', '2021-07-28 12:16:42'),
(90899, '::1', NULL, 'fabbi01', 'gdmj02h7tr5ka3cc58bc0f9h25', 'ログアウト__outschedule/index', '2021-07-28 12:16:43', '2021-07-28 12:16:43'),
(90900, '::1', NULL, 'fabbi02', '61resc8o2ssk73mj796l93p0h5', ' 結果ログ一括DL__outschedule/index', '2021-07-28 12:21:36', '2021-07-28 12:21:36'),
(90901, '::1', NULL, 'fabbi02', '61resc8o2ssk73mj796l93p0h5', ' 結果ログ一括DL__outschedule/index', '2021-07-28 12:21:43', '2021-07-28 12:21:43'),
(90902, '::1', NULL, 'fabbi02', '61resc8o2ssk73mj796l93p0h5', ' 発信NGリスト__outschedule/index', '2021-07-28 12:21:54', '2021-07-28 12:21:54'),
(90903, '::1', NULL, 'fabbi02', '61resc8o2ssk73mj796l93p0h5', 'fabbi02__calllistng/calllistng', '2021-07-28 12:21:56', '2021-07-28 12:21:56'),
(90904, '::1', NULL, 'fabbi02', '61resc8o2ssk73mj796l93p0h5', 'ログアウト__calllistng/index', '2021-07-28 12:21:57', '2021-07-28 12:21:57'),
(90905, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' 結果ログ一括DL__outschedule/index', '2021-07-28 12:22:06', '2021-07-28 12:22:06'),
(90906, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' 着信設定__outschedule/index', '2021-07-28 12:22:22', '2021-07-28 12:22:22'),
(90907, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' 着信拒否リスト__inboundincominghistory/index', '2021-07-28 12:22:24', '2021-07-28 12:22:24'),
(90908, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' 結果ログ一括DL__inboundrestrict/index', '2021-07-28 12:22:25', '2021-07-28 12:22:25'),
(90909, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' ユーザー管理__outschedule/index', '2021-07-28 12:22:36', '2021-07-28 12:22:36'),
(90910, '::1', NULL, 'fabbi02', 'o841nggsnb4f4j5cufmvgncrk6', ' 結果ログ一括DL__manageuser/index', '2021-07-28 12:30:03', '2021-07-28 12:30:03'),
(90911, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', ' 結果ログ一括DL__managemenu/index', '2021-07-28 13:01:15', '2021-07-28 13:01:15'),
(90912, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 13:01:16', '2021-07-28 13:01:16'),
(90913, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:05:46', '2021-07-28 17:05:46'),
(90914, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:06:28', '2021-07-28 17:06:28'),
(90915, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:07:29', '2021-07-28 17:07:29'),
(90916, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:13:32', '2021-07-28 17:13:32'),
(90917, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:14:03', '2021-07-28 17:14:03'),
(90918, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:21:30', '2021-07-28 17:21:30'),
(90919, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:24:39', '2021-07-28 17:24:39'),
(90920, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:25:18', '2021-07-28 17:25:18'),
(90921, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:47:16', '2021-07-28 17:47:16'),
(90922, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:48:00', '2021-07-28 17:48:00'),
(90923, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:48:06', '2021-07-28 17:48:06'),
(90924, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 17:54:10', '2021-07-28 17:54:10'),
(90925, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:01:38', '2021-07-28 18:01:38'),
(90926, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:06:42', '2021-07-28 18:06:42'),
(90927, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:09:18', '2021-07-28 18:09:18'),
(90928, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:12:43', '2021-07-28 18:12:43'),
(90929, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:26:20', '2021-07-28 18:26:20'),
(90930, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:33:43', '2021-07-28 18:33:43'),
(90931, '::1', NULL, 'fabbi', 'rmi1o6a817ld9unaruntdi6j25', 'ダウンロード__downloadresult/downloadresult', '2021-07-28 18:43:16', '2021-07-28 18:43:16'),
(90932, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', ' 結果ログ一括DL__outschedule/index', '2021-07-29 11:41:14', '2021-07-29 11:41:14'),
(90933, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:41:23', '2021-07-29 11:41:23'),
(90934, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:42:43', '2021-07-29 11:42:43'),
(90935, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:44:12', '2021-07-29 11:44:12'),
(90936, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:44:45', '2021-07-29 11:44:45'),
(90937, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:45:39', '2021-07-29 11:45:39'),
(90938, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:46:33', '2021-07-29 11:46:33'),
(90939, '::1', NULL, 'fabbi', 'io5tqppk7594lbrdiavcoma4f0', 'ダウンロード__downloadresult/downloadresult', '2021-07-29 11:47:00', '2021-07-29 11:47:00'),
(90940, '::1', NULL, 'fabbi', 'kr4ig41430007detb3gp4pn5k0', ' 結果ログ一括DL__outschedule/index', '2021-07-30 15:55:39', '2021-07-30 15:55:39');

-- --------------------------------------------------------

--
-- Table structure for table `t92_locks`
--

CREATE TABLE `t92_locks` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `lock_flag` varchar(20) DEFAULT NULL COMMENT 'ロック種類	 schedule-script-list',
  `lock_id` varchar(20) DEFAULT NULL COMMENT 'ロックID',
  `use_user_id` varchar(64) DEFAULT NULL COMMENT 'ユーザーID',
  `session_id` varchar(128) DEFAULT NULL COMMENT '会社ID',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '操作内容',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t92ロック';

--
-- Dumping data for table `t92_locks`
--

INSERT INTO `t92_locks` (`id`, `lock_flag`, `lock_id`, `use_user_id`, `session_id`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 'call_list', '1', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 16:27:46', 'kamo_s', 'CallList_upload_file_start', '2021-02-26 16:27:46', 'kamo_s', 'CallList_upload_file_done'),
(2, 'call_list', '2', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file_start', '2021-02-26 16:29:50', 'kamo_s', 'CallList_upload_file_done'),
(3, 'inbound_call_list', '1', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 16:50:17', 'kamo_s', 'InboundCallList_upload_file_start', '2021-02-26 16:50:17', 'kamo_s', 'InboundCallList_upload_file_end'),
(4, 'inbound_call_list', '2', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file_start', '2021-02-26 17:08:53', 'kamo_s', 'InboundCallList_upload_file_end'),
(5, 'sms_template_list', '1', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 17:15:56', 'kamo_s', 'SmsTemplate_add_sms_template_start', '2021-02-26 17:15:56', 'kamo_s', 'SmsTemplate_add_sms_template_end'),
(6, 'upload_sms_send_list', '1', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 17:17:39', 'kamo_s', 'SmsSendList_upload_file_start', '2021-02-26 17:17:39', 'kamo_s', 'SmsSendList_upload_file_done'),
(7, 'upload_sms_send_list', '2', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file_start', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file_done'),
(8, 'sms_template_list', '2', 'kamo_s', '5ljqcto8caofm4o0dte8a8fan2', 'Y', '2021-02-26 17:20:02', 'kamo_s', 'SmsTemplate_add_sms_template_start', '2021-02-26 17:20:02', 'kamo_s', 'SmsTemplate_add_sms_template_end'),
(9, 'schedule', '1', 'kamo_s', 'lf2kcsoori7vtbog6n1ldmuim3', 'Y', '2021-03-01 11:21:09', 'kamo_s', 'OutSchedule_Update_Schedule', '2021-03-01 11:21:09', 'kamo_s', 'OutSchedule_Update_Schedule'),
(10, 'call_list', '3', 'kamo_s', 'vicfpcsl84ajugg8ao24pu37e7', 'Y', '2021-03-01 12:11:23', 'kamo_s', 'CallList_upload_file_start', '2021-03-01 12:11:23', 'kamo_s', 'CallList_upload_file_done'),
(11, 'incoming_history', '0363863696', 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', 'Y', '2021-03-01 12:49:34', 'kamo_s', 'InboundIncomingHistory_check_info_setting_inbound_start', '2021-03-01 12:49:34', 'kamo_s', 'InboundIncomingHistory_save_end'),
(12, 'incoming_history', '0363863696', 'kamo_s', '7cmn7prguj48vprq7p16h65rl1', 'Y', '2021-03-01 12:54:14', 'kamo_s', 'InboundIncomingHistory_check_info_setting_inbound_start', '2021-03-01 12:54:14', 'kamo_s', 'InboundIncomingHistory_save_end'),
(13, 'upload_sms_send_list', '3', 'kamo_s', 'itifaftr0viio82o68fl0r2bg6', 'Y', '2021-03-01 14:07:04', 'kamo_s', 'SmsSendList_upload_file_start', '2021-03-01 14:07:04', 'kamo_s', 'SmsSendList_upload_file_done'),
(14, 't11_tel_list', '6', 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', 'Y', '2021-06-23 16:50:05', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-23 16:50:05', 'fabbi', 'CallList_add_and_edit_tel_done'),
(15, 'schedule', '3', 'fabbi', 'as38qudq9f67ggs46f8jg06pg2', 'N', '2021-06-23 19:11:28', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-23 19:11:28', NULL, NULL),
(16, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 11:47:46', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 11:47:46', 'fabbi', 'CallList_add_and_edit_tel_done'),
(17, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 11:48:31', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 11:48:31', 'fabbi', 'CallList_add_and_edit_tel_done'),
(18, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 11:49:23', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 11:49:23', 'fabbi', 'CallList_add_and_edit_tel_done'),
(19, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 11:54:25', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 11:54:25', NULL, NULL),
(20, 'schedule', '5', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 12:23:43', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 12:23:43', NULL, NULL),
(21, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 12:26:46', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 12:26:46', 'fabbi', 'CallList_add_and_edit_tel_done'),
(22, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 13:00:55', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:00:55', NULL, NULL),
(23, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 13:03:01', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:03:01', NULL, NULL),
(24, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 13:40:30', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 13:40:30', 'fabbi', 'CallList_add_and_edit_tel_done'),
(25, 't11_tel_list', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 13:40:50', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 13:40:50', 'fabbi', 'CallList_add_and_edit_tel_done'),
(26, 't11_tel_list', '5', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 13:46:39', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 13:46:39', 'fabbi', 'CallList_add_and_edit_tel_done'),
(27, 't11_tel_list', '5', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 13:55:28', 'fabbi', 'CallList_add_and_edit_tel_start', '2021-06-24 13:55:28', 'fabbi', 'CallList_add_and_edit_tel_done'),
(28, 'schedule', '5', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 13:56:55', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:56:55', NULL, NULL),
(29, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 13:57:13', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 13:57:13', NULL, NULL),
(30, 'schedule', '6', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 14:03:27', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 14:03:27', NULL, NULL),
(31, 'schedule', '7', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 14:04:41', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 14:04:41', NULL, NULL),
(32, 'schedule', '8', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 17:10:58', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 17:10:58', NULL, NULL),
(33, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 17:11:57', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 17:11:57', NULL, NULL),
(34, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 17:12:14', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 17:12:14', NULL, NULL),
(35, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 17:12:29', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 17:12:29', NULL, NULL),
(36, 'schedule', '4', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'N', '2021-06-24 17:12:59', 'fabbi', 'OutSchedule_Update_Schedule', '2021-06-24 17:12:59', NULL, NULL),
(37, 'schedule', '1', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 17:22:47', 'fabbi', 'OutSchedule_Index_StopSchedule', '2021-06-24 17:22:47', 'fabbi', 'OutSchedule_Index_StopSchedule'),
(38, 'schedule', '2', 'fabbi', '6pqn6q72jh1f5at9dm6aull6u6', 'Y', '2021-06-24 17:22:52', 'fabbi', 'OutSchedule_Index_StopSchedule', '2021-06-24 17:22:52', 'fabbi', 'OutSchedule_Index_StopSchedule'),
(39, 'incoming_history', '0363863696', 'fabbi', 'sbmscn4r5n80rfaq2mg3k1hs14', 'Y', '2021-06-30 11:01:38', 'fabbi', 'InboundIncomingHistory_check_info_setting_inbound_start', '2021-06-30 11:01:38', 'fabbi', 'InboundIncomingHistory_save_end');

-- --------------------------------------------------------

--
-- Table structure for table `t93_sms_getstatus_log`
--

CREATE TABLE `t93_sms_getstatus_log` (
  `id` int(11) NOT NULL,
  `entry_id` varchar(45) DEFAULT NULL,
  `ResStatus` varchar(10) DEFAULT NULL,
  `ResCount` varchar(10) DEFAULT NULL,
  `create_date` varchar(45) DEFAULT NULL,
  `req_stat` varchar(10) DEFAULT NULL,
  `group_id` varchar(10) DEFAULT NULL,
  `service_id` varchar(10) DEFAULT NULL,
  `user` varchar(45) DEFAULT NULL,
  `to_address` varchar(20) DEFAULT NULL,
  `use_cr_find` varchar(1) DEFAULT NULL,
  `carrier_id` varchar(1) DEFAULT NULL,
  `message_no` varchar(20) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `encode` varchar(1) DEFAULT NULL,
  `permit_time` varchar(20) DEFAULT NULL,
  `sent_date` varchar(20) DEFAULT NULL,
  `status` varchar(3) DEFAULT NULL,
  `send_result` varchar(20) DEFAULT NULL,
  `result_status` varchar(20) DEFAULT NULL,
  `command_status` varchar(20) DEFAULT NULL,
  `network_error_code` varchar(20) DEFAULT NULL,
  `tracking_code` varchar(20) DEFAULT NULL,
  `partition_size` varchar(2) DEFAULT NULL,
  `use_jdg_find` varchar(1) DEFAULT NULL,
  `ResErrorCode` varchar(10) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t94_company_hide_menus`
--

CREATE TABLE `t94_company_hide_menus` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(64) DEFAULT NULL,
  `menu_item_code` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `update_user` varchar(64) DEFAULT NULL,
  `update_program` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t95_api_results`
--

CREATE TABLE `t95_api_results` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `request_id` varchar(20) DEFAULT NULL,
  `api_name` varchar(50) DEFAULT NULL,
  `schedule_id` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t96_api_logs`
--

CREATE TABLE `t96_api_logs` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) DEFAULT NULL,
  `request_id` varchar(20) DEFAULT NULL,
  `client_ip` varchar(20) DEFAULT NULL,
  `user_id` varchar(20) DEFAULT NULL,
  `api_name` varchar(50) DEFAULT NULL,
  `in_json_data` text,
  `status` varchar(1) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `response_code` varchar(20) DEFAULT NULL,
  `response_body` text,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t97_api_request_ids`
--

CREATE TABLE `t97_api_request_ids` (
  `id` bigint(20) NOT NULL,
  `request_id` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t98_login_page_infos`
--

CREATE TABLE `t98_login_page_infos` (
  `id` bigint(20) NOT NULL,
  `message` varchar(30) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `t100_sms_send_lists`
--

CREATE TABLE `t100_sms_send_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT '会社ID',
  `list_no` int(11) DEFAULT NULL,
  `list_name` varchar(128) DEFAULT NULL COMMENT '発信リスト名',
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `tel_total` int(12) DEFAULT NULL,
  `muko_tel_total` int(12) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t10発信リスト';

--
-- Dumping data for table `t100_sms_send_lists`
--

INSERT INTO `t100_sms_send_lists` (`id`, `company_id`, `list_no`, `list_name`, `list_test_flag`, `tel_total`, `muko_tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '002', 1, 'サンプル送信リスト1', '1', 2, 2, 'N', '2021-02-26 17:17:39', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39', NULL, NULL),
(2, '002', 2, 'サンプル送信リスト2', '1', 3, 3, 'N', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47', NULL, NULL),
(3, '002', 3, 'サンプル送信リスト3', '1', 1, 1, 'N', '2021-03-01 14:07:04', 'kamo_s', 'SmsSendList_upload_file', '2021-03-01 14:07:04', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t101_sms_tel_lists`
--

CREATE TABLE `t101_sms_tel_lists` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `list_id` bigint(20) NOT NULL,
  `tel_no` int(11) DEFAULT NULL,
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL,
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `consentday` varchar(14) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t11 発信電話番号リスト';

--
-- Dumping data for table `t101_sms_tel_lists`
--

INSERT INTO `t101_sms_tel_lists` (`id`, `list_id`, `tel_no`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `consentday`) VALUES
(1, 1, 1, '09000000000', 'ダミー1', '1000', '1234', '1990年03月21日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:17:39', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL),
(2, 1, 2, '09000000001', 'ダミー2', '2000', '5678', '1985年12月01日', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:17:39', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL),
(3, 2, 1, '09000000002', 'ダミー3', '3000', '1234', '88888', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL),
(4, 2, 2, '09000000003', 'ダミー4', '4000', '5678', '77777', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL),
(5, 2, 3, '09000000004', 'ダミー5', '5000', '0123', '66666', '', '', '', '', '', '', 'N', NULL, 'N', '2021-02-26 17:18:47', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL),
(6, 3, 1, '09000000005', '', '', '', '', '', '', '', '', '', '', 'N', NULL, 'N', '2021-03-01 14:07:04', 'kamo_s', 'SmsSendList_upload_file', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t102_sms_list_items`
--

CREATE TABLE `t102_sms_list_items` (
  `id` bigint(20) NOT NULL,
  `company_id` varchar(20) NOT NULL,
  `list_id` varchar(20) NOT NULL,
  `order_num` int(6) DEFAULT NULL,
  `item_name` varchar(64) DEFAULT NULL,
  `item_code` varchar(64) DEFAULT NULL,
  `column` varchar(20) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `entry_user` varchar(64) DEFAULT NULL,
  `entry_program` varchar(64) DEFAULT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `t102_sms_list_items`
--

INSERT INTO `t102_sms_list_items` (`id`, `company_id`, `list_id`, `order_num`, `item_name`, `item_code`, `column`, `del_flag`, `entry_user`, `entry_program`, `created`) VALUES
(1, '002', '1', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39'),
(2, '002', '1', 2, '名前', 'customer_name', 'customize2', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39'),
(3, '002', '1', 3, '金額', 'money', 'customize3', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39'),
(4, '002', '1', 4, '認証番号', '', 'customize4', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39'),
(5, '002', '1', 5, '生年月日', 'birthday', 'customize5', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:17:39'),
(6, '002', '2', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(7, '002', '2', 2, '名前', 'customer_name', 'customize2', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(8, '002', '2', 3, '金額', 'money', 'customize3', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(9, '002', '2', 4, '認証番号', '', 'customize4', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(10, '002', '2', 5, '顧客番号', '', 'customize5', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(11, '002', '3', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-03-01 14:07:04'),
(12, '003', '2', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-02-26 17:18:47'),
(13, '004', '3', 1, '電話番号', 'tel_no', 'customize1', 'N', 'kamo_s', 'SmsSendList_upload_file', '2021-03-01 14:07:04');

-- --------------------------------------------------------

--
-- Table structure for table `t200_sms_send_schedules`
--

CREATE TABLE `t200_sms_send_schedules` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` varchar(20) NOT NULL COMMENT 'サーバID',
  `schedule_no` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `schedule_name` varchar(64) NOT NULL,
  `service_id` varchar(20) NOT NULL,
  `display_number` varchar(20) DEFAULT NULL,
  `list_id` varchar(20) NOT NULL COMMENT '送信リストID',
  `template_id` varchar(20) NOT NULL COMMENT 'スクリプトID',
  `status` varchar(1) NOT NULL DEFAULT '0' COMMENT '0：まだ、1：実行中、2：手動停止、3：停止、4：終了、5：停止中、6：終了中',
  `send_total` int(12) DEFAULT NULL,
  `resend_flag` varchar(1) DEFAULT 'N',
  `stop_time` datetime DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `consent_flag` varchar(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t200 SMSスケジュール';

--
-- Dumping data for table `t200_sms_send_schedules`
--

INSERT INTO `t200_sms_send_schedules` (`id`, `company_id`, `schedule_no`, `schedule_name`, `service_id`, `display_number`, `list_id`, `template_id`, `status`, `send_total`, `resend_flag`, `stop_time`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `consent_flag`) VALUES
(1, '002', 1, 'サンプルスケジュール', 'CDgyo3MyOac128', '0120558656(試験用.)', '3', '1', '4', 1, 'N', '2021-03-01 13:55:04', 'N', '2021-03-01 13:51:57', 's_kamo', 'SmsSchedule_Create_Schedule', '2021-03-01 13:56:03', NULL, 'sms_api(set_status_schedule)', '0'),
(2, '003', 2, 'サンプルスケジュール 2', 'CDgyo3MyOac128', '0120521346(試験用.)', '2', '1', '4', 1, 'N', '2021-03-01 13:55:04', 'N', '2021-03-01 13:51:57', 's_kamo', 'SmsSchedule_Create_Schedule', '2021-03-01 13:56:03', NULL, 'sms_api(set_status_schedule)', '0'),
(3, '004', 3, 'サンプルスケジュール 3', 'CDgyo3MyOac128', '0120555346(試験用.)', '3', '1', '0', 1, 'N', '2021-03-01 13:55:04', 'N', '2021-03-01 13:51:57', 's_kamo', 'SmsSchedule_Create_Schedule', '2021-03-01 13:56:03', NULL, 'sms_api(set_status_schedule)', '0');

-- --------------------------------------------------------

--
-- Table structure for table `t201_sms_send_times`
--

CREATE TABLE `t201_sms_send_times` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュールID',
  `time_start` datetime NOT NULL COMMENT '開始時間',
  `time_end` datetime NOT NULL COMMENT '終了時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t201 SMSスケジュール詳細';

--
-- Dumping data for table `t201_sms_send_times`
--

INSERT INTO `t201_sms_send_times` (`id`, `schedule_id`, `time_start`, `time_end`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', '2021-03-01 13:55:00', '2021-03-01 15:05:00', 'N', '2021-03-01 13:51:57', 's_kamo', 'SmsSchedule_Create_Schedule', '2021-03-01 13:51:57', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t202_sms_send_logs`
--

CREATE TABLE `t202_sms_send_logs` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュールID',
  `time_start` datetime NOT NULL COMMENT '開始時間',
  `time_end` datetime DEFAULT NULL COMMENT '終了時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t202 SMSスケジュール履歴';

--
-- Dumping data for table `t202_sms_send_logs`
--

INSERT INTO `t202_sms_send_logs` (`id`, `schedule_id`, `time_start`, `time_end`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', '2021-06-01 13:55:03', '2021-06-30 13:55:04', 'N', '2021-02-01 13:55:03', NULL, 'sms_api', '2021-03-01 13:55:04', NULL, 'sms_api'),
(2, '2', '2021-06-04 13:55:03', '2021-06-30 13:55:04', 'N', '2021-02-01 13:55:03', NULL, 'sms_api', '2021-03-01 13:55:04', NULL, 'sms_api'),
(3, '3', '2021-06-03 13:55:03', '2021-06-23 13:55:04', 'N', '2021-02-01 13:55:03', NULL, 'sms_api', '2021-03-01 13:55:04', NULL, 'sms_api');

-- --------------------------------------------------------

--
-- Table structure for table `t300_sms_templates`
--

CREATE TABLE `t300_sms_templates` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `company_id` bigint(20) NOT NULL,
  `template_no` bigint(20) NOT NULL COMMENT '会社毎発番',
  `template_name` varchar(128) NOT NULL COMMENT 'メッセージ件名',
  `template_type` int(1) DEFAULT NULL,
  `description` text,
  `content` varchar(1000) DEFAULT NULL COMMENT '本文',
  `sms_use_short_url` varchar(1) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t300 SMSテンプレート';

--
-- Dumping data for table `t300_sms_templates`
--

INSERT INTO `t300_sms_templates` (`id`, `company_id`, `template_no`, `template_name`, `template_type`, `description`, `content`, `sms_use_short_url`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 2, 1, 'サンプルSMSテンプレート', 1, '', 'サンプルテンプレートです。\nhttp://sample.com/', '', 'N', '2021-02-26 17:15:56', 'kamo_s', 'SmsTemplate_add_sms_template', '2021-02-26 17:15:56', NULL, NULL),
(2, 2, 2, 'サンプルSMSテンプレート2', 1, '', '{名前}さんこんにちは。\nSMSサンプルテンプレートです。\nhttp://sample2.com/', '1', 'N', '2021-02-26 17:20:02', 'kamo_s', 'SmsTemplate_add_sms_template', '2021-02-26 17:20:02', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t500_sms_list_histories`
--

CREATE TABLE `t500_sms_list_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `list_id` bigint(20) NOT NULL COMMENT '発信リストID',
  `list_name` varchar(128) DEFAULT NULL COMMENT '発信リスト名',
  `list_test_flag` varchar(1) DEFAULT '0' COMMENT 'テストリストフラグ	 １：テストリスト',
  `tel_total` varchar(6) DEFAULT NULL COMMENT '総件数',
  `muko_tel_total` int(12) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t500SMS送信リスト履歴';

--
-- Dumping data for table `t500_sms_list_histories`
--

INSERT INTO `t500_sms_list_histories` (`id`, `schedule_id`, `list_id`, `list_name`, `list_test_flag`, `tel_total`, `muko_tel_total`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 3, 'サンプル送信リスト3', '1', '1', 1, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t501_sms_tel_histories`
--

CREATE TABLE `t501_sms_tel_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `customize1` varchar(128) DEFAULT NULL COMMENT '項目1',
  `customize2` varchar(128) DEFAULT NULL COMMENT '項目2',
  `customize3` varchar(128) DEFAULT NULL COMMENT '項目3',
  `customize4` varchar(128) DEFAULT NULL COMMENT '項目4',
  `customize5` varchar(128) DEFAULT NULL COMMENT '項目5',
  `customize6` varchar(128) DEFAULT NULL COMMENT '項目6',
  `customize7` varchar(128) DEFAULT NULL COMMENT '項目7',
  `customize8` varchar(128) DEFAULT NULL COMMENT '項目8',
  `customize9` varchar(128) DEFAULT NULL COMMENT '項目9',
  `customize10` varchar(128) DEFAULT NULL COMMENT '項目10',
  `customize11` varchar(128) DEFAULT NULL,
  `carrier` varchar(128) DEFAULT NULL,
  `muko_flag` varchar(1) DEFAULT 'N' COMMENT '無効フラグ',
  `muko_modified` datetime DEFAULT NULL COMMENT '無効時間',
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム',
  `consentday` varchar(14) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t501 SMS送信電話番号履歴';

--
-- Dumping data for table `t501_sms_tel_histories`
--

INSERT INTO `t501_sms_tel_histories` (`id`, `schedule_id`, `customize1`, `customize2`, `customize3`, `customize4`, `customize5`, `customize6`, `customize7`, `customize8`, `customize9`, `customize10`, `customize11`, `carrier`, `muko_flag`, `muko_modified`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`, `consentday`) VALUES
(1, 1, '09000000005', 'erew', '45345', '454534', 'fdgff', 'rrrrr', '66555', '54555', '56gtttt', 'fdg5644', '43345g', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL),
(2, 1, '09000102445', 'sms 1', 'sms 2', 'sms 3', 'sms 4', 'sms 5', 'sms 6', 'sms 7', 'sms 8', 'sms 9', 'sms 10', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL),
(3, 1, '09000344105', 'test 1', 'test 2', 'test 3', 'test 4', 'test 5', 'test 6', 'test 7', 'test 8', 'test 9', 'test 10', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL),
(4, 1, '09001234005', 'abc', 'sms 2', 'sms 3', 'sms 4', 'sms 5', 'sms 6', 'sms 7', 'sms 8', 'sms 9', 'sms 10', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL),
(5, 1, '09002466888', '123', 'sms 2', 'sms 3', 'sms 4', 'sms 5', 'sms 6', 'sms 7', 'sms 8', 'sms 9', 'sms 10', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL),
(6, 1, '09002421100', '456', 'test 2', 'test 3', 'test 4', 'test 5', 'test 6', 'test 7', 'test 8', 'test 9', 'test 10', 'docomo', 'N', NULL, 'N', '2021-03-01 13:55:02', NULL, 'sms_api', '2021-03-01 13:56:03', NULL, 'sms_api', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t600_sms_template_histories`
--

CREATE TABLE `t600_sms_template_histories` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` bigint(20) NOT NULL COMMENT 'スケジュールID',
  `template_id` bigint(20) DEFAULT NULL,
  `template_name` varchar(128) NOT NULL COMMENT 'テンプレート名',
  `description` text COMMENT '説明',
  `content` varchar(1000) DEFAULT NULL,
  `use_short_url` varchar(1) DEFAULT NULL,
  `del_flag` varchar(1) DEFAULT 'N' COMMENT '削除フラグ',
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t600 SMSテンプレート履歴';

--
-- Dumping data for table `t600_sms_template_histories`
--

INSERT INTO `t600_sms_template_histories` (`id`, `schedule_id`, `template_id`, `template_name`, `description`, `content`, `use_short_url`, `del_flag`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, 1, 1, 'サンプルSMSテンプレート', '', 'サンプルテンプレートです。\nhttp://sample.com/', '0', 'N', '2021-03-01 13:55:02', NULL, 'sms_api', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `t800_sms_send_results`
--

CREATE TABLE `t800_sms_send_results` (
  `id` bigint(20) NOT NULL COMMENT 'ID',
  `schedule_id` varchar(20) NOT NULL COMMENT 'スケジュール',
  `tel_no` varchar(20) NOT NULL COMMENT '電話番号',
  `entry_id` varchar(64) DEFAULT NULL,
  `memo` text COMMENT 'メモ',
  `del_flag` varchar(45) DEFAULT 'N',
  `send_datetime` datetime DEFAULT NULL COMMENT '発信日時',
  `end_datetime` datetime DEFAULT NULL COMMENT '切断日時',
  `status` varchar(20) DEFAULT NULL COMMENT 'ステータス',
  `warning_msg` varchar(256) DEFAULT NULL COMMENT '送信結果のメッセージ',
  `sms_short_url_key` varchar(256) DEFAULT NULL,
  `created` datetime DEFAULT NULL COMMENT '登録日時',
  `entry_user` varchar(64) DEFAULT NULL COMMENT '登録ユーザー',
  `entry_program` varchar(64) DEFAULT NULL COMMENT '登録プログラム',
  `modified` datetime DEFAULT NULL COMMENT '更新日時',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新ユーザー',
  `update_program` varchar(64) DEFAULT NULL COMMENT '更新プログラム'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='t800 SMS送信結果';

--
-- Dumping data for table `t800_sms_send_results`
--

INSERT INTO `t800_sms_send_results` (`id`, `schedule_id`, `tel_no`, `entry_id`, `memo`, `del_flag`, `send_datetime`, `end_datetime`, `status`, `warning_msg`, `sms_short_url_key`, `created`, `entry_user`, `entry_program`, `modified`, `update_user`, `update_program`) VALUES
(1, '1', '09000000005', 'dr691d4ff4a98e987b7b9df88c6f6404d8', '09000000005', 'N', '2021-06-01 13:55:03', '2021-06-30 00:00:00', 'success', '項目に岐東する ', 'KEY 1', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus'),
(2, '1', '09000102445', 'dr691d4ff4a98e987b7b9df88c6f6404d8', NULL, 'N', '2021-06-02 13:55:03', '2021-06-24 00:00:00', 'unknown', '', '', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus'),
(3, '1', '09000344105', 'dr691d4ff4a98e987b7b9df88c6f6404d8', NULL, 'N', '2021-06-02 05:55:03', '2021-06-29 00:00:00', 'outside', '', '', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus'),
(4, '1', '09001234005', 'dr691d4ff4a98e987b7b9df88c6f6404d8', NULL, 'N', '2021-06-25 13:55:03', '2021-06-28 00:00:00', 'history_judgement_ng', 'message 1', 'KEY 2', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus'),
(5, '1', '09002466888', 'dr691d4ff4a98e987b7b9df88c6f6404d8', NULL, 'N', '2021-06-13 13:55:03', '2021-06-16 00:00:00', 'connect', 'message 2', 'KEY 3', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus'),
(6, '1', '09002421100', 'dr691d4ff4a98e987b7b9df88c6f6404d8', NULL, 'N', '2021-06-09 13:55:03', '2021-06-10 00:00:00', 'fail', 'message 3', 'KEY 4', '2021-03-01 13:55:04', NULL, 'Send_Sms_V2', '2021-03-01 13:56:03', NULL, 'GetSendStatus');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `m01_servers`
--
ALTER TABLE `m01_servers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m02_companies`
--
ALTER TABLE `m02_companies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m03_auths`
--
ALTER TABLE `m03_auths`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m04_controller_actions`
--
ALTER TABLE `m04_controller_actions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m05_users`
--
ALTER TABLE `m05_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m06_company_externals`
--
ALTER TABLE `m06_company_externals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m07_server_externals`
--
ALTER TABLE `m07_server_externals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m08_sms_api_infos`
--
ALTER TABLE `m08_sms_api_infos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m09_kaisen_infos`
--
ALTER TABLE `m09_kaisen_infos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `index2` (`kaisen_code`);

--
-- Indexes for table `m10_api_users`
--
ALTER TABLE `m10_api_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m90_pulldown_codes`
--
ALTER TABLE `m90_pulldown_codes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m91_menu_manage_items`
--
ALTER TABLE `m91_menu_manage_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `m92_limit_functions`
--
ALTER TABLE `m92_limit_functions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id_UNIQUE` (`id`);

--
-- Indexes for table `m99_system_parameters`
--
ALTER TABLE `m99_system_parameters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t10_call_lists`
--
ALTER TABLE `t10_call_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t11_tel_lists`
--
ALTER TABLE `t11_tel_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_list_id` (`list_id`),
  ADD KEY `idx_customize1` (`customize1`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize11` (`customize11`);

--
-- Indexes for table `t12_list_items`
--
ALTER TABLE `t12_list_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t13_inbound_list_items`
--
ALTER TABLE `t13_inbound_list_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t14_outgoing_ng_lists`
--
ALTER TABLE `t14_outgoing_ng_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t15_outgoing_ng_tels`
--
ALTER TABLE `t15_outgoing_ng_tels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_listid_telno` (`tel_no`,`list_ng_id`);

--
-- Indexes for table `t16_inbound_call_lists`
--
ALTER TABLE `t16_inbound_call_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t17_inbound_tel_lists`
--
ALTER TABLE `t17_inbound_tel_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_list_id` (`list_id`),
  ADD KEY `idx_customize1` (`customize1`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize11` (`customize11`);

--
-- Indexes for table `t18_incoming_ng_lists`
--
ALTER TABLE `t18_incoming_ng_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t19_incoming_ng_tels`
--
ALTER TABLE `t19_incoming_ng_tels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t20_out_schedules`
--
ALTER TABLE `t20_out_schedules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t21_out_times`
--
ALTER TABLE `t21_out_times`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t22_out_logs`
--
ALTER TABLE `t22_out_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t25_inbounds`
--
ALTER TABLE `t25_inbounds`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t30_templates`
--
ALTER TABLE `t30_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t31_template_questions`
--
ALTER TABLE `t31_template_questions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t32_template_buttons`
--
ALTER TABLE `t32_template_buttons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t40_news`
--
ALTER TABLE `t40_news`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `t50_list_histories`
--
ALTER TABLE `t50_list_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t51_tel_histories`
--
ALTER TABLE `t51_tel_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_schedule_id` (`schedule_id`),
  ADD KEY `idx_customize11` (`customize11`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize1` (`customize1`);

--
-- Indexes for table `t52_tel_redials`
--
ALTER TABLE `t52_tel_redials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_schedule_id` (`schedule_id`),
  ADD KEY `idx_customize11` (`customize11`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize1` (`customize1`);

--
-- Indexes for table `t54_list_ng_histories`
--
ALTER TABLE `t54_list_ng_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t55_tel_ng_histories`
--
ALTER TABLE `t55_tel_ng_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t56_inbound_list_histories`
--
ALTER TABLE `t56_inbound_list_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t57_inbound_tel_histories`
--
ALTER TABLE `t57_inbound_tel_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_inbound_id` (`inbound_id`),
  ADD KEY `idx_customize1` (`customize1`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize11` (`customize11`);

--
-- Indexes for table `t58_inbound_list_ng_histories`
--
ALTER TABLE `t58_inbound_list_ng_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t59_inbound_tel_ng_histories`
--
ALTER TABLE `t59_inbound_tel_ng_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t60_template_histories`
--
ALTER TABLE `t60_template_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t61_question_histories`
--
ALTER TABLE `t61_question_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t62_button_histories`
--
ALTER TABLE `t62_button_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_schedule_id` (`schedule_id`),
  ADD KEY `idx_question_no` (`question_no`),
  ADD KEY `idx_answer_no` (`answer_no`),
  ADD KEY `idx_answer_content` (`answer_content`);

--
-- Indexes for table `t63_inbound_template_histories`
--
ALTER TABLE `t63_inbound_template_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t64_inbound_question_histories`
--
ALTER TABLE `t64_inbound_question_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t65_inbound_button_histories`
--
ALTER TABLE `t65_inbound_button_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_schedule_id` (`inbound_id`),
  ADD KEY `idx_question_no` (`question_no`),
  ADD KEY `idx_answer_no` (`answer_no`),
  ADD KEY `idx_answer_content` (`answer_content`);

--
-- Indexes for table `t70_rdd_tels`
--
ALTER TABLE `t70_rdd_tels`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `t71_prefectures`
--
ALTER TABLE `t71_prefectures`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `t72_districts`
--
ALTER TABLE `t72_districts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `t80_outgoing_results`
--
ALTER TABLE `t80_outgoing_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `Unique` (`schedule_id`,`tel_no`,`tel_type`,`call_datetime`,`connect_datetime`,`cut_datetime`,`status`),
  ADD KEY `idx_tel_no` (`tel_no`),
  ADD KEY `idx_call_datetime` (`call_datetime`),
  ADD KEY `idx_connect_datetime` (`connect_datetime`),
  ADD KEY `idx_cut_datetime` (`cut_datetime`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_ans_accuracy` (`ans_accuracy`),
  ADD KEY `idx_schedule_id` (`schedule_id`),
  ADD KEY `idx_answer1` (`answer1`),
  ADD KEY `idx_answer2` (`answer2`),
  ADD KEY `idx_answer3` (`answer3`),
  ADD KEY `idx_answer4` (`answer4`),
  ADD KEY `idx_answer5` (`answer5`),
  ADD KEY `idx_answer6` (`answer6`),
  ADD KEY `idx_answer7` (`answer7`),
  ADD KEY `idx_answer8` (`answer8`),
  ADD KEY `idx_answer9` (`answer9`),
  ADD KEY `idx_answer10` (`answer10`),
  ADD KEY `idx_answer11` (`answer11`),
  ADD KEY `idx_answer12` (`answer12`),
  ADD KEY `idx_answer13` (`answer13`),
  ADD KEY `idx_answer14` (`answer14`),
  ADD KEY `idx_answer15` (`answer15`),
  ADD KEY `idx_answer16` (`answer16`),
  ADD KEY `idx_answer18` (`answer18`),
  ADD KEY `idx_answer19` (`answer19`),
  ADD KEY `idx_answer20` (`answer20`),
  ADD KEY `idx_answer17` (`answer17`),
  ADD KEY `idx_answer21` (`answer21`),
  ADD KEY `idx_answer22` (`answer22`),
  ADD KEY `idx_answer23` (`answer23`),
  ADD KEY `idx_answer24` (`answer24`),
  ADD KEY `idx_answer25` (`answer25`),
  ADD KEY `idx_answer26` (`answer26`),
  ADD KEY `idx_answer27` (`answer27`),
  ADD KEY `idx_answer28` (`answer28`),
  ADD KEY `idx_answer29` (`answer29`),
  ADD KEY `idx_answer30` (`answer30`),
  ADD KEY `idx_answer31` (`answer31`),
  ADD KEY `idx_answer32` (`answer32`),
  ADD KEY `idx_answer33` (`answer33`),
  ADD KEY `idx_answer34` (`answer34`),
  ADD KEY `idx_answer35` (`answer35`),
  ADD KEY `idx_answer36` (`answer36`),
  ADD KEY `idx_answer37` (`answer37`),
  ADD KEY `idx_answer38` (`answer38`),
  ADD KEY `idx_answer39` (`answer39`),
  ADD KEY `idx_answer40` (`answer40`),
  ADD KEY `idx_answer41` (`answer41`);

--
-- Indexes for table `t81_incoming_results`
--
ALTER TABLE `t81_incoming_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_tel_no_call_datetime` (`inbound_id`,`tel_no`,`call_datetime`,`connect_datetime`,`cut_datetime`);

--
-- Indexes for table `t82_bukken_fax_statuses`
--
ALTER TABLE `t82_bukken_fax_statuses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique` (`log_id`,`inbound_id`,`template_id`,`fax_question_no`);

--
-- Indexes for table `t83_outgoing_sms_statuses`
--
ALTER TABLE `t83_outgoing_sms_statuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sms_index` (`log_id`,`sms_entry_id`),
  ADD KEY `schedule_index` (`schedule_id`,`tel_no`,`sms_question_no`);

--
-- Indexes for table `t84_outgoing_getsmsstatus_histories`
--
ALTER TABLE `t84_outgoing_getsmsstatus_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t85_incomming_bukken_histories`
--
ALTER TABLE `t85_incomming_bukken_histories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `index2` (`log_id`,`inbound_id`,`template_id`,`question_no`),
  ADD KEY `index3` (`call_datetime`),
  ADD KEY `index4` (`property_cost_decimal`),
  ADD KEY `index5` (`property_square_decimal`),
  ADD KEY `index6` (`external_number`);

--
-- Indexes for table `t86_inbound_sms_statuses`
--
ALTER TABLE `t86_inbound_sms_statuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sms_index` (`log_id`,`sms_entry_id`),
  ADD KEY `schedule_index` (`inbound_id`,`tel_no`,`sms_question_no`);

--
-- Indexes for table `t87_inbound_getsmsstatus_histories`
--
ALTER TABLE `t87_inbound_getsmsstatus_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t89_manage_files`
--
ALTER TABLE `t89_manage_files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t90_login_histories`
--
ALTER TABLE `t90_login_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t91_action_histories`
--
ALTER TABLE `t91_action_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t92_locks`
--
ALTER TABLE `t92_locks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t93_sms_getstatus_log`
--
ALTER TABLE `t93_sms_getstatus_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t94_company_hide_menus`
--
ALTER TABLE `t94_company_hide_menus`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t95_api_results`
--
ALTER TABLE `t95_api_results`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t96_api_logs`
--
ALTER TABLE `t96_api_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_request_id` (`request_id`);

--
-- Indexes for table `t97_api_request_ids`
--
ALTER TABLE `t97_api_request_ids`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_request_id` (`request_id`);

--
-- Indexes for table `t98_login_page_infos`
--
ALTER TABLE `t98_login_page_infos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t100_sms_send_lists`
--
ALTER TABLE `t100_sms_send_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t101_sms_tel_lists`
--
ALTER TABLE `t101_sms_tel_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_list_id` (`list_id`),
  ADD KEY `idx_customize1` (`customize1`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize11` (`customize11`);

--
-- Indexes for table `t102_sms_list_items`
--
ALTER TABLE `t102_sms_list_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t200_sms_send_schedules`
--
ALTER TABLE `t200_sms_send_schedules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t201_sms_send_times`
--
ALTER TABLE `t201_sms_send_times`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t202_sms_send_logs`
--
ALTER TABLE `t202_sms_send_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t300_sms_templates`
--
ALTER TABLE `t300_sms_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t500_sms_list_histories`
--
ALTER TABLE `t500_sms_list_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t501_sms_tel_histories`
--
ALTER TABLE `t501_sms_tel_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_schedule_id` (`schedule_id`),
  ADD KEY `idx_customize11` (`customize11`),
  ADD KEY `idx_customize10` (`customize10`),
  ADD KEY `idx_customize9` (`customize9`),
  ADD KEY `idx_customize8` (`customize8`),
  ADD KEY `idx_customize7` (`customize7`),
  ADD KEY `idx_customize6` (`customize6`),
  ADD KEY `idx_customize5` (`customize5`),
  ADD KEY `idx_customize4` (`customize4`),
  ADD KEY `idx_customize3` (`customize3`),
  ADD KEY `idx_customize2` (`customize2`),
  ADD KEY `idx_customize1` (`customize1`);

--
-- Indexes for table `t600_sms_template_histories`
--
ALTER TABLE `t600_sms_template_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t800_sms_send_results`
--
ALTER TABLE `t800_sms_send_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `Unique` (`schedule_id`,`tel_no`,`send_datetime`,`end_datetime`,`status`),
  ADD KEY `idx_tel_no` (`tel_no`),
  ADD KEY `idx_call_datetime` (`send_datetime`),
  ADD KEY `idx_cut_datetime` (`end_datetime`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_schedule_id` (`schedule_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `m01_servers`
--
ALTER TABLE `m01_servers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `m02_companies`
--
ALTER TABLE `m02_companies`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `m03_auths`
--
ALTER TABLE `m03_auths`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `m04_controller_actions`
--
ALTER TABLE `m04_controller_actions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=484;
--
-- AUTO_INCREMENT for table `m05_users`
--
ALTER TABLE `m05_users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `m06_company_externals`
--
ALTER TABLE `m06_company_externals`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `m07_server_externals`
--
ALTER TABLE `m07_server_externals`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `m08_sms_api_infos`
--
ALTER TABLE `m08_sms_api_infos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `m09_kaisen_infos`
--
ALTER TABLE `m09_kaisen_infos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `m10_api_users`
--
ALTER TABLE `m10_api_users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `m90_pulldown_codes`
--
ALTER TABLE `m90_pulldown_codes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=274;
--
-- AUTO_INCREMENT for table `m91_menu_manage_items`
--
ALTER TABLE `m91_menu_manage_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `m92_limit_functions`
--
ALTER TABLE `m92_limit_functions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `m99_system_parameters`
--
ALTER TABLE `m99_system_parameters`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `t10_call_lists`
--
ALTER TABLE `t10_call_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `t11_tel_lists`
--
ALTER TABLE `t11_tel_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `t12_list_items`
--
ALTER TABLE `t12_list_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `t13_inbound_list_items`
--
ALTER TABLE `t13_inbound_list_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `t14_outgoing_ng_lists`
--
ALTER TABLE `t14_outgoing_ng_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t15_outgoing_ng_tels`
--
ALTER TABLE `t15_outgoing_ng_tels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `t16_inbound_call_lists`
--
ALTER TABLE `t16_inbound_call_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `t17_inbound_tel_lists`
--
ALTER TABLE `t17_inbound_tel_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `t18_incoming_ng_lists`
--
ALTER TABLE `t18_incoming_ng_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t19_incoming_ng_tels`
--
ALTER TABLE `t19_incoming_ng_tels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `t20_out_schedules`
--
ALTER TABLE `t20_out_schedules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `t21_out_times`
--
ALTER TABLE `t21_out_times`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `t22_out_logs`
--
ALTER TABLE `t22_out_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `t25_inbounds`
--
ALTER TABLE `t25_inbounds`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `t30_templates`
--
ALTER TABLE `t30_templates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `t31_template_questions`
--
ALTER TABLE `t31_template_questions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=64;
--
-- AUTO_INCREMENT for table `t32_template_buttons`
--
ALTER TABLE `t32_template_buttons`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=168;
--
-- AUTO_INCREMENT for table `t40_news`
--
ALTER TABLE `t40_news`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t50_list_histories`
--
ALTER TABLE `t50_list_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t51_tel_histories`
--
ALTER TABLE `t51_tel_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `t52_tel_redials`
--
ALTER TABLE `t52_tel_redials`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t54_list_ng_histories`
--
ALTER TABLE `t54_list_ng_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t55_tel_ng_histories`
--
ALTER TABLE `t55_tel_ng_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t56_inbound_list_histories`
--
ALTER TABLE `t56_inbound_list_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t57_inbound_tel_histories`
--
ALTER TABLE `t57_inbound_tel_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `t58_inbound_list_ng_histories`
--
ALTER TABLE `t58_inbound_list_ng_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t59_inbound_tel_ng_histories`
--
ALTER TABLE `t59_inbound_tel_ng_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t60_template_histories`
--
ALTER TABLE `t60_template_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t61_question_histories`
--
ALTER TABLE `t61_question_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `t62_button_histories`
--
ALTER TABLE `t62_button_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `t63_inbound_template_histories`
--
ALTER TABLE `t63_inbound_template_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t64_inbound_question_histories`
--
ALTER TABLE `t64_inbound_question_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `t65_inbound_button_histories`
--
ALTER TABLE `t65_inbound_button_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t70_rdd_tels`
--
ALTER TABLE `t70_rdd_tels`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t71_prefectures`
--
ALTER TABLE `t71_prefectures`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t72_districts`
--
ALTER TABLE `t72_districts`
  MODIFY `ID` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t80_outgoing_results`
--
ALTER TABLE `t80_outgoing_results`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=81939;
--
-- AUTO_INCREMENT for table `t81_incoming_results`
--
ALTER TABLE `t81_incoming_results`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `t82_bukken_fax_statuses`
--
ALTER TABLE `t82_bukken_fax_statuses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t83_outgoing_sms_statuses`
--
ALTER TABLE `t83_outgoing_sms_statuses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t84_outgoing_getsmsstatus_histories`
--
ALTER TABLE `t84_outgoing_getsmsstatus_histories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t85_incomming_bukken_histories`
--
ALTER TABLE `t85_incomming_bukken_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t86_inbound_sms_statuses`
--
ALTER TABLE `t86_inbound_sms_statuses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t87_inbound_getsmsstatus_histories`
--
ALTER TABLE `t87_inbound_getsmsstatus_histories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t89_manage_files`
--
ALTER TABLE `t89_manage_files`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t90_login_histories`
--
ALTER TABLE `t90_login_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=55603;
--
-- AUTO_INCREMENT for table `t91_action_histories`
--
ALTER TABLE `t91_action_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=90941;
--
-- AUTO_INCREMENT for table `t92_locks`
--
ALTER TABLE `t92_locks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=40;
--
-- AUTO_INCREMENT for table `t93_sms_getstatus_log`
--
ALTER TABLE `t93_sms_getstatus_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t94_company_hide_menus`
--
ALTER TABLE `t94_company_hide_menus`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID';
--
-- AUTO_INCREMENT for table `t95_api_results`
--
ALTER TABLE `t95_api_results`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t96_api_logs`
--
ALTER TABLE `t96_api_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t97_api_request_ids`
--
ALTER TABLE `t97_api_request_ids`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t98_login_page_infos`
--
ALTER TABLE `t98_login_page_infos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `t100_sms_send_lists`
--
ALTER TABLE `t100_sms_send_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `t101_sms_tel_lists`
--
ALTER TABLE `t101_sms_tel_lists`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `t102_sms_list_items`
--
ALTER TABLE `t102_sms_list_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `t200_sms_send_schedules`
--
ALTER TABLE `t200_sms_send_schedules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `t201_sms_send_times`
--
ALTER TABLE `t201_sms_send_times`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t202_sms_send_logs`
--
ALTER TABLE `t202_sms_send_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `t300_sms_templates`
--
ALTER TABLE `t300_sms_templates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `t500_sms_list_histories`
--
ALTER TABLE `t500_sms_list_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t501_sms_tel_histories`
--
ALTER TABLE `t501_sms_tel_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `t600_sms_template_histories`
--
ALTER TABLE `t600_sms_template_histories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `t800_sms_send_results`
--
ALTER TABLE `t800_sms_send_results`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID', AUTO_INCREMENT=7;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
