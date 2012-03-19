require 'astrails/clicktale'
Astrails::Clicktale.init

Astrails::Clicktale::CONFIG.merge! \
  case Rails.env
  when 'development'
    {
    'project_id' => 0,
    'param'      => 'CLICKTALE_PARAM',
    'ratio'      => 1,
    'enabled'    => false
    }
  when 'staging'
    {
    'project_id' => 7250,
    'param'      => 'www09',
    'ratio'      => 1,
    'enabled'    => true
    }
  when 'production'
    {
    'project_id' => 7249,
    'param'      => 'www09',
    'ratio'      => 1,
    'enabled'    => true
    }
  end
