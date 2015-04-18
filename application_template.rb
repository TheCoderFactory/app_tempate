# An application template for your convenience

gsub_file 'Gemfile', /gem 'sqlite3'\n/
gem 'devise'
gem 'simple_form'
gem 'country_select'
gem 'cancancan'
gem 'rolify'
gem 'friendly_id'
gem 'invisible_captcha'
gem 'carrierwave'
gem 'cloudinary'
gem 'sitemap_generator'
gem 'whenever', :require => false
gem 'sucker_punch', '~> 1.0'
gem 'newrelic_rpm'
gem 'pg'
gem_group :development do
  gem "better_errors"
  gem 'quiet_assets'
end
gem_group :production do
  gem 'rails_12factor'
  gem "passenger"
end
run "bundle install --without production"

# replace README
remove_file "README.rdoc"

create_file 'README.md' do <<-TEXT
# Ya Bits
 
This is a simple rails app with bootstrap!
TEXT
end

# create database.yml

remove_file "config/database.yml"
create_file 'config/database.yml' do <<-TEXT
development:
  adapter: postgresql
  encoding: unicode
  database: myapp_development
  pool: 5
  username: 
  password: 

test:
  adapter: postgresql
  encoding: unicode
  database: myapp_test
  pool: 5
  username: 
  password: 
TEXT
end


# add bootstrap
remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.erb" do <<-TEXT
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
  <title><%= content_for?(:title) ? yield(:title) : "Page Title" %></title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
  <%= csrf_meta_tags %>
  <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">
</head>
<body style="padding-top:100px;">
<%= render 'layouts/navbar' %>
<%= render 'layouts/flash_messages' %>
<div class="container">
  <%= yield %>
</div>
</body>
</html>
TEXT
end

bundle_command "exec rails generate simple_form:install --bootstrap"
bundle_command "exec rails generate devise:install"
bundle_command "exec rails generate devise User"
bundle_command "exec rails generate friendly_id"
bundle_command "exec rails generate controller pages home admin contact"
generate 'cancan:ability'
generate 'rolify Role User'
rake "db:drop db:create db:migrate"


gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
  <<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
RUBY
    end
gsub_file 'config/environments/production.rb', /config.active_support.deprecation = :notify/ do
  <<-RUBY
config.active_support.deprecation = :notify
  config.action_mailer.default_url_options = { :host => 'example.com' }
  # ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"
RUBY
    end
mandrill_configuration_text = <<-TEXT
\n
  config.action_mailer.smtp_settings = {
    :address   => "smtp.mandrillapp.com",
    :port      => 25,
    :user_name => ENV["MANDRILL_USERNAME"],
    :password  => ENV["MANDRILL_API_KEY"]
  }
TEXT
inject_into_file 'config/environments/development.rb', mandrill_configuration_text, :after => 'config.action_mailer.default :charset => "utf-8"'
inject_into_file 'config/environments/production.rb', mandrill_configuration_text, :after => 'config.action_mailer.default :charset => "utf-8"'
# navbar

create_file "app/views/layouts/_navbar.html.erb" do <<-TEXT
<nav class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="/">Brand</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="navbar-collapse">
      
      <ul class="nav navbar-nav navbar-right">
      	<li><%= link_to "Admin", admin_path %></li>
      	<li><%= link_to "Contact", contact_path %></li>
        <% unless user_signed_in? %>
          <li><%= link_to "Sign in", new_user_session_path %></li>
        <% else %>
          <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Dropdown <span class="caret"></span></a>
            <ul class="dropdown-menu" role="menu">
              <li><a href="#">Link</a></li>
              <li class="divider"></li>
              <li><%= link_to "Sign out", destroy_user_session_path, method: :delete %></li>
            </ul>
          </li>
        <% end %>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>
TEXT
end

create_file "app/views/layouts/_flash_messages.html.erb" do <<-TEXT
<div class="container">
  <% flash.each do |key, value| %>
    <div class="alert alert-<%= key %>"><%= value %></div>
  <% end %>
</div>
TEXT
end

create_file "lib/templates/erb/scaffold/index.html.erb" do <<-TEXT
<h1>Listing <%= plural_table_name %></h1>

<table class="table">
    <tr>
  <% attributes.each do |attribute| -%>
    <th><%%= '<%= attribute.name.capitalized %>' %></th>
  <% end -%>
      <th colspan="3"></th>
    </tr>

  <%%= content_tag_for(:tr, @<%= plural_table_name %>) do |<%= singular_table_name %>| %>
  <% attributes.each do |attribute| -%>
  <td><%%= <%= singular_table_name %>.<%= attribute.name %> %></td>
  <% end -%>
    <td><%%= link_to 'Show', <%= singular_table_name %> %></td>
    <td><%%= link_to 'Edit', edit_<%= singular_table_name %>_path(<%= singular_table_name %>), class: 'btn btn-edit' %></td>
    <td><%%= link_to 'Delete', <%= singular_table_name %>, method: :delete, data: { confirm: 'Are you sure?' }, class: 'btn btn-destroy' %></td>
  <%% end %>
</table>


<div class="form-actions">
  <%%= link_to 'New <%= human_name %>', new_<%= singular_table_name %>_path, class: 'btn btn-success' %>
</div>
TEXT
end
# insert_into_file("config/application.rb", "\nconfig.generators do |g|\ng.stylesheets false\ng.javascripts false\nend", :after => /class Application < Rails::Application/)

# Create a home, admin and contact page
 
# generate(:controller, "pages home admin contact")
route "root 'pages#home'"
route "get 'contact', to: 'pages#contact'"
route "get 'admin', to: 'pages#admin'"

config = <<-RUBY
config.generators do |generate|
  generate.helper false
  generate.javascript_engine false
  generate.request_specs false
  generate.routing_specs false
  generate.stylesheets false
  generate.test_framework :rspec
  generate.view_specs false
end
RUBY

inject_into_class 'config/application.rb', 'Application', config

run "git init"
run "git add -A && git commit -m 'Initial Commit'"