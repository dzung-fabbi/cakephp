<?php
class CsvComponent extends Component {

	var $delimiter = ',';
	var $enclosure = '"';
	var $filename = 'Export.csv';
	var $zipFileName = 'Export.zip';
	var $line = array();
	var $buffer;
    var $zip;
	
	function CsvComponent() {
		$this->clear();
	}

	function clear() {
		$this->line = array();
		$this->buffer = fopen('php://temp/maxmemory:'. (5*1024*1024), 'r+');
	}

	function addField($value) {
		$this->line[] = $value;
	}

	function endRow() {
		$this->addRow($this->line);
		$this->line = array();
	}

	function addRow($row, $mark = ',', $have_quotes=true) {
		$this->_fputcsv($this->buffer, $row, $have_quotes, $mark);
	}

	function addFile($name, $data) {
		$this->zip->addFromString($name, $data);
	}

	function renderHeaders() {
		header("Content-type:application/vnd.ms-excel");
		header("Content-disposition:attachment;filename=".$this->filename);
	}

    function renderZipHeaders() {
        //preg_match('/MSIE (.*?);/', $_SERVER['HTTP_USER_AGENT'], $matches);
        //if (count($matches) < 2) {
        //    preg_match('/Trident\/\d{1,2}.\d{1,2}; rv:([0-9]*)/', $_SERVER['HTTP_USER_AGENT'], $matches);
        //}

        //if (count($matches) > 1) {
            //browser using is IE
            //$zipFileName = urlencode($this->zipFileName);
        //} else {
            //browser using is not IE
        $zipFileName = $this->zipFileName;
        //}
        header("Content-type:application/zip");
        //Chrome72‘Î‰ž
        //header("Content-disposition:attachment; filename='".$zipFileName."'");
        header("Content-disposition:attachment; filename=".$zipFileName);
    }

	function setFilename($filename) {
		$this->filename = $filename;
		if (strtolower(substr($this->filename, -4)) != '.csv') {
			$this->filename .= '.csv';
		}
	}

    function setZipFilename($filename) {
        $this->zipFileName = $filename;
        if (strtolower(substr($this->zipFileName, -4)) != '.zip') {
            $this->zipFileName .= '.zip';
        }
    }

    function createZip($outputHeaders = true) {
        if ($outputHeaders) {
            if (is_string($outputHeaders)) {
                $this->setZipFilename($outputHeaders);
            }
        }
        $this->zip = new ZipArchive();
        $result = $this->zip->open($this->zipFileName, ZIPARCHIVE::CREATE | ZIPARCHIVE::OVERWRITE);
        if ($result !== true) {
            return false;
        }
        return true;
    }    

	function addToZip($name = null, $to_encoding = null, $from_encoding = "auto") {
		rewind($this->buffer);
		$output = stream_get_contents($this->buffer);
		if ($to_encoding) {
			$output = mb_convert_encoding($output, $to_encoding, $from_encoding);
		}
		$this->zip->addFromString($name , $output);
	}

    function renderZip($to_encoding = null, $from_encoding = "auto") {
        $this->zip->close();
        $output = file_get_contents($this->zipFileName);
        $this->renderZipHeaders();
        unlink($this->zipFileName);
        return $output;
    }

	function render($outputHeaders = true, $to_encoding = null, $from_encoding = "auto") {
		
		if ($outputHeaders) {
			if (is_string($outputHeaders)) {
				$this->setFilename($outputHeaders);
			}
			$this->renderHeaders();
		}
		
		rewind($this->buffer);
		$output = stream_get_contents($this->buffer);

		if ($to_encoding) {
			$output = mb_convert_encoding($output, $to_encoding, $from_encoding);
		}

		return $output;
	}
	
	function _fputcsv($fp, $data, $have_quotes=true, $mark = ',') {
		$csv = ''; 
		$i=0;
		foreach ($data as $col) { 
			if ($i == 0) {
				$csv .= $have_quotes ? ('"'.$col.'"') : $col;
			} else {
				$csv .= $mark;
				$csv .= $have_quotes ? ('"'.$col.'"') : $col;
			}
			$i = $i + 1;
		}
		fwrite($fp, $csv);
		fwrite($fp, "\r\n");
	}
}

