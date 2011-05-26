Jsus::Middleware.settings = {
  :cache         => true,
  :cache_path    => "#{Rails.root}/public/javascripts/jsus/require",
  :packages_dir  => "#{Rails.root}/public/javascripts/Source",
  :cache_pool    => false,
  :includes_root => "#{Rails.root}/public/javascripts/Source"
}

Rails.configuration.middleware.use Jsus::Middleware