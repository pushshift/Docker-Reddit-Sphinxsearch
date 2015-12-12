-- phpMyAdmin SQL Dump
-- version 4.2.3deb1.trusty~ppa.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Dec 11, 2015 at 12:19 PM
-- Server version: 5.5.44-MariaDB-1~trusty
-- PHP Version: 5.5.9-1ubuntu4.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `reddit`
--
CREATE DATABASE IF NOT EXISTS `reddit` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `reddit`;

-- --------------------------------------------------------

--
-- Table structure for table `com-index`
--

CREATE TABLE IF NOT EXISTS `com-index` (
  `comment_id` bigint(20) unsigned NOT NULL,
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `submission_id` int(10) unsigned NOT NULL,
  `score` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Reddit comment index table';

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

CREATE TABLE IF NOT EXISTS `comment` (
  `comment_id` bigint(20) unsigned NOT NULL COMMENT 'Comment id',
  `body` mediumtext CHARACTER SET utf8mb4 NOT NULL COMMENT 'Comment body'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reddit comment bodies ';

-- --------------------------------------------------------

--
-- Table structure for table `subreddit`
--

CREATE TABLE IF NOT EXISTS `subreddit` (
  `subreddit_id` int(10) unsigned NOT NULL COMMENT 'Subreddit id',
  `name` varchar(32) NOT NULL COMMENT 'Subreddit name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Reddit subreddits';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `com-index`
--
ALTER TABLE `com-index`
 ADD PRIMARY KEY (`comment_id`), ADD KEY `created_utc` (`created_utc`,`subreddit_id`,`submission_id`), ADD KEY `score` (`score`);

--
-- Indexes for table `comment`
--
ALTER TABLE `comment`
 ADD PRIMARY KEY (`comment_id`);

--
-- Indexes for table `subreddit`
--
ALTER TABLE `subreddit`
 ADD PRIMARY KEY (`subreddit_id`), ADD KEY `subreddit-name` (`name`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

