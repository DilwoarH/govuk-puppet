class hosts::ertp_preview {
  host { 'puppet':
    ip => '10.33.163.224',
  }
  host { 'ertp-api':
    ip => '10.33.180.32'
  }
  host { 'ertp-admin-api':
    ip => '10.33.180.32'
  }
  host { 'ertp-mongo-1':
    ip => '10.238.233.55'
  }
  host { 'ertp-mongo-2':
    ip => '10.234.66.40'
  }
  host { 'ertp-mongo-3':
    ip => '10.32.40.93'
  }
  host { 'places-api':
    ip => '10.229.118.175'
  }
  host { 'monitoring.cluster':
    ip => '10.51.62.202'
  }
  host { 'graylog.cluster':
    ip => '10.32.31.104'
  }
}
