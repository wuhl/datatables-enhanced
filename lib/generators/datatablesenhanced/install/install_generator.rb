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
        gsub_file "Gemfile", "gem \'turbolinks\'", "# gem \'turbolinks\'"
        gsub_file "app/assets/javascripts/application.js", "//= require turbolinks\n", ""
        gsub_file "app/views/layouts/application.html.erb", ", \"data-turbolinks-track\" => true", ""
      end
      
      def install_langauge_file
        if File.exist? "config/locales/#{language_type}"
          copy_file "de.datatable.yml", "config/locales/#{language_type}/de.datatable.yml"
        else
          copy_file "de.datatable.yml", "config/locales/de.datatable.yml"
        end
      end

      def install_helper_function
        if File.exist? "app/helpers/helper.rb"
          insert_into_file "app/helpers/helper.rb", :before => "  module_function" do
            "  def set_datatable_params\n" +
            "    gon.oLanguage = {\n" +
            "      :sProcessing   => t('datatable.sProcessing'),\n" +
            "      :sLengthMenu   => t('datatable.sLengthMenu'),\n" +
            "      :sZeroRecords  => t('datatable.sZeroRecords'),\n" +
            "      :sInfo         => t('datatable.sInfo'),\n" +
            "      :sInfoEmpty    => t('datatable.sInfoEmpty'),\n" +
            "      :sInfoFiltered => t('datatable.sInfoFiltered'),\n" +
            "      :sInfoPostFix  => t('datatable.sInfoPostFix'),\n" +
            "      :sSearch       => t('datatable.sSearch'),\n" +
            "      :sUrl          => t('datatable.sUrl'),\n" +
            "      :oPaginate => {\n" +
            "        :sFirst    => t('datatable.sFirst'),\n" +
            "        :sPrevious => t('datatable.sPrevious'),\n" +
            "        :sNext     => t('datatable.sNext'),\n" +
            "        :sLast     => t('datatable.sLast'),\n" +
            "      }\n" +
            "    }\n" +
            "  end\n\n"
          end
        end
      end

      def install_gon
        if File.exist? "app/views/layouts/application.html.erb"
          insert_into_file "app/views/layouts/application.html.erb", :after => "</title>\n" do
            "  <%= include_gon %>\n"
          end
        end
        if File.exist? "lib/templates/rails/scaffold_controller/controller.rb"
          insert_into_file "lib/templates/rails/scaffold_controller/controller.rb", :after => "def index\n" do
            "    set_datatable_params\n"
          end
        end
      end
      
    end
  end
end