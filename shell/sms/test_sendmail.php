<?php
require('SendSmsScheduleMail.php');

sendCreateSmsScheduleMail('companyName', 'scheduleId', 'scheduleName', 'listName', 'listTotal', 'sendTime', 'endTime', 'serviceId');
// sendErrorSmsScheduleMail('companyName', 'scheduleId', 'scheduleName', 'listName', 'listTotal', 'sendTime', 'endTime', 'serviceId', 'attach/error.log');
