namespace :scaffolder do
  
  # color goodness from http://snippets.dzone.com/posts/show/6693
  $terminal = %x(echo $TERM).strip!

  def puts_in_color(text, options = {})
    if $terminal == 'xterm-color'
      case options[:color]
      when :red
        puts "\033[31m#{text}\033[0m"
      when :green
        puts "\033[32m#{text}\033[0m"
      else
        puts text
      end
    else
      puts text
    end
  end

  def green(text)
    puts_in_color text, :color => :green
  end

  def red(text)
    puts_in_color text, :color => :red
  end

  desc "Set up config dir"
  task :setup => :environment do
    config_dir = File.expand_path('config/scaffolder', Rails.root)
    mkdir config_dir unless File.exists? config_dir
    source_file = File.expand_path('../../../config/scaffolder/model.yml', __FILE__)
    dest_file = File.expand_path('model.yml', config_dir)
    copy_file source_file, dest_file
  end
  
  desc "Generate scaffolds from model input"
  task :generate, :model, :command, :needs => :environment do |t, args|
    model_file = args[:model].blank? ? 'model' : args[:model]
    scaffold_command = args[:command].blank? ? 'scaffold' : args[:command]

    models = YAML.load_file(File.expand_path('config/scaffolder/%s.yml' % model_file, Rails.root))
    models.each do |modelname, fields|
      # assemble the scaffold command
      fieldstring = ''
      if !fields.nil?
        if fields[0]['field'].nil?
          # supporting shorter syntax
          fields.each do |field|
            value = field.collect { |field, type| " %s:%s" % [field, type] }
            fieldstring << value.to_s
          end
        else
          # supporting verbose syntax
          fieldstring = fields.collect { |field| " %s:%s" % [field['field'], field['type']] }
        end
      end
      command = "rails generate %s %s%s\n" % [scaffold_command, modelname, fieldstring]
      puts "Running:"
      green command
      # send the command to the os
      # system(command)
    end
  end

end