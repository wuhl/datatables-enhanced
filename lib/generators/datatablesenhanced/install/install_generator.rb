#  install_generator.rb

module Datatablesenhanced
  module Generators
    class InstallGenerator < ::Rails::Generators::Base

      source_root File.expand_path("../templates", __FILE__)
      desc "This generator installs Datatables Enhanced"
      argument :language_type, :type => :string, :default => 'de', :banner => '*de or other language'
			class_option :template_engine, desc: 'Template engine to be invoked (erb, haml or slim).'

      # def run_other_generators
      #   generate "simple_form:install --bootstrap"
      # end

      def add_javascripts
        insert_into_file "app/assets/javascripts/application.js", :after => "//= require jquery_ujs\n" do 
          "//= require dataTables/jquery.dataTables\n"
        end
      end

      def add_stylesheets
        insert_into_file "app/assets/stylesheets/application.css", :after => " *= require_self\n" do 
          " *= require jquery.ui.core\n" +
          " *= require jquery.ui.theme\n" +
          " *= require dataTables/src/demo_table_jui\n"
        end
      end

      def change_table_in_index
        engine = options[:template_engine]
        if File.exist? "lib/templates/#{engine}/scaffold/index.html.#{engine}"
          insert_into_file "lib/templates/#{engine}/scaffold/index.html.#{engine}", :after => "<table" do 
            " class=\"datatable display\""
          end
        end 
      end

      def copy_datatable_js
        copy_file "datatable.js.coffee", "app/assets/javascripts/datatable.js.coffee"
      end

      def uninstall_turbolink
        insert_into_file "Gemfile", :before => "gem \'turbolinks\'" do
          "# "
        end
        gsub_file "app/assets/javascripts/application.js", "//= require turbolinks\n", ""
        gsub_file "app/views/layouts/application.html.erb", ", \"data-turbolinks-track\" => true", ""
      end
    end
  end
end